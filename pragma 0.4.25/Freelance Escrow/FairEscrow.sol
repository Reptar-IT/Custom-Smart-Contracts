pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) { 
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); //Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract Administratable {
  address public escrowAgent;
  address public RecoDaley;
  event AdministrationTransferred(address indexed previousEscrowAgent, address indexed newEscrowAgent);
  constructor () public {
    escrowAgent = 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca;
    RecoDaley = 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca;
   }
  modifier onlyEscrowAgent() {
    require(0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca == escrowAgent);
    _;
  }
  function transferAdministration(address newEscrowAgent) public onlyEscrowAgent {
    require(newEscrowAgent != address(0));
    escrowAgent = newEscrowAgent;
    emit AdministrationTransferred(escrowAgent, newEscrowAgent);
  }
}
contract EscrowEtherForRecoDaley is Administratable{
    using SafeMath for uint256;
    
    address public buyer;
    address public seller;
    address public agent;
    
    uint256 public escrowFee;
    uint256 public escrowedBalance;
    uint256 public duration;
    uint256 internal deadline;
    
    bool deadlineMet = false;
    bool escrowCompleted = false;
    bool escrowCanceled = false;
    bool agentSummoned = false;
    
    event EscrowCompleted(address indexed _employer, bool _escrowCompleted);
    event AgentSummoned(address indexed _escrowee, bool _agentSummoned, uint256 _serviceFeeInAdvance);
    event FeeTransfer(address indexed _RecoDaley, uint256 _serviceFee);
    event TransferPayment(address indexed _seller, uint256 _payment);
    event TransferRefundEscrowCanceled(address indexed _buyer, uint256 _funds, bool _escrowCanceled);
    
    constructor (address employee, uint256 agreedDays) public {
        agent = escrowAgent;
        buyer = msg.sender;
        seller = employee;
        duration = agreedDays;
        deadline = now + duration * 1 days;
        escrowFee = 0;
    }
    
    // set deadline modifier
    modifier deadlinePassed() { 
        if (now > deadline) { 
            deadlineMet = true;
        } 
        _;
    }
    
    function() payable public {
        if(deadlineMet) revert();
        uint amount = msg.value;
        escrowedBalance = escrowedBalance.add(amount);
        escrowFee = escrowFee.add(escrowedBalance * 10/100);
    }
    
    function cancelJob() public deadlinePassed {
        if(agentSummoned || escrowCompleted) revert();
        if(msg.sender == buyer) {
            uint256 funds = escrowedBalance;
            escrowedBalance = 0;
            escrowCanceled = true;
            buyer.transfer(funds);
            emit TransferRefundEscrowCanceled(msg.sender, funds, escrowCanceled);
        }
    }
    
    function completeJob() public {
        if(msg.sender == buyer || msg.sender == agent) {
            escrowCompleted = true;
            if(escrowFee != 0) {
                escrowedBalance = escrowedBalance.sub(escrowFee);
                uint256 serviceFee = escrowFee;
                escrowFee = 0;
                RecoDaley.transfer(serviceFee);
                emit FeeTransfer(msg.sender, serviceFee);
            }
            emit EscrowCompleted(msg.sender, escrowCompleted);
        }
    }
    
    function claimPayment() public {
        if(!escrowCompleted || escrowCanceled) revert();
        if(msg.sender == seller) {
            uint256 payment = escrowedBalance;
            escrowedBalance = 0;
            seller.transfer(payment);
            emit TransferPayment(msg.sender, payment);
        }
    }
    
    function summonAgent() public {
        if(deadlineMet || escrowCompleted) revert();
        if(msg.sender == buyer || msg.sender == seller) {
            uint256 serviceFeeInAdvance = escrowFee;
            escrowFee = 0;
            agentSummoned = true;
            RecoDaley.transfer(serviceFeeInAdvance);
            emit AgentSummoned(msg.sender, agentSummoned, serviceFeeInAdvance);
        }
    }
    
    function refundbuyer() public onlyEscrowAgent {
        if(!agentSummoned || escrowCompleted) revert();
        uint256 funds = escrowedBalance;
        escrowedBalance = 0;
        escrowCanceled = true;
        buyer.transfer(funds);
        emit TransferRefundEscrowCanceled(msg.sender, funds, escrowCanceled);
    }
    
}