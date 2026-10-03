# ABI reference

Generated from the successfully compiled primary contract. Includes inherited OpenZeppelin methods. Authorization requirements and economic semantics are in the Solidity source and architecture guide.

| Signature | Type | Mutability | Return values |
|---|---|---|---|
| `constructor(address asset,uint16 fee,address feeRecipient,address admin)` | constructor | nonpayable |  |
| `EnforcedPause()` | error |  |  |
| `ExpectedPause()` | error |  |  |
| `OwnableInvalidOwner(address owner)` | error |  |  |
| `OwnableUnauthorizedAccount(address account)` | error |  |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `SafeERC20FailedOperation(address token)` | error |  |  |
| `Cancelled(uint256 id)` | event |  |  |
| `Listed(uint256 id,address seller,address collection,uint256 tokenId,uint256 price)` | event |  |  |
| `OwnershipTransferStarted(address previousOwner,address newOwner)` | event |  |  |
| `OwnershipTransferred(address previousOwner,address newOwner)` | event |  |  |
| `Paused(address account)` | event |  |  |
| `Purchased(uint256 id,address buyer)` | event |  |  |
| `Unpaused(address account)` | event |  |  |
| `Withdrawn(address account,uint256 amount)` | event |  |  |
| `acceptOwnership()` | function | nonpayable |  |
| `buy(uint256 id,uint256 maxPrice)` | function | nonpayable |  |
| `cancel(uint256 id)` | function | nonpayable |  |
| `credits(address )` | function | view | uint256  |
| `feeBps()` | function | view | uint16  |
| `liability()` | function | view | uint256  |
| `list(address collection,uint256 tokenId,uint256 price,address creator,uint16 royaltyBps)` | function | nonpayable | uint256 id |
| `listings(uint256 )` | function | view | address seller, address collection, uint256 tokenId, uint256 price, address creator, uint16 royaltyBps, bool active |
| `nextId()` | function | view | uint256  |
| `onERC721Received(address ,address ,uint256 ,bytes )` | function | nonpayable | bytes4  |
| `owner()` | function | view | address  |
| `paused()` | function | view | bool  |
| `paymentToken()` | function | view | address  |
| `pendingOwner()` | function | view | address  |
| `renounceOwnership()` | function | nonpayable |  |
| `setPaused(bool value)` | function | nonpayable |  |
| `transferOwnership(address newOwner)` | function | nonpayable |  |
| `treasury()` | function | view | address  |
| `withdraw()` | function | nonpayable |  |
