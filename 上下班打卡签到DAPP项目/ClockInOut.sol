pragma solidity ^0.4.16;

//请在http://dapps.oraclize.it中使用0.4.20以下的编译器, 选择JavaScript VM模式,并在部署合约时输入一定量的eth进行测试,否则会各种报错
//调用oraclize的支持，注意oraclizeAPI.sol目前并不能使用，可以在github看到代码只有一行，可能是开发者还没写完对solidity0.5的支持
import "github.com/oraclize/ethereum-api/oraclizeAPI_0.4.sol";
/*
    DateTime是计算当前时间的合约,为了测试部署方便就直接先包括在合约中
    使用oraclizeAPI来获取当前时间,可能会有几秒钟的误差,不过无伤大雅
*/


//此处开始实现程序功能的主要代码即ClockInOut合约的代码
contract ClockInOut is usingOraclize {

    //员工结构体
    struct staff {
        uint staffId; //定义员工号
        string name; //定义员工名
        bool clockIn; //是否上班打卡
        bool clockOut; //是否下班签到
    }

    uint numStaffs; //统计员工数量
    mapping (uint => staff) public staffs; //以键对的形式存储员工信息

    //取得当前的时间
    string public timestamp;
    uint public hour;

    event newOraclizeQuery(string description);
    event newTimestampMeasure(string timestamp);

    function __callback(bytes32 myid, string result) {
       timestamp = result;
       newTimestampMeasure(timestamp);
       //利用orcalize的parseInt获取时间戳的uint格式
       hour = getHour(parseInt(timestamp));
    }

    //通过update函数向oraclize获取当前的时间戳,注意该时间戳timestamp为string格式需要转换
    function update() payable {
        newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        oraclize_query("WolframAlpha", "Timestamp now");
    }

    //构造函数
    function ClockInOut() public {
        numStaffs = 0;
        //OAR = OraclizeAddrResolverI(0xedc373ce361e7f2d965438829531ea817ec7c322);
    }

    //注册新增员工信息,需要传入员工名和员工号
    function newStaff(uint staffId, string memory name) public {
        //创建一个员工对象,并存储到staffs里面
        staffs[staffId] = staff(staffId,name,false,true);
        numStaffs = numStaffs + 1; //统计员工数
    }

    //通过输入员工号进行签到
    function clockIn(uint id) public {
        update();
        if (staffs[id].clockOut == true && hour >= 14 && hour <= 15) {
            staffs[id].clockIn = true;
            staffs[id].clockOut = false;
        }else{
            revert();
        }
    }

    //输入员工号进行打卡
    function clockOut(uint id) public {
        //通过id获取id对应的staff对象
        update();
        if (staffs[id].clockIn == true && hour >= 14 && hour <= 15) {
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

    function getHour(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60 / 60) % 24 + 8);
    }

    //借助后备函数(fallback function)让合约能够接受转账
    function () payable {

    }

}
