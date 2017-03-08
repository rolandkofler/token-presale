// DO NOT use the newest version of solidity but an old stable one,
// check the bug lists of in the release anouncement of solidity after this versions.

pragma solidity ^0.4.8;

/**
 * SIKOBA PRESALE CONTRACTS
 *
 * Version 0.1
 *
 * Author Roland Kofler, Alex Kampa
 *
 * MIT LICENSE Copyright 2016 Sikoba LTD
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 **/

import "./owned.sol";


/// @title Sikoba Presale Contract
/// @author Roland Kofler, Alex Kampa
/// @dev changes to this contract will invalidate any security audits done before. It is MANDATORY to protocol audits in the "Security reviews done" section
///  # Security checklists to use in each review:
///  - Consensys checklist https://github.com/ConsenSys/smart-contract-best-practices
///  - Roland Kofler's checklist https://github.com/rolandkofler/ether-security
///  - read all of the code and use creative and lateral thinking to disccover bugs
///  # Security reviews done:
///  Date         Auditors                 Short summary of the review executed
///  2017 MAR 3 - Roland Kofler             - NO SECURITY REVIEW DONE
///  2017 MAR 7 - Roland Kofler, Alex Kampa - informal Security Review, added overflow protections, fixed wrong inequality operatiors, added maximal amount per transactions
///  2017 MAR 7 - Alex Kampa                - some code clean up, removed restriction of MINIMAL_AMOUNT_TO_SEND for preallocations


contract SikobaPresale is owned {
    //remember total balance of contract
    uint public totalFunding;

    //TODO: substitute all wei values with ether values before launching, if they are set for not spending too much on ropsten

    // Minimal and maximal amounts per transaction for public participants
    //TODO: check if for test reasons there is no wrong amount
    uint public constant MINIMAL_AMOUNT_TO_SEND =   5 ether;
    uint public constant MAXIMAL_AMOUNT_TO_SEND = 250 ether;

    // Minimal and maximal goals of the presale
    // If the minimum is not reached at the end of the presale, senders can withdraw via withdrawYourAssetsIfPresaleFailed()
    //TODO: before launch, adjust these values to approximate the desired EUR at current rates
    uint public constant MINIMAL_BALANCE_OF_PRESALE =  9000 ether;
    uint public constant MAXIMAL_BALANCE_OF_PRESALE = 18000 ether;

    // Public presale period
    // Starts on 04/05/2017 @ 12:00pm (UTC) 2017-04-05T12:00:00+00:00 in ISO 8601
    // Ends 2 weeks after the start
    uint public constant START_DATE_PRESALE = 1491393600;
    uint public constant DEADLINE_DATE_PRESALE = START_DATE_PRESALE + 2 weeks ;

    /// @notice The balances of all submitted Ether, includes preallocated Ether and the Ether submitted during the public phase
    /// @dev name complies with ERC20 token standard, etherscan for example will recognize this and show the balances of the address
    mapping (address => uint) public balanceOf;

    /// @notice a log of participations in the presale and preallocation
    /// @dev helps to extract the addresses form balanceOf.
    /// Because we want to avoid loops to prevent 'out of gas' runtime bugs we
    /// don't hold a set of unique participants but simply log partecipations.
    event LogParticipation(address indexed sender, uint value, uint timestamp, bool isPreallocation);

    /// @dev creating the contract needs two steps:
    ///       1. Set the value each preallocation address has submitted to the Sikoba bookmaker
    ///       2. Send the total amount of preallocated ether otherwise VM Exception: invalid JUMP
    function SikobaPresale () payable {
        owner = msg.sender;
        //TODO: check if having 100 participants in preallocation would not run the contract out of gas on mainnet

        //TODO: exchange the following example with the real preallocation:
        // Preallocation Ether must be sent on construction or contract creation fails
        //
        // Declare sum of preallocation balances
        // and verify that the actual amount sent corresponds
        uint totalPreallocationInWei = 15 ether;
        assertEquals(totalPreallocationInWei, msg.value);

        //TODO: exchange with real address and ether value
        // Pre-allocations (hard-coded based on ETH values previously received)
        addBalance(0xdeadbeef, 10 wei, true);
        addBalance(0xcafebabe, 5 wei, true);
    }

    /// @notice Send at least `MINIMAL_AMOUNT_TO_SEND` and at most `MAXIMAL_AMOUNT_TO_SEND` ether to this contract
    /// @notice or the transaction will fail and the value will be given back.
    /// Timeframe: if `now` >= `START_DATE_PRESALE` and `now` <= `DEADLINE_DATE_PRESALE`
    /// `MAXIMAL_BALANCE_OF_PRESALE-balance` still payable.

    function () payable {
        //preconditions to be met:

        // only during the public presale period
        if (now < START_DATE_PRESALE) throw;
        if (now > DEADLINE_DATE_PRESALE) throw;

        // the value sent must be between the minimal and maximal amounts accepted
        if (msg.value < MINIMAL_AMOUNT_TO_SEND) throw;
        if (msg.value > MAXIMAL_AMOUNT_TO_SEND) throw;

        // check if maximum presale amount has been met already
        if (safeIncrement(totalFunding, msg.value) > MAXIMAL_BALANCE_OF_PRESALE) throw;

        // register payment
        addBalance(msg.sender, msg.value, false);
    }


    /// @notice owner withdraws ether from presale
    /// @dev the owner can transfer ether anytime from this contract if the presale succeeded

    function withdraw(uint value) external onlyowner payable {

        // withdrawal IF PRESALE SUCCEEDED
        // only after the public deadline has been reached
        // and minimal presale goal is reached
        if (now <= DEADLINE_DATE_PRESALE) throw;
        if (totalFunding < MINIMAL_BALANCE_OF_PRESALE) throw;

        // withdraw the amount wanted
        bool success = owner.send(value);

        // basic check if sending failed, not really needed but good custom.
        if (!success) throw;
    }

    /// @notice If `MINIMAL_BALANCE_OF_PRESALE` > `balance` after `DEADLINE_DATE_PRESALE` then you can withdraw your balance here
    /// @dev the owner can transfer ether anytime from this contract if the presale failed

    function withdrawYourAssetsIfPresaleFailed(uint value) external {

        // withdrawal IF PRESALE FAILED
        // only after the public deadline has been reached
        // and minimal presale goal was not reached
        if (now <= DEADLINE_DATE_PRESALE) throw;
        if (totalFunding >= MINIMAL_BALANCE_OF_PRESALE) throw;

        // sender must have sent the amount he wants to withdraw
        if (balanceOf[msg.sender] < value) throw;

        // decrement the balance of the sender by the claimed amount
        balanceOf[msg.sender] = safeDecrement(balanceOf[msg.sender], value);

        // withdraw the amount wanted
        bool success= msg.sender.send(value);

        // basic check if sending failed, not really needed but good custom.
        if (!success) throw;
    }


    /// @dev private function to increment balances
    function addBalance(address participant, uint valueInWei, bool isPreallocation) private{

        // add amount to the balance of the participant
        balanceOf[participant] = safeIncrement(balanceOf[participant], valueInWei);

        // add to total balance
        totalFunding = safeIncrement(totalFunding, valueInWei);

        // log the participation to easily gather them for furter processing
        LogParticipation(participant, valueInWei, now, isPreallocation);

    }

    ////////////////////////////////////////////////////////////////////////////

    /// @dev Simple Assertion like in Unit Testing frameworks.
    function assertEquals(uint expectedValue, uint actualValue) private constant {
        if (expectedValue != actualValue) throw;
    }

    /// @dev if an addition is used for incrementing a base value, in order to detect an overflow
    ///      we can simply check if the result is smaller than the base value.
    /// TODO: double check edge cases
    function safeIncrement(uint base, uint increment) private constant returns (uint) {
      uint result = base + increment;
      if (result < base) throw;
      return result;
    }

    /// @dev if a subtraction is used for decrementing a base value, in order to detect an underflow
    ///      we can simply check if the result is bigger than the base value.
    /// TODO: double check edge cases
    function safeDecrement(uint base, uint increment) private constant returns (uint) {
      uint result = base - increment;
      if (result > base) throw;
      return result;
    }
}
