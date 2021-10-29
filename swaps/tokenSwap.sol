pragma solidity ^0.8.0;

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
//give ownership to creator
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  constructor () {
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

interface Reptar { 
    function transfer(address to, uint256 value) external ;
}
contract Wrapper is Ownable {
 using SaveMath for uint256;
 Reptar public inputToken;
 Reptar public outputToken;
 Reptar public beneficiary;
 uint256 public inputTokenBalance;
 uint256 public outputTokenBalance; 
 uint256 public rate;
 uint256 public caughtNativeToken;
 
    event TokenPurchase(address indexed purchaser, uint256 amount);
    /* 
    * use setSwapParams to set an input token and output token to swap.
    * input tokens and output tokens must be sent to the newly created setSwapParams contract address
    * before swap can begin operation.
    */
    function setSwapParams(address _inputToken, address _outputToken) public {
        inputToken = Reptar(_inputToken);
        outputToken = Reptar(_outputToken);
        inputTokenBalance = 0;
        outputTokenBalance = 0;
        rate = 1;
        caughtNativeToken = 0;
    }
    //---------------------------------------------------------------------------
    // 
    //---------------------------------------------------------------------------
    /**
     * Convert an amount of input token_ to an equivalent amount of the output token
     *
     * @param token_ address of token to swap
     * @param amount amount of token to swap/receive
     */
    function swap(address token_, uint amount) external {
        // define address type as Reptar
        inputToken = Reptar(token_);
        require (amount != 0);
        require (inputToken != outputToken);
        require (outputTokenBalance >= amount);
        inputTokenBalance = inputTokenBalance.add(amount);
        outputTokenBalance = outputTokenBalance.sub(amount);
        uint256 outputTokenAmount = amount.div(rate);
        inputToken.transfer(msg.sender, outputTokenAmount);
        emit TokenPurchase(msg.sender, outputTokenAmount);
    }

    /**
     * Convert an amount of the output token to an equivalent amount of input token_
     *
     * @param token_ address of token to receive
     * @param amount amount of token to swap/receive
     */
    function unswap(address token_, uint amount) external {
        // define address type as Reptar
        outputToken = Reptar(token_);
        require (amount != 0);
        require (outputToken != inputToken);
        require (inputTokenBalance >= amount);
        outputTokenBalance = outputTokenBalance.add(amount);
        inputTokenBalance = inputTokenBalance.sub(amount);
        uint256 inputTokenAmount = amount.div(rate);
        outputToken.transfer(msg.sender, inputTokenAmount);
        emit TokenPurchase(msg.sender, inputTokenAmount);
    }
    
    //----------------------------------------------------------------------------
    // SAFETY MEASURES: CAN RECIEVE NATIVE COIN & WITHDRAW 
    //----------------------------------------------------------------------------
    
    // allow this contract to recieve native token "ether" in case of accidentally being sent.
    receive() external payable {
        uint amount = msg.value;
        caughtNativeToken = caughtNativeToken.add(amount);
    }
    
    // withdraw can only be called other functions within by this contract.
    function withdraw() external {
        require(owner == msg.sender);
        uint cash = caughtNativeToken;
        caughtNativeToken = 0;
        // define address type as Reptar
        beneficiary = Reptar(msg.sender);
        // transfer all ether to beneficiary address.
        beneficiary.transfer(msg.sender, cash);
        emit TokenPurchase(msg.sender, cash);
    }    
}
