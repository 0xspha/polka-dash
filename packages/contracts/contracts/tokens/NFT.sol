// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import {ERC721, IERC721Errors} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

/// @title NFT Contract
contract NFT is ERC721, Ownable {
    /// ERRORS
    error InvalidTokenQuantity();
    error TokensNotMinted();
    error NotAuthorised();
    /// State variables
    uint256[] public tokens;
    uint256 public totalSupply;
    address public immutable GAME_ADDRESS;

    constructor(
        string memory name_,
        string memory symbol_,
        address gameAddress
    ) ERC721(name_, symbol_) Ownable(msg.sender) {
        GAME_ADDRESS = gameAddress;
    }

    /// @notice Public function to mint a new token
    /// @dev Increments the total supply, mints the new token to the specified address, and returns the new token ID
    /// @param to The address to which the new token will be minted
    /// @return The new token ID that was minted
    function mint(address to) public returns (uint256) {
        require(
            msg.sender == owner() || msg.sender == GAME_ADDRESS,
            NotAuthorised()
        );
        ++totalSupply; 
        _safeMint(to, totalSupply);
        tokens.push(totalSupply);
        return totalSupply;
    }
}
