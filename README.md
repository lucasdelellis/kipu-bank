# KipuBank Smart Contract

## 📖 Descripción
`KipuBank` es un contrato inteligente en Solidity que implementa un sistema bancario simple sobre Ethereum.  
Los usuarios pueden **depositar** y **retirar ETH**, con las siguientes reglas:

- Existe un **tope máximo de ETH** que el contrato puede almacenar (`i_bankCap`).
- Cada retiro tiene un **límite máximo permitido** (`i_maxWithdrawal`).
- Se lleva un **registro de depósitos y retiros realizados**.
- Cada usuario tiene su propio **balance interno** en el contrato.
- Incluye **eventos** para auditar depósitos y retiros.
- Usa patrones de seguridad como *Checks-Effects-Interactions* para evitar ataques de reentrancy.

---

## 📌 Dirección del contrato en Etherscan
> [Etherscan link](https://sepolia.etherscan.io/address/0xed67aeca286ee47398597821ed74c9706f91342c)

---

## 🛠️ Interacción con el contrato

### Métodos principales
- `deposit()` → Depositar ETH en el contrato.  
- `withdraw(uint256 amount)` → Retirar ETH, respetando el balance y el límite de retiro.  
- `getBalance()` → Consultar el balance del usuario que llama.  
- `s_depositCount` → Total de depósitos realizados.  
- `s_withdrawalCount` → Total de retiros realizados.  
