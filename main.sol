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
