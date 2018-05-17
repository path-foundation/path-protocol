pragma solidity ^0.4.23;

import "openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol";
import "./Deputable.sol";

contract PathToken is StandardToken, Ownable, Deputable {
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor() public {
        name = "Path Token";
        symbol = "PATH";
        decimals = 6;
        totalSupply_ = 500000000 * 10 ** uint(decimals);
        balances[owner] = totalSupply_;
    }

    // Make sure nobody can send ETH directly to the token contract
    function () public payable {
        revert();
    }

    // Ability to retrieve other ERC20 tokens mistakenly sent to this contract
    function sendTokens(address _destination, address _token, uint _amount) public onlyOwnerOrDeputy returns (bool success) {
        return ERC20(_token).transfer(_destination, _amount);
    }
}