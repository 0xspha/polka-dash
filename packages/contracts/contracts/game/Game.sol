// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {IGame} from "../interfaces/IGame.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Token} from "../tokens/Token.sol";
import {NFT} from "../tokens/NFT.sol";
import {StreamCreator, LockupLinear} from "../sablier/StreamCreator.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract Game is IGame, Ownable {
    using ECDSA for bytes32;

    modifier onlyGameActive() {
        require(GAME_ACTIVE, GameNotActive());
        _;
    }

    uint256[] public times;
    uint256[] public scores;
    address[] public playersKeys;
    uint256 public PLAY_COST;
    Token public TOKEN;
    NFT public NFT_TOKEN;
    StreamCreator public CREATOR;
    GamePrize public GAME_PRIZE;
    uint40 public MAX_TOKEN_LENGTH;
    bool public GAME_ACTIVE;
    mapping(address key => Player player) players;
    mapping(bytes signature => bool used) public usedSignatures;

    constructor() Ownable(msg.sender) {}
    function setGameConfig(
        uint256 cost,
        uint40 maxTokenLength,
        address tokenAddress,
        address nftAddress,
        address sablierAddress,
        GamePrize memory prize
    ) external override onlyOwner {
        require(!GAME_ACTIVE, GameActiveAlready());
        PLAY_COST = cost;
        CREATOR = StreamCreator(sablierAddress);
        TOKEN = Token(tokenAddress);
        NFT_TOKEN = NFT(nftAddress);
        GAME_PRIZE = prize;
        GAME_ACTIVE = true;
        MAX_TOKEN_LENGTH = maxTokenLength;
    }
    function play() external override onlyGameActive {
        Player storage player = players[msg.sender];
        LockupLinear.StreamLL memory stream = CREATOR.getStream(
            player.streamId
        );
        if (stream.endTime < block.timestamp) {
            bool success = TOKEN.transferFrom(
                msg.sender,
                address(this),
                PLAY_COST
            );
            require(success, InsufficientBalance());
            uint256 streamId = CREATOR.createLockupLinearStream(
                msg.sender,
                PLAY_COST,
                uint40(block.timestamp + MAX_TOKEN_LENGTH),
                0,
                uint40(block.timestamp)
            );
            player.streamId = streamId;
        }
        stream = CREATOR.getStream(player.streamId);
        emit Play(msg.sender, stream);
    }
    function claimPrize() external override onlyGameActive {
        require(players[msg.sender].winner, NotWinner());
        if (GAME_PRIZE.prizeType == Prize.NFT) {
            NFT_TOKEN.mint(msg.sender);
        } else if (GAME_PRIZE.prizeType == Prize.Sablier) {
            emit StreamDistributed(
                CREATOR.createLockupLinearStream(
                    msg.sender,
                    GAME_PRIZE.amount,
                    uint40(block.timestamp + 1 days),
                    0,
                    uint40(block.timestamp)
                )
            );
        } else {
            TOKEN.mint(msg.sender, GAME_PRIZE.amount);
        }
        players[msg.sender].winner = false;
        emit PlayerClaimed(GAME_PRIZE, msg.sender);
    }
    function uploadScore(
        uint256[] memory scores_,
        uint256[] memory times_,
        address[] memory players_,
        bytes memory signature
    ) external override onlyGameActive {
        if (
            (scores_.length != times_.length &&
                scores_.length != players_.length) ||
            players_.length == 0 ||
            players_.length > 10
        ) {
            revert ArrayLengthMissmatch();
        }
        if (usedSignatures[signature]) {
            revert UsedSignature();
        }
        bytes32 messageHash = keccak256(
            abi.encodePacked(scores_, times_, players_, block.chainid)
        );
        bytes32 message = MessageHashUtils.toEthSignedMessageHash(messageHash);
        address recoveredAddress = ECDSA.recover(message, signature);
        if (recoveredAddress != owner()) { //@dev need to ensure that the scores are uploaded from within the game
            revert InvalidClientSignature();
        }
        scores = scores_;
        playersKeys = players_;
        times = times_;
    }
    function playerScoresTime()
        external
        view
        override
        returns (address[] memory, uint256[] memory, uint256[] memory)
    {
        return (playersKeys, scores, times);
    }

    function wrapPlayToken() public payable override {
        require(msg.value > 0, InvalidEther());
        TOKEN.mint(msg.sender, msg.value);
    }
    function unwrapPlayToken(uint256 amount) public payable override {
        require(msg.value > 0, InvalidEther());
        bool success = TOKEN.transferFrom(msg.sender, address(this), amount);
        require(success, InsufficientBalance());
        (success, ) = msg.sender.call{value: amount}("0x");
        require(success, InsufficientBalance());
    }
}
