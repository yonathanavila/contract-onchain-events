// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title  Onchain Events, management secury and transparency on attendance
/// @notice This contracts is used for management events porpuse in Onchain Events
/// @dev    Contains functions to verify merkle threee root hash to verify the information of the attendace
///         and Verify signatures of the attendance
contract OnchainEvents is Ownable, ReentrancyGuard {
    /// @notice the event struct
    struct EventStruct {
        bytes32 leaf;
        address organizer;
    }
    /// @notice the attendace struct
    struct AttendanceStruct {
        bytes32 leaf;
    }
    /// @notice from `address` to `EventStruct` of all events
    mapping(address => EventStruct) internal _allEvents;
    /// @notice from `address` to `AttendanceStruct` of all attendances
    mapping(address => AttendanceStruct) internal _allAttendances;

    /// @notice event Onchain Event registered
    event OnchainEventRegistered(address account, bytes32 leaf);
    /// @notice event attendance registered
    event AttendanceRegistered(address account, bytes32 leaf);

    /// @notice register new Onchain Event
    function onchainAttestation(bytes32 leaf) public nonReentrant {
        address organizer = _msgSender();
        _allEvents[organizer] = EventStruct(leaf, organizer);
        emit OnchainEventRegistered(organizer, leaf);
    }

    /// @notice attend a new event
    function attendEvent(bytes32 leaf) public nonReentrant {
        address client = _msgSender();
        bytes32 encodeLeaf = keccak256(abi.encode(leaf));
        _allAttendances[client] = AttendanceStruct(encodeLeaf);
        emit AttendanceRegistered(client, encodeLeaf);
    }

    /// @notice verify attendance
    function identifyVerification(
        bytes32[] calldata proof,
        address to
    ) public nonReentrant returns (bool) {
        bytes32 root = _getRoot(proof, _allAttendances[to].leaf);
        return
            MerkleProof.verifyCalldata(proof, root, _allAttendances[to].leaf);
    }

    /// @notice get the merkle root hash
    function _getRoot(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        return MerkleProof.processProof(proof, leaf);
    }
}
