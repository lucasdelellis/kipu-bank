// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @author lucasdelellis
 */
contract KipuBank {
    /*///////////////////////////////////
            Type declarations
    ///////////////////////////////////*/

    /*///////////////////////////////////
            State variables
    ///////////////////////////////////*/
    mapping(address user => uint256 balance) private s_balances;
    uint256 internal s_depositAmount;
    uint256 internal s_withdrawalAmount;
    uint256 immutable public i_maxAmountPerWithdrawal;
    uint256 immutable public i_maxContractBalance;

    /*///////////////////////////////////
                Events
    ///////////////////////////////////*/
    event KipuBank_DepositReceived(address user, uint256 amount);
    event KipuBank_WithdrawalMade(address user, uint256 amount);

    /*///////////////////////////////////
                Errors
    ///////////////////////////////////*/
    error KipuBank_MaxContractBalanceReached(uint256 maxContractBalance, uint256 currentBalance);
    error KipuBank_NotEnoughBalance(uint256 balance, uint256 amount);
    error KipuBank_TooMuchWithdrawal(uint256 maxAmountPerWithdrawal, uint256 amount);
    error KipuBank_WithdrawalFailed(bytes error);

    /*///////////////////////////////////
                Modifiers
    ///////////////////////////////////*/

    /*///////////////////////////////////
                Functions
    ///////////////////////////////////*/

    /*/////////////////////////
            constructor
    /////////////////////////*/
    constructor(uint256 _maxContractBalance, uint256 _maxAmountPerWithdrawal) {
        i_maxAmountPerWithdrawal = _maxAmountPerWithdrawal;
        i_maxContractBalance = _maxContractBalance;
    }

    /*/////////////////////////
        Receive&Fallback
    /////////////////////////*/

    /*/////////////////////////
            external
    /////////////////////////*/
    function deposit() external payable {
        if (address(this).balance >= i_maxContractBalance) {
            revert KipuBank_MaxContractBalanceReached(i_maxContractBalance, address(this).balance);
        }

        s_depositAmount += 1;
        s_balances[msg.sender] += msg.value;
        emit KipuBank_DepositReceived(msg.sender, msg.value);
    }

    function withdrawal(uint256 _amount) external {
        if (_amount > i_maxAmountPerWithdrawal) {
            revert KipuBank_TooMuchWithdrawal(i_maxAmountPerWithdrawal, _amount);
        }

        if (s_balances[msg.sender] < _amount) {
            revert KipuBank_NotEnoughBalance(s_balances[msg.sender], _amount);
        }

        s_depositAmount += 1;
        s_balances[msg.sender] -= _amount;

        (bool success, bytes memory error) = msg.sender.call{value: _amount}("");

        if (!success) {
            revert KipuBank_WithdrawalFailed(error);
        }

        emit KipuBank_DepositReceived(msg.sender, _amount);
    }

    /*/////////////////////////
            public
    /////////////////////////*/

    /*/////////////////////////
            internal
    /////////////////////////*/

    /*/////////////////////////
            private
    /////////////////////////*/

    /*/////////////////////////
        View & Pure
    /////////////////////////*/
    function getBalance() external view returns (uint256 balance_) {
        balance_ = s_balances[msg.sender];
    }
}