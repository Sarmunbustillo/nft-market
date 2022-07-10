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

    event NftItemCreated (
      uint tokenId,
      uint price,
      address creator,
      bool isListed
    );

    constructor() ERC721("PlayersNFT", "PNFT") {}

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

  function getNftItem(uint tokenId) public view returns(NftItem memory) {
    return _idToNftItem[tokenId];
  }

  function listedItemsCount() public view returns (uint) {
    return _listedItems.current();
  }

  function tokenURIExists(string memory tokenURI) public view returns (bool) {
    return _usedTokenURIs[tokenURI] == true;
  }
}
