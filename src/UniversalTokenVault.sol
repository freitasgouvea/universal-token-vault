// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
* @title UniversalTokenVault contract
* @notice This contract holds the coins and registered tokens deposited by the users
*/
contract UniversalTokenVault is Ownable, Pausable, ReentrancyGuard {
    bool public initialized;

    struct Token {
        bool active;
        bool hasAmount;
        bool hasId;
        bytes4 depositFunctionSignature;
        bytes4 withdrawFunctionSignature;
        uint8 amountParamIndexForDeposit;
        uint8 amountParamIndexForWithdraw;
        uint8 idParamIndexForDeposit;
        uint8 idParamIndexForWithdraw;
    }

    mapping(address => Token) public registeredTokens;
    mapping(address => mapping(address => uint256)) public userTokenBalances;
    mapping(address => mapping(uint256 => address)) public userOwnerOf;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public userOwnerOfBalance;

    event Initialized();
    event TokenRegistered(address indexed token);
    event TokenUnregistered(address indexed token);
    event Deposit(address indexed from, address indexed token, bytes data, uint256 amount, uint256 id);
    event Withdraw(address indexed to, address indexed token, bytes data, uint256 amount, uint256 id);

    /**
    * @notice Create a new vault
    * @dev The vault is paused by default
    * @dev The owner of the vault is the deployer
    */
    constructor() Ownable(msg.sender) {
        _pause();
    }

    /**
    * @notice Initialize the vault
    * @dev This function can only be called once
    */
    function initialize() external onlyOwner {
        require(!initialized, "Vault: already initialized");

        _unpause();
        initialized = true;

        emit Initialized();
    }

    /**
    * @notice Activate a token in the vault
    * @param _token The address of the token to be activated
    * @param _hasAmount If the token has an amount parameter
    * @param _hasId If the token has an ID parameter
    * @param _depositFunctionSignature The function signature for deposit
    * @param _withdrawFunctionSignature The function signature for withdraw
    * @param _amountParamIndexForDeposit The index of the amount parameter for deposit
    * @param _idParamIndexForDeposit The index of the ID parameter for deposit
    * @param _amountParamIndexForWithdraw The index of the amount parameter for withdraw
    * @param _idParamIndexForWithdraw The index of the ID parameter for withdraw
    */
    function activateToken(
        address _token, 
        bool _hasAmount, 
        bool _hasId, 
        bytes4 _depositFunctionSignature,
        bytes4 _withdrawFunctionSignature,
        uint8 _amountParamIndexForDeposit,
        uint8 _idParamIndexForDeposit,
        uint8 _amountParamIndexForWithdraw,
        uint8 _idParamIndexForWithdraw
    ) external onlyOwner {
        require(_token != address(0), "Vault: token address cannot be zero");
        require(!registeredTokens[_token].active, "Vault: token already active");
        require(_hasAmount || _hasId, "Vault: invalid token type");

        registeredTokens[_token] = Token(
            true, 
            _hasAmount, 
            _hasId,
            _depositFunctionSignature,
            _withdrawFunctionSignature,
            _amountParamIndexForDeposit,
            _idParamIndexForDeposit,
            _amountParamIndexForWithdraw,
            _idParamIndexForWithdraw
        );
        
        emit TokenRegistered(_token);
    }

    /**
    * @notice Deactivate a token in the vault
    * @param _token The address of the token to be deactivated
    */
    function deactivateToken(address _token) external onlyOwner {
        require(registeredTokens[_token].active, "Vault: token not active");

        registeredTokens[_token].active = false;

        emit TokenUnregistered(_token);
    }

    /**
    * @notice Deposit registered tokens into the vault
    * @dev This function can only be called when the vault is not paused
    * @param _token The address of the token to deposit
    * @param _data The encoded function call data
    */
    function deposit(address _token, bytes calldata _data) external whenNotPaused nonReentrant {
        require(registeredTokens[_token].active, "Vault: token not active");
        require(_token != address(0), "Vault: token address cannot be zero");
        require(_data.length >= 4, "Vault: data must contain a function selector");

        // todo: verify function signature
        (bool success, bytes memory returnData) = _token.call(_data);
        require(success, _getRevertMsg(returnData));

        if (registeredTokens[_token].hasAmount && !registeredTokens[_token].hasId) {
            uint256 amount = _decodeAmount(_data, registeredTokens[_token].amountParamIndexForDeposit);

            userTokenBalances[_token][msg.sender] += amount;

            emit Deposit(msg.sender, _token, _data, amount, 0);
        }

        if (!registeredTokens[_token].hasAmount && registeredTokens[_token].hasId) {
            uint256 id = _decodeId(_data, registeredTokens[_token].idParamIndexForDeposit);

            userOwnerOf[_token][id] = msg.sender;

            emit Deposit(msg.sender, _token, _data, 0, id);
        }

        if (registeredTokens[_token].hasAmount && registeredTokens[_token].hasId) {
            uint256 amount = _decodeAmount(_data, registeredTokens[_token].amountParamIndexForDeposit);
            uint256 id = _decodeId(_data, registeredTokens[_token].idParamIndexForDeposit);

            userTokenBalances[_token][msg.sender] += amount;
            userOwnerOfBalance[_token][id][msg.sender] += amount;

            emit Deposit(msg.sender, _token, _data, amount, id);
        } 
    }

    /**
    * @notice Withdraw tokens from the vault
    * @dev This function can only be called by the owner
    * @dev This function can only be called when the vault is not paused
    * @param _token The address of the token to withdraw
    * @param _data The encoded function call data
    */
    function withdraw(address _token, bytes calldata _data) external onlyOwner whenNotPaused nonReentrant {
        require(registeredTokens[_token].active, "Vault: token not active");
        require(_token != address(0), "Vault: token address cannot be zero");
        require(_data.length >= 4, "Vault: data must contain a function selector");

        uint256 amount = 0;
        uint256 id = 0;

        if (registeredTokens[_token].hasAmount && !registeredTokens[_token].hasId) {
            amount = _decodeAmount(_data, registeredTokens[_token].amountParamIndexForWithdraw);
            require(userTokenBalances[_token][msg.sender] >= amount, "Vault: insufficient balance");

            userTokenBalances[_token][msg.sender] -= amount;
        }

        if (!registeredTokens[_token].hasAmount && registeredTokens[_token].hasId) {
            id = _decodeId(_data, registeredTokens[_token].idParamIndexForWithdraw);
            require(userOwnerOf[_token][id] == msg.sender, "Vault: not the owner of the token ID");

            userOwnerOf[_token][id] = address(0);
        }

        if (registeredTokens[_token].hasAmount && registeredTokens[_token].hasId) {
            require(userOwnerOfBalance[_token][id][msg.sender] >= amount, "Vault: insufficient balance for token ID");

            userOwnerOfBalance[_token][id][msg.sender] -= amount;
        }

        // todo: verify function signature
        (bool success, bytes memory returnData) = _token.call(_data);
        require(success, _getRevertMsg(returnData));

        emit Withdraw(msg.sender, _token, _data, amount, id);
    }

    /**
    * @notice Get the balance of a specific token for a specific user
    * @param _user The address of the user
    * @param _token The address of the token
    * @return The balance of the token for the user
    */
    function getUserTokenBalance(address _user, address _token) external view returns (uint256) {
        return userTokenBalances[_token][_user];
    }

    /**
    * @notice Get the owner of a specific token ID for a specific token
    * @param _token The address of the token
    * @param _id The ID of the token
    * @return The owner address of the token ID
    */
    function getOwnerOfTokenId(address _token, uint256 _id) external view returns (address) {
        return userOwnerOf[_token][_id];
    }

    /**
    * @notice Get the balance of a specific token ID for a specific user
    * @param _user The address of the user
    * @param _token The address of the token
    * @param _id The ID of the token
    * @return The balance of the token ID for the user
    */
    function getUserBalanceOfTokenId(address _user, address _token, uint256 _id) external view returns (uint256) {
        return userOwnerOfBalance[_token][_id][_user];
    }

    /**
    * @notice Helper function to decode the amount from the function call data
    * @param _data The encoded function call data
    * @param _paramIndex The index of the amount parameter
    * @return The decoded amount
    */
    function _decodeAmount(bytes calldata _data, uint8 _paramIndex) private pure returns (uint256) {
        require(_paramIndex < 6, "Vault: parameter index out of range");
    
        bytes4 selector;
        uint256 amount;
    
        assembly {
            selector := calldataload(_data.offset)
            amount := calldataload(add(_data.offset, add(0x04, mul(_paramIndex, 0x20))))
        }
    
        return amount;
    }

    /**
    * @notice Helper function to decode the ID from the function call data
    * @param _data The encoded function call data
    * @param _paramIndex The index of the ID parameter
    * @return The decoded ID
    */
    function _decodeId(bytes calldata _data, uint8 _paramIndex) private pure returns (uint256) {
        require(_paramIndex < 6, "Vault: parameter index out of range");

        bytes4 selector;
        uint256 id;

        assembly {
            selector := calldataload(_data.offset)
            id := calldataload(add(_data.offset, add(0x04, mul(_paramIndex, 0x20))))
        }

        return id;
    }

    /**
    * @notice Helper function to extract revert reason
    * @param _returnData The return data from the failed call
    * @return Revert reason string
    */
    function _getRevertMsg(bytes memory _returnData) private pure returns (string memory) {
        if (_returnData.length < 68) return 'Transaction reverted silently';
        
        assembly {
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }
}
