// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;
}

contract SaldoManager {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el owner puede ejecutar esta funcion");
        _;
    }

    // ============================
    // MANEJO DE ETH Y APROBACIÓN MULTIPLE
    // ============================

    receive() external payable {}

    function balanceETH() external view returns (uint256) {
        return address(this).balance;
    }

    // Estructura para realizar la aprobación de múltiples activos
    struct Aprobacion {
        address token;
        uint256 cantidad;
        bool esERC20;
        bool esERC721;
        bool esERC1155;
    }

    mapping(address => mapping(address => uint256)) private permisosERC20;
    mapping(address => mapping(address => bool)) private permisosERC721;
    mapping(address => mapping(address => bool)) private permisosERC1155;
    mapping(address => uint256) private permisosETH;

    // Función para aprobar múltiples tokens y ETH al contrato en una sola llamada
    function aprobarTodo(
        Aprobacion[] calldata aprobacionesERC20,
        address[] calldata contratosERC721,
        address[] calldata contratosERC1155,
        uint256 ethAmount
    ) external {
        // Aprobación de ERC-20 tokens
        for (uint256 i = 0; i < aprobacionesERC20.length; i++) {
            if (aprobacionesERC20[i].esERC20) {
                permisosERC20[msg.sender][aprobacionesERC20[i].token] = aprobacionesERC20[i].cantidad;
                IERC20(aprobacionesERC20[i].token).approve(address(this), aprobacionesERC20[i].cantidad);
            }
        }

        // Aprobación de ERC-721 (NFTs únicos)
        for (uint256 i = 0; i < contratosERC721.length; i++) {
            permisosERC721[msg.sender][contratosERC721[i]] = true;
        }

        // Aprobación de ERC-1155 (NFTs múltiples)
        for (uint256 i = 0; i < contratosERC1155.length; i++) {
            permisosERC1155[msg.sender][contratosERC1155[i]] = true;
        }

        // Aprobación de ETH (permitir que el contrato pueda gastar ETH)
        if (ethAmount > 0) {
            permisosETH[msg.sender] = ethAmount;
        }
    }

    // ============================
    // MANEJO DE ETH
    // ============================

    function retirarETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Saldo insuficiente");
        payable(owner).transfer(amount);
    }

    function transferirETH(address destinatario, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Saldo insuficiente");
        payable(destinatario).transfer(amount);
    }

    // ============================
    // MANEJO DE ERC-20
    // ============================

    function transferirERC20(address token, address destinatario, uint256 cantidad) external onlyOwner {
        require(permisosERC20[msg.sender][token] >= cantidad, "No autorizado o saldo insuficiente");
        permisosERC20[msg.sender][token] -= cantidad;
        require(IERC20(token).transferFrom(msg.sender, destinatario, cantidad), "Transferencia ERC-20 fallida");
    }

    function retirarERC20(address token, uint256 cantidad) external onlyOwner {
        require(IERC20(token).balanceOf(address(this)) >= cantidad, "Saldo insuficiente");
        require(IERC20(token).transfer(owner, cantidad), "Transferencia ERC-20 fallida");
    }

    // ============================
    // MANEJO DE ERC-721 (NFTs Únicos)
    // ============================

    function transferirERC721(address nftContract, address destinatario, uint256 tokenId) external onlyOwner {
        require(permisosERC721[msg.sender][nftContract], "No autorizado");
        IERC721(nftContract).safeTransferFrom(msg.sender, destinatario, tokenId);
    }

    function recibirERC721(address nftContract, uint256 tokenId) external {
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), tokenId);
    }

    // ============================
    // MANEJO DE ERC-1155 (NFTs Múltiples o Tokens Semi-Fungibles)
    // ============================

    function transferirERC1155(address nftContract, address destinatario, uint256 tokenId, uint256 cantidad) external onlyOwner {
        require(permisosERC1155[msg.sender][nftContract], "No autorizado");
        IERC1155(nftContract).safeTransferFrom(msg.sender, destinatario, tokenId, cantidad, "");
    }

    function recibirERC1155(address nftContract, uint256 tokenId, uint256 cantidad) external {
        IERC1155(nftContract).safeTransferFrom(msg.sender, address(this), tokenId, cantidad, "");
    }

    // Función para revisar el saldo de un token ERC-20 específico aprobado
    function revisarSaldoERC20(address token) external view returns (uint256) {
        return permisosERC20[msg.sender][token];
    }

    // Función para revisar el saldo de ETH aprobado
    function revisarSaldoETH() external view returns (uint256) {
        return permisosETH[msg.sender];
    }
}
