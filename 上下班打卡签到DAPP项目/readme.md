目前的程序直接获取最后区块创建的时间戳block.timestamp来计算签到打卡的时间,如果在公链或者测试链上部署可能会有十几分钟不等的误差,建议在创建区块时间间隔较短的私有链上部署测试.

测试程序请使用ClockInOut-test.sol在`http://remix.ethereum.org/`上部署,建议选用0.4.20以下的solidity版本.

尝试使用oraclize来获取最新时间戳,可以将误差缩小到几秒钟之内,使用oraclize自带的IDE`http://dapps.oraclize.it`可以在**JavaScript VM**模式下进行编译部署合约.

但是使用该IDE操作并不能够向合约中发送eth来维持支付gas的费用,导致了只能够update一次即只能获取一次最新时间戳,如果向合约中发送eth会导致操作码错误的提示.

搜索google和百度之后,目前并没有发现具体原因.

所以尝试使用testrpc创建测试链环境,再通过remix和MetaMask来部署合约,就可以使用MetaMask钱包向合约地址发送eth来支付gas消耗.

这种方法必须要使用ethereum-bridge来建立testrpc与oraclize的连接,否则无法引用OraclizeAPI的支持.

目前在打在ethereum-bridge时遇到一些小问题,正在解决中...

成功了!之所以无法在testrpc中向部署好的合约转账是因为没有添加fallback function导致合约不能接受转账

添加fallback function之后就可以完整的部署,并在truffle console与合约交互,但是不太方便,再试试用oraclize的IDE编译
