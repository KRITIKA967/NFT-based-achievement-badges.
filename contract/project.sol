// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTAchievementBadges {
    struct NFT {
        uint256 id;
        string name;
        string metadataURI;
        address owner;
        bool forSale;
        uint256 price;
    }

    uint256 public nextNFTId;
    mapping(uint256 => NFT) public nfts;
    mapping(address => uint256[]) public ownerNFTs;

    event NFTCreated(uint256 id, string name, string metadataURI, address owner);
    event NFTTransferred(uint256 id, address from, address to);
    event NFTListedForSale(uint256 id, uint256 price);
    event NFTSold(uint256 id, address buyer, uint256 price);

    function createNFT(string memory _name, string memory _metadataURI) public {
        NFT memory newNFT = NFT({
            id: nextNFTId,
            name: _name,
            metadataURI: _metadataURI,
            owner: msg.sender,
            forSale: false,
            price: 0
        });

        nfts[nextNFTId] = newNFT;
        ownerNFTs[msg.sender].push(nextNFTId);
        emit NFTCreated(nextNFTId, _name, _metadataURI, msg.sender);
        nextNFTId++;
    }

    function listNFTForSale(uint256 _id, uint256 _price) public {
        require(nfts[_id].owner == msg.sender, "Only owner can list NFT for sale");
        require(_price > 0, "Price must be greater than zero");

        nfts[_id].forSale = true;
        nfts[_id].price = _price;
        emit NFTListedForSale(_id, _price);
    }

    function buyNFT(uint256 _id) public payable {
        require(nfts[_id].forSale, "NFT is not for sale");
        require(msg.value >= nfts[_id].price, "Insufficient funds");

        address previousOwner = nfts[_id].owner;
        nfts[_id].owner = msg.sender;
        nfts[_id].forSale = false;
        nfts[_id].price = 0;

        payable(previousOwner).transfer(msg.value);

        emit NFTSold(_id, msg.sender, msg.value);
        emit NFTTransferred(_id, previousOwner, msg.sender);
    }

    function getNFT(uint256 _id) public view returns (NFT memory) {
        return nfts[_id];
    }

    function getUserNFTs(address _user) public view returns (uint256[] memory) {
        return ownerNFTs[_user];
    }
}


