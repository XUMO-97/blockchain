pragma solidity ^0.4.16;

/*
为了方便在网页编译器上部署,将调用的DateTime合约直接写在同一个sol文件中,并继承使用
但是去掉了DateTime合约后部分的toTimestamp内容,因为在本合约中没有用处
注意!!由于调用的时间戳为格林尼治时间,在国内使用时需要在getHour处加上8就是北京时间
*/
contract DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
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
                return uint8((timestamp / 60 / 60) % 24);
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


//此处开始实现程序功能的主要代码即ClockInOut合约的代码
contract ClockInOut is DateTime {

    //员工结构体
    struct staff {
        uint staffId; //定义员工号
        string name; //定义员工名
        bool clockIn; //是否上班打卡
        bool clockOut; //是否下班签到
        uint registeredTime; //以时间戳形式记录员工注册的时间
    }

    uint numStaffs; //统计员工数量
    mapping (uint => staff) public staffs; //以键对的形式存储员工信息

    //构造函数
    function ClockInOut() public {
        numStaffs = 0;
    }

    //注册新增员工信息,需要传入员工名和员工号
    function newStaff(uint staffId, string memory name) public {
        //创建一个员工对象,并存储到staffs里面
        staffs[staffId] = staff(staffId,name,false,true,now);
        numStaffs = numStaffs + 1; //统计员工数
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
        uint hour = getHour(now);
        if (staffs[id].clockIn == true && hour >= 0 && hour <= 24) {
            staffs[id].clockOut = true;
            staffs[id].clockIn = false;
            return "打卡成功.";
        }else{
            return "打卡失败.";
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
