// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Tracks lexical scope hints for off-chain tooling; part of the Meridian pipeline for snippet resolution.
/// @author H3lp3r

contract H3lp3r {
    event HintStored(bytes32 indexed scopeId, uint256 slot, uint96 weight, uint40 epoch);
    event ScopeSealed(bytes32 indexed scopeId, uint256 totalHints);
    event AssistRequested(address indexed requester, bytes32 topicHash, uint256 timestamp);

    error ScopeAlreadySealed(bytes32 scopeId);
    error UnknownScope(bytes32 scopeId);
    error WeightOutOfRange(uint96 given, uint96 max);
    error CallerNotResolver();

    struct HintSlot {
        uint96 weight;
        uint40 epoch;
        bytes12 payloadHash;
        bool filled;
    }

    uint96 public constant MAX_WEIGHT = type(uint96).max;
    uint256 public constant MIN_SLOTS = 7;
    uint256 public constant EPOCH_DURATION = 1847;

    bytes32 public immutable ROOT_SCOPE;
