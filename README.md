# UniversalTokenVault

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Solidity](https://img.shields.io/badge/solidity-%5E0.8.20-lightgrey.svg)
![Status](https://img.shields.io/badge/status-WIP-red.svg)

UniversalTokenVault is a versatile smart contract that allows users to deposit and withdraw various types of tokens (ERC20, ERC721, ERC1155 and Custom Tokens) with ease. This project aims to provide a unified interface for managing multiple token standards, ensuring security and flexibility.

> **Disclaimer:** This code is for testing purposes only. For now it is not recommended to use this in production, it is under development (WIP) and has not been audited. Use at your own risk.

## 📚 Table of Contents

- [Overview](#🌟-overview)
- [Features](#✨-features)
- [Security Features](#🛡️-security-features)
- [Limitations](#🚫-limitations)
- [Getting Started](#🚀-getting-started)
- [Smart Contract Structure](#📜-smart-contract-structure)
- [Running Tests](#🧪-running-tests)
- [Usage](#🧐-usage)
- [Scripts](#👨‍💻-scripts)
- [Findings](#🕵-findings)
- [Alternative Approach](#🛣-alternative-approach)
- [License](#license)

## 🌟 Overview

UniversalTokenVault is designed to handle various token standards with custom function signatures for deposits and withdrawals. The contract maintains user balances and ownership of tokens, providing a flexible and secure solution for token management.

## ✨ Features

- **Multi-token support:** Handle ERC20, ERC721, ERC1155 and Custom Tokens.
- **Custom function signatures:** Store and verify function signatures for deposits and withdrawals.
- **Flexible parameter indexing:** Configure different parameter indices for each token type.

## 🛡️ Security Features

- **ReentrancyGuard:** Prevents reentrancy attacks.
- **Pausable:** Allows the contract to be paused in case of emergencies.
- **Ownable:** Restricts certain functions to the contract owner.
- **Function Signature Verification:** Ensures that the registered token functions for deposits and withdraws are correctly called.
- **Safe Deposit**: Validates and decodes the address used in field `from` to only allow deposits from owner and the address used in field `to` to only allow deposits to vault.
- **Safe Withdraw**: Validates and decodes the address used in field `to` to only allow withdraws to owner and the address used in field `from` to only allow withdeaws from vault.
- **Amount and/or Id Verification:** Validates and decodes the `amount` and `id` parameters for deposits and withdrawals.

## 🚫 Limitations

While the `UniversalTokenVault` contract offers significant flexibility and security, it also has some limitations:

- **Complexity in Registration**: The process of registering different types of tokens with varying function signatures and parameter indices can be complex and error-prone.
- **Gas Efficiency**: The additional checks and decoding processes may lead to higher gas consumption, especially for complex token transactions.
- **Custom Token Functions**: Support for custom token functions requires precise configuration and testing to ensure compatibility and security.
- **Single Contract Limitations**: Managing multiple token standards within a single contract may lead to challenges in maintenance and upgrades.
- **Three tokens patters**: This contract is only able to handle tokens that have some similiarities with the three major tokens patterns (fungilble, non-fungible and semi-fungible).

## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) - Ethereum development environment
- [Node.js](https://nodejs.org/) and [npm](https://www.npmjs.com/)

### Installation

1. Clone the repository:

   ```sh
   git clone https://github.com/yourusername/UniversalTokenVault.git
   cd UniversalTokenVault
   ```

2. Compile the contracts:

   ```sh
   forge build
   ```

## 📜 Smart Contract Structure

### Initialization

- `initialize()`: Initializes the vault, enabling it for use. This function can only be called once by the owner.

### Token Activation and Deactivation

- `activateToken(address _token, bool _hasAmount, bool _hasId, bytes4 _depositFunctionSignature, bytes4 _withdrawFunctionSignature, uint8 _fromParamIndexForDeposit, uint8 _toParamIndexForDeposit, uint8 _amountParamIndexForDeposit, uint8 _idParamIndexForDeposit, uint8 _fromParamIndexForWithdraw, uint8 _toParamIndexForWithdraw, uint8 _amountParamIndexForWithdraw, uint8 _idParamIndexForWithdraw)`: Registers a token in the vault with specific parameters.
  - `_token`: The address of the token to be activated.
  - `_hasAmount`: Indicates if the token has an amount parameter.
  - `_hasId`: Indicates if the token has an ID parameter.
  - `_depositFunctionSignature`: The function signature for deposit.
  - `_withdrawFunctionSignature`: The function signature for withdrawal.
  - `_fromParamIndexForDeposit`: The index of the from parameter for deposit.
  - `_toParamIndexForDeposit`: The index of the from parameter for deposit.
  - `_amountParamIndexForDeposit`: The index of the amount parameter for deposit.
  - `_idParamIndexForDeposit`: The index of the ID parameter for deposit.
  - `_fromParamIndexForWithdraw`: The index of the to parameter for withdrawal.
  - `_toParamIndexForWithdraw`: The index of the to parameter for withdrawal.
  - `_amountParamIndexForWithdraw`: The index of the amount parameter for withdrawal.
  - `_idParamIndexForWithdraw`: The index of the ID parameter for withdrawal.

- `deactivateToken(address _token)`: Deactivates a previously registered token, preventing further deposits and withdrawals.

### Deposit and Withdraw

- `deposit(address _token, bytes calldata _data)`: Allows users to deposit registered tokens into the vault. The function decodes the provided data to extract the amount and/or ID parameters as needed, updates the user's balance, and calls the specified deposit function on the token contract.
- `withdraw(address _token, bytes calldata _data)`: Allows users to withdraw tokens from the vault. The function decodes the provided data to extract the amount and/or ID parameters, checks the user's balance, updates the balance, and calls the specified withdraw function on the token contract.

### Helper Functions

- `_verifyFunctionSignature(bytes4 _storedSignature, bytes calldata _data)`: Compares the stored function signature with the calldata selector to verify the function being called.
- `_decodeAmount(bytes calldata _data, uint8 _paramIndex)`: Decodes the amount parameter from the provided data based on the specified parameter index.
- `_decodeId(bytes calldata _data, uint8 _paramIndex)`: Decodes the ID parameter from the provided data based on the specified parameter index.
- `_getRevertMsg(bytes memory _returnData)`: Extracts the revert reason from the return data of a failed call.

### View Functions

- `getUserTokenBalance(address _user, address _token)`: Returns the balance of a specific token for a user.
- `getOwnerOfTokenId(address _token, uint256 _id)`: Returns the owner of a specific token ID.
- `getUserBalanceOfTokenId(address _user, address _token, uint256 _id)`: Returns the balance of a specific token ID for a user.

### ERC1155 Receiver Functions

These functions are implemented to allow the vault to receive ERC1155 tokens directly:

- `onERC1155Received(...)`: Handles the receipt of single ERC1155 token transfers.
- `onERC1155BatchReceived(...)`: Handles the receipt of batch ERC1155 token transfers.

## 🧪 Running Tests

1. Compile the smart contract:
    ```bash
    forge build
    ```

2. Run tests:
    ```bash
    forge test
    ```
    
## 🧐 Usage

To use the `UniversalTokenVault` contract, follow these steps:

1. **Deployment**: Deploy the contract and initialize it by calling the `initialize()` function.
2. **Token Registration**: Register the tokens you want to manage by calling the `activateToken()` function with the appropriate parameters.
3. **Deposits and Withdrawals**: Users can deposit tokens into the vault using the `deposit()` function and withdraw tokens using the `withdraw()` function.

## 👨‍💻 Scripts

To deploy and test the UniversalTokenVault contract using Foundry, follow these steps:

### 1. Deploy the Vault Contract

```sh
forge script script/Deploy.s.sol --rpc-url chain-rpc-url --private-key your-private-key --broadcast
```

### 2. Deploy and Register Tokens

```sh
forge script script/RegisterTokens.s.sol --rpc-url chain-rpc-url --private-key your-private-key --sig "run(address)" <vaultAddress> --broadcast
```

### 3. Deposit Tokens

```sh
forge script script/Deposit.s.sol --rpc-url chain-rpc-url --private-key your-private-key --sig "run(address,address,address,address)" <vaultAddress> <erc20Address> <erc721Address> <erc1155Address> --broadcast
```

### 4. Withdraw Tokens

```sh
forge script script/Withdraw.s.sol --rpc-url chain-rpc-url --private-key your-private-key --sig "run(address,address,address,address)" <vaultAddress> <erc20Address> <erc721Address> <erc1155Address> --broadcast
```

## 🕵 Findings

During the development and testing of the `UniversalTokenVault` contract, the following issues and considerations were identified:

### **ERC20 Withdrawal Mechanism**:

- **Issue**: The initial approach using transfer function for ERC20 rely on verify from address and transferFrom withdrawals required an allowance, even though the contract was the owner.
- **Solution**: Modified the approach to ensure withdrawals are handled correctly without relying on withdraw for ERC20 tokens.

### **ERC1155 Token Handling**:

- **Issue**: The contract initially lacked support for handling ERC1155 tokens.
- **Solution**: Added `onERC1155Received` and `onERC1155BatchReceived` functions to handle the receipt of ERC1155 tokens.

### **Generic Token Handling**:

- **Issue**: The need to support various token standards (ERC20, ERC721, ERC1155) and custom tokens introduced complexity in function signatures and parameter indices.
- **Solution**: Implemented a flexible system to register tokens with customizable deposit and withdrawal function signatures and parameter indices.

### **Security Checks**:

- **Issue**: Ensuring deposits and withdrawals are only executed with the correct from and to addresses.
- **Solution**: Added checks to verify that tokens are deposited to the vault and withdrawn by the rightful owner.

### **Function Signature Verification**:

- **Issue**: Ensuring that the provided calldata matches the registered function signatures.
- **Solution**: Implemented a helper function _verifyFunctionSignature to compare stored signatures with calldata selectors.

### **Parameter Decoding**:

- **Issue**: Correctly decoding addresses and uint256 parameters from the calldata for deposits and withdrawals.
- **Solution**: Added helper functions _decodeAddressFromData and _decodeUintFromData for accurate decoding based on parameter indices.

### **Struct Token Parameters**:

- **Issue**: The `Token` struct has a large number of parameters, which can lead to complexity in managing and registering tokens.
- **Solution**: While this is a current limitation, future iterations could look into optimizing or simplifying the struct parameters to reduce complexity.

### **Security Issues Related to Calldata**:

- **Issue**: Calldata can be manipulated by users, which might lead to vulnerabilities if not properly validated. The contract relies on decoding calldata to extract parameters, and if the calldata format is incorrect, it could result in unexpected behaviors.
- **Solution**: Implement strict validation checks and require precise encoding to mitigate risks associated with incorrect or malicious calldata.

### **Use of Assembly Code**:

- **Issue**: The contract uses low-level assembly code for decoding calldata and verifying function signatures. While assembly can be efficient, it can also introduce risks such as security vulnerabilities and maintenance challenges.
- **Solution**: Ensure thorough testing and review of the assembly code.

## 🛣 Alternative Approach

An alternative approach to managing multiple token types within a single vault is to use a router contract along with separate vault contracts for each token type. This approach can provide a more modular and scalable solution:

### Router Contract

A router contract can be used to interface with different vault contracts based on the token type. It would route deposit and withdrawal requests to the appropriate vault contract.

### Vault Contracts

Each vault contract would be specialized for a specific token standard (e.g., ERC20Vault, ERC721Vault, ERC1155Vault). These contracts would implement the token-specific logic for deposits and withdrawals.

### Unified Interface

A unified interface can be provided to users through the router contract, allowing them to interact with different vaults seamlessly. The router contract would handle the logic for determining which vault to use based on the token type.

### Benefits

- Modularity: Separate vault contracts for each token type make the system more modular and easier to maintain.
- Scalability: Adding support for new token standards is simpler, as it only requires deploying a new vault contract and updating the router.
- Gas Efficiency: Token-specific vault contracts can be optimized for their respective token standards, potentially reducing gas costs.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to fork this repository and contribute by submitting a pull request. For major changes, please open an issue first to discuss what you would like to change. Thanks!


