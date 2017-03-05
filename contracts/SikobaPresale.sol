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
///  #Security reviews done:
///  Date         Auditors        Short summary of the review executed
///  2017 MAR 3 - Roland Kofler - NO SECURITY REVIEW DONE

contract SikobaPresale is owned{

    uint public constant MINIMAL_AMOUNT_TO_SEND = 5 wei; //TODO: check if for test reasons there is no wrong amount
    uint MAXIMAL_BALANCE_OF_PRESALE = 18000 ether; //TODO: potentially change the value to represent more or less the desired EUR at current rate
    uint MINIMAL_BALANCE_OF_PRESALE =  9000 ether; //TODO: potentially change the value to represent more or less the desired EUR at current rate
    uint START_DATE_PRESALE = 1491393600; // Is equivalent to: 04/05/2017 @ 12:00pm (UTC) 2017-04-05T12:00:00+00:00 in ISO 8601
    uint DEADLINE_DATE_PRESALE = START_DATE_PRESALE + 2 weeks ;


    /// @notice The balances of all submitted Ether, includes the preallocated ether and the ether submitted during the public phase
    /// @dev name complies with ERC20 token standard, etherscan for example will recognize this and show the balances of the address
    mapping (address => uint) public balanceOf;


    /// @notice a log of participations in the presale and preallocation
    /// @dev helps to extract the addresses form balanceOf.
    /// Because we want to avoid loops to prevent 'out of gas' runtime bugs we
    /// don't hold a set of unique partecipants but simply log partecipations.
    event LogPartecipation( address indexed sender, uint value, uint timestamp, bool isPreallocation);

    /// @dev creating the contract needs two steps:
    ///       1. Set the value each preallocation address has submitted to the Sikoba bookmaker
    ///       2. Send the total amount of preallocated ether otherwise VM Exception: invalid JUMP
    function SikobaPresale () payable{
        // implicitly owned by creator

        //bonus: claim the ENS registry
        //reverseRegistrar.claim(msg.sender);

        // Manually set the preallocation investments
        // Example:

        //sum of preallocation balances
        uint totalPreallocationInEther = 15 wei; //TODO: exchange with total preallocation ether value.

        //preallocation money must be sent on construction or contract creation fails
        //assertEquals(totalPreallocationInEther, msg.value);

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

        // minimal amount met
        if (msg.value < MINIMAL_AMOUNT_TO_SEND) throw;
        // maximal amount not met with new payment
        if ((this.balance + msg.value) >= MAXIMAL_BALANCE_OF_PRESALE) throw;
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
        if (this.balance > value) throw;
        bool success= owner.send(value);
        if (!success) throw;
    }

    // @notice If `MINIMAL_BALANCE_OF_PRESALE` > `balance` after `DEADLINE_DATE_PRESALE` then you can withdraw your balance here
    /// @dev the owner can transfer ether anytime from this contract
    function withdrawYourAssetsIfPresaleFailed(uint value) external {
        if (this.balance > value) throw;
        if (balanceOf[msg.sender]> value) throw;
        if (now <= DEADLINE_DATE_PRESALE)throw;
        if (this.balance >= MINIMAL_BALANCE_OF_PRESALE) throw;
        balanceOf[msg.sender] = balanceOf[msg.sender] - value;
        bool success= msg.sender.send(value);
        if (!success) throw;
    }

    // @dev Simple Assertion like in Unit Testing frameworks.
    function assertEquals(uint expectedValue, uint actualValue ) private constant{
        if (expectedValue != actualValue) throw;
    }

    // @dev TODO: implicitly this means that even preallocations must be more than MINIMAL_AMOUNT_TO_SEND
    function addBalance(address partecipant, uint valueInWei, bool isPreallocation) private{
        if (valueInWei < MINIMAL_AMOUNT_TO_SEND) throw;
        balanceOf[partecipant] = balanceOf[partecipant] + valueInWei;
        LogPartecipation(partecipant, valueInWei, now, isPreallocation);

    }
}
