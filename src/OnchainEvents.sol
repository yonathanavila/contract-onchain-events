// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {MerkleProofLib} from "solmate/utils/MerkleProofLib.sol";
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
    mapping(address => EventStruct) internal allEvents;
    /// @notice from `address` to `AttendanceStruct` of all attendances
    mapping(address => AttendanceStruct) internal allAttendances;

    /// @notice event Onchain Event registered
    event OnchainEventRegistered(address account, bytes32 leaf);
    /// @notice event attendance registered
    event AttendanceRegistered(address account, bytes32 leaf);

    /// @notice register new Onchain Event
    function onchainAttestation(bytes32 leaf) public nonReentrant {
        address organizer = _msgSender();
        allEvents[organizer] = EventStruct(leaf, organizer);
        emit OnchainEventRegistered(organizer, leaf);
    }

    /// @notice attend a new event
    function attendEvent(bytes32 leaf) public nonReentrant {
        address client = _msgSender();
        allAttendances[client] = AttendanceStruct(leaf);
        emit AttendanceRegistered(client, leaf);
    }

    /// @notice verify attendance
    function identifyVerification(
        bytes32[] calldata proof,
        address to
    ) public nonReentrant returns (bool) {
        bytes32 root = getRoot(proof, allAttendances[to].leaf);
        return MerkleProofLib.verify(proof, root, allAttendances[to].leaf);
    }

    /// @notice get the merkle root hash
    function getRoot(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        return MerkleProof.processProof(proof, leaf);
    }
}
