pragma solidity ^0.4.16;

//此处开始实现程序功能的主要代码即ClockInOut合约的代码
contract ClockInOut {

    //员工结构体
    struct staff {
        uint staffId; //定义员工号
        string name; //定义员工名
        bool clockIn; //是否上班打卡
        bool clockOut; //是否下班签到
    }

    uint numStaffs; //统计员工数量
    mapping (uint => staff) public staffs; //以键对的形式存储员工信息

    //取得当前的时间,now为当前部署链上最新区块的时间戳,如果在公链或测试链上部署,会导致十几分钟不等的误差

    uint public timestamp = now;

    //注意!!由于调用的时间戳为格林尼治时间,在国内使用时需要在getHour处加上8就是北京时间
    function getHour(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60 / 60) % 24 + 8);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60) % 60);
    }

    //构造函数
    function ClockInOut() public {
        numStaffs = 0;
    }

    //注册新增员工信息,需要传入员工名和员工号
    function newStaff(uint staffId, string memory name) public {
        //创建一个员工对象,并存储到staffs里面
        staffs[staffId] = staff(staffId,name,false,true);
        numStaffs = numStaffs + 1; //统计员工数
    }

    //通过输入员工号进行签到
    function clockIn(uint id) public {
        hour = getHour(timestamp);
        if (staffs[id].clockOut == true && hour >= 16 && hour <= 17) {
            staffs[id].clockIn = true;
            staffs[id].clockOut = false;
        }else{
            revert();
        }
    }

    //输入员工号进行打卡
    function clockOut(uint id) public {
        //通过id获取id对应的staff对象
        hour = getHour(timestamp);
        if (staffs[id].clockIn == true && hour >= 16 && hour <= 17) {
            staffs[id].clockOut = true;
            staffs[id].clockIn = false;
        }else{
            revert();
        }
    }

    //调用函数读取统计的员工数量
    function getNumStaffs() public view returns(uint) {
        return numStaffs;
    }

    //借助后备函数(fallback function)让合约能够接受转账
    function () payable {

    }

}
