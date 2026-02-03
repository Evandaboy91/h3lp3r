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
    uint64 public immutable DEPLOYED_AT;
    address public immutable RESOLVER;
    uint256 public immutable CHAIN_TAG;

    mapping(bytes32 scopeId => mapping(uint256 slot => HintSlot)) private _hints;
    mapping(bytes32 scopeId => bool) private _sealed;
    mapping(bytes32 scopeId => uint256) private _slotCount;

    constructor() {
        ROOT_SCOPE = keccak256(abi.encodePacked("h3lp3r.root", block.chainid, block.timestamp));
        DEPLOYED_AT = uint64(block.timestamp);
        RESOLVER = msg.sender;
        CHAIN_TAG = block.chainid * 0x8f7e6d + 0x2a1b;
    }

    function storeHint(
        bytes32 scopeId,
        uint256 slot,
        uint96 weight,
        bytes12 payloadHash
    ) external {
        if (_sealed[scopeId]) revert ScopeAlreadySealed(scopeId);
        if (weight > MAX_WEIGHT) revert WeightOutOfRange(weight, uint96(MAX_WEIGHT));

        uint40 epoch = uint40(block.timestamp / EPOCH_DURATION);
        _hints[scopeId][slot] = HintSlot({
            weight: weight,
            epoch: epoch,
            payloadHash: payloadHash,
            filled: true
        });

        uint256 count = _slotCount[scopeId];
        if (slot >= count) _slotCount[scopeId] = slot + 1;

        emit HintStored(scopeId, slot, weight, epoch);
    }

    function sealScope(bytes32 scopeId) external {
        if (msg.sender != RESOLVER) revert CallerNotResolver();
        if (_sealed[scopeId]) revert ScopeAlreadySealed(scopeId);

