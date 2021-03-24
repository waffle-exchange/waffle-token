pragma solidity 0.6.4;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Demo is ERC20 {
    constructor () public ERC20("COIN", "COI") {
        _mint(msg.sender, 120000000000000000000000000);
    }
}