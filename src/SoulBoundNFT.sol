// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract SoulBoundNFT is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // address public immutable owner;
    mapping(address => bool) private isApprovedMinter;

    error NotApproved();
    error AlreadyApproved();
    error AlreadyMinted();

    event TokenMinted(address indexed _minter, uint256 _tokenId);
    event TokenBurned(address indexed _burnedFrom, uint256 _tokenId);

    constructor() ERC721("SoulBound", "SNFT") {
        // owner = msg.sender;
    }

    function safeMint() public {
        if(!isApprovedMinter[msg.sender]) revert NotApproved();
        if(balanceOf(msg.sender) == 1) revert AlreadyMinted();

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    function approveMinters(address _minter) external onlyOwner {
        if(isApprovedMinter[_minter]) revert AlreadyApproved();

        isApprovedMinter[_minter] = true; 
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override public {
        burn(_tokenId);
        emit TokenBurned(_from, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override public {
        burn(_tokenId);
        emit TokenBurned(_from, _tokenId);
    }
}