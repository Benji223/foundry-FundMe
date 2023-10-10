// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// constant, immutable 
// to reduce gas and for variable that don't change 

error NotOwner();

contract FundMe {

    
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18;

    address[] private s_funders;
    mapping(address funder => uint256 amountFunded) private s_addressToAmountFunded;
    // keep tracking adresses  

    address private immutable i_owner; 
    AggregatorV3Interface private s_priceFeed;
    
    
    constructor(address priceFeed)  { //input the adress of the price feed in the chain we want instead of coding it and be stuck in yhis chain 
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed); //refactoring
    }


    function fund() public payable  {
         
        require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,"You didn't send enough ETH"); // 1e18 = 1ETH
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }  

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool sucess,)= i_owner.call{value: address(this).balance}("");
        require(sucess, "call failed");
        

    }


    function Withdraw() public onlyOwner{

        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++){
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        s_funders = new address[](0);

        (bool sucess,)= i_owner.call{value: address(this).balance}("");
        require(sucess, "call failed");
        

    }

    function getVersion() public view returns(uint256 version) {
        return s_priceFeed.version();
    }

    modifier onlyOwner() {

        if (msg.sender != i_owner){
           revert NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
      fund();  
    }

    // What happens if someone sends this contract ETH without calling the fund function

    // receive()
    // fallback()

    function getAddressToAmountFunded(address fundingAdress) external view returns(uint256) {
        return s_addressToAmountFunded[fundingAdress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns(address){
        return i_owner;
    }
   
}