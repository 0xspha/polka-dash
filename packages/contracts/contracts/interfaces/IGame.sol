// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
import {GameTypes} from "../types/GameTypes.sol";
import {StreamCreator, LockupLinear} from "../sablier/StreamCreator.sol";
interface IGame is GameTypes {
    error InvalidEther();
    error NotWinner();
    error InsufficientBalance();
    error ArrayLengthMissmatch();
    error UsedSignature();
    error InvalidClientSignature();
    error GameActiveAlready();
    error GameNotActive();
    event StreamDistributed(uint256 indexed stream);
    event PlayerClaimed(GamePrize indexed prize, address indexed player);
    event Play(address indexed player, LockupLinear.StreamLL indexed stream);
    event WinnerChosen(address indexed player, GamePrize indexed prize);
    function play() external;
    function claimPrize() external;
    function playerScoresTime()
        external
        view
        returns (address[] memory, uint256[] memory, uint256[] memory);
    function uploadScore(
        uint256[] memory scores_,
        uint256[] memory times_,
        address[] memory players_,
        bytes memory signature
    ) external;
    function wrapPlayToken() external payable;
    function unwrapPlayToken(uint256 amount) external payable;
    function setGameConfig(
        uint256 cost,
        uint40 maxTokenLength,
        address tokenAddress,
        address nftAddress,
        address sablierAddress,
        GamePrize memory prize
    ) external;
}
