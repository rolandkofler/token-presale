// DO NOT use the newest version of solidity but an old stable one, check the bug lists of in the release anouncement of solidity after this versions.
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
/// @dev changes to this contract it will invalidate any security audits done before. It is MANDATORY to protocol audits in the "Security reviews done" section
///  # Security checklists to use in each review:
///  - Consensys checklist https://github.com/ConsenSys/smart-contract-best-practices
///  - Roland Kofler's checklist https://github.com/rolandkofler/ether-security
///  - read all of the code and use creative and lateral thinking to disccover bugs
///  # Security reviews done:
///  Date         Auditors                 Short summary of the review executed
///  2017 MAR 3 - Roland Kofler            - NO SECURITY REVIEW DONE
///  2017 MAR 7 - Roland Kofler, Alex Kampa- informal Security Review, added overflow protections, fixed wrong inequality operatiors, added maximal amount per transactions

contract SikobaPresale is owned{

    //TODO: substitute all wei values with ether values before launching, if they are set for not spending to much on ropsten
    // Preallocators and public participants both need to send minimal 5 ether;
    uint public constant MINIMAL_AMOUNT_TO_SEND = 5 ether; //TODO: check if for test reasons there is no wrong amount

    // Public participants can send maximal 250 ether per transaction, but they can send as many transactions as they want.
    uint public constant Maximal_AMOUNT_TO_SEND = 250 ether; //TODO: check if for test reasons there is no wrong amount

    // Maximal goal of the presale is 18000 ether. More can't be sent
    uint public constant MAXIMAL_BALANCE_OF_PRESALE = 18000 ether; //TODO: potentially change the value to represent more or less the desired EUR at current rate

    // Minimal goal is 9000 ether, if not reached the sender can withdraw their ether via withdrawYourAssetsIfPresaleFailed()
    uint public constant MINIMAL_BALANCE_OF_PRESALE =  9000 ether; //TODO: potentially change the value to represent more or less the desired EUR at current rate

    // The start of the public presale
    uint public constant START_DATE_PRESALE = 1491393600; // Is equivalent to: 04/05/2017 @ 12:00pm (UTC) 2017-04-05T12:00:00+00:00 in ISO 8601

    // The deadline of the presale is 2 weeks after the start.
    uint public constant DEADLINE_DATE_PRESALE = START_DATE_PRESALE + 2 weeks ;


    /// @notice The balances of all submitted Ether, includes the preallocated ether and the ether submitted during the public phase
    /// @dev name complies with ERC20 token standard, etherscan for example will recognize this and show the balances of the address
    mapping (address => uint) public balanceOf;


    /// @notice a log of participations in the presale and preallocation
    /// @dev helps to extract the addresses form balanceOf.
    /// Because we want to avoid loops to prevent 'out of gas' runtime bugs we
    /// don't hold a set of unique participants but simply log partecipations.
    event LogPartecipation( address indexed sender, uint value, uint timestamp, bool isPreallocation);

    /// @dev creating the contract needs two steps:
    ///       1. Set the value each preallocation address has submitted to the Sikoba bookmaker
    ///       2. Send the total amount of preallocated ether otherwise VM Exception: invalid JUMP
    function SikobaPresale () payable{
        //TODO: verify if implicitly owned by creator because constructor of owner is called.
        //TODO: check if having 100 participants in preallocation would not run the contract out of gas on mainnet

        //TODO exchange the following example with the real preallocation:

        //sum of preallocation balances
        uint totalPreallocationInWei = 15 ether; //TODO: exchange with total preallocation ether value.

        //preallocation money must be sent on construction or contract creation fails
        assertEquals(totalPreallocationInWei, msg.value);

        //example address deadbeef has 10 ether submitted during preallocation phase
        addBalance(0xdeadbeef, 10 wei, true);   //TODO: exchange with real address and ether value.

        //example address cafebabe has 10 ether submitted during preallocation phase
        addBalance(0xcafebabe, 5 wei, true);    //TODO: exchange with real address and ether value.


    }

    /// @notice Send at least `MINIMAL_AMOUNT_TO_SEND` ether to this contract or the transaction will fail and the value will be given back.
    /// Timeframe: if `now` >= `START_DATE_PRESALE` and `now` <= `DEADLINE_DATE_PRESALE`
    /// `MAXIMAL_BALANCE_OF_PRESALE-balance` still payable.
    function () payable{
        //preconditions to be met:

        // maximal amount per tx met
        if (msg.value > Maximal_AMOUNT_TO_SEND) throw;

        // minimal amount per tx met is checked in addBalance()

        // maximal amount not met with new payment
        if (safeIncrement(this.balance, msg.value) >= MAXIMAL_BALANCE_OF_PRESALE) throw;

        // public deadline not reached yet
        if (now > DEADLINE_DATE_PRESALE)throw;

        // public allocation round started
        if (now < START_DATE_PRESALE)throw;

        //account for the ether sent
        addBalance(msg.sender, msg.value, false);
    }


    /// @notice owner withdraws ether from presale
    /// @dev the owner can transfer ether anytime from this contract
    function withdraw( uint value) external onlyowner payable{
        // only withdraw if public deadline reached
        // TODO: attention that the complement check is always > not =>
        if (now <= DEADLINE_DATE_PRESALE) throw;

        // only withdraw if minimal ether goal is reached
        if (this.balance < MINIMAL_BALANCE_OF_PRESALE) throw;

        // check if balance can be withdrawn,
        // TODO: probably redundand to basic ethereum checks and can be removed after clarification
        if (this.balance < value) throw;

        // withdraw the amount wanted
        bool success= owner.send(value);

        // basic check if sending failed, not really needed but good custom.
        if (!success) throw;
    }

    // @notice If `MINIMAL_BALANCE_OF_PRESALE` > `balance` after `DEADLINE_DATE_PRESALE` then you can withdraw your balance here
    /// @dev the owner can transfer ether anytime from this contract
    function withdrawYourAssetsIfPresaleFailed(uint value) external {
        // check if balance can be withdrawn,
        // TODO: probably redundand to basic ethereum checks and can be removed after clarification
        if (this.balance < value) throw;

        // sender must have sent the amount he wants to withdraw
        if (balanceOf[msg.sender]< value) throw;

        // the sender can only withdraw his amount after the deadline of the presale
        if (now <= DEADLINE_DATE_PRESALE) throw;

        // the sender can only withdraw if the minimal goal of the presale has NOT been met.
        if (this.balance >= MINIMAL_BALANCE_OF_PRESALE) throw;

        // decrement the balance of the sender by the claimed amount
        balanceOf[msg.sender] = safeDecrement(balanceOf[msg.sender], value);

        // withdraw the amount wanted
        bool success= msg.sender.send(value);

        // basic check if sending failed, not really needed but good custom.
        if (!success) throw;
    }

    // @dev Simple Assertion like in Unit Testing frameworks.
    function assertEquals(uint expectedValue, uint actualValue ) private constant{
        if (expectedValue != actualValue) throw;
    }

    // @dev implicitly this means that even preallocations must be more than MINIMAL_AMOUNT_TO_SEND
    function addBalance(address participant, uint valueInWei, bool isPreallocation) private{
        // addition must be bigger than minimal amount.
        if (valueInWei < MINIMAL_AMOUNT_TO_SEND) throw;

        // add amount to the balance of the participant
        balanceOf[participant] = safeIncrement(balanceOf[participant], valueInWei);

        // log the participation to easily gather them for furter processing
        LogPartecipation(participant, valueInWei, now, isPreallocation);

    }

    // @dev if an addition is used for incrementing a base value, in order to detect an overflow
    //      we can simply check if the result is smaller than the base value.
    // TODO: double check edge cases
    function safeIncrement(uint base, uint increment) private constant returns (uint){
      uint result = base + increment;
      if (result < base) throw;
      return result;
    }

    // @dev if a subtraction is used for decrementing a base value, in order to detect an underflow
    //      we can simply check if the result is bigger than the base value.
    // TODO: double check edge cases
    function safeDecrement(uint base, uint increment) private constant returns (uint){
      uint result = base - increment;
      if (result > base) throw;
      return result;
    }
}
