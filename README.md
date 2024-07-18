# Universal Token Vault

The `UniversalTokenVault` smart contract is designed to be a flexible vault that can hold and manage various types of tokens, including ERC20, ERC721, ERC1155, and custom token standards. It allows users to deposit and withdraw tokens while keeping track of balances and ownership. The contract supports customization of the deposit and withdraw functions, making it adaptable to different token types and use cases.

## Table of Contents

- [Features](#features)
- [Key Concepts](#key-concepts)
- [Smart Contract Structure](#smart-contract-structure)
- [Installation and Setup](#installation-and-setup)
- [Usage](#usage)

## Features

- Supports multiple token standards (ERC20, ERC721, ERC1155, and custom tokens).
- Ability to register, deposit, and withdraw tokens.
- Tracks user balances and ownership of tokens.
- Implements Pausable and ReentrancyGuard for enhanced security.
- Ability to handle custom function signatures for deposit and withdraw operations.

## Key Concepts

### Token Registration

The vault allows the owner to register different tokens by specifying their characteristics, such as whether they have an amount parameter, an ID parameter, and the function signatures for deposit and withdrawal. This makes the contract versatile and capable of handling multiple token standards.

### User Balances and Ownership

The contract maintains mappings to track user balances and ownership of tokens. For ERC20-like tokens, it tracks the amount held by each user. For ERC721 and ERC1155 tokens, it tracks ownership and balances based on token IDs.

### Security Features

The contract implements security features such as `Pausable` and `ReentrancyGuard` to ensure safe and reliable operation. The vault can be paused to prevent deposits and withdrawals during maintenance or emergencies.

Additionally, helper functions ensure that only the registered functions can be called and only the correct amounts and IDs can be used:

- Verify function signature: Ensures that the function being called matches the registered function signature.
- Decode amount: Decodes the amount parameter from the provided data based on the specified parameter index.
- Decode Id: Decodes the ID parameter from the provided data based on the specified parameter index.

## Smart Contract Structure

### Initialization

- `initialize()`: Initializes the vault, enabling it for use. This function can only be called once by the owner.

### Token Activation and Deactivation

- `activateToken(address _token, bool _hasAmount, bool _hasId, bytes4 _depositFunctionSignature, bytes4 _withdrawFunctionSignature, uint8 _amountParamIndexForDeposit, uint8 _idParamIndexForDeposit, uint8 _amountParamIndexForWithdraw, uint8 _idParamIndexForWithdraw)`: Registers a token in the vault with specific parameters.
  - `_token`: The address of the token to be activated.
  - `_hasAmount`: Indicates if the token has an amount parameter.
  - `_hasId`: Indicates if the token has an ID parameter.
  - `_depositFunctionSignature`: The function signature for deposit.
  - `_withdrawFunctionSignature`: The function signature for withdrawal.
  - `_amountParamIndexForDeposit`: The index of the amount parameter for deposit.
  - `_idParamIndexForDeposit`: The index of the ID parameter for deposit.
  - `_amountParamIndexForWithdraw`: The index of the amount parameter for withdrawal.
  - `_idParamIndexForWithdraw`: The index of the ID parameter for withdrawal.

- `deactivateToken(address _token)`: Deactivates a previously registered token, preventing further deposits and withdrawals.

### Deposit and Withdraw

- `deposit(address _token, bytes calldata _data)`: Allows users to deposit registered tokens into the vault. The function decodes the provided data to extract the amount and/or ID parameters as needed, updates the user's balance, and calls the specified deposit function on the token contract.
- `withdraw(address _token, bytes calldata _data)`: Allows users to withdraw tokens from the vault. The function decodes the provided data to extract the amount and/or ID parameters, checks the user's balance, updates the balance, and calls the specified withdraw function on the token contract.

### Helper Functions

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

## Installation and Setup

### Prerequisites

- [Foundry](https://getfoundry.sh/) for compiling, testing, and deploying smart contracts.

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/freitasgouvea/universal-token-vault.git
    cd universal-token-vault
    ```

2. Install dependencies:
    ```bash
    forge install
    ```

### Running Tests

1. Compile the smart contract:
    ```bash
    forge build
    ```

2. Run tests:
    ```bash
    forge test
    ```

## Usage

To use the `UniversalTokenVault` contract, follow these steps:

1. **Deployment**: Deploy the contract and initialize it by calling the `initialize()` function.
2. **Token Registration**: Register the tokens you want to manage by calling the `activateToken()` function with the appropriate parameters.
3. **Deposits and Withdrawals**: Users can deposit tokens into the vault using the `deposit()` function and withdraw tokens using the `withdraw()` function.

## Example Scripts

Here are the example scripts to deploy and interact with the `UniversalTokenVault` contract using Foundry.

I understand. Here are the terminal commands to run the scripts with the required parameters and private key:

### 1. Deploy Vault

```sh
forge script Deploy.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY>
```

### 2. Deploy and Register Tokens

```sh
forge script RegisterTokens.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --sig "run(address)" <VAULT_ADDRESS>
```

### 3. Deposit Tokens

```sh
forge script Deposit.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --sig "run(address,address,address,address)" <VAULT_ADDRESS> <ERC20_ADDRESS> <ERC721_ADDRESS> <ERC1155_ADDRESS>
```

### 4. Withdraw Tokens

```sh
forge script Withdraw.s.sol --broadcast --rpc-url <YOUR_RPC_URL> --private-key <YOUR_PRIVATE_KEY> --sig "run(address,address,address,address)" <VAULT_ADDRESS> <ERC20_ADDRESS> <ERC721_ADDRESS> <ERC1155_ADDRESS>
```

### Contribution

Feel free to fork this repository and contribute by submitting a pull request. For major changes, please open an issue first to discuss what you would like to change.

## Disclaimer

**This code is for testing purposes only and has not been audited. It may contain vulnerabilities and should not be used in production. The contract is under development and is considered a Work In Progress (WIP). Use at your own risk.**

### License

This project is licensed under the MIT License.