pragma solidity 0.6.4;

import "../node_modules/@openzeppelin/contracts/math/SafeMath.sol";
import '../node_modules/@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import "../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "../node_modules/@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../node_modules/@openzeppelin/contracts/utils/Address.sol";

contract WafflePrivateSale is ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using Address for address payable;

    mapping(address => uint256) participants;

    uint256 buyPrice;
    uint256 minimalGoal;
    uint256 hardCap;

    IERC20 crowdsaleToken;

    uint256 tokenDecimals = 18;

    event SellToken(address recepient, uint tokensSold, uint value);

    address payable fundingAddress;
    uint256 public totalCollected;
    uint256 totalSold;
    uint256 start;
    bool stopped = false;

    constructor(
        IERC20 _token,
        address payable _fundingAddress
    ) public {
        minimalGoal = 10000000000000000000;
        hardCap = 500000000000000000000;
        buyPrice = 125000000000000; // 0,000125 BNB
        crowdsaleToken = _token;
        fundingAddress = _fundingAddress;
        start = getTime();
    }

    function getToken()
    external
    view
    returns(address)
    {
        return address(crowdsaleToken);
    }

    receive() external payable {
        require(msg.value >= 500000000000000000, "Min 0.5 BNB");
        require(msg.value <= 5000000000000000000, "Min 5 BNB");
        sell(msg.sender, msg.value);
    }

    function sell(address payable _recepient, uint256 _value) internal
        nonReentrant
        whenCrowdsaleAlive()
    {
        uint256 newTotalCollected = totalCollected.add(_value);

        if (hardCap < newTotalCollected) {
            // Refund anything above the hard cap
            uint256 refund = newTotalCollected.sub(hardCap);
            uint256 diff = _value.sub(refund);
            _recepient.sendValue(refund);
            _value = diff;
            newTotalCollected = totalCollected.add(_value);
        }

        // Token amount per price
        uint256 tokensSold = (_value).mul(10 ** tokenDecimals).div(buyPrice);


        // Send user tokens
        require(crowdsaleToken.transfer(_recepient, tokensSold), "Error transfering");

        emit SellToken(_recepient, tokensSold, _value);

        // Save participants
        participants[_recepient] = participants[_recepient].add(_value);

        fundingAddress.sendValue(_value);

        // Update total BNB
        totalCollected = totalCollected.add(_value);

        // Update tokens sold
        totalSold = totalSold.add(tokensSold);
    }

  function totalTokensNeeded() external view returns (uint256) {
    return hardCap.mul(10 ** tokenDecimals).div(buyPrice);
  }

  function stop()
    external
    onlyOwner()
  {
        stopped = true;
  }

  function unstop()
    external
    onlyOwner()
  {
        stopped = false;
  }

  function returnUnsold()
    external
    nonReentrant
    onlyOwner()
  {
    crowdsaleToken.transfer(fundingAddress, crowdsaleToken.balanceOf(address(this)));
  }

  function getTime()
    public
    view
    returns(uint256)
  {
    return block.timestamp;
  }

  function isActive()
    public
    view
    returns(bool)
  {
    return (
      totalCollected < hardCap && !stopped
    );
  }

  function isSuccessful()
    public
    view
    returns(bool)
  {
    return (
      totalCollected >= minimalGoal
    );
  }

  modifier whenCrowdsaleAlive() {
    require(isActive());
    _;
  }

}