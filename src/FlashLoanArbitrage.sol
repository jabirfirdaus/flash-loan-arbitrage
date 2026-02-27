pragma solidity ^0.8.20;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

// Interface simulasi untuk memanggil pool pinjaman
interface ILendingPool {
    function flashLoan(address receiver, uint256 amount) external;
}

contract FlashLoanArbitrage {
    address public owner;
    ILendingPool public pool;
    IUniswapV2Router public uniswapRouter;
    IERC20 public tokenPinjaman;

    // Kita tambahkan parameter router dan token di constructor
    constructor(address _poolAddress, address _routerAddress, address _tokenAddress) {
        owner = msg.sender;
        pool = ILendingPool(_poolAddress);
        uniswapRouter = IUniswapV2Router(_routerAddress);
        tokenPinjaman = IERC20(_tokenAddress);
    }

    function mulaiArbitrage(uint256 jumlahPinjaman) external {
        require(msg.sender == owner, "Hanya bos yang eksekusi");
        pool.flashLoan(address(this), jumlahPinjaman);
    }

    // Fungsi ini tereksekusi otomatis setelah dana pinjaman masuk
    function executeOperation(uint256 amount, uint256 fee) external returns (bool) {
        
        // 1. IZIN AKSES: Beri akses ke Uniswap untuk memakai token kita
        tokenPinjaman.approve(address(uniswapRouter), amount);

        // 2. SETUP RUTE: Dari Token Pinjaman (A) ke Token Target (B)
        address[] memory path = new address[](2);
        path[0] = address(tokenPinjaman);
        // Ganti 0x00... dengan alamat Token B yang sesungguhnya nanti
        path[1] = 0x0000000000000000000000000000000000000000; 

        // 3. EKSEKUSI BELI MURAH (DEX A - Uniswap)
        uint256 deadline = block.timestamp + 300; // Kadaluarsa 5 menit
        
        // Kita masukkan logika di dalam try-catch untuk menahan error jika harga meleset
        try uniswapRouter.swapExactTokensForTokens(
            amount,
            0, // Peringatan: 0 berarti kita terima harga berapa pun (bahaya slippage di real-world)
            path,
            address(this),
            deadline
        ) {
            // Jika sukses, token B masuk ke kontrak kita.
            // 4. LOGIKA JUAL MAHAL (DEX B):
            // Di sini lo panggil Router DEX B (misal Sushiswap) untuk menukar kembali Token B ke Token A.
        } catch {
            // Jika swap gagal, transaksi flash loan akan otomatis revert
            revert("Swap di DEX A gagal!");
        }

        // 5. KALKULASI UTANG DAN PENGEMBALIAN
        uint256 totalUtang = amount + fee;
        uint256 saldoAkhir = tokenPinjaman.balanceOf(address(this));
        
        // Cek apakah hasil swap bolak-balik kita lebih besar dari utang
        require(saldoAkhir >= totalUtang, "Rugi bro! Arbitrage batal.");

        // Kembalikan uang pinjaman + bunga ke Pool
        tokenPinjaman.approve(address(pool), totalUtang);

        return true;
    }
}