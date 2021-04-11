pragma solidity 0.6.4;

import "../WafflePrivateSale.sol";

contract WafflePrivateSaleMock is WafflePrivateSale {

    constructor (IERC20 _token, address payable funding) public WafflePrivateSale(_token, funding) {
    }

    function mock_setSoftCapAndHardCap(uint256 mockSoftcap, uint256 mockHardcap) external {
        minimalGoal = mockSoftcap;
        hardCap = mockHardcap;
    }
}