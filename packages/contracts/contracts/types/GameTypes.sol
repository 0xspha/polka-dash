// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;
interface GameTypes {
    /// @notice Enum representing the different types of prizes available in the game.
    enum Prize {
        Token,
        Sablier,
        NFT
    }

    /// @notice Enum representing the different types of messages that can be sent.
    enum MessageType {
        Verify,
        Verified
    }

    /// @notice Structure representing a prize in the prize pool.
    /// @param prizeType Type of the prize.
    /// @param amount Amount or value of the prize.
    struct GamePrize {
        Prize prizeType;
        uint256 amount;
    }

    struct Player {
        uint256 streamId;
        bool winner;
        address player;
    }
}
