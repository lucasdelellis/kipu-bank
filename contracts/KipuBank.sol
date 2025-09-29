// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

/**
 * @title KipuBank
 * @author lucasdelellis
 * @notice This contract implements a simple bank system where users can deposit and withdraw ETH.
 * @dev The contract has a maximum cap on the total ETH it can hold and a maximum withdrawal limit per transaction.
 */
contract KipuBank {
    /*///////////////////////////////////
            State variables
    ///////////////////////////////////*/
    /**
     * @dev Mapping to store the balance of each user.
     */
    mapping(address user => uint256 balance) private s_balances;

    /**
     * @dev Counter for the number of deposits made.
     */
    uint256 public s_depositCount;

    /**
     * @dev Counter for the number of withdrawals made.
     */
    uint256 public s_withdrawalCount;

    /**
     * @dev Maximum amount that can be withdrawn in a single transaction.
     */
    uint256 immutable public i_maxWithdrawal;

    /**
     * @dev Maximum total ETH the contract can hold.
     */
    uint256 immutable public i_bankCap;

    /*///////////////////////////////////
                Events
    ///////////////////////////////////*/
    /**
     * @dev Emitted when a deposit is received.
     * @param user The address of the user who made the deposit.
     * @param amount The amount of ETH deposited.
     */
    event KipuBank_DepositReceived(address user, uint256 amount);

    /**
     * @dev Emitted when a withdrawal is made.
     * @param user The address of the user who made the withdrawal.
     * @param amount The amount of ETH withdrawn.
     */
    event KipuBank_WithdrawalMade(address user, uint256 amount);

    /*///////////////////////////////////
                Errors
    ///////////////////////////////////*/
    /**
     * @dev Reverted when the contract's balance cap is reached.
     * @param maxContractBalance The maximum balance the contract can hold.
     * @param currentBalance The current balance of the contract.
     * @param transactionAmount The amount of ETH of the deposit.
     */
    error KipuBank_BankCapReached(uint256 maxContractBalance, uint256 currentBalance, uint256 transactionAmount);

    /**
     * @dev Reverted when the user does not have enough balance to withdraw.
     * @param balance The current balance of the user.
     * @param amount The amount the user tried to withdraw.
     */
    error KipuBank_NotEnoughBalance(uint256 balance, uint256 amount);

    /**
     * @dev Reverted when the withdrawal amount exceeds the maximum allowed per transaction.
     * @param maxAmountPerWithdrawal The maximum amount allowed per withdrawal.
     * @param amount The amount the user tried to withdraw.
     */
    error KipuBank_TooMuchWithdrawal(uint256 maxAmountPerWithdrawal, uint256 amount);

    /**
     * @dev Reverted when the ETH transfer fails.
     * @param error The error message from the failed transfer.
     */
    error KipuBank_TransferFailed(bytes error);

    /**
     * @dev Reverted when the fallback function is called.
     */
    error KipuBank_FallbackNotAllowed();

    /*///////////////////////////////////
                Modifiers
    ///////////////////////////////////*/
    /**
     * @dev Modifier to check if the user has enough balance to withdraw the specified amount.
     * @param _amount The amount to withdraw.
     */
    modifier hasEnoughBalance(uint256 _amount) {
        if (_amount > i_maxWithdrawal) {
            revert KipuBank_TooMuchWithdrawal(i_maxWithdrawal, _amount);
        }

        if (s_balances[msg.sender] < _amount) {
            revert KipuBank_NotEnoughBalance(s_balances[msg.sender], _amount);
        }
        _;
    }

    /*/////////////////////////
            constructor
    /////////////////////////*/
    /**
     * @dev Constructor to initialize the contract with the maximum bank cap and maximum withdrawal limit.
     * @param _bankCap The maximum total ETH the contract can hold.
     * @param _maxWithdrawal The maximum amount that can be withdrawn in a single transaction.
     */
    constructor(uint256 _bankCap, uint256 _maxWithdrawal) {
        i_maxWithdrawal = _maxWithdrawal;
        i_bankCap = _bankCap;
    }

    /*/////////////////////////
        Receive&Fallback
    /////////////////////////*/
    /**
     * @dev Receive function to deposit ETH.
     */
    receive() external payable {
        _deposit(msg.sender, msg.value);    
    }

    /**
     * @dev Fallback function to prevent accidental ETH transfers.
     */
    fallback() external payable { 
        revert KipuBank_FallbackNotAllowed();
    }

    /*/////////////////////////
            external
    /////////////////////////*/
    /**
     * @dev Function to deposit ETH into the contract.
     */
    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    /**
     * @dev Function to withdraw ETH from the contract.
     * @param _amount The amount of ETH to withdraw.
     */
    function withdraw(uint256 _amount) external hasEnoughBalance(_amount) {
        // No se verifica que el contrato tenga suficiente balance porque no es un escenario valido. 

        s_withdrawalCount += 1;
        s_balances[msg.sender] -= _amount;

        _transferEth(payable(msg.sender), _amount);

        emit KipuBank_WithdrawalMade(msg.sender, _amount);
    }

    /*/////////////////////////
            private
    /////////////////////////*/
    /**
     * @dev Function to check if the deposit exceeds the bank cap.
     * @param _amount The amount to deposit.
     * @return bool True if the deposit exceeds the bank cap, false otherwise.
     */
    function _exceedsBankCap(uint256 _amount) private view returns (bool) {
        return (address(this).balance + _amount) > i_bankCap;
    }

    /**
     * @dev Function to transfer ETH to a recipient.
     * @param _recipient The address of the recipient.
     * @param _amount The amount of ETH to transfer.
     */
    function _transferEth(address payable _recipient, uint256 _amount) private {
        (bool success, bytes memory error) = _recipient.call{value: _amount}("");

        if (!success) revert KipuBank_TransferFailed(error);
    }

    /**
     * @dev Function to deposit ETH into the contract.
     * @param _from The address of the user making the deposit.
     * @param _amount The amount of ETH to deposit.
     */
    function _deposit(address _from, uint256 _amount) private {
        if (_exceedsBankCap(_amount)) {
            revert KipuBank_BankCapReached(i_bankCap, address(this).balance, _amount);
        }

        s_depositCount += 1;
        s_balances[_from] += _amount;
        emit KipuBank_DepositReceived(_from, _amount);
    }

    /*/////////////////////////
        View & Pure
    /////////////////////////*/
    /**
     * @dev Function to get the balance of the caller.
     * @return uint256 The balance of the caller.
     */
    function getBalance() external view returns (uint256) {
        return s_balances[msg.sender];
    }
}