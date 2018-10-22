pragma solidity ^0.4.18;

contract clockInOut {

    //员工结构体
    struct staff {
        uint staffId; //定义员工号
        string name; //定义员工名
        bool clockIn; //是否上班打卡
        bool clockOut; //是否下班签到
    }

    uint numStaffs; //统计员工数量
    mapping (uint => staff) public staffs; //以键对的形式存储员工信息

    //构造函数
    constructor () public {
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
        if (staffs[id].clockOut == true) {
            staffs[id].clockIn = true;
            staffs[id].clockOut = false;
        }else{
            revert();
        }
    }

    //输入员工号进行打卡
    function clockOut(uint id) public {
        //通过id获取id对应的staff对象
        if (staffs[id].clockIn == true) {
            staffs[id].clockOut = true;
            staffs[id].clockIn = false;
        }else{
            revert();
        }
    }

    //调用函数读取统计的员工数量
    function getNumStaffs() public view returns(uint numStaffs) {
        return uint(numStaffs);
    }

}
