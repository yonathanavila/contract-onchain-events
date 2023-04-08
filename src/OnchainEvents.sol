// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

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
        bytes32[] proof;
    }
    /// @notice the attendace struct
    struct AttendanceStruct {
        bytes32[] proof;
    }

    /// @notice from `address` to `EventStruct` of all events
    mapping(address => EventStruct) internal allEvents;
    /// @notice from `address` to `AttendanceStruct` of all attendances
    mapping(address => AttendanceStruct) internal allAttendances;

    /// @notice event Onchain Event registered
    event OnchainEventRegistered(address account, bytes32[] proof);

    /// @notice event attendance registered
    event AttendanceRegistered(address account, bytes32[] proof);

    /// @notice register new Onchain Event
    function registerOnchainEvent(
        bytes32[] memory proof
    ) external nonReentrant {
        allEvents[_msgSender()] = EventStruct(proof);
        emit OnchainEventRegistered(_msgSender(), proof);
    }

    /// @notice attend a new event
    function attendEvent(bytes32[] memory proof) public nonReentrant {
        allAttendances[_msgSender()] = AttendanceStruct(proof);
        emit AttendanceRegistered(_msgSender(), proof);
    }

    /// @notice verify attendance
    function verifyAttendance(
        bytes32[] memory proof,
        bytes32 root_, // root attendance
        bytes32 leaf // root event
    ) public nonReentrant returns (bool attend) {
        attend = MerkleProof.verify(proof, root_, leaf);
        return attend;
    }
}
