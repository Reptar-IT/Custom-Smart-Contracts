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


contract EscrowEtherForRecoDaley {
    using SafeMath for uint256;
    
    address public buyer;
    address public seller;
    address public Admin;
    address public RecoDaley;
    
    uint256 public escrowFee;
    uint256 public escrowedBalance;
    uint256 public duration;
    uint256 internal deadline;
    
    bool public escrowCompleted = false;
    bool public escrowCanceled = false;
    bool public agentSummoned = false;
    
    event Transfer(address indexed _RecoDaley, uint256 _serviceFee, bool _escrowCompleted);
    event TransferPayment(address indexed _seller, uint256 _payment);
    
    constructor (address employee, uint256 agreedDays) public {
        buyer = msg.sender;
        seller = employee; //0x736052ea144977c0936d85e816610B06387D3239
        duration = agreedDays;
        deadline = now + duration * 1 minutes;
        escrowFee = 0;
        Admin = 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca;
        RecoDaley = 0xD58BaD4146A649a15d0620de3b5eE6A948A59336;
    }
    
    function() payable public {
        require(now < deadline);
        require(!escrowCanceled);
        require(!escrowCompleted);
        uint amount = msg.value;
        escrowedBalance = escrowedBalance.add(amount);
        escrowFee = escrowFee.add(escrowedBalance * 10/100);
    }
    
    function _sommonAgent() internal {
        require(escrowFee != 0);
        require(!escrowCompleted);
        require(!escrowCanceled);
        require(!agentSummoned);
        uint256 serviceFeeInAdvance = escrowFee;
        agentSummoned = true;
        RecoDaley.transfer(serviceFeeInAdvance);
        emit Transfer(msg.sender, serviceFeeInAdvance, agentSummoned);
    }
    
    function buyerSummonedAgent() public returns (bool success) {
        require(msg.sender == buyer);
        _sommonAgent();
        return true;
    }
    
    function sellerSummonedAgent() public returns (bool success) {
        require(msg.sender == seller);
        _sommonAgent();
        return true;
    }
    
    function buyerCompleteJob() public returns (bool success) {
        require(msg.sender == buyer);
        require(escrowFee != 0);
        escrowedBalance = escrowedBalance.sub(escrowFee);
        uint256 serviceFee = escrowFee;
        escrowFee = 0;
        escrowCompleted = true;
        RecoDaley.transfer(serviceFee);
        emit Transfer(msg.sender, serviceFee, escrowCompleted);
        return true;
    }
    
    function agentCompletedJob() public returns (bool success) {
        require(msg.sender == Admin);
        require(agentSummoned);
        require(escrowFee != 0);
        escrowedBalance = escrowedBalance.sub(escrowFee);
        escrowFee = 0;
        escrowCompleted = true;
        emit Transfer(msg.sender, escrowFee, escrowCompleted);
        return true;
    }
    
    function cancelJob() public returns (bool success) {
        require(msg.sender == buyer);
        require(now < deadline);
        require(!agentSummoned);
        require(!escrowCompleted);
        uint256 funds = escrowedBalance;
        escrowedBalance = 0;
        escrowCanceled = true;
        buyer.transfer(funds);
        emit Transfer(msg.sender, funds, escrowCanceled);
        return true;
    }
    
    function claimPayment() public returns (bool success) {
        require(msg.sender == seller);
        require(escrowCompleted);
        require(!escrowCanceled);
        uint256 payment = escrowedBalance;
        escrowedBalance = 0;
        seller.transfer(payment);
        emit TransferPayment(msg.sender, payment);
        return true;
    }
    
    function refundbuyer() public returns (bool success) {
        require(msg.sender == Admin);
        require(agentSummoned);
        require(!escrowCompleted);
        uint256 refund = escrowedBalance.sub(escrowFee);
        escrowedBalance = 0;
        escrowFee = 0;
        escrowCanceled = true;
        buyer.transfer(refund);
        emit Transfer(msg.sender, refund, escrowCanceled);
        return true;
    }
    
}