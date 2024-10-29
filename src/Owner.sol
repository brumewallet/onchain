// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Owned } from "./owned.sol";
import { SafeCast } from "@openzeppelin/contracts/utils/math/SafeCast.sol";

contract Owner {
    using SafeCast for *;

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

    modifier onlyOwner() {
        if (msg.sender == owner()) {
            _;
        } else {
            revert();
        }
    }

    function owner() public view returns (address) {
        return collection.ownerOf(uint256(uint160(address(this))));
    }

    function setImplementation(address implementation_) external onlyOwner {
        implementation = implementation_;
    }

    function dontcallme() external onlyOwner {
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
        if (msg.sender == owner()) {
            call();
        } else {
            staticcall();
        }
    }

    receive() external payable {
        payable(owner()).transfer(msg.value);
    }

    fallback() external payable {
        proxy();
    }

}