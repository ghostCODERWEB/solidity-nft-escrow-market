// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {SuiteBase, AssetFlow} from "./SuiteBase.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title Escrowed NFT marketplace
/// @notice ERC721 custody listings with fixed token prices, royalty caps, cancellation and pull-based sale proceeds.
/// @dev Reference implementation; independent audit required before production.

contract NFTMarket is SuiteBase, ERC721Holder {
    using SafeERC20 for IERC20;
    IERC20 public immutable paymentToken;
    uint256 public nextId;
    uint256 public liability;
    uint16 public immutable feeBps;
    address public immutable treasury;
    struct Listing {
        address seller;
        address collection;
        uint256 tokenId;
        uint256 price;
        address creator;
        uint16 royaltyBps;
        bool active;
    }
    mapping(uint256 => Listing) public listings;
    mapping(address => uint256) public credits;
    event Listed(
        uint256 indexed id,
        address indexed seller,
        address collection,
        uint256 tokenId,
        uint256 price
    );
    event Purchased(uint256 indexed id, address indexed buyer);
    event Cancelled(uint256 indexed id);
    event Withdrawn(address indexed account, uint256 amount);
    constructor(
        address asset,
        uint16 fee,
        address feeRecipient,
        address admin
    ) SuiteBase(admin) {
        require(
            asset.code.length > 0 && fee <= 1000 && feeRecipient != address(0),
            "config"
        );
        paymentToken = IERC20(asset);
        feeBps = fee;
        treasury = feeRecipient;
    }
    function list(
        address collection,
        uint256 tokenId,
        uint256 price,
        address creator,
        uint16 royaltyBps
    ) external nonReentrant whenNotPaused returns (uint256 id) {
        require(
            collection.code.length > 0 &&
                price > 0 &&
                royaltyBps + feeBps <= 10000 &&
                (royaltyBps == 0 || creator != address(0)),
            "listing"
        );
        require(IERC721(collection).ownerOf(tokenId) == msg.sender, "owner");
        id = ++nextId;
        listings[id] = Listing(
            msg.sender,
            collection,
            tokenId,
            price,
            creator,
            royaltyBps,
            true
        );
        IERC721(collection).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        emit Listed(id, msg.sender, collection, tokenId, price);
    }
    function buy(
        uint256 id,
        uint256 maxPrice
    ) external nonReentrant whenNotPaused {
        Listing storage l = listings[id];
        require(
            l.active && l.seller != msg.sender && l.price <= maxPrice,
            "buy"
        );
        l.active = false;
        AssetFlow.pullExact(paymentToken, msg.sender, l.price);
        uint256 fee = Math.mulDiv(l.price, feeBps, 10000);
        uint256 royalty = Math.mulDiv(l.price, l.royaltyBps, 10000);
        credits[treasury] += fee;
        credits[l.creator] += royalty;
        credits[l.seller] += l.price - fee - royalty;
        liability += l.price;
        IERC721(l.collection).safeTransferFrom(
            address(this),
            msg.sender,
            l.tokenId
        );
        emit Purchased(id, msg.sender);
    }
    function cancel(uint256 id) external nonReentrant {
        Listing storage l = listings[id];
        require(l.active && l.seller == msg.sender, "cancel");
        l.active = false;
        IERC721(l.collection).safeTransferFrom(
            address(this),
            msg.sender,
            l.tokenId
        );
        emit Cancelled(id);
    }
    function withdraw() external nonReentrant {
        uint256 amount = credits[msg.sender];
        require(amount > 0, "credit");
        credits[msg.sender] = 0;
        liability -= amount;
        paymentToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
}
