pragma solidity ^0.8.2;

contract Token {
    address private contractOwner;
    address private charity;
    uint256 public basePercent = 100;
    
    mapping(address => uint) public balances;
    mapping(address => mapping(address => uint)) public allowance;

    uint public totalSupply = 10000 * 10 ** 18; // 10000
    string public name = "MADE TOKENV5";
    string public symbol = "MDTV5";
    uint public decimals = 18;

    // events
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor() {
        contractOwner = msg.sender;
        balances[msg.sender] = totalSupply;
        charity = 0x2287e921A72D766b7767755F698182ECC4DC41c5;
    }
    
    function balanceOf(address owner) public view returns(uint) {
        return balances[owner];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(balanceOf(msg.sender) >= value, "balance too low");
        
        uint256 feeValue = (value/100) * 10; // 10%
        uint256 charityReceivedValue = (feeValue/100) * 25;
        uint256 ownerReceivedValue = feeValue - charityReceivedValue; 
        uint256 receivedValue = value - feeValue;

        balances[msg.sender] -= value;
        balances[to] += receivedValue; // 90%
        balances[getOwner()] += ownerReceivedValue;  // 7.5%
        balances[charity] += charityReceivedValue;  // 2.5%
        
        emit Transfer(msg.sender, to, value); 
        return true;
    }
    
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(balanceOf(from) >= value, "balance too low");
        require(allowance[from][msg.sender] >= value, "allowance too low");
        
        uint256 feeValue = (value/100) * 10; // 10%
        uint256 charityReceivedValue = (feeValue/100) * 25;
        
        uint256 ownerReceivedValue = feeValue - charityReceivedValue;
        uint256 receivedValue = value - feeValue; 
        
        balances[from] -= value;
        balances[to] += receivedValue; // 90%
        balances[getOwner()] += ownerReceivedValue; // 7.5%
        balances[charity] += charityReceivedValue; // 2.5%

        emit Transfer(from, to, value);
        return true;
    }
    
    function approve(address spender, uint256 value) public returns (bool) {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }
    
    function getOwner() public view returns (address) {    
        return contractOwner;
    }
}
