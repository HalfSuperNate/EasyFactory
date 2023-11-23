// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EasyLibrary.sol";

contract EasyCollectionProxy {
    address public owner;
    address public implementation;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    constructor(address _implementation, string memory _name, string memory _symbol, address _newOwner) {
        owner = msg.sender;
        implementation = _implementation;

        // Deploy the EasyCollection instance using delegatecall
        (bool success, ) = _implementation.delegatecall(abi.encodeWithSignature("initialize(string,string,address)", _name, _symbol, _newOwner));
        require(success, "Failed to initialize EasyCollection");
    }

    fallback() external payable {
        address _impl = implementation;
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), _impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    // Receive function to handle incoming ether transfers
    receive() external payable {}
}