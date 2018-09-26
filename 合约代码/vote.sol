pragma solidity ^0.4.18;
contract vote {

    //定义投票人的结构体
    struct voter {
        uint weight; //投票人的权重
        bool voted; //是否已投票
        address delegate; //委托代理人投票
        uint vote; //投票主题的序号
    }

    //定义投票主题的结构
    struct proposal {
        bytes32 name; //投票主题的名字
        uint votecount; //主题被投票的票数
    }

    //定义投票的发起者
    address public chairperson;

    //所有的投票人
    mapping (address => voter) public voters;

    //具体的投票主题
    proposal[] public proposals;

    //构造函数，如果在比较老的编译器版本中，可以使用function vote(){}作为构造函数
    constructor (bytes32[] proposalname) public {
        //初始化投票的发起人，就是当前合约的部署者，也可以改变成别人
        chairperson = msg.sender;
        //给发起人投票权
        voters[chairperson].weight = 1;

        //初始化投票的主题
        for(uint i = 0; i < proposalname.length; i++){
            proposals.push(proposal({name:proposalname[i],votecount:0}));
        }
    }

    //添加投票者
    function giverighttovote(address _voter) public {
        //只有投票发起人才能添加投票人
        //添加的投票者的状态必须为没有投过票
        if(msg.sender != chairperson || voters[_voter].voted){
            revert();
        }
        //赋予投票人投票权
        voters[_voter].weight = 1;
    }

    //将自己的票委托给to来投票
    function delegate(address to) public {
        //检查交易的发起者是否已经投过票
        voter storage sender = voters[msg.sender];
        //如果已经投过票，则终止程序
        if(sender.voted){
            revert();
        }
        assert(sender.voted == false);
        require(sender.voted == false);

        while(voters[to].delegate != address(0)){
            to = voters[to].delegate;
            if(to == msg.sender){
                revert();
            }
        }

        //交易的发起者不能再投票了
        sender.voted = true;
        //设置交易的发起者的投票代理人
        sender.delegate = to;

        //找到代理人
        voter storage delegates = voters[to];
        //检查代理人是否已经投票
        if(delegates.voted){
            //如果是，则把票都投给代理人所投的主题
            proposals[delegates.vote].votecount += sender.weight;
        }
        else{
            //如果不是，则把投票的权重给予代理人
            delegates.weight += sender.weight;
        }
    }

    //开始投票
    function voting(uint pid) public {
        //找到投票者
        voter storage sender = voters[msg.sender];
        //检查是否已经投过票
        if(sender.voted){
            //如果已经投过票，程序终止
            revert();
        }
        else{
            //如果没有投过票，则进行投票
            sender.voted = true; //将用户设置为已投票的状态
            sender.vote = pid; //设置当前用户所投票的主题的编号
            proposals[pid].votecount += sender.weight; //把当前用户的投票权重给予相应的主题
        }
    }

    //计算票数最多的主题
    function winid() public view returns(uint winnerid) {
        //声明一个用来比大小的临时变量
        uint wincount = 0;
        //编列主题，找到投票数最大的主题
        for(uint i = 0; i < proposals.length; i++){
            if(proposals[i].votecount > wincount){
                wincount = proposals[i].votecount;
                winnerid = i;
            }
        }
    }

    function winname() public view returns(bytes32 winnername){
        if(proposals[winid()].name == proposals[0].name){
            //设置一个弃票主题，将命名的第一个主题作为弃票主题
            winnername = 0x00;
        }
        else{
            winnername = proposals[winid()].name;
        }
    }

    //调用kill函数销毁合约
    function kill() public {
        if (chairperson == msg.sender) {
            selfdestruct(chairperson);
        }
    }
}
