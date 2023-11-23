// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./EasyCollectionProxy.sol";

//placed in EasyFactoProx.sol

contract EasyFactory {
    address[] public deployedProxies;

    function createProxy(address _implementation) public {
        address newProxy = address(new EasyCollectionProxy(_implementation));
        deployedProxies.push(newProxy);
    }

    function getDeployedProxies() public view returns (address[] memory) {
        return deployedProxies;
    }
}
