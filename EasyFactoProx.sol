// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EasyLibrary.sol";

contract EasyFactory {
    address[] public deployedContracts;
    address public collectionAddress;
    
    constructor(address payable _collectionAddress) {
        collectionAddress = _collectionAddress;
    }

    function createContract(string calldata _name_, string calldata _symbol_) public {
        address newContract = address(new EasyCollectionProxy(collectionAddress, _name_, _symbol_, msg.sender));
        deployedContracts.push(newContract);
    }

    function getDeployedContracts() public view returns (address[] memory) {
        return deployedContracts;
    }
}

contract EasyCollectionProxy {
    address public implementation;

    constructor(address _implementation, string memory _name, string memory _symbol, address _newOwner) {
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