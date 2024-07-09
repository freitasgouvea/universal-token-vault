// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {Pausable} from "../lib/openzeppelin-contracts/contracts/utils/Pausable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

/**
* @title UniversalTokenVault contract
* @notice This contract holds the coins and regsiteredTokens deposited by the users
*/
contract UniversalTokenVault is Ownable, Pausable, ReentrancyGuard {
    bool public initialized;

    struct Token {
        bool active;
        bool hasAmount;
        uint8 amountParamIndex;
        bool hasId;
        uint8 idParamIndex;
    }

    mapping(address => Token) public regsiteredTokens;
    mapping(address => mapping(address => uint256)) public userTokenBalances;
    mapping(address => mapping(uint256 => address)) public userOwnerOf;
    mapping(address => mapping(uint256 => mapping(address => uint256))) public userOwnerOfBalance;

    event Initialized();
    event TokenRegistered(address indexed token);
    event TokenUnregistired(address indexed token);
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
    * @notice Active a token in the vault
    * @param _token The address of the token to be active
    */
    function activeToken(
        address _token, 
        bool _hasAmount, 
        uint8 _amountParameterIndex, 
        bool _hasId, 
        uint8 _idParameterIndex
    ) external onlyOwner {
        require(_token != address(0), "Vault: token address cannot be zero");
        require(!regsiteredTokens[_token].active, "Vault: token already active");

        regsiteredTokens[_token] = (Token(true, _hasAmount, _amountParameterIndex, _hasId, _idParameterIndex));
        
        emit TokenRegistered(_token);
    }

    /**
    * @notice Deposit regsiteredTokens into the vault
    * @dev This function can only be called when the vault is not paused
    * @param _token The address of the token to deposit
    * @param _data The encoded function call data
    */
    function deposit(address _token, bytes calldata _data) external whenNotPaused nonReentrant {
        require(regsiteredTokens[_token].active, "Vault: token not active");
        require(_token != address(0), "Vault: token address cannot be zero");
        require(_data.length >= 4, "Vault: data must contain a function selector");

        (bool success, bytes memory returnData) = _token.call(_data);
        require(success, _getRevertMsg(returnData));


        if (regsiteredTokens[_token].hasAmount && !regsiteredTokens[_token].hasId) {
            uint256 amount = _decodeAmount(_data, regsiteredTokens[_token].amountParamIndex);

            userTokenBalances[_token][msg.sender] += amount;

            emit Deposit(msg.sender, _token, _data, amount, 0);
        }

        if (!regsiteredTokens[_token].hasAmount && regsiteredTokens[_token].hasId) {
            uint256 id = _decodeId(_data, regsiteredTokens[_token].idParamIndex);

            userOwnerOf[_token][id] = msg.sender;

            emit Deposit(msg.sender, _token, _data, 0, id);
        }

        if (regsiteredTokens[_token].hasAmount && regsiteredTokens[_token].hasId) {
            uint256 amount = _decodeAmount(_data, regsiteredTokens[_token].amountParamIndex);
            uint256 id = _decodeId(_data, regsiteredTokens[_token].idParamIndex);

            userTokenBalances[_token][msg.sender] += amount;
            userOwnerOfBalance[_token][id][msg.sender] += amount;

            emit Deposit(msg.sender, _token, _data, amount, id);
        } 
    }

    /**
    * @notice Helper function to decode the amount from the function call data
    * @param _data The encoded function call data
    * @param _idParameterIndex The index of amount param
    * @return The decoded amount
    */
    function _decodeId(bytes calldata _data, uint8 _idParameterIndex) private pure returns (uint256) {
        require(_idParameterIndex < 6, "Vault: parameter index out of range");

        bytes4 selector;
        uint256 amount;

        assembly {
            selector := calldataload(_data.offset)
            amount := calldataload(add(_data.offset, add(0x04, mul(_idParameterIndex, 0x20))))
        }

        // Validate the selector if needed
        // require(selector == expectedSelector, "Vault: invalid function selector");

        return amount;
    }

    /**
    * @notice Helper function to decode the amount from the function call data
    * @param _data The encoded function call data
    * @param _amountParameterIndex The index of amount param
    * @return The decoded amount
    */
    function _decodeAmount(bytes calldata _data, uint8 _amountParameterIndex) private pure returns (uint256) {
        require(_amountParameterIndex < 6, "Vault: parameter index out of range");
    
        bytes4 selector;
        uint256 amount;
    
        assembly {
            selector := calldataload(_data.offset)
            amount := calldataload(add(_data.offset, add(0x04, mul(_amountParameterIndex, 0x20))))
        }
    
        // Validate the selector if needed
        // require(selector == expectedSelector, "Vault: invalid function selector");
    
        return amount;
    }

    /**
    * @notice Helper function to extract revert reason
    * @param _returnData The return data from the failed call
    * @return Revert reason string
    */
    function _getRevertMsg(bytes memory _returnData) private pure returns (string memory) {
        // If the _returnData length is less than 68, then the transaction failed silently (without a revert message)
        if (_returnData.length < 68) return 'Transaction reverted silently';
        
        assembly {
            // Slice the sighash.
            _returnData := add(_returnData, 0x04)
        }
        return abi.decode(_returnData, (string));
    }
}
