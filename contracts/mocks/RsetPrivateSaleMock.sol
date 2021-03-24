pragma solidity 0.6.4;

import "../RsetPrivateSale.sol";

contract RsetPrivateSaleMock is RsetPrivateSale {

    constructor (IERC20 _token, address payable funding) public RsetPrivateSale(_token, funding) {
    }

    function mock_setSoftCapAndHardCap(uint256 mockSoftcap, uint256 mockHardcap) external {
        minimalGoal = mockSoftcap;
        hardCap = mockHardcap;
    }
}