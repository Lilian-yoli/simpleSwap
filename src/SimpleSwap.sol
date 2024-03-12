// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestERC20.sol";

contract SimpleSwap {
  // phase 1
  TestERC20 public token0;
  TestERC20 public token1;

  // phase 2
  uint256 public totalSupply = 0;
  mapping(address => uint256) public share;

  constructor(address _token0, address _token1) {
    token0 = TestERC20(_token0);
    token1 = TestERC20(_token1);
  }

  function swap(address _tokenIn, uint256 _amountIn) public {
    require(_tokenIn == address(token0) || _tokenIn == address(token1));
    
    if(_tokenIn == address(token0)){
      token0.transferFrom(msg.sender, address(this), _amountIn);
      token1.transfer(msg.sender, _amountIn);
    } else {
      token1.transferFrom(msg.sender, address(this), _amountIn);
      token0.transfer(msg.sender, _amountIn);
    }
  }

  // phase 1
  function addLiquidity1(uint256 _amount) public {
    token0.transferFrom(msg.sender, address(this), _amount);
    token1.transferFrom(msg.sender, address(this), _amount);
  }

  function removeLiquidity1() public {
    uint256 balanceToken0 = token0.balanceOf(address(this));
    uint256 balanceToken1 = token1.balanceOf(address(this));
    require(balanceToken0 > 0);
    require(balanceToken1 > 0);

    token0.transfer(msg.sender, balanceToken0);
    token1.transfer(msg.sender, balanceToken1);
  }

  // phase 2
  function addLiquidity2(uint256 _amount) public {
    require(_amount > 0);
    token0.transferFrom(msg.sender, address(this), _amount);
    token1.transferFrom(msg.sender, address(this), _amount);
    uint256 totalAmount = _amount * 2;
    totalSupply += totalAmount;
    share[msg.sender] += totalAmount;
  }

  function removeLiquidity2() public {
    uint userShare = share[msg.sender];
    uint256 balanceOfToken0 = token0.balanceOf(address(this));
    uint256 balanceOfToken1 = token1.balanceOf(address(this));

    uint256 amountToken0 = (userShare * balanceOfToken0)/ totalSupply;
    uint256 amountToken1 = (userShare * balanceOfToken1)/ totalSupply;

    token0.transfer(msg.sender, amountToken0);
    token1.transfer(msg.sender, amountToken1);

    totalSupply -= (amountToken0 + amountToken1);
  }

  // phase 3
  // Apply swap() apart from X * Y = K & X + Y = K
  function swap3(address _tokenIn, uint256 _amountIn) public {
    uint256 balanceOfToken0 = token0.balanceOf(address(this));
    uint256 balanceOfToken1 = token1.balanceOf(address(this));
    require(_amountIn > 0);

    if(_tokenIn == address(token0)) {
      require(balanceOfToken0 >= _amountIn);
      uint256 returnAmount = (_amountIn * balanceOfToken1) / balanceOfToken0;
      require(balanceOfToken1 >= returnAmount);
      token0.transferFrom(msg.sender, address(this), _amountIn);
      token1.transfer(msg.sender, returnAmount);
    } else {
      require(balanceOfToken1 > _amountIn);
      uint256 returnAmount = (_amountIn * balanceOfToken0) / balanceOfToken1;
      require(balanceOfToken0 >= returnAmount);
      token1.transferFrom(msg.sender, address(this), _amountIn);
      token0.transfer(msg.sender, returnAmount);
    }
  }
}
