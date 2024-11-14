// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ud60x18} from "@prb/math/src/UD60x18.sol";
import {ISablierV2LockupLinear} from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";
import {Broker, LockupLinear} from "@sablier/v2-core/src/types/DataTypes.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SablierV2NFTDescriptor} from "@sablier/v2-core/src/SablierV2NFTDescriptor.sol";
import {SablierV2LockupLinear} from "@sablier/v2-core/src/SablierV2LockupLinear.sol";

/// @title Stream Creator Contract
/// @notice This contract allows the creation of linear lockup streams using Sablier V2
contract StreamCreator is Ownable {
    /**
     * @dev Errors to provide specific revert messages for failed operations
     */
    error InvalidCliff();
    error InvalidDuration();
    error InvalidStart();
    error InvalidAmount();
    error ZeroAddress();
    error InvalidStreamId();
    error TokenTransferFailed();
    error NotAuthorised();

    /**
     * @dev State variables
     * @notice streamingToken is the ERC20 token used for streaming
     * @notice sablier is the Sablier V2 Lockup Linear contract
     * @notice controller is the contract controlling access to certain functions
     * @notice userStreams is a mapping of user addresses to their stream IDs
     */
    IERC20 public immutable streamingToken;
    ISablierV2LockupLinear public immutable sablier;
    mapping(address => uint256[]) public userStreams;
    address public immutable GAME_ADDRESS;

    constructor(
        address token,
        address gameAddress
    ) Ownable(msg.sender) {
        streamingToken = IERC20(token);
        GAME_ADDRESS = gameAddress;
        SablierV2NFTDescriptor sablierV2NFTDescriptor = new SablierV2NFTDescriptor();
        SablierV2LockupLinear lockupLinear = new SablierV2LockupLinear(
            msg.sender,
            sablierV2NFTDescriptor
        );
        sablier = lockupLinear;
    }

    /// @notice Creates a linear lockup stream
    /// @param recipient The address to receive the stream
    /// @param totalAmount The total amount of tokens to be streamed
    /// @param duration The duration of the stream
    /// @param unlockAfter The time after which the stream starts unlocking
    /// @param start The start time of the stream
    /// @return streamId The ID of the created stream
    function createLockupLinearStream(
        address recipient,
        uint256 totalAmount,
        uint40 duration,
        uint40 unlockAfter,
        uint40 start
    ) external returns (uint256 streamId) {
        require(
            msg.sender == GAME_ADDRESS || msg.sender == owner(),
            NotAuthorised()
        );

        if (recipient == address(0)) revert ZeroAddress();
        if (start == 0) revert InvalidStart();
        if (duration == 0) revert InvalidDuration();
        if (unlockAfter == 0) revert InvalidCliff();
        if (totalAmount == 0) revert InvalidAmount();

        require(
            msg.sender == GAME_ADDRESS || msg.sender == owner(),
            NotAuthorised()
        );

        streamingToken.approve(address(sablier), totalAmount);

        LockupLinear.CreateWithTimestamps memory params;

        params.sender = msg.sender;
        params.recipient = recipient;
        params.totalAmount = uint128(totalAmount);
        params.asset = streamingToken;
        params.cancelable = false;
        params.timestamps = LockupLinear.Timestamps({
            start: start,
            cliff: unlockAfter,
            end: start + duration
        });
        params.broker = Broker(address(0), ud60x18(0));

        streamId = sablier.createWithTimestamps(params);
        userStreams[msg.sender].push(streamId);
    }

    function getStream(
        uint256 streamId
    ) public view returns (LockupLinear.StreamLL memory stream) {
        stream = sablier.getStream(streamId);
    }
}
