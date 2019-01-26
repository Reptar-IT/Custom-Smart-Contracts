pragma solidity ^0.4.25;

library SaveMath {
  //@dev Multiplies two numbers, throws on overflow.
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  //@dev Integer division of two numbers, truncating the quotient.
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  //@dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  //@dev Adds two numbers, throws on overflow.
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
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
interface TokenReward { 
    function transfer(address to, uint256 value) external;
    function balanceOf(address who) external view returns (uint256);
}
contract tokenLockUp is Ownable {
    using SaveMath for uint256;
    TokenReward public token;
    uint256 public lockUpEnd;
    uint256 public weiRaised; 
    address[] public payees; 
    uint256 public duration; 
    uint256 public totalShares;
    uint256 internal maxShares;
    uint256 public totalReleased;
    
    bool LockUpReleased = false;
    bool fundsAvailable = false;
  
    mapping(address => uint256) public shares;
    mapping(address => uint256) public released;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
  
  constructor (uint durationInMinutes, address addressOfTokenUsedAsReward) public {
        token = TokenReward(addressOfTokenUsedAsReward); // insert token address here
        duration = durationInMinutes; // insert duration in coverted to minutes.
        totalShares = 0;
        maxShares = 100;
        totalReleased = 0;
        lockUpEnd = now + duration * 1 minutes;
    }
    // set beneficiaries
    function setBeneficiaries(address[] _payees, uint256[] _shares) public payable {
        require(_payees.length == _shares.length);
    
        for (uint256 i = 0; i < _payees.length; i++) {
          addPayee(_payees[i], _shares[i]);
        }
    }
    // set lockup modifier
    modifier afterLockUpEnd() { if (now >= lockUpEnd) _; }
    //check if lockup is over
    function checkFundsAvailable() public afterLockUpEnd {
        fundsAvailable = true;
    }
    //@dev Determines how ETH is stored can be claimed by beneficiary based on beneficiary's share.
    function claimFundsShare() public afterLockUpEnd payable {
        require(fundsAvailable);
        address payee = msg.sender;
        require(shares[payee] > 0);
        uint256 tokenBalance = token.balanceOf(this);
        uint256 payment = tokenBalance.mul(shares[payee]).div(maxShares).sub(released[payee]);
        require(payment != 0);
        require(token.balanceOf(this) >= payment);
        released[payee] = released[payee].add(payment);
        totalReleased = totalReleased.add(payment);
        token.transfer(payee, payment);
    }
    // durationInMinutes 15
    // tokenReward18 0x5899d197A4a647C7AfF2824B47Fc26ECcc28641c
    // payee 0xf9fE46227013EFBcc0255b4CEd93192Fe2F6a097
    // payee 0x736052ea144977c0936d85e816610B06387D3239
    // payee 0x51a6ba2433bb06bD7317645E34eeb0EBA20E562D
    // payee 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca
    /**
   * @dev Add a new payee to the contract.
   * @param _payee The address of the payee to add.
   * @param _shares The number of shares owned by the payee must add up to 100 shares.
   */
   function addPayee(address _payee, uint256 _shares) public onlyOwner {
        require(totalShares < maxShares);
        require(_payee != address(0));
        require(_shares > 0);
        require(_shares <= (maxShares.sub(totalShares)));
        require(shares[_payee] == 0);
    
        payees.push(_payee);
        shares[_payee] = _shares;
        totalShares = totalShares.add(_shares);
    }
  
    /**
    * *********************
    * Reptar_IT 
    */ 
}