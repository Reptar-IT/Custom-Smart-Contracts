
pragma solidity ^0.4.25;
//give ownership to creator
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () public {
    owner = msg.sender;
   }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
interface token {
    function transfer(address receiver, uint amount) external;
}

contract Crowdsale is Ownable {
    address public beneficiary;
    uint public fundingGoal;
    uint public amountRaised;
    uint public deadline;
    uint public price;
    uint public minimum;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;

    event GoalReached(address recipient, uint totalAmountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constructor function
     *
     * Setup the owner
     */
    constructor(
        address ifSuccessfulSendTo,
        uint fundingGoalInEthers,
        uint durationInMinutes,
        uint etherCostOfEachToken,
        uint minimumEtherAccepted,
        address addressOfTokenUsedAsReward
    ) public {
        beneficiary = ifSuccessfulSendTo;
        fundingGoal = fundingGoalInEthers * 1 ether;
        deadline = now + durationInMinutes * 1 minutes;
        price = etherCostOfEachToken / 1 wei;
        minimum = minimumEtherAccepted / 1 wei;
        tokenReward = token(addressOfTokenUsedAsReward);
    }
    // beneficiary 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca
    // fundingGoalInEthers 1
    // durationInMinutes 120
    // price 1000000000000000
    // minim 10000000000000000
    // tokenReward18 0x5899d197A4a647C7AfF2824B47Fc26ECcc28641c
    // tokenReward0 0xBdD6ba5eEAe13A458a0607a6Dcbcffb763348C63
    
    
    
    function priceChange(uint etherCostOfEachToken, uint minimumEtherAccepted) public onlyOwner {
        price = etherCostOfEachToken / 1 wei;
        minimum = minimumEtherAccepted / 1 wei;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        //require(msg.value >= minimum);
        //if(msg.value < minimum) revert();
        if(crowdsaleClosed) revert();
        uint amount = msg.value;
        balanceOf[msg.sender] += amount;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, amount / price);
       emit FundTransfer(msg.sender, amount, true);
    }
    
    

    modifier afterDeadline() { if (now >= deadline) _; }

    /**
     * Check if goal was reached
     *
     * Checks if the goal or time limit has been reached and ends the campaign
     */
    function checkGoalReached() public afterDeadline {
        if (amountRaised >= fundingGoal){
            fundingGoalReached = true;
            emit GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

    /**
     * Withdraw the funds
     *
     * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
     * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
     * the amount they contributed.
     */
    function safeWithdrawal() public afterDeadline {            // After the deadline.
        checkGoalReached();                                     // Checks is the funding goal was reached.
        if (!fundingGoalReached && beneficiary == msg.sender) { // If funding goal was not reached and Beneficiary is the caller.
            withdraw();                                         // Beneficiary is allowed withdraw funds raised to beneficiary's account.
            emit FundTransfer(beneficiary, amountRaised, false);     // Trigger and publicly log event. 
            } else {
                fundingGoalReached = true;                      // Funding goal was reached.
            }

        if (fundingGoalReached && beneficiary == msg.sender) {  // If funding goal was reached and Beneficiary is the caller.
            withdraw();                                         // Beneficiary is allowed withdraw funds raised to beneficiary's account.
            emit FundTransfer(beneficiary, amountRaised, false);     // Trigger and publicly log event.
            } else {
                fundingGoalReached = false;                     // Fund goal was not reached.
            }
    }
    
    function withdraw() internal {
        uint cash = amountRaised;
        amountRaised = 0;
        beneficiary.transfer(cash); // transfer all ether to beneficiary address.
    }
}
