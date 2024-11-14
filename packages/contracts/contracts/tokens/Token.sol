// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Token Contract
contract Token is ERC20, Ownable {
    /// errors
    error NotAuthorised();
    address public immutable GAME_ADDRESS;

    constructor(
        string memory name_,
        string memory symbol_,
        address gameAddress
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        _mint(msg.sender, 10000000000000000 ether);
        GAME_ADDRESS = gameAddress;
       // _mint(gameAddress, 1_000_000 * 10 ** 18);
    }

    /// @notice Mints new tokens to a specified address
    /// @dev Only callable by addresses with the OWNER_ROLE or the contract owner
    /// @param to The address to mint tokens to
    /// @param amount The amount of tokens to mint
    function mint(address to, uint256 amount) public {
        require(
            msg.sender == GAME_ADDRESS || msg.sender == owner(),
            "Caller does not have permission to mint"
        );
        _mint(to, amount);
    }
}
