//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";
contract Vault {
    IRebaseToken private immutable i_rebaseToken;
    event Deposit(address indexed sender, uint256 amount);
    event Redeem(address indexed sender, uint256 amount);
    error Vault__RedeemFailed();
    constructor(IRebaseToken rebaseToken) {
        i_rebaseToken = rebaseToken;
    }
    function getRebaseTokenAddress() external view returns (address) {
        return address(i_rebaseToken);
    }
    receive() external payable {}
    function deposit() external payable{
        i_rebaseToken.mint(msg.sender, msg.value,i_rebaseToken.getInterestRate());
        emit Deposit(msg.sender,msg.value);
    }
    function redeem(uint256 _amount) external{
        if(_amount == type(uint256).max){
            _amount = i_rebaseToken.balanceOf(msg.sender);
        }
        i_rebaseToken.burn(msg.sender, _amount);
        (bool success,) = payable(msg.sender).call{value: _amount}("");
        if (!success) {
            revert Vault__RedeemFailed();
        }
        emit Redeem(msg.sender,_amount);
    }

}