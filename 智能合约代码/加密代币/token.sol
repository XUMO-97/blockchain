pragma solidity ^0.4.18;

//创建一个基础合约，有些操作是当前合约创建者才能操作
contract owned{
    //声明一个用于接收合约创建者的状态变量
    address public owner;
    //构造函数，把当前交易的发送者(也就是合约的创建者)赋予owner变量
    constructor() public {
        owner = msg.sender;
    }

    //声明一个修改器，用于一些只有合约的创建者才能操作的方法
    modifier onlyOwner{
        if(msg.sender != owner){
            revert();
        }
        else{
            _;//继续执行程序就是一个下划线
        }
    }

    //把合约转送给其他人
    function transferOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract token is owned{
    string public name;//代币名字
    string public symbol;//代币符号
    uint8 public decimals = 0;//代币的小数位
    uint public totalSupply;// 代币总量

    uint public sellPrice = 1 ether;//设置代币出售的价格为一个以太币
    uint public buyPrice = 1 ether;//设置代币购买的价格为一个以太币

    //用一个映射的变量，来记录所有账户的代币余额
    mapping (address => uint) public balanceOf;
    //用一个映射的变量，来记录被冻结的账户
    mapping (address => bool) public frozenAccount;

    //构造函数，初始化代币的变量和初始化代币总量
    constructor(uint initialSupply,string _name,string _symbol,uint8 _decimals,address centralMiner) public {
        //手动指定代币的拥有者，如果不填，则默认为当前合约的发起者
        if(centralMiner != 0){
            owner = centralMiner;
        }
        balanceOf[owner] = initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = initialSupply;
    }

    //发行代币,向指定的目标账户添加代币,payable使合约在部署时可以转入以太币作为gas
    function mintToken(address target,uint mintedAmount) onlyOwner public payable {
        //判断目标账户是否存在
        if(target != 0){
            //设置目标账户相应的代币余额
            balanceOf[target] = mintedAmount;
            //增加总量
            totalSupply += mintedAmount;
        }
        else{
            revert();
        }
    }

    //实现账户的冻结和解冻
    function freezeAccount(address target,bool _bool) onlyOwner public {
        if(target != 0){
            frozenAccount[target] = _bool;
        }
    }

    //实现账户间代币的转移，在实际项目中应该有一个事件来通知用户，记录转移事件
    function transfer(address _to,uint _value) public {
        //检测交易的发起者是否冻结
        if(frozenAccount[msg.sender]){
            revert();
        }
        else{
            //检测交易发起者代币的余额是否足够
            if(balanceOf[msg.sender] < _value){
                revert();
            }
            else{
                //检测溢出
                if(balanceOf[_to] + _value < balanceOf[_to]) {
                    revert();
                }
                else{
                    //实现代币转移
                    balanceOf[msg.sender] -= _value;
                    balanceOf[_to] += _value;
                }
            }
        }
    }

    //设置代币的买卖价格
    function setPrice(uint newSellPrice,uint newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    //实现卖出代币
    function sell (uint amount) public returns (uint revenue) {
        //检测交易的发起者的账户是否被冻结
        if(frozenAccount[msg.sender]){
            revert();
        }
        else{
            //检测交易发起者的账户代币余额是否足够
            if(balanceOf[msg.sender] < amount){
                revert();
            }
            else{
                //将相应数量的代币给合约的拥有者
                balanceOf[owner] += amount;
                //卖家的账户减去相应的余额
                balanceOf[msg.sender] -= amount;

                //计算对应的以太币的价格
                revenue = amount * sellPrice;
                //向卖家的账户发送相应数量的以太币
                if(msg.sender.send(revenue)){
                    return revenue;
                }
                else{
                    //如果以太币发送失败，则终止程序，并恢复状态变量
                    revert();
                }
            }
        }
    }

    //实现买操作
    function buy () public payable returns (uint amount) {
        //检测买家购买的价格是否大于零
        if(buyPrice <=0){
            revert();
        }
        //根据用户发送的以太币的数量和代币的买价，计算出代币的数量
        amount = msg.value / buyPrice;
        //检测合约的拥有者是否有足够多的代币
        if(balanceOf[owner] < amount){
            revert();
        }
        //向合约的拥有者转移以太币
        if(!owner.send(msg.value)){
            //如果失败，则终止操作
            revert();
        }
        //从拥有者的账户减去相应数量的代币
        balanceOf[owner] -= amount;
        //买家的账户增加相应数量的代币
        balanceOf[msg.sender] += amount;

        return amount;
    }

    //使用Fallback函数实现向只能合约转入以太币，这些以太币用于gas
    function () public payable {}
}
