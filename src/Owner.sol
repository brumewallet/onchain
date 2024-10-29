// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Owned } from "./owned.sol";

contract Owner {

    Owned public collection;

    address public implementation;

    constructor(
        Owned collection_,
        address implementation_
    ) {
        collection = collection_;
        implementation = implementation_;

        collection.mint(msg.sender);
 
        return;
    }

    modifier ifAdmin() {
        if (msg.sender == collection.ownerOf(uint256(uint160(address(this))))) {
            _;
        } else {
            staticcall();
        }
    }

    function setImplementation(address implementation_) public ifAdmin {
        implementation = implementation_;
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

    function proxy() internal {
        if (msg.sender == collection.ownerOf(uint256(uint160(address(this))))) {
            call();
        } else {
            staticcall();
        }
    }

    receive() external payable {
        // NOOP
    }

    fallback() external payable {
        proxy();
    }

}