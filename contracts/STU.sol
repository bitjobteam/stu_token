pragma solidity ^0.4.8;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./ERC20.sol";
import "./TokenSpender.sol";
contract STU is ERC20, SafeMath, Ownable {

    /* Public variables of the token */
  string public name;       //fancy name
  string public symbol;
  uint8 public decimals;    //How many decimals to show.
  string public version = 'v0.1'; 
  uint public initialSupply;
  uint public totalSupply;
  bool public locked;
  //uint public unlockBlock;

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  // lock transfer during the ICO
  modifier onlyUnlocked() {
    if (msg.sender != owner && locked) throw;
    _;
  }

  /*
   *  The STU Token created with the time at which the crowdsale end
   */

  function STU() {
    // lock the transfer function during the crowdsale
    locked = true;
    //unlockBlock=  now + 45 days; // (testnet) - for mainnet put the block number



     // One hundred million coins, each divided to up to 10^decimals units.
    initialSupply = 100000000 * (10 ** decimals);
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;// Give the creator all initial tokens                    
    name = 'STU Bitjob Token';        // Set the name for display purposes     
    symbol = 'STU';                       // Set the symbol for display purposes  
    decimals = 6;                        // Amount of decimals for display purposes
  }

  function unlock() onlyOwner {
    locked = false;
  }

  function burn(uint256 _value) onlyOwner returns (bool){
    balances[msg.sender] = safeSub(balances[msg.sender], _value) ;
    totalSupply = safeSub(totalSupply, _value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

  function transfer(address _to, uint _value) onlyUnlocked returns (bool) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) onlyUnlocked returns (bool) {
    var _allowance = allowed[_from][msg.sender];
    
    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

    /* Approve and then comunicate the approved contract in a single tx */
  function approveAndCall(address _spender, uint256 _value, bytes _extraData){    
      TokenSpender spender = TokenSpender(_spender);
      if (approve(_spender, _value)) {
          spender.receiveApproval(msg.sender, _value, this, _extraData);
      }
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
  
}

