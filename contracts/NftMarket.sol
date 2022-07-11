// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/counters.sol";

contract NftMarket is ERC721URIStorage {
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

    // minting token
    if(from == address(0)) {
      _addTokenToAllTokensEnumeration(tokenId);
    }

    // if owner/seller is not the same user/buyer it
    if (to != from) {
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
}
