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
    function ClockInOut() public payable {
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

    //contract DateTime中的内容直接在合约中部署调取使用
    //注意!!由于调用的时间戳为格林尼治时间,在国内使用时需要在getHour处加上8就是北京时间
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

    function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
            return toTimestamp(year, month, day, 0, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
            return toTimestamp(year, month, day, hour, 0, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
            return toTimestamp(year, month, day, hour, minute, 0);
    }

    function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
            uint16 i;

            // Year
            for (i = ORIGIN_YEAR; i < year; i++) {
                    if (isLeapYear(i)) {
                            timestamp += LEAP_YEAR_IN_SECONDS;
                    }
                    else {
                            timestamp += YEAR_IN_SECONDS;
                    }
            }

            // Month
            uint8[12] memory monthDayCounts;
            monthDayCounts[0] = 31;
            if (isLeapYear(year)) {
                    monthDayCounts[1] = 29;
            }
            else {
                    monthDayCounts[1] = 28;
            }
            monthDayCounts[2] = 31;
            monthDayCounts[3] = 30;
            monthDayCounts[4] = 31;
            monthDayCounts[5] = 30;
            monthDayCounts[6] = 31;
            monthDayCounts[7] = 31;
            monthDayCounts[8] = 30;
            monthDayCounts[9] = 31;
            monthDayCounts[10] = 30;
            monthDayCounts[11] = 31;

            for (i = 1; i < month; i++) {
                    timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
            }

            // Day
            timestamp += DAY_IN_SECONDS * (day - 1);

            // Hour
            timestamp += HOUR_IN_SECONDS * (hour);

            // Minute
            timestamp += MINUTE_IN_SECONDS * (minute);

            // Second
            timestamp += second;

            return timestamp;
    }

}
