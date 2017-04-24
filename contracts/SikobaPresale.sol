pragma solidity ^0.4.8;

/**
 * SIKOBA PRESALE CONTRACTS
 *
 * Version 0.1
 *
 * Author Roland Kofler, Alex Kampa, Bok 'BokkyPooBah' Khoo
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


/**
 *
 * Important information about the Sikoba token presale
 *
 * For details about the Sikoba token presale, and in particular to find out
 * about risks and limitations, please visit:
 *
 * http://www.sikoba.com/www/presale/index.html
 *
 **/


contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }
}

/// ----------------------------------------------------------------------------------------
/// @title Sikoba Presale Contract
/// @author Roland Kofler, Alex Kampa, Bok 'Bokky Poo Bah' Khoo
/// @dev Changes to this contract will invalidate any security audits done before.
/// It is MANDATORY to protocol audits in the "Security reviews done" section
///  # Security checklists to use in each review:
///  - Consensys checklist https://github.com/ConsenSys/smart-contract-best-practices
///  - Roland Kofler's checklist https://github.com/rolandkofler/ether-security
///  - Read all of the code and use creative and lateral thinking to discover bugs
///  # Security reviews done:
///  Date         Auditors       Short summary of the review executed
///  Mar 03 2017 - Roland Kofler  - NO SECURITY REVIEW DONE
///  Mar 07 2017 - Roland Kofler, - Informal Security Review; added overflow protections;
///                Alex Kampa       fixed wrong inequality operators; added maximum amount
///                                 per transactions
///  Mar 07 2017 - Alex Kampa     - Some code clean up; removed restriction of
///                                 MINIMUM_PARTICIPATION_AMOUNT for preallocations
///  Mar 08 2017 - Bok Khoo       - Complete security review and modifications
///  Mar 09 2017 - Roland Kofler  - Check the diffs between MAR 8 and MAR 7 versions
///  Mar 12 2017 - Bok Khoo       - Renamed TOTAL_PREALLOCATION_IN_WEI
///                                 to TOTAL_PREALLOCATION.
///                                 Removed isPreAllocation from addBalance(...)
///  Mar 13 2017 - Bok Khoo       - Made dates in comments consistent
///  Apr 05 2017 - Roland Kofler  - removed the necessity of presale end before withdrawing
///                                 thus price drops during presale can be mitigated
///  Apr 24 2017 - Alex Kampa     - edited constants and added pre-allocation amounts
///                                 
/// ----------------------------------------------------------------------------------------
contract SikobaPresale is Owned {
    // -------------------------------------------------------------------------------------
    // TODO Before deployment of contract to Mainnet
    // 1. Confirm MINIMUM_PARTICIPATION_AMOUNT and MAXIMUM_PARTICIPATION_AMOUNT below
    // 2. Adjust PRESALE_MINIMUM_FUNDING and PRESALE_MAXIMUM_FUNDING to desired EUR
    //    equivalents
    // 3. Adjust PRESALE_START_DATE and confirm the presale period
    // 4. Update TOTAL_PREALLOCATION to the total preallocations received
    // 5. Add each preallocation address and funding amount from the Sikoba bookmaker
    //    to the constructor function
    // 6. Test the deployment to a dev blockchain or Testnet to confirm the constructor
    //    will not run out of gas as this will vary with the number of preallocation
    //    account entries
    // 7. A stable version of Solidity has been used. Check for any major bugs in the
    //    Solidity release announcements after this version.
    // 8. Remember to send the preallocated funds when deploying the contract!
    // -------------------------------------------------------------------------------------

    // Keep track of the total funding amount
    uint256 public totalFunding;

    // Minimum and maximum amounts per transaction for public participants
    uint256 public constant MINIMUM_PARTICIPATION_AMOUNT =   1 ether;
    uint256 public constant MAXIMUM_PARTICIPATION_AMOUNT = 250 ether;

    // Minimum and maximum goals of the presale
    uint256 public constant PRESALE_MINIMUM_FUNDING = 4000 ether;
    uint256 public constant PRESALE_MAXIMUM_FUNDING = 8000 ether;

    // Total preallocation in wei
    uint256 public constant TOTAL_PREALLOCATION = 496.46472668 ether;

    // Public presale period
    // Starts Apr 25 2017 @ 12:00pm (UTC) 2017-04-05T12:00:00+00:00 in ISO 8601
    // Ends May 15 2017 @ 12:00pm (UTC) 2017-05-15T12:00:00+00:00 in ISO 8601
    uint256 public constant PRESALE_START_DATE = 1493121600;
    uint256 public constant PRESALE_END_DATE = 1494849600;

    // Owner can clawback after a date in the future, so no ethers remain
    // trapped in the contract. This will only be relevant if the
    // minimum funding level is not reached
    // Jan 01 2018 @ 12:00pm (UTC) 2018-01-01T12:00:00+00:00 in ISO 8601
    uint256 public constant OWNER_CLAWBACK_DATE = 1514808000;

    /// @notice Keep track of all participants contributions, including both the
    ///         preallocation and public phases
    /// @dev Name complies with ERC20 token standard, etherscan for example will recognize
    ///      this and show the balances of the address
    mapping (address => uint256) public balanceOf;

    /// @notice Log an event for each funding contributed during the public phase
    /// @notice Events are not logged when the constructor is being executed during
    ///         deployment, so the preallocations will not be logged
    event LogParticipation(address indexed sender, uint256 value, uint256 timestamp);

    function SikobaPresale () payable {
        assertEquals(TOTAL_PREALLOCATION, msg.value);
        // Pre-allocations
        addBalance(0xe902741cd4666e4023b7e3ab46d3de2985c996f1, 0.647 ether);
        addBalance(0x98ab52e249646ca2b013af8f2e411bb90c1c9b4d, 66.98333494 ether);
        addBalance(0x7c6003edeb99886e8d65b5a3af81cd82962266f6, 1.0508692 ether);
        addBalance(0x7c6003edeb99886e8d65b5a3af81cd82962266f6, 1.9491308 ether);
        addBalance(0x99a4f90e16c043197da52d5d8c9b36a106c27042, 13 ether);
        addBalance(0x452f7faa5423e8d38435ffc5cfba6da806f159a5, 0.412 ether);
        addBalance(0x7FEA1962E35D62059768C749bedd96cAB930D378, 127.8142 ether);
        addBalance(0x0bfec3578b7174997efbf145b8d5f5b5b66f273f, 10 ether);
        addBalance(0xB4f14EDd0e846727cAe9A4B866854ed1bfE95781, 110 ether);
        addBalance(0xb6500cebed3334dcd9a5484d27a1986703bdcb1a, 0.9748227 ether);
        addBalance(0x8fbce39ab5f2664506d6c3e3cd39f8a419784f62, 75.1 ether);
        addBalance(0x665A816F54020a5A255b366b7763D5dfE6f87940, 9 ether);
        addBalance(0x665A816F54020a5A255b366b7763D5dfE6f87940, 12 ether);
        addBalance(0x9cb37d0ae943c8b4256e71f98b2dd0935e89344f, 10 ether);
        addBalance(0x00f87d9949b8e96f7c70f9dd5a6951258729c5c3, 22.24507475 ether);
        addBalance(0xff2694cd9ca6a72c7864749072fab8db6090a1ca, 10 ether);
        addBalance(0xcb5a0bc5efc931c336fa844c920e070e6fc4e6ee, 0.27371429 ether);
        addBalance(0xd956d333bf4c89cb4e3a3d833610817d8d4beda3, 1 ether);
        addBalance(0xba43bbd58e0f389b5652a507c8f9d30891750c00, 2 ether);
        addBalance(0x1203c41ae7469b837b340870ce4f2205b035e69f, 5 ether);
        addBalance(0x8efdb5ee103c2295dab1410b4e3d1ed7a91584d4, 1 ether);
        addBalance(0xed1b8bbae30a58dc1ce57bcd7dca51eb75e1fde9, 6.01458 ether);
        addBalance(0x96050f871811344dd44c2f5b7bc9741dff296f5e, 10 ether);
        assertEquals(TOTAL_PREALLOCATION, totalFunding);
    }

    /// @notice A participant sends a contribution to the contract's address
    ///         between the PRESALE_STATE_DATE and the PRESALE_END_DATE
    /// @notice Only contributions between the MINIMUM_PARTICIPATION_AMOUNT and
    ///         MAXIMUM_PARTICIPATION_AMOUNT are accepted. Otherwise the transaction
    ///         is rejected and contributed amount is returned to the participant's
    ///         account
    /// @notice A participant's contribution will be rejected if the presale
    ///         has been funded to the maximum amount
    function () payable {
        // A participant cannot send funds before the presale start date
        if (now < PRESALE_START_DATE) throw;
        // A participant cannot send funds after the presale end date
        if (now > PRESALE_END_DATE) throw;
        // A participant cannot send less than the minimum amount
        if (msg.value < MINIMUM_PARTICIPATION_AMOUNT) throw;
        // A participant cannot send more than the maximum amount
        if (msg.value > MAXIMUM_PARTICIPATION_AMOUNT) throw;
        // A participant cannot send funds if the presale has been reached the maximum
        // funding amount
        if (safeIncrement(totalFunding, msg.value) > PRESALE_MAXIMUM_FUNDING) throw;
        // Register the participant's contribution
        addBalance(msg.sender, msg.value);
    }

    /// @notice The owner can withdraw ethers already during presale,
    ///         only if the minimum funding level has been reached
    function ownerWithdraw(uint256 value) external onlyOwner {
        // The owner cannot withdraw if the presale did not reach the minimum funding amount
        if (totalFunding < PRESALE_MINIMUM_FUNDING) throw;
        // Withdraw the amount requested
        if (!owner.send(value)) throw;
    }

    /// @notice The participant will need to withdraw their funds from this contract if
    ///         the presale has not achieved the minimum funding level
    function participantWithdrawIfMinimumFundingNotReached(uint256 value) external {
        // Participant cannot withdraw before the presale ends
        if (now <= PRESALE_END_DATE) throw;
        // Participant cannot withdraw if the minimum funding amount has been reached
        if (totalFunding >= PRESALE_MINIMUM_FUNDING) throw;
        // Participant can only withdraw an amount up to their contributed balance
        if (balanceOf[msg.sender] < value) throw;
        // Participant's balance is reduced by the claimed amount.
        balanceOf[msg.sender] = safeDecrement(balanceOf[msg.sender], value);
        // Send ethers back to the participant's account
        if (!msg.sender.send(value)) throw;
    }

    /// @notice The owner can clawback any ethers after a date in the future, so no
    ///         ethers remain trapped in this contract. This will only be relevant
    ///         if the minimum funding level is not reached
    function ownerClawback() external onlyOwner {
        // The owner cannot withdraw before the clawback date
        if (now < OWNER_CLAWBACK_DATE) throw;
        // Send remaining funds back to the owner
        if (!owner.send(this.balance)) throw;
    }

    /// @dev Keep track of participants contributions and the total funding amount
    function addBalance(address participant, uint256 value) private {
        // Participant's balance is increased by the sent amount
        balanceOf[participant] = safeIncrement(balanceOf[participant], value);
        // Keep track of the total funding amount
        totalFunding = safeIncrement(totalFunding, value);
        // Log an event of the participant's contribution
        LogParticipation(participant, value, now);
    }

    /// @dev Throw an exception if the amounts are not equal
    function assertEquals(uint256 expectedValue, uint256 actualValue) private constant {
        if (expectedValue != actualValue) throw;
    }

    /// @dev Add a number to a base value. Detect overflows by checking the result is larger
    ///      than the original base value.
    function safeIncrement(uint256 base, uint256 increment) private constant returns (uint256) {
        uint256 result = base + increment;
        if (result < base) throw;
        return result;
    }

    /// @dev Subtract a number from a base value. Detect underflows by checking that the result
    ///      is smaller than the original base value
    function safeDecrement(uint256 base, uint256 increment) private constant returns (uint256) {
        uint256 result = base - increment;
        if (result > base) throw;
        return result;
    }
}
