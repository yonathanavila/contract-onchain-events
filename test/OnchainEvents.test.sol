// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/OnchainEvents.sol";

contract CounterScript is Test {
    OnchainEvents onchainEventContract;
    bytes32[] eventMerkleRoot;
    bytes32[] attendanceMerkleRoot;

    function setUp() public {
        onchainEventContract = new OnchainEvents();
    }

    function testRegisterOnchainEvent() public {
        attendanceMerkleRoot = new bytes32[](3);
        eventMerkleRoot[0] = vm.parseBytes32(
            "0x4246af7740fec2fd7b47be7797b0a0d87611b4375edd61e99b14bcf300071ac0"
        );
        eventMerkleRoot[1] = vm.parseBytes32(
            "0xf75299d4c5bcdcab2672668efaaea4e0c5d046c451c45b40d0c63b5538811ee1"
        );
        eventMerkleRoot[2] = vm.parseBytes32(
            "0x321ec32866f415cb8acc70cf613eca8f2e07b4da532d58a171539a633682b370"
        );
        vm.startPrank(address(0x2));
        onchainEventContract.attendEvent(attendanceMerkleRoot);
        vm.stopPrank();
    }
}
