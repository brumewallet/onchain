// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Owned } from "./owned.sol";

Owned constant owned = Owned(address(0xd6cCd11a09e616e9F3C24c13F53d62BB1337af3F));

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