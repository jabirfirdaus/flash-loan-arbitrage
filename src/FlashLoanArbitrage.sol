// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/ILendingPool.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

/// @title Bot Arbitrage Flash Loan DeFi
/// @author Jabir
/// @notice Kontrak ini digunakan untuk meminjam dana tanpa agunan dan melakukan arbitrase
/// @dev Masih menggunakan interface dasar, perlu penyesuaian untuk mainnet Aave/Uniswap
contract FlashLoanArbitrage {
    address public owner;
    ILendingPool public pool;
    IUniswapV2Router public uniswapRouter;
    IERC20 public tokenPinjaman;

    /// @notice Mengatur alamat protokol DeFi yang akan digunakan
    /// @param _poolAddress Alamat Smart Contract penyedia Flash Loan (misal: Aave)
    /// @param _routerAddress Alamat mesin penukar DEX (misal: Uniswap V2 Router)
    /// @param _tokenAddress Alamat token kripto yang ingin dipinjam (misal: WETH atau DAI)
    constructor(address _poolAddress, address _routerAddress, address _tokenAddress) {
        owner = msg.sender;
        pool = ILendingPool(_poolAddress);
        uniswapRouter = IUniswapV2Router(_routerAddress);
        tokenPinjaman = IERC20(_tokenAddress);
    }

    /// @notice Memulai eksekusi pinjaman kilat
    /// @dev Hanya owner kontrak yang bisa memanggil fungsi ini untuk mencegah eksploitasi
    /// @param jumlahPinjaman Nominal token yang ingin dipinjam dalam format wei
    function mulaiArbitrage(uint256 jumlahPinjaman) external {
        require(msg.sender == owner, "Hanya bos yang eksekusi");
        pool.flashLoan(address(this), jumlahPinjaman);
    }

    /// @notice Fungsi callback wajib yang dipanggil otomatis oleh Lending Pool
    /// @dev Logika beli murah dan jual mahal (arbitrase) ditempatkan di dalam fungsi ini
    /// @param amount Jumlah dana yang berhasil dipinjam
    /// @param fee Biaya jasa pinjaman yang harus dikembalikan ke Pool
    /// @return bool Mengembalikan nilai true jika seluruh proses arbitrase dan pembayaran utang sukses
    function executeOperation(uint256 amount, uint256 fee) external returns (bool) {
        tokenPinjaman.approve(address(uniswapRouter), amount);

        address[] memory path = new address[](2);
        path[0] = address(tokenPinjaman);
        path[1] = 0x0000000000000000000000000000000000000000; 

        uint256 deadline = block.timestamp + 300; 
        
        try uniswapRouter.swapExactTokensForTokens(amount, 0, path, address(this), deadline) {
            // Logika jual di DEX B
        } catch {
            revert("Swap di DEX A gagal!");
        }

        uint256 totalUtang = amount + fee;
        uint256 saldoAkhir = tokenPinjaman.balanceOf(address(this));
        
        require(saldoAkhir >= totalUtang, "Rugi bro! Arbitrage batal.");
        tokenPinjaman.approve(address(pool), totalUtang);

        return true;
    }
}