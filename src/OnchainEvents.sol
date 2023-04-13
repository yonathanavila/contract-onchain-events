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
        allEvents[_msgSender()] = EventStruct(leaf);
        emit OnchainEventRegistered(_msgSender(), leaf);
    }

    /// @notice attend a new event
    function attendEvent(bytes32 leaf) public nonReentrant {
        allAttendances[_msgSender()] = AttendanceStruct(leaf);
        emit AttendanceRegistered(_msgSender(), leaf);
    }

    /// @notice verify attendance
    function identifyVerification(
        bytes32[] calldata proof
    ) public nonReentrant returns (bool) {
        bytes32 root = getRoot(proof, allAttendances[_msgSender()].leaf);
        return
            MerkleProofLib.verify(
                proof,
                root,
                allAttendances[_msgSender()].leaf
            );
    }

    /// @notice get root
    function getRoot(
        bytes32[] calldata proof,
        bytes32 leaf
    ) internal pure returns (bytes32) {
        return MerkleProof.processProof(proof, leaf);
    }
}
