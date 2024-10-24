// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

abstract contract OldDisposable {
    function dispose() external virtual;
}

abstract contract NewDisposable {
    function dispose(address to) external virtual;
}

contract Acquirer is Ownable {

    OldDisposable public disposable;

    Ownable public ownable;

    constructor(
        Ownable ownable_,
        OldDisposable disposable_
    )
        Ownable(_msgSender())
    {
        disposable = disposable_;
        ownable = ownable_;
    }

    function acquire() public /* EVERYONE! */ {
        disposable.dispose();

        ownable.transferOwnership(owner());
    }

}