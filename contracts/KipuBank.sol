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
    uint256 public s_depositCount;
    uint256 public s_withdrawalCount;
    uint256 immutable public i_maxWithdrawal;
    uint256 immutable public i_bankCap;

    /*///////////////////////////////////
                Events
    ///////////////////////////////////*/
    event KipuBank_DepositReceived(address user, uint256 amount);
    event KipuBank_WithdrawalMade(address user, uint256 amount);

    /*///////////////////////////////////
                Errors
    ///////////////////////////////////*/
    error KipuBank_BankCapReached(uint256 maxContractBalance, uint256 currentBalance);
    error KipuBank_NotEnoughBalance(uint256 balance, uint256 amount);
    error KipuBank_TooMuchWithdrawal(uint256 maxAmountPerWithdrawal, uint256 amount);
    error KipuBank_TransferFailed(bytes error);
    error KipuBank_FallbackNotAllowed();

    /*///////////////////////////////////
                Modifiers
    ///////////////////////////////////*/
    modifier hasEnoughBalance(uint256 _amount) {
        if (_amount > i_maxWithdrawal) {
            revert KipuBank_TooMuchWithdrawal(i_maxWithdrawal, _amount);
        }

        if (s_balances[msg.sender] < _amount) {
            revert KipuBank_NotEnoughBalance(s_balances[msg.sender], _amount);
        }
        _;
    }

    /*///////////////////////////////////
                Functions
    ///////////////////////////////////*/

    /*/////////////////////////
            constructor
    /////////////////////////*/
    constructor(uint256 _bankCap, uint256 _maxWithdrawal) {
        i_maxWithdrawal = _maxWithdrawal;
        i_bankCap = _bankCap;
    }

    /*/////////////////////////
        Receive&Fallback
    /////////////////////////*/
    receive() external payable {
        _deposit(msg.sender, msg.value);    
    }

    fallback() external payable { 
        revert KipuBank_FallbackNotAllowed();
    }

    /*/////////////////////////
            external
    /////////////////////////*/
    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external hasEnoughBalance(_amount) {
        // No se verifica que el contrato tenga suficiente balance porque no es un escenario valido. 

        s_withdrawalCount += 1;
        s_balances[msg.sender] -= _amount;

        _transferEth(payable(msg.sender), _amount);

        emit KipuBank_WithdrawalMade(msg.sender, _amount);
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
    function _exceedsBankCap(uint256 _amount) private view returns (bool) {
        return (address(this).balance + _amount) > i_bankCap;
    }

    function _transferEth(address payable _recipient, uint256 _amount) private {
        (bool success, bytes memory error) = _recipient.call{value: _amount}("");

        if (!success) revert KipuBank_TransferFailed(error);
    }

    function _deposit(address _from, uint256 _amount) private {
        if (_exceedsBankCap(_amount)) {
            revert KipuBank_BankCapReached(i_bankCap, address(this).balance + _amount);
        }

        s_depositCount += 1;
        s_balances[_from] += _amount;
        emit KipuBank_DepositReceived(_from, _amount);
    }

    /*/////////////////////////
        View & Pure
    /////////////////////////*/
    function getBalance() external view returns (uint256) {
        return s_balances[msg.sender];
    }
}