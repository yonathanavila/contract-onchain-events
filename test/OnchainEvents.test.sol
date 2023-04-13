// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {OnchainEvents} from "src/OnchainEvents.sol";

contract CounterScript is Test {
    OnchainEvents onchainEventContract;
    address pedro = address(0x1);
    address manolo = address(0x2);

    function setUp() public {
        vm.startPrank(pedro);
        onchainEventContract = new OnchainEvents();
        vm.stopPrank();
    }

    function testValidProofSupplied() public {
        // Merkle tree created from leaves ['a', 'b', 'c'].
        // Leaf is 'a'.
        bytes32[] memory proof = new bytes32[](2);
        proof[
            0
        ] = 0xb5553de315e0edf504d9150af82dafa5c4667fa618ed0a6f19c69b41166c5510;
        proof[
            1
        ] = 0x0b42b6393c1f53060fe3ddbfcd7aadcca894465a5a438f69c87d790b2299b9b2;
        bytes32 leaf = 0x3ac225168df54212a25c1c01fd35bebfea408fdac2e31ddd6f80a4bbf9a5f1cb;
        assertEq(this.verify(proof, leaf), true);
    }

    function verify(
        bytes32[] calldata proof,
        bytes32 leaf
    ) external returns (bool) {
        return onchainEventContract.identifyVerification(proof, leaf);
    }
}
