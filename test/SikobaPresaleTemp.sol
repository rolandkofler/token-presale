pragma solidity ^0.4.8;



























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
    uint256 public constant MINIMUM_PARTICIPATION_AMOUNT = 10 ether;
    uint256 public constant MAXIMUM_PARTICIPATION_AMOUNT = 1000 ether;

    // Minimum and maximum goals of the presale
    uint256 public constant PRESALE_MINIMUM_FUNDING = 1500 ether;
    uint256 public constant PRESALE_MAXIMUM_FUNDING = 2000 ether;

    // Total preallocation in wei
    uint256 public constant TOTAL_PREALLOCATION = 1400 ether;

    // Public presale period
    // Starts Apr 05 2017 @ 12:00pm (UTC) 2017-04-05T12:00:00+00:00 in ISO 8601
    // Ends 2 weeks after the start
    uint256 public constant PRESALE_START_DATE = 1489417569; // Mon 13 Mar 2017 15:06:09 UTC
    uint256 public constant PRESALE_END_DATE = 1489417869; // Mon 13 Mar 2017 15:11:09 UTC

    // Owner can clawback after a date in the future, so no ethers remain
    // trapped in the contract. This will only be relevant if the
    // minimum funding level is not reached
    // Jan 01 2018 @ 12:00pm (UTC) 2018-01-01T12:00:00+00:00 in ISO 8601
    uint256 public constant OWNER_CLAWBACK_DATE = 1489418109; // Mon 13 Mar 2017 15:15:09 UTC

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
        addBalance(0x0020017ba4c67f76c76b1af8c41821ee54f37171, 1000 ether);
        addBalance(0x0036f6addb6d64684390f55a92f0f4988266901b, 400 ether);
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

    /// @notice The owner can withdraw ethers after the presale has completed,
    ///         only if the minimum funding level has been reached
    function ownerWithdraw(uint256 value) external onlyOwner {
        // The owner cannot withdraw before the presale ends
        if (now <= PRESALE_END_DATE) throw;
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
