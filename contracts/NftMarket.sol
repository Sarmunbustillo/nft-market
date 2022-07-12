// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftMarket is ERC721URIStorage, Ownable {
  using Counters for Counters.Counter;

  struct NftItem {
    uint tokenId;
    uint price;
    address creator;
    bool isListed;
  }

  uint public listingPrice = 0.025 ether;

  Counters.Counter private _listedItems;
  Counters.Counter private _tokenIds;


  mapping(string => bool) private _usedTokenURIs;
  mapping(uint => NftItem) private _idToNftItem;

  // mapping of address user to mapping of current index to tokenId
  mapping(address => mapping(uint => uint)) private _ownedTokens;
  mapping(uint =>uint) private _idToOwnedIndex;

  // all tokens in the array
  uint256[] private _allNfts;
  mapping(uint => uint) private _idToNftIndex;

  event NftItemCreated (
    uint tokenId,
    uint price,
    address creator,
    bool isListed
  );

  constructor() ERC721("PlayersNFT", "PNFT") {}

  function setListingPrice(uint newPrice) external onlyOwner {
    require(newPrice  > 0, "Price must be at least 1 wei");
    listingPrice = newPrice;
  }

  function getNftItem(uint tokenId) public view returns(NftItem memory) {
    return _idToNftItem[tokenId];
  }

  function listedItemsCount() public view returns (uint) {
    return _listedItems.current();
  }

  function tokenURIExists(string memory tokenURI) public view returns (bool) {
    return _usedTokenURIs[tokenURI] == true;
  }

  function totalSupply() public view returns (uint) {
    return _allNfts.length;
  }

  function tokenByIndex(uint index) public view returns (uint) {
    // check that index exist on all nfts
    require(index <  totalSupply(), "Index out of bounds");
    return _allNfts[index];
  }

  function tokenOfOwnerByIndex(address owner, uint index) public view returns (uint) {
    // check that index exist on all nfts
    require(index <  ERC721.balanceOf(owner), "Index out of bounds");
    return _ownedTokens[owner][index];
  }

  function getAllNftsOnSale() public view returns (NftItem[] memory) {
    uint allItemsCounts = totalSupply();
    uint currentIndex = 0;
    // create an array nft items with the length of the already listed items
    NftItem[] memory items = new NftItem[](_listedItems.current());

    // for all items
    for (uint i = 0; i < allItemsCounts; i++) {
      uint tokenId = tokenByIndex(i);
      // get item by id
      NftItem storage item = _idToNftItem[tokenId];

      // if the item is listed
      if (item.isListed == true) {
        items[currentIndex] = item;
        currentIndex += 1;
      }
    }

    return items;
  }

  function getOwnedNfts() public view returns (NftItem[] memory) {
    uint ownedItemsCount = ERC721.balanceOf(msg.sender);
    NftItem[] memory items = new NftItem[](ownedItemsCount);

    for (uint i = 0; i < ownedItemsCount; i++) {
      uint tokenId = tokenOfOwnerByIndex(msg.sender, i);
      NftItem storage item = _idToNftItem[tokenId];
      items[i] = item;
    }

    return items;
  }

  // creation of token 
  function mintToken(string memory tokenURI, uint price) public payable returns (uint) {
    require(!tokenURIExists(tokenURI), "TokenURI already exists");
    require(msg.value == listingPrice, "Price must be equal to listing price"
    );

    _tokenIds.increment();
    _listedItems.increment();

    uint newTokenId = _tokenIds.current();

    _safeMint(msg.sender, newTokenId);
    _setTokenURI(newTokenId, tokenURI);
    _createNftItem(newTokenId, price);
    _usedTokenURIs[tokenURI] = true;

    return newTokenId;
  }

  function buyNft(
    uint tokenId
  ) public payable {
    uint price = _idToNftItem[tokenId].price;
    address owner = ERC721.ownerOf(tokenId);

    require(msg.sender != owner, "You already own this NFT");
    require(msg.value == price, "Please submit the asking price");

    // remove item from lising
    _idToNftItem[tokenId].isListed = false;
    _listedItems.decrement();

    // transfer the ownership
    _transfer(owner, msg.sender, tokenId);
    payable(owner).transfer(msg.value);
  }

  // list an nft to sale
  function placeNftOnSale(uint tokenId, uint newPrice) public payable {
    require(ERC721.ownerOf(tokenId) == msg.sender, "You are not the owner of this nft");
    require(_idToNftItem[tokenId].isListed == false, "Item is already on sale");
    require(msg.value == listingPrice, "Price must be equal to listing price");

    _idToNftItem[tokenId].isListed = true;
    _idToNftItem[tokenId].price = newPrice;
    _listedItems.increment();

  }

  // automatically list the item after minting it
  function _createNftItem(uint tokenId, uint price) private {
    require(price > 0, "price must be at least 1 wei");
    

    _idToNftItem[tokenId] = NftItem(
      tokenId,
      price,
      msg.sender,
      true
    );

    emit NftItemCreated(
      tokenId, 
      price, 
      msg.sender,
      true
    );
  }

  function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual override {
    super._beforeTokenTransfer(from, to, tokenId);

    // minting/creating token 
    if(from == address(0)) {
      _addTokenToAllTokensEnumeration(tokenId);
    }  // remove ownership if owner/seller is not the same user/buyer it
    else if (from != to) {
      _removeTokenFromOwnerEnumeration(from, tokenId);
    } 

    if(to == address(0)) {
      _removeTokenFromAllTokensEnumeration(tokenId);
    } // add token to buyer if owner/seller is not the same user/buyer it
    else if (to != from) {
      _addTokenToOwnerEnumeration(to, tokenId);
    }

  }

  function _addTokenToAllTokensEnumeration(uint tokenId) private {
    // ex: [tokenID => _allNfts.length] maps id to array's length
    // first iteration: --> [1 => 0] = [1]
    // second iteration  [1 => 0, 2 => 1 ] = [1, 2].
    _idToNftIndex[tokenId] = _allNfts.length;
    _allNfts.push(tokenId);
  }

  function _addTokenToOwnerEnumeration(address to,  uint tokenId) private {
    // gets tokens owned by user
    uint length = ERC721.balanceOf(to); // if user has 0 tokens then length = 0

    _ownedTokens[to][length] = tokenId; // user addresss => 0 => 1
    _idToOwnedIndex[tokenId] = length;  // 1 => 0 
  }

  // removes and updates mapping of tokens to owner 
  function _removeTokenFromOwnerEnumeration(address from, uint tokenId) private {
    // ex: _ownedTokens: {token1: 0, token2: 1, token3: 2},  _idToOwnedIndex: {0:token1, 1: token2, 2: token3}
    // if tokenId = token2 then 
    // result: _ownedTokens: {token1: 0, token3: 1},  _idToOwnedIndex: {0: token1, 1: token3}
    uint lastTokenIndex = ERC721.balanceOf(from) - 1; // get last index of tokens owned
    uint tokenIndex = _idToOwnedIndex[tokenId]; // get the index of the desired token in trade

    if(tokenIndex != lastTokenIndex) { // if the token in trade does not happen to be the last token/index in the array
      uint lastTokenId = _ownedTokens[from][lastTokenIndex]; // get the id from the last token owned

      // remapping to update values and positions
      _ownedTokens[from][tokenIndex] = lastTokenId; // replace the index of the traded token to the last token id
      _idToOwnedIndex[lastTokenId] = tokenIndex; // replace the id of last token to the traded token
    }

    delete _idToOwnedIndex[tokenId]; // delete the index mapping to the token in trade from the previous owner
    delete _ownedTokens[from][lastTokenIndex]; // delete the token in trade from the previous owner
  }

  //similar to function above
  function _removeTokenFromAllTokensEnumeration(uint tokenId) private {
    uint lastTokenIndex = _allNfts.length - 1; // get the index of the last token
    uint tokenIndex = _idToNftIndex[tokenId]; // get the index of the traded token 
    uint lastTokenId = _allNfts[lastTokenIndex]; // get the id of the las token

    _allNfts[tokenIndex] = lastTokenId; //replace the id of the traded token to the last token id
    _idToNftIndex[lastTokenId] = tokenIndex; // replace the index of the last token to the traded token

    delete _idToNftIndex[tokenId]; // delete index of traded token
    _allNfts.pop(); // delete last token
  }
}
