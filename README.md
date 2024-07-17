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


## Smart Contract Structure

### Initialization

- `initialize()`: Initializes the vault, enabling it for use. This function can only be called once by the owner.

### Token Activation and Deactivation

- `activateToken(...)`: Registers a token in the vault with specific parameters. This includes whether the token has an amount and/or ID parameter, and the function signatures for deposit and withdraw operations.
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

## Example

Here's a simple example in solidity of how to interact with the contract:

1. **Deploy the contract**:

```solidity
UniversalTokenVault vault = new UniversalTokenVault();
vault.initialize();
```

2. **Register a token**:

```solidity
address token = address(0x1234);
vault.activateToken(
    token, 
    true, 
    false, 
    bytes4(keccak256("transfer(address,uint256)")), 
    bytes4(keccak256("transfer(address,uint256)")), 
    1, 
    0, 
    1, 
    0
);
```

3. **Deposit a token**:

```solidity
bytes memory data = abi.encodeWithSelector(
    bytes4(keccak256("transfer(address,uint256)")), 
    address(vault), 
    100
);
vault.deposit(token, data);
```

4. **Withdraw a token**:

```solidity
bytes memory data = abi.encodeWithSelector(
    bytes4(keccak256("transfer(address,uint256)")), 
    msg.sender, 
    100
);
vault.withdraw(token, data);
```

This example demonstrates the basic usage of the `UniversalTokenVault` contract, from deployment and initialization to token registration and deposit/withdrawal operations.

### Contribution

Feel free to fork this repository and contribute by submitting a pull request. For major changes, please open an issue first to discuss what you would like to change.

## Disclaimer

**This code is for testing purposes only and has not been audited. It may contain vulnerabilities and should not be used in production. The contract is under development and is considered a Work In Progress (WIP). Use at your own risk.**

### License

This project is licensed under the MIT License.