// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Owned } from "./owned.sol";

Owned constant owned = Owned(address(0xeC35c0380aA6a444171663Ccac4fa5a1A83F4549));

contract Owner {

    address public implementation;

    constructor(
        address implementation_
    ) {
        implementation = implementation_;

        owned.mint(msg.sender);
 
        return;
    }

    function dontcallme() external {
       assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), address(), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function call() internal {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := call(gas(), sload(implementation.slot), callvalue(), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function staticcall() internal view {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := staticcall(gas(), sload(implementation.slot), 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    receive() external payable { 
        if (msg.sender == address(this)) {
            return;
        }

        if (msg.sender == owned.ownerOf(uint256(uint160(address(this))))) {
            return call();
        }

        return staticcall();
    }

    fallback() external payable {
        if (msg.sender == address(this)) {
            return;
        }

        if (msg.sender == owned.ownerOf(uint256(uint160(address(this))))) {
            return call();
        }

        return staticcall();
    }

}