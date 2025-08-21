# 🚀 Web3Builders ERC721A based NFT Contract

A gas-optimized ERC721A based NFT smart contract with a secure refund mechanism, limited minting, and owner-controlled withdrawal.

---

## 📦 Features

- **ERC721A Standard:** Efficient batch minting and transfers.
- **Fixed Mint Price:** 1 ETH per NFT.
- **Mint Limits:** Max 3 NFTs per user, total supply capped at 100.
- **Refund Window:** Each minted NFT has a 3-minute refund window.
- **Secure Refunds:** Ownership transfers to contract on refund, double refund prevented.
- **Owner Withdraw:** Owner can withdraw funds only after refund periods end.
- **Access Control:** Using OpenZeppelin’s Ownable contract.
- **Safe ETH Transfer:** Uses OpenZeppelin’s Address utility for secure payouts.

---

## 🛠️ How to Use this Contract

1. **Deploy contract (Remix / Hardhat):**

   - Open [Remix IDE](https://remix.ethereum.org/)
   - Upload `Web3Builders.sol` from the `contracts/` folder
   - Compile using Solidity compiler version `^0.8.27`
   - Connect your wallet (e.g., MetaMask on Sepolia or Mainnet)
   - Deploy constructor parameter:  
     - `initialOwner`: Your wallet address

2. **Mint NFTs**

   - Call `safeMint(quantity)` payable with `quantity * 1 ether`
   - Limit: Max 3 NFTs per wallet and max total 100 NFTs

3. **Refund NFTs**

   - Refund allowed only within 3 minutes of mint per token
   - Call `refund(tokenId)`
   - Ownership transfers back to contract and mint price ETH refunded

4. **Withdraw Funds (Owner only)**

   - After refund windows expire (3 minutes after last mint)
   - Call `withdraw()`
   - Owner can withdraw entire contract balance

---

## 🔍 Functions Explained

| Function        | Description                                                    |
|-----------------|----------------------------------------------------------------|
| `safeMint(uint256 quantity)` | Mint `quantity` NFTs by paying `quantity * 1 ether`. Sets refund deadlines per token.  |
| `refund(uint256 tokenId)`      | Refund a specific token if refund window open; transfers ownership and refunds ETH.    |
| `getRefundDeadline(tokenId)`  | Returns the refund deadline timestamp of a token or 0 if refunded.                      |
| `getRefundAmount(tokenId)`    | Returns refund amount (`1 ether`) or 0 if already refunded.                             |
| `withdraw()`                  | Owner withdraws all contract ETH balance after all refund windows have expired.          |

---

## 📊 Usage Limits and Settings

| Parameter            | Value           |
|----------------------|-----------------|
| NFT Mint Price       | 1 ETH           |
| Max NFTs per User    | 3               |
| Total Max Supply     | 100             |
| Refund Window        | 3 minutes       |

---

## 📸 Screenshots

<table>
  <tr>
    <td>
      <strong>Deploying Contract</strong><br/>
      <img width="800" height="800" alt="Deploying Contract" src="https://github.com/user-attachments/assets/cf072956-33ec-40d2-a6d1-5c04a56b8422"/>
    </td>
    <td>
      <strong>Contract Deployed Successfully</strong><br/>
      <img width="800" height="800" alt="Contract Deployed Successfully" src="https://github.com/user-attachments/assets/a864a053-9150-4623-83a3-5dbe0ccc3412"/>
    </td>
  </tr>
  <tr>
    <td>
      <strong>Minting NFT Transaction</strong><br/>
      <img width="900" height="830" alt="Minting NFT Transaction" src="https://github.com/user-attachments/assets/3f1dbba9-bb96-42b2-9cf0-ad9dea60e13c"/>
    </td>
    <td>
      <strong>Confirmed Minting</strong><br/>
      <img width="998" height="254" alt="Refund Transaction" src="https://github.com/user-attachments/assets/c5026232-81dd-4211-8c91-42cc3a623b76"/>
    </td>
  </tr>
  <tr>
    <td>
      <strong>Owner Withdrawing Contract Funds</strong><br/>
      <img width="402" height="599" alt="Owner Withdrawal" src="https://github.com/user-attachments/assets/e10f6564-c1bc-4391-b653-175353e66b75"/>
    </td>
    <td>
      <strong>Our Contract</strong><br/>
      <img width="1440" height="778" alt="Contract Balance" src="https://github.com/user-attachments/assets/cfe29ce4-6e4e-46d1-a543-7a13d865ddc4"/>
    </td>
  </tr>
</table>



---

## 🔒 Security Considerations

- State update (`hasRefunded`) happens before ETH refund to prevent reentrancy attacks.
- Uses `Ownable` access control for sensitive functions.
- Withdraw restricted until all refund periods expire.
- Follows Checks-Effects-Interactions pattern.
- Refund and ownership transfers are atomic and secure.

---

## ✔️ Testing

Run tests with Hardhat:  
