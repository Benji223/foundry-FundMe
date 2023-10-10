// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
// import {HelperConfig} from "../../script/HelperConfig.s.sol";
// import {StdCheats} from "forge-std/StdCheats.sol";

// I call FundMeTest which calls FundMe 
// so different adresses

contract TestFundMe is Test {
    FundMe public fundMe;

    address USER = makeAddr("user"); // doesn't have any money
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external { 
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        // fundMe = new contract FundMe
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        // run is gonna return a fundme contract  
        // now everytime we gonna update Deploy is gonna update test
        
        vm.deal(USER, STARTING_BALANCE);
        
    
    }


    function testUSD() external {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        // verify if minimum usd is 5e18
    }

    function testOwner() external{
        assertEq(fundMe.getOwner(), msg.sender);

    }

    // What can we do to work with addresses outside our system?
    // 1. Unit
    // Testing a specific part of our code
    // 2. Integration
    // Testing how our code works with other parts of our code
    // 3. Forked
    // Testing our code on a simulated real environment
    // 4. Staging
    // Testing our code in a real environment that is not prod

    function testVersion() external {
        assertEq(fundMe.getVersion(), 4);
    }

    function testFunctionFundFail() public {
        vm.expectRevert(); // hey, the next line, should revert!
        // assert (This tx fails/reverts)
        fundMe.fund();// send 0 value
    }

   function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);  
        assertEq(amountFunded, SEND_VALUE);
    }

    function testArray() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        assert(address(fundMe).balance > 0);
        _;
    }

    function testOnlyOwnerWithdraw() public funded {    
        vm.expectRevert();
        fundMe.cheaperWithdraw();            
    }

    function testWithdraw() public funded{
        // arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        uint256 startingContractBalance = address(fundMe).balance;
        // act 
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        // assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingContractBalance = address(fundMe).balance;
        assertEq(endingContractBalance, 0);
        assertEq(startingContractBalance + startingOwnerBalance, endingOwnerBalance);  
    }

    function testWithdrawFromMultipleFundersCheaper() public funded{
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++){
            // vm.prank = give an address
            // vm.deal = give the address value
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            console.log(address(i));
            vm.expectRevert();
            fundMe.cheaperWithdraw();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();  
        
        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingContractBalance + startingOwnerBalance == fundMe.getOwner().balance); 
        
    }
    function testWithdrawFromMultipleFunders() public funded{
        // arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++){
            // vm.prank = give an address
            // vm.deal = give the address value
            hoax(address(i), SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();
            console.log(address(i));
            vm.expectRevert();
            fundMe.Withdraw();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingContractBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.Withdraw();  
        
        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingContractBalance + startingOwnerBalance == fundMe.getOwner().balance); 
        
    }


}