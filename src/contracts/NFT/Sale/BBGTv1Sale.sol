// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../../openzeppelin/contracts/utils/Context.sol";
import "../../openzeppelin/contracts/utils/math/SafeMath.sol";
import "../../openzeppelin/contracts/token/ERC721/extenstions/IERC721Enumerable.sol";
import "../../openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BBGTSale is Context {
	using SafeMath for uint256;

	IERC721Enumerable public BBGTNFTContract;
	IERC20 public BBGTTokenContract;

	uint16 MAX_CLONES_SUPPLY = 100;
	uint256 PRICE_PER_POP = 9999 ether;
  uint256 PRICE_PER_BBGT = 1999 ether;

	uint256 public constant maxPurchase = 20;
	bool public isSale = false;

	address public D1;
	address public D2;
	address public A1;

	modifier mintRole(uint256 numberOfTokens) {
		require(isSale, "The sale has not started.");
		require(BBGTNFTContract.totalSupply() < MAX_CLONES_SUPPLY, "Sale has already ended.");
		require(numberOfTokens <= maxPurchase, "Can only mint 20 Clones at a time");
		require(BBGTNFTContract.totalSupply().add(numberOfTokens) <= MAX_CLONES_SUPPLY, "Purchase would exceed max supply of Clones");
		_;
	}

	modifier mintRoleByPOP(uint256 numberOfTokens) {
		require(PRICE_PER_POP.mul(numberOfTokens) <= msg.value, "POP value sent is not correct");
		_;
	}

	modifier mintRoleByBBGT(uint256 numberOfTokens) {
		uint256 balance = BBGTTokenContract.balanceOf(_msgSender());
		require(PRICE_PER_BBGT.mul(numberOfTokens) <= balance, "Not enough balance");
		_;
	}

	//D1: Developer, D2: Developer, A1: Artist

	modifier onlyCreator() {
		require(D1 == _msgSender() || D2 == _msgSender() || A1 == _msgSender(), "onlyCreator: caller is not the creator");
		_;
	}

	modifier onlyD1() {
		require(D1 == _msgSender(), "only D1: caller is not the D1");
		_;
	}

	modifier onlyD2() {
		require(D2 == _msgSender(), "only D2: caller is not the D2");
		_;
	}

	modifier onlyA1() {
		require(A1 == _msgSender(), "only A1: caller is not the A1");
		_;
	}

	constructor(address nft, address token, address _D1, address _D2, address _A1) {
		BBGTNFTContract = IERC721(nft);
		BBGTTokenContract = IERC20(token);
		D1 = _D1;
		D2 = _D2;
		A1 = _A1;
	}

	function mintByPOP(uint256 numberOfTokens) public payable mintRole(numberOfTokens), mintRoleByPOP(numberOfTokens) {
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (BBGTNFTContract.totalSupply() < MAX_CLONES_SUPPLY) {
				BBGTNFTContract.mint(_msgSender());
			}
		}
	}
	function mintByBBGT(uint256 numberOfTokens) public payable mintRole(numberOfTokens), mintRoleByBBGT(numberOfTokens) {
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (BBGTNFTContract.totalSupply() < MAX_CLONES_SUPPLY) {
				BBGTTokenContract.transferFrom(_msgSender(), address(this), numberOfTokens.mul(PRICE_PER_BBGT));
				BBGTNFTContract.mint(_msgSender());

			}
		}
	}

	function preMintClone(uint256 numberOfTokens, address receiver) public onlyCreator {
		require(!isSale, "The sale has started. Can't call preMintClone");
		for (uint256 i = 0; i < numberOfTokens; i++) {
			if (BBGTNFTContract.totalSupply() < MAX_CLONES_SUPPLY) {
				BBGTNFTContract.mint(receiver);
			}
		}
	}


	function withdraw() public payable onlyCreator {
		uint256 contractPOPBalance = address(this).balance;
		uint256 percentagePOP = contractPOPBalance / 100;

		uint256 contractBBGTBalance = BBGTTokenContract.balanceOf(address(this));
		uint256 percentageBBGT = contractBBGTBalance / 100;		

		require(payable(D1).send(percentagePOP * 35));
		require(payable(D2).send(percentagePOP * 35));
		require(payable(A1).send(percentagePOP * 30));
		require(BBGTTokenContract.transfer(address(D1), percentageBBGT * 35));
		require(BBGTTokenContract.transfer(address(D2), percentageBBGT * 35));
		require(BBGTTokenContract.transfer(address(A1), percentageBBGT * 30));
	}

	function setD1(address changeAddress) public onlyD1 {
		D1 = changeAddress;
	}

	function setD2(address changeAddress) public onlyD2 {
		D2 = changeAddress;
	}

	function setA1(address changeAddress) public onlyA1 {
		A1 = changeAddress;
	}

	function setSale() public onlyCreator {
		isSale = !isSale;
	}
}