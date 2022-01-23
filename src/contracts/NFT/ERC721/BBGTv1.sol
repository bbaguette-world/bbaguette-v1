// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../../openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "../../openzeppelin/contracts/utils/Context.sol";
import "../../openzeppelin/contracts/utils/Counters.sol";
import "../../openzeppelin/contracts/access/Ownable.sol";

contract BBGTv1 is ERC721, ERC721Enumerable, Context, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    address public minterContract;
    string private _baseTokenURI;

    modifier onlyMinter() {
        require(_msgSender() == minterContract);
        _;
    }

    constructor(string memory baseTokenURI) ERC721("BBGT_NFT", "BBGT") {
        _baseTokenURI = baseTokenURI;
    }

    function mint(address to) external virtual onlyMinter {
        require(totalSupply() < 100, "OVER MINTING");
        _mint(to, _tokenIdCounter.current());
        _tokenIdCounter.increment();
    }

    function setMinterContract(address saleContract) public onlyOwner {
        minterContract = saleContract;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _baseTokenURI = baseURI;
    }

    function getBaseURI() public view returns (string memory) {
        return _baseURI();
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
