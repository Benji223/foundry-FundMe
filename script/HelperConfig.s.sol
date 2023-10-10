// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains
// Sepolia ETH/USD.
// Mainnet ETH/USD

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on a local anvil, we deploy mocks
    // Otherwise, grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;
    uint256 public constant SEPOLIA_CHAIN_ID = 1155111;
    uint256 public constant ETH_CHAIN_ID = 1;

    constructor(){
        if (block.chainid == SEPOLIA_CHAIN_ID) { // if we are in sepolia active the adresses
            activeNetworkConfig = getSepoliaConfig();            
        } else if (block.chainid == ETH_CHAIN_ID) {
            activeNetworkConfig = getEthConfig();
        } else {
            activeNetworkConfig = getAnvilConfig();
        }
    }

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
        }

    function getSepoliaConfig() public pure returns(NetworkConfig memory){
        // Price Feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        return sepoliaConfig;
    }

    function getEthConfig() public pure returns(NetworkConfig memory){
        // Price Feed address
        NetworkConfig memory ethConfig = NetworkConfig(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        return ethConfig;
    }

    function getAnvilConfig() internal returns(NetworkConfig memory) {
        // Pice Feed address
        
        // 1. Deploy the mocks
        // 2. Return the mock address
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
            }

        vm.startBroadcast();

        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); 

        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig(address(mockPriceFeed));
        return anvilConfig;
    }
}

