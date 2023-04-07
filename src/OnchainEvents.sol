// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Script.sol";
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
        address account,
        bytes32 leaf
    ) public nonReentrant returns (bool attend) {
        require(account != address(0), "OnchainEvent: zero account receiver");
        bytes32 root = MerkleProof.processProof(
            allAttendances[account].proof,
            leaf
        );
        attend = MerkleProof.verify(allAttendances[account].proof, root, leaf);
        require(
            attend,
            "OnchainEvent: this account is not registered in the event"
        );

        return attend;
    }
}
