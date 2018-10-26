pragma solidity ^0.4.16;
//为了方便在网页编译器上部署,将调用的DateTime合约直接写在同一个合约中使用

//此处开始实现程序功能的主要代码即ClockInOut合约的代码
contract ClockInOut {

    //员工签到时间结构体,用于记录员工所有签到的日期
    struct clockTime {
        uint time;
    }

    //员工结构体
    struct staff {
        uint staffId; //定义员工号
        string name; //定义员工名
        bool registered; //标明该员工号是否已经被注册
        bool clockIn; //是否上班打卡
        bool clockOut; //是否下班签到
        uint registeredTime; //以时间戳形式记录员工注册的时间
        uint clockDays;//总签到的天数
        mapping (uint => clockTime) clockTimes; //签到日期的映射
    }

    uint numStaffs; //统计员工数量
    mapping (uint => staff) public staffs; //以键对的形式存储员工信息

    //构造函数
    function ClockInOut() public {

    }

    //注册新增员工信息,需要传入员工名和员工号
    function newStaff(uint staffId, string memory name) public returns(string) {
        if (staffs[staffId].registered == true) {
            return "该员工号已被注册.";
        }else{
            //创建一个员工对象,并存储到staffs里面
            staffs[staffId] = staff(staffId,name,true,false,true,now,0);
            numStaffs = numStaffs + 1; //统计员工数
            return "员工注册成功.";
        }
    }

    //通过输入员工号进行签到
    function clockIn(uint id) public returns(string) {
        //取得当前的时间,now为当前部署链上最新区块的时间戳,如果在公链或测试链上部署,可能会导致十几分钟不等的误差
        uint hour = getHour(now);
        //为测试方便将时间签到时间定为24小时
        if (staffs[id].clockOut == true && hour >= 0 && hour <= 24) {
            staffs[id].clockIn = true;
            staffs[id].clockOut = false;
            return "签到成功.";
        }else{
            return "签到失败.";
        }
    }

    //输入员工号进行打卡
    function clockOut(uint id) public returns(string) {
        /*
            此处定义变量来取得now的值看似多此一举,浪费了空间
            但是如果直接使用now来进行判定可能会产生误差
            比如在两个now的调用之间忽然产生了一个新块
            虽然这种情况发生的几率异常小,因为两个now之间执行的速度非常快
            但是为了程序逻辑的完整性,还是定义一下
            因为如果之后使用oraclize调取即时时间的话,必须要这么操作,以保证判定的正确性和稳定性
        */
        uint nowTime = now;
        uint hour = getHour(nowTime);
        if (staffs[id].clockIn == true && hour >= 0 && hour <= 24) {
            staffs[id].clockOut = true;
            staffs[id].clockIn = false;
            staffs[id].clockDays = staffs[id].clockDays + 1;
            //创建一个临时的memory结构体来调用staff结构体中的clockTime结构体
            staff storage s = staffs[id];
            uint clockDaysNow = s.clockDays;
            //创建一个临时的memory结构体,并将其拷贝到storage中来给clocktime结构体赋值,双重调用可能会有点绕
            clockTime storage c = s.clockTimes[clockDaysNow];
            c.time = nowTime;
            return "打卡成功.";
        }else{
            return "打卡失败.";
        }
    }

    //调用函数读取统计的员工数量
    function getNumStaffs() public view returns(uint) {
        return numStaffs;
    }

    //调出员工最新签到的时间,仅用于测试程序,正常来说需要打印出所有签到的时间,不过这得配合ui界面来显示,例如一个日历上打钩
    function getStaffsClockTimes(uint staffId) public returns(uint year,uint month,uint day,uint hour) {
        //参照打卡函数中的双重调用来获取最新的签到时间
        staff storage s = staffs[staffId];
        uint latestClockDay = s.clockDays;
        clockTime storage c = s.clockTimes[latestClockDay];
        uint latestClockTime = c.time;
        //此时获取了该员工最新签到时间的时间戳,接下来利用DateTime将它转换成具体的年月日后返回
        year = getYear(latestClockTime);
        month = getMonth(latestClockTime);
        day = getDay(latestClockTime);
        hour = getHour(latestClockTime);
        return (year,month,day,hour);
    }

    //借助后备函数(fallback function)让合约能够接受转账,从而支付gas
    function () payable public {

    }

    /*
        以下为DateTime合约中的内容,详见https://github.com/pipermerriam/ethereum-datetime
        但是删减了DateTime合约后部分的toTimestamp内容,因为在本合约中没有用处
        注意!!由于调用的时间戳为格林尼治时间,在国内使用时需要在getHour处加上8就是北京时间
    */
    struct _DateTime {
            uint16 year;
            uint8 month;
            uint8 day;
            uint8 hour;
            uint8 minute;
            uint8 second;
            uint8 weekday;
    }

    uint constant DAY_IN_SECONDS = 86400;
    uint constant YEAR_IN_SECONDS = 31536000;
    uint constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint constant HOUR_IN_SECONDS = 3600;
    uint constant MINUTE_IN_SECONDS = 60;

    uint16 constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) public pure returns (bool) {
            if (year % 4 != 0) {
                    return false;
            }
            if (year % 100 != 0) {
                    return true;
            }
            if (year % 400 != 0) {
                    return false;
            }
            return true;
    }

    function leapYearsBefore(uint year) public pure returns (uint) {
            year -= 1;
            return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
            if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                    return 31;
            }
            else if (month == 4 || month == 6 || month == 9 || month == 11) {
                    return 30;
            }
            else if (isLeapYear(year)) {
                    return 29;
            }
            else {
                    return 28;
            }
    }

    function parseTimestamp(uint timestamp) internal pure returns (_DateTime dt) {
            uint secondsAccountedFor = 0;
            uint buf;
            uint8 i;

            // Year
            dt.year = getYear(timestamp);
            buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
            secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

            // Month
            uint secondsInMonth;
            for (i = 1; i <= 12; i++) {
                    secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                    if (secondsInMonth + secondsAccountedFor > timestamp) {
                            dt.month = i;
                            break;
                    }
                    secondsAccountedFor += secondsInMonth;
            }

            // Day
            for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                    if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                            dt.day = i;
                            break;
                    }
                    secondsAccountedFor += DAY_IN_SECONDS;
            }

            // Hour
            dt.hour = getHour(timestamp);

            // Minute
            dt.minute = getMinute(timestamp);

            // Second
            dt.second = getSecond(timestamp);

            // Day of week.
            dt.weekday = getWeekday(timestamp);
    }

    function getYear(uint timestamp) public pure returns (uint16) {
            uint secondsAccountedFor = 0;
            uint16 year;
            uint numLeapYears;

            // Year
            year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
            numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

            secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
            secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

            while (secondsAccountedFor > timestamp) {
                    if (isLeapYear(uint16(year - 1))) {
                            secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                    }
                    else {
                            secondsAccountedFor -= YEAR_IN_SECONDS;
                    }
                    year -= 1;
            }
            return year;
    }

    function getMonth(uint timestamp) public pure returns (uint8) {
            return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) public pure returns (uint8) {
            return parseTimestamp(timestamp).day;
    }

    function getHour(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60 / 60) % 24 + 8);
    }

    function getMinute(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / 60) % 60);
    }

    function getSecond(uint timestamp) public pure returns (uint8) {
            return uint8(timestamp % 60);
    }

    function getWeekday(uint timestamp) public pure returns (uint8) {
            return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
    }

}
