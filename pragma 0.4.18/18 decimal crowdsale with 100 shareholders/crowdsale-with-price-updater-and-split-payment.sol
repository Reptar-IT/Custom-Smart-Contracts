pragma solidity ^0.4.18;
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
contract owned {
    address public owner;
    function owned() public {
        owner = msg.sender; // 0xEb1874f8b702AB8911ae64D36f6B34975afcc431;
    }
    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}
    //@title Crowdsale
    //@dev Crowdsale is a base contract for managing a token crowdsale,
    //allowing investors to purchase tokens with ether. 
    interface Tokener { 
        function transfer(address to, uint256 value) external ;
    }
contract ACrowdsale is owned {
  using SaveMath for uint256;
    Tokener public token;
    uint256 public crowdsaleEnd;
    uint256 public rate; 
    uint256 public weiRaised; 
    address[] public payees; 
    uint256 public duration; 
    uint256 public price; 
    uint256 public minimumBuy;
    uint256 public totalShares;
    uint256 internal maxShares;
    uint256 public totalReleased;
    uint256 public ethPrice;
    uint256 internal etherUnit;
    uint256 internal usdinWei;
    uint256 public minimumUSD;
    mapping(address => uint256) public shares;
    mapping(address => uint256) public released;
    //Event for token purchase logging
    //@param purchaser who paid for the tokens
    //@param beneficiary who got the tokens
    //@param value weis paid for purchase
    //@param amount amount of tokens purchased
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function ACrowdsale(uint _tokenUSD, uint _ethUSD, uint _minimumUSD) public {
        token = Tokener(0xD08F5A940C7890a9B8793a6a67Db5f2b6Fd2F0af); // insert token address here
        duration = 4320; // insert duration in coverted to minutes.
        etherUnit = 1000000000000000000 wei; // one ether in wei
        totalShares = 0;
        maxShares = 100;
        totalReleased = 0;
        minimumUSD = _minimumUSD;
        ethPrice = _ethUSD;
        price = _tokenUSD; //multiply your value by 100 before input example $0.01 = 1 . 
        usdinWei = etherUnit / ethPrice;
        rate = ((usdinWei * _tokenUSD) / maxShares)* 1 wei;
        minimumBuy = (usdinWei * minimumUSD) * 1 wei;
        crowdsaleEnd = now + duration * 1 minutes;
    }
    function priceChange(uint _tokenUSD, uint _ethUSD, uint _minimumUSD) public onlyOwner {
        price = _tokenUSD;
        ethPrice = _ethUSD;
        minimumUSD = _minimumUSD;
    }
    // Crowdsale external interface
    //@dev High level token purchase parameters ***DO NOT OVERRIDE***
    //@param _beneficiary Address performing the token purchase
    function saleParam(address _beneficiary) internal {
        _getMinimumBuy();
        uint256 weiAmount = msg.value;
        _preValidatePurchase(_beneficiary, weiAmount);
        uint256 tokens = _getpresaleTokenAmount(weiAmount);
        weiRaised = weiRaised.add(weiAmount);
        _processPurchase(_beneficiary, tokens);
        TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);
    }
    //@dev high level token purchase ***DO NOT OVERRIDE***
    function seller(address _beneficiary) public payable {
        if(now < crowdsaleEnd){
            saleParam(_beneficiary);
        } else revert();
    }
    //@dev crowdsale fallback function ***DO NOT OVERRIDE***
    function () external payable {
        seller(msg.sender);
    }
    //Internal interface (extensible)
    function _getpresaleTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        return (_weiAmount.div(rate)) * 1 ether;
    }
    function _getMinimumBuy()  internal view {
        require (msg.value >= minimumBuy);
    }
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view {
        require(_beneficiary == msg.sender);
        require(_weiAmount != 0);
    }
    function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
        token.transfer(_beneficiary, _tokenAmount);
    }
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        _deliverTokens(_beneficiary, _tokenAmount);
    }
    function setBeneficiaries(address[] _payees, uint256[] _shares) public payable {
            require(_payees.length == _shares.length);
            for (uint256 i = 0; i < _payees.length; i++) {
            addPayee(_payees[i], _shares[i]);
        }
    }
   //@dev Determines how ETH is stored can be claimed by beneficiary based on beneficiary's share.
    function claimFundsShare() public payable {
        address payee = msg.sender;
        require(shares[payee] > 0);
        uint256 totalReceived = address(this).balance.add(totalReleased);
        uint256 payment = totalReceived.mul(shares[payee]).div(maxShares).sub(released[payee]);
        require(payment != 0);
        require(address(this).balance >= payment);
        released[payee] = released[payee].add(payment);
        totalReleased = totalReleased.add(payment);
        payee.transfer(payment);
    }
    //@dev Add a new payee to the contract.
    //@param _payee The address of the payee to add.
    //@param _shares The number of shares owned by the payee must add up to 100 shares.
    function addPayee(address _payee, uint256 _shares) internal {
        require(totalShares < maxShares);
        require(_payee != address(0));
        require(_shares > 0);
        require(_shares <= (maxShares.sub(totalShares)));
        require(shares[_payee] == 0);
        payees.push(_payee);
        shares[_payee] = _shares;
        totalShares = totalShares.add(_shares);
    }
}