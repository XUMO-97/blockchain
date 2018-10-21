# Solidity学习笔记

## 一.智能合约介绍

### 1.什么是智能合约？

​	在区块链上运行的程序，通常称为智能合约（Smart Contract）。

​	所以通常会把写区块链程序改称写智能合约。

​	简单点来讲，合约就是运行在区块链上的一段程序。

​	solidity是以太坊编写只能合约目前最流行的编程语言。

### 2.一个完整的智能合约与注释示例。

```soli
//pragma solidity表示solidity版本声明，0.4.4为版本，^表示向上兼容但不包括0.0.5及以上。
pragma solidity ^0.4.4; 

//contract是合约声明的关键字，counter为合约名字，合起来就是声明一个Counter合约。
contract Counter {       
 
	//count和owner是状态变量，合约中的状态变量相当于类中的属性变量。
    uint count = 0; 
    address owner;

	//function Counter()函数名与合约名相同时，此函数是合约的构造函数，当合约对象创建时，会先调用构造函数对相关数据进行初始化处理
    function Counter() { 
       owner = msg.sender;
    } 

	//unction increment() public和function getCount() constant returns (uint)都是Counter合约的成员函数
    function increment() public {  
       uint step = 10;             //当调用increment()函数时，会让状态变量count增加step
       if (owner == msg.sender) {  //increment()方法中声明的step就是局部变量。局部变量只在离它最近的{}内容使用。
          count = count + step;
       }
    }
 
 	//当调用getCount()时会得到状态变量count的值
    function getCount() constant returns (uint) {   
       return count;
    }

	//析构函数和构造函数对应，构造函数是初始化数据，而析构函数是销毁数据。
	//在counter合约中，当我们手动调用kill函数时，就会调用selfdestruct(owner)销毁当前合约。
    function kill() {
       if (owner == msg.sender) { 
          selfdestruct(owner);   
       }                         
    }
}
```



## 二.HelloWorld智能合约

```soli
/* 我们的Counter合约将increment方法被调用的次数存储到count属性中。并且每个人都可以通过getCount方法获取区块链上count的值。 */
pragma solidity ^0.4.4;

contract Counter {
    // 定义一个uint类型的count变量
    uint count = 0;

    // 当这个方法被调用时count的值会加1 
    function increment() public {
       count = count + 1;
    }

    // 读取count数据 
    function getCount() constant returns (uint) {
       return count;
    }
}
```



## 三.Solidity合约的结构

### 1.版本声明

```soli
pragma solidity ^0.4.4;
```

​	`pragma solidity`代表`solidity`版本声明，`0.4.4`代表`solidity`版本，`^`表示向上兼容，`^0.4.4`表示`solidity`的版本在`0.4.4 ~ 0.5.0(不包含0.5.0)`的版本都可以对上面的合约代码进行编译，`0.4.5`,`0.4.8`等等可以用来修复前面的`solidity`存在的一些`bug`。

### 2.合约声明

​	`contract`是合约声明的关键字，`Counter`是合约名字，`contract Counter`就是声明一个`Counter`合约。

​	`contract`相当于其他语言中的`class`，`Counter`相当于类名，`contract Counter`相当于`class Counter extends Contract`。

### 3.状态变量

```soli
uint count = 0;
address owner;
```

​	`count`和`owner`就是状态变量，合约中的状态变量相当于`类`中的属性变量。

### 4.构造函数

​	`function Counter()`函数名和合约名相同时，此函数是合约的构造函数，当合约对象创建时，会先调用构造函数对相关数据进行初始化处理。

​	但随着版本更新，更建议使用`constructor(){}`来声明构造函数，一些比较旧的编译软件或者mist客户端可能会在使用`function Counter()`来声明构造函数时报错

### 5.成员函数

​	`function increment() public`和`function getCount() constant returns (uint)`都是`Counter`合约的成员函数，成员函数在iOS里面叫做方法、行为，合约实例可以调用成员函数处理相关操作。当调用`increment()`函数时，会让`状态变量count`增加`step`。当调用`getCount()`时会得到状态变量`count`的值。

### 6.本地变量

```soli
function increment() public {
   uint step = 10;
   if (owner == msg.sender) {
      count = count + step;
   }
}
```

​	`increment()`方法中声明的`step`就是局部变量。局部变量只在离它最近的`{}`内容使用。

### 7.构析函数

​	`析构函数`和`构造函数`对应，构造函数是初始化数据，而析构函数是销毁数据。在`counter`合约中，当我们手动调用`kill`函数时，就会调用`selfdestruct(owner)`销毁当前合约。

​	当一个合约通过kill方法将其杀死，那么我们将不能再和这个合约进行交互，如果一个合约被销毁，那么当前地址指向的是一个僵尸对象，这个僵尸对象调用任何方法都会抛出异常。你想销毁合约，需要调用`selfdestruct(address)`才能将其进行销毁。

### 8.完整的智能合约示例

​	部署合约时，因为要往区块链写入数据，需要矿工进行验证，所以需要花费一些gas奖励给矿工，还有当我们每次调用increment方法时，也属于写入数据，同样需要花费gas，但是调用getCount方法时只是从区块链读取数据，无需验证，读取数据无须花费gas。

​	合约代码及注释:

```soli
//声明solidity版本
pragma solidity ^0.4.4; 

//声明一个counter合约，contract是声明合约的关键字，counter是合约名自己随便起
contract Counter {   
 
 	//count和owner是状态变量
    uint count = 0; 
    address owner;

	//function counter函数名与合约名相同，此函数为合约的构造函数，但随着版本更新，更建议使用constructor(){}来声明构造函数
    function Counter() {   
       owner = msg.sender;
    } 
    
    //成员函数，即方法、行为，increment会让状态函数count增加step
    function increment() public { 
       //increment中声明的step是局部变量，局部变量只在离它最近的{}中使用
       uint step = 10;	           
       if (owner == msg.sender) {
          count = count + step;
       }
    }
 
 	//调用getcount时会得到count的值
    function getCount() constant returns (uint) { 
       return count;
    }

	//析构函数，与构造函数对应，用于销毁数据，调用kill函数时，就会调用selfdestruct(owner)销毁当前合约
    function kill() { 
       if (owner == msg.sender) {  //调查谁在使用合约,只有创建者才可以销毁合约
          selfdestruct(owner);
       }
    }
}
```



## 四.值类型与引用类型

​	由于Solidity是一个静态类型的语言，所以编译时需明确指定变量的类型（包括本地变量或状态变量），Solidity编程语言提供了一些基本类型(elementary types)可以用来组合成复杂类型。

### 1.值类型(Value Type)

值类型包含：

​	①布尔(Booleans)
​	②整型(Integer)
​	③地址(Address)
​	④定长字节数组(fixed byte arrays)
​	⑤有理数和整型(Rational and Integer Literals，String literals)
​	⑥枚举类型(Enums)
​	⑦函数(Function Types)

例如：

```soli
int a = 100;  // a == 100
int b = a;    // b == 100,a == 100
b = 300;      // b == 300,a == 100
```

​	由上面的数据看，执行 b = a时，会将a的值临时拷贝一份传给b，所以当你修改b时，其实与a没任何关系。

### 2.引用类型(Reference Types)

引用类型包含：

​	①不定长字节数组（bytes）
​	②字符串（string）
​	③数组（Array）
​	④结构体（Struts）

​	引用类型，赋值时，我们可以值传递，也可以引用即地址传递，如果是值传递，和上面的案例一样，修改新变量时，不会影响原来的变量值，如果是引用传递，那么当你修改新变量时，原来变量的值会跟着变化，这是因为新就变量同时指向同一个地址的原因。

​	引用类型中如何类比值传递？

​	值传递伪代码（以iOS中可变字符串NSMutableString为例子）：

```soli
//创建一个可变的字符串name
NSMutableString *name = [@"xumo" mutableCopy];  // name == "xumo"

NSMutableString *name1 = [name copy]; //name1 == "xumo", name == "xumo"

name1 = "xumo123"; //name1 == "xumo123",name == "xumo"
引用类型中如何类比引用传递？

//创建一个可变的字符串name
NSMutableString *name = [@"xumo" mutableCopy];  // name == "xumo"
```



## 五.状态变量、局部变量与memory、storage

### 1.通过一段代码认识状态变量、局部变量

```soli
pragma solidity ^0.4.4;

contract Person {
	//_age和_name属于状态变量
	int public _age;    
	string public _name;

	//age，name属于局部变量
	function Person(int age,string name) {   
		_age = age;
		_name = name;
	}
	
	//name，name1属于局部变量
	function f(string name) {    
		var name1 = name;
     	...
	}
}
```

### 2.值类型代码演示

    pragma solidity ^0.4.4;
    
    contract Person {
    
        int public _age;
        
        function Person(int age) {
          _age = age;
        }
    
        function f() {
          midifyAge(_age);
        }
    
        function midifyAge(int age) {
          age = 100;
        }
    }
​	创建合约时，因为构造函数中需要传入一个参数age，传入值29

​	合约创建完成后，可以在界面看到`_age`的初始值为29

​	接下来我们切换到f方法，然后点击执行，因为`_age`是值类型，所以在函数传参或者将值类型的变量值赋值给一个新变量，当我们尝试修改新变量时，原来的值类型变量值并不会发生任何变化，在本案例中，当我们调用`midifyAge(_age)`代码时，我们可以理解成，创建了一个临时变量`age`，并且将`_age`的值传给了`age`，因为是值传递，当我们尝试在`midifyAge`函数中修改新变量`age`的值时，原来的变量值`_age`的值保持不变

### 3.引用类型memory/storage

​	引用类型的变量有两种，memory和storage

​	memory(值传递)

    pragma solidity ^0.4.4;
    
    contract Person {
    
        string public  _name;
        
        function Person() {
            _name = "xumo";
        }
    
        function f() {
            
            modifyName(_name);
        }
    
    	// 等价于function modifyName(string memory name)
        function modifyName(string name)  { 
        	// 等价于 string name1 = name   2x2=四种随意换
            var name1 = name;                
            bytes(name1)[0] = 'X';
        }
    }
​	不难看出，当引用类型作为函数参数时，它的类型默认为`momory`，函数参数为`memory`类型的变量给一个变量赋值时，这个变量的类型必须和函数参数类型一致，所以可以用`string memory name1 = name; 或者 var name1 = name`; `var`声明一个变量时，这个变量的类型最终由赋给它值的类型决定。

​	任何函数参数当它的类型为引用型时，这个函数参数都默认为`memory`，`memory`类型的变量会临时拷贝一份存储到内存中，当我们将这个参数值赋给一个新的变量，并尝试去修改这个新的变量的值时，最原始的变量的值并不会发生变化，如上案例中，创建合约时，`_name`的值为`xumo`，当我们调用`f()`函数时，`f()`函数会将`_name`的值赋给临时的`memory`变量`name`，换句话说，因为`name`的类型为`memory`，所以`name`和`_name`会分别指向不同的对象，当我们尝试去修改`name`指针指向的值时，`_name`所指向的内容不会发生变化。

storage(指针传递)

​	当函数参数为memory类型时，相当于值传递，而storage类型的函数参数将是指针传递

​	如果要在`modifyName`函数中通过传递过来的指针修改`_name`的值，那么必须将函数参数的类型显示设置为`storage`类型，`storage`类型拷贝的不是值，而是`_name`指针，当调用`modifyName(_name)`函数时，相当于同时有`_name`，`name`，`name1`三个指针同时指向一个对象，我们可以通过三个指针中的任何一个指针修改他们共同指向的内容的值。

    pragma solidity ^0.4.4;
    
    contract Person {
    
        string public  _name;
        
        function Person() {
            _name = "xumo";
        }
    
        function f() {
            
            modifyName(_name);
        }
    
        function modifyName(string storage name)  {
        
            var name1 = name;    //等价与string name1 = name;
            bytes(name1)[0] = 'X';
        }
    }
    string public  _name;
    
    function Person() {
        _name = "xumo";
    }
    
    function f() {
        
        modifyName(_name);
    }
    
    function modifyName(string storage name)  {
    
        var name1 = name;    //等价与string name1 = name;
        bytes(name1)[0] = 'X';
    }
​	上述代码会报错，错误为  function modifyName(string storage name)   

​	错误原因:函数默认为public类型，但当我们的函数参数如果为storage类型时，函数的类型必须为internal或者private
将代码修改为 function modifyName(string storage name) internal {}

​	正确代码：

    pragma solidity ^0.4.4;
    
    contract Person {
    
        string public  _name;
        
        function Person() {
            _name = "xumo";
        }
    
        function f() {
            
            modifyName(_name);
        }
    
        function modifyName(string storage name) internal {
        
            var name1 = name;
            bytes(name1)[0] = 'X';
        }
    }
​	部署该合约后，`name`初始值为`xumo`,调用`f()`函数后，`name`为`Xumo`。

## 六、public、internal、private在状态变量和函数中的使用以及继承、重写

### 1.public

​	`public`类型的**状态变量**和**函数**的权限最大，可供外部、子合约、合约内部访问。

```soli
pragma solidity ^0.4.4;

contract Animal {


    string _birthDay; // 生日
    int public _age; // 年龄
    int internal _weight; // 身高
    string private _name; // 姓名
    

    function Animal() {
    	_age = 29;
      	_weight = 170;
      	_name = "Lucky dog";
     	 _birthDay = "2011-01-01";
    }
    
    function birthDay() constant returns (string) {
      	return _birthDay;
    }
    
    function age() constant public returns (int) {
      	return _age;
    }

    function height() constant internal returns (int) {
      	return _weight;
    }

    function name() constant private returns (string) {
      	return _name;
    }
    
}
```

​	在这个合约中，我们通过运行结果不难看出，可供外部调用的一个有三个函数，分别为`birthDay`，`_age`,`age`，也许有人会问，**为什么外部可以调用_age函数呢，为什么外部可以调用_age函数呢，为什么外部可以调用_age函数呢，**原因是因为我们的状态变量`_age`的权限是`public`，当一个状态变量的权限为`public`类型时，它就会自动生成一个可供外部调用的`get`函数。在我们这个合约中，因为`_age`是`public`类型，所以在合约中其实会有一个默认的和状态变量同名的`get函数`，如下所示：

```solidity
function _age() constant public returns (int) {
  	return _age;
}
```

​	在我们显示声明的四个函数中：

```solidity
function birthDay() constant returns (string) {
  	return _birthDay;
}
    
function age() constant public returns (int) {
  	return _age;
}

function height() constant internal returns (int) {
  	return _weight;
}

function name() constant private returns (string) {
 	return _name;
}
```

​	由上面的运行结果，我们知道，这四个函数中，只有`birthDay`、`age`函数可供外部访问，**【PS：age函数是我显示声明的，_age函数是因为状态变量_age为public自动生成的，因为状态变量默认为internal类型，所以不会自动生成可供外部访问的和状态变量同名的函数】**，换句话说，只有`public`类型的函数才可以供外部访问，由此可知，函数声明时，它默认为是`public`类型，而**状态变量声明时，默认为internal类型**。

**小结：**

- 状态变量声明时，默认为`internal`类型，只有显示声明为`public`类型的状态变量才会自动生成一个和状态变量同名的`get`函数以供外部获取当前状态变量的值。
- 函数声明时默认为`public`类型，和显示声明为`public`类型的函数一样，都可供外部访问。

### 2.internal

- `internal`类型的**状态变量**可供**外部**和**子合约**调用。
- `internal`类型的**函数**和`private`类型的函数一样，智能合约自己内部调用，它和其他语言中的`protected`不完全一样。

```soli
pragma solidity ^0.4.4;

contract Animal {

    string _birthDay; // 生日
    int public _age; // 年龄
    int internal _weight; // 身高
    string private _name; // 姓名

    function Animal() {
     	 _age = 29;
     	 _weight = 170;
     	 _name = "Lucky dog";
     	 _birthDay = "2011-01-01";
    }

    function birthDay() constant returns (string) {
    	return _birthDay;
    }

    function age() constant public returns (int) {
      	return _age;
    }

    function height() constant internal returns (int) {
     	return _weight;
    }

    function name() constant private returns (string) {
      	return _name;
    }

}

contract Person is Animal {

    function Person() {

    	_age = 50;
        _weight = 270;
        _birthDay = "2017-01-01";

    }
}
```

​	在这个案例中，`contract Person is Animal`，`Person`合约继承了`Animal`合约的`public/internal`的所有状态变量，但是只能继承父合约中的所有的`public`类型的函数，**不能继承internal/private的函数，不能继承internal/private的函数，不能继承internal/private的函数。**

### 3.private

​	我们在`person`合约中尝试调用`_name`状态变量，你会发现，编译没法通过。

​	因为`_name`状态变量在`Animal`合约中属于`private`私有类型，只能在`Animal`内部使用，所以到我们在子合约`Person`中尝试使用时，就会报错。

### 4.重写

​	子合约**可以将**父合约**的`public`类型的函数，**只能集成public类型的函数，只能集成public类型的函数，只能集成public类型的函数，我们可以直接调用继承过来的函数，当然，我们还可以对继承过来的函数进行重写。

​	重写前:

```soli
pragma solidity ^0.4.4;

contract Animal {

    string _birthDay; // 生日
    int public _age; // 年龄
    int internal _weight; // 身高
    string private _name; // 姓名

    function Animal() {
      	_age = 29;
      	_weight = 170;
      	_name = "Lucky dog";
      	_birthDay = "2011-01-01";
    }

    function birthDay() constant returns (string) {
      	return _birthDay;
    }

    function age() constant public returns (int) {
      	return _age;
    }

    function height() constant internal returns (int) {
      	return _weight;
    }

    function name() constant private returns (string) {
      	return _name;
    }

}

contract Person is Animal {

}
```

 	重写后:

```soli
pragma solidity ^0.4.4;

contract Animal {

    string _birthDay; // 生日
    int public _age; // 年龄
    int internal _weight; // 身高
    string private _name; // 姓名

    function Animal() {
      	_age = 29;
      	_weight = 170;
      	_name = "Lucky dog";
      	_birthDay = "2011-01-01";
    }

    function birthDay() constant returns (string) {
      	return _birthDay;
    }

    function age() constant public returns (int) {
      	return _age;
    }

    function height() constant internal returns (int) {
      	return _weight;
    }

    function name() constant private returns (string) {
      	return _name;
    }

}

contract Person is Animal {

    function birthDay() constant returns (string) {
        
      	return "2020-12-15";
    }
    
}
```



## 七.布尔值(booleans)

​	bool: 可能的取值为常量值true和false

​	支持的运算符：

​	! 逻辑非

​	&& 逻辑与

​	|| 逻辑或

​	== 等于

​	!= 不等于

​	运算符&&和||是短路运算符，如f(x)||g(y)，当f(x)为真时，则不会继续执行g(y)
在f(x)&&g(y)表达式中，当f(x)为false时，则不会执行g(y)

```soli
bool a = true;
bool b = !a;

// a == b -> false
// a != b -> true
// a || b -> true
// a && b -> false
```



## 八.整型(Integer)

### 1.什么是有符号整型，什么是无符号整型

​	**无符号整型**（uint）是计算机编程中的一种数值资料型别。**有符号整型**（int）可以表示任何规定范围内的整数，**无符号整型**只能表示非负数（**0及正数**）。

​	有符号整型**能够表示负数**的代价是其能够存储正数的范围的缩小，因为其约一半的数值范围要用来表示负数。如：`uint8`的存储范围为`0 ~ 255`，而`int8`的范围为`-127 ~ 127`

​	如果用二进制表示：

- **uint8**: **0b**`00000000` ~ **0b**`11111111`，每一位都存储值，范围为**0 ～ 255**
- **int8**：**0b**`11111111` ~ **ob**`01111111`，最左一位表示符号，`1`表示`负`，`0`表示`正`，范围为**-127 ～ 127**

​	`int/uint：`变长的**有符号**或**无符号**整型。变量支持的步长以`8`递增，支持从`uint8`到`uint256`，以及`int8`到`int256`。需要注意的是，`uint`和`int`默认代表的是`uint256`和`int256`。

### 2.支持的运算符

- 比较：`<=`，`<`，`==`，`!=`，`>=`，`>`，返回值为`bool`类型。
- 位运算符：`&`，`|`，（`^`异或），（`~`非）。
- 数学运算：`+`，`-`，一元运算`+`，`*`，`/`，（`%`求余），（`**`次方），（`<<`左移），（`>>`右移）。

​	Solidity目前沒有支持`double/float`，如果是 `7/2` 会得到`3`，即无条件舍去。但如果运算符是字面量，则不会截断(后面会进一步提到)。另外除0会抛异常 ，我们来看看下面的这个例子：

### 3.加 +，减 -，乘 *，除 ／

```solidity
pragma solidity ^0.4.4;

contract Math {

  function mul(int a, int b) constant returns (int) {

  	  int c = a * b;
      return c;
  }

  function div(int a, int b) constant returns (int) {

      int c = a / b;
      return c;
  }

  function sub(int a, int b) constant returns (int) {
      
      return a - b;
  }

  function add(int a, int b) constant returns (int) {

      int c = a + b;
      return c;
  }
}
```



### 4.求余 %

```solidity
pragma solidity ^0.4.4;

contract Math {

  function m(int a, int b) constant returns (int) {

      int c = a % b;
      return c;
  }
}
```



### 5.次方

```solodity
pragma solidity ^0.4.4;

contract Math {

  function m(uint a, uint b) constant returns (uint) {

      uint c = a**b;
      return c;
  }

}
```



### 6.与 &，| 或，非 ～，^ 异或

```soli
pragma solidity ^0.4.4;

contract Math {

  function yu() constant returns (uint) {

      uint a = 3; // 0b0011
      uint b = 4; // 0b0100
    
      uint c = a & b; // 0b0000
      return c; // 0
  }

  function huo() constant returns (uint) {

      uint a = 3; // 0b0011
      uint b = 4; // 0b0100
    
      uint c = a | b; // 0b0111
      return c; // 7
  }

  function fei() constant returns (uint8) {

      uint8 a = 3; // 0b00000011
      uint8 c = ~a; // 0b11111100
      return c; // 0
  }
  
  function yihuo() constant returns (uint) {

      uint a = 3; // 0b0011
      uint b = 4; // 0b0100
    
      uint c = a ^ b; // 0b0111
      return c; // 252
  }
}
```



### 7.位移

```solidity
pragma solidity ^0.4.4;

contract Math {

  function leftShift() constant returns (uint8) {

      uint8 a = 8; // 0b00001000
      uint8 c = a << 2; // 0b00100000
      return c; // 32
  }

  function rightShift() constant returns (uint8) {

      uint8 a = 8; // 0b00001000
      uint8 c = a >> 2; // 0b00000010
      return c; // 2
  }

}
```

- `a << n` 表示a的二进制位向左移动`n`位，在保证位数没有溢出的情况下等价于 `a乘以2的n次方`。
- `a >> n` 表示a的二进制位向右移动`n`位，在保证位数没有溢出的情况下等价于 `a除以2的n次方`。

### 8.整数字面量

​	整数字面量，由包含`0-9`的数字序列组成，默认被解释成十进制。在Solidity中不支持八进制，前导0会被默认忽略，如0100，会被认为是100，【PS：十六进制可以这么写，0x11】。

​	小数由`.`组成，在他的左边或右边至少要包含一个数字。如`1.`，`.1`，`1.3`均是有效的小数。

```solidity
pragma solidity ^0.4.4;

contract IntegerLiteral{
  function integerTest1() constant returns (uint) {
      
    	var i = (2**800 + 1) - 2**800;
    	return i;
  }
  
  function integerTest2() constant returns (uint) {
   
    	var j = 2/4.0*10;
    	return j;
  }
  
  function integerTest3() constant returns (uint) {
    
    
    	var k = 0.5*8;
    	return k;
  }
  
  function integerTest4() constant returns (uint) {
    
    	var c = 1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111112222 - 1111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111;
    
    	return c;
  }
  
}
```



## 九.地址(Address)

### 1.以太坊钱包地址位数

​	以太坊中的地址的长度20字节，一字节等于8位，一共160位，所以address其实亦可以用unit160来声明

​	假如一个以太坊钱包的地址为0xF055775eBD516e7419ae486C1d50C682d4170645

​	0x代表十六进制，以太坊钱包地址是以16进制的形式呈现,如果将F055775eBD516e7419ae486C1d50C682d4170645进行二进制转换，它的二进制刚好160位

### 2.合约拥有者

​	`msg.sender`就是当前调用方法时的发起人，一个合约部署后，通过钱包地址操作合约的人很多，但是如何正确判断谁是合约的拥有者，判断方式很简单，就是第一次部署合约时，谁出的`gas`，谁就对合约具有拥有权。

```solidity
pragma solidity ^0.4.4;


contract Test {
    
    address public _owner;
    
    uint public _number;

    function Test() {
        _owner = msg.sender;
        _number = 100;
    }
    
    function msgSenderAddress() constant returns (address) {
        return msg.sender;
    }
    
    function setNumberAdd1() {
        _number = _number + 5;
    }
    
    function setNumberAdd2() {
        if (_owner == msg.sender) {
            _number = _number + 10;
        }
    }
    
}
```

### 3.合约地址

```sol
pragma solidity ^0.4.4;


// 0x903ad08970c70d10e5fb5b3c26f7b714830afcf6
// 0x62e40877f4747e06197aa1a2b9ac06dd9bb244a3

// 0xf055775ebd516e7419ae486c1d50c682d4170645

// 0xe7795e05d15f7406baf411cafe766fc28eccf35f
// 0xe7795e05d15f7406baf411cafe766fc28eccf35f

contract Test {
    
    address public _owner;
    
    uint public _number;

    function Test() {
        _owner = msg.sender;
        _number = 100;
    }
    
    function msgSenderAddress() constant returns (address) {
        return msg.sender;
    }
    
    function setNumberAdd1() {
        _number = _number + 5;
    }
    
    function setNumberAdd2() {
        if (_owner == msg.sender) {
            _number = _number + 10;
        }
    }
    
    
    function returnContractAddress() constant returns (address) {
        return this;
    }
    
}
```

​	一个合约部署后，会有一个合约地址，这个合约地址就代表合约自己。

​	`this`是人还是鬼?

​	`this`在合约中到底是`msg.sender`还是`合约地址`，由上图不难看出，`this`即是当前合约地址。

### 4.支持的运算符

`<=`，`<`，`==`，`!=`，`>=`和`>`

```soli
pragma solidity ^0.4.4;



contract Test {
    
    address address1;
    address address2;
    
    // <=，<，==，!=，>=和>
    
    
    function Test() {
        address1 = 0xF055775eBD516e7419ae486C1d50C682d4170645;
        address2 = 0xEAEC9B481c60e8cDc3cdF2D342082C349E5D6318;
    }
    
    
    // <=
    function test1() constant returns (bool) {
        return address1 <= address2;
    }
    
    // <
    function test2() constant returns (bool) {
        return address1 < address2;
    }
    
    //  != 
    function test3() constant returns (bool) {
        return address1 != address2;
    }
    
    // >=
    function test4() constant returns (bool) {
        return address1 >= address2;
    }
    
    // >
    function test5() constant returns (bool) {
        return address1 > address2;
    }
}
```



### 5.成员变量和函数

#### ①balance

​	如果我们需要查看一个地址的余额，我们可以使用`balance`属性进行查看。

```solidity
pragma solidity ^0.4.4;

contract addressBalance{
    
    function getBalance(address addr) constant returns (uint){
        return addr.balance;
    }
    
}
```

​	使用`http://remix.ethereum.org/`进行编译

​	在`Account`一栏中，会自动生成`5`个钱包地址供我们测试使用，在我们点击`Create`按钮时，`Account`一栏选中的是哪个钱包地址，我们部署合约时，花费的`gas`就从哪个钱包地址里面扣除，【**PS，这5个钱包地址每次都是系统临时生成，所以在我们开发测试过程中，每次的地址不会相同**】。因为在本案例中，我们部署合约时，用的是第一个`Account`，所以`gas`自然从它里面扣除，大家会发现，其它四个钱包地址中的余额是`ether`，而第一个钱包地址中不到`100`个`ether`。

​	当我们点击`getBalance`获取某个钱包地址的余额时，获取到的余额的单位是`Wei`，一个`ether`等于`1000000000000000000Wei`，`Wei`是最小单位，相当于我们的`1元RMB`等于`100分`。【**PS：1ether等于10的18次方Wei**】

**99999999999996890347 wei == 99.999999999996890347 ether**

​	换成第二个钱包地址，显示的余额刚好为`100000000000000000000 wei`，也就是`100 ether`。

#### 	②this查看当前合约地址余额

```solidity
pragma solidity ^0.4.4;

contract addressBalance{
    
    function getBalance(address addr) constant returns (uint){
        return addr.balance;
    }

}
```

​	将当前合约地址作为参数，由上图所示，当前合约地址余额为`0 wei`。

​	在上面的文章中我们说过，`this`代表当前合约地址，那么如果在代码中我们只是想简单查询当前合约余额，我们可以直接通过`this.balance`进行查询。

```solidity
pragma solidity ^0.4.4;

contract addressBalance{
    
    function getBalance() constant returns (uint){
        return this.balance;
    }
    
    function getContractAddrees() constant returns (address){
        return this;
    }
    
    function getBalance(address addr) constant returns (uint){
        return addr.balance;
    }

}
```

#### ③transfer

​	**transfer：**从合约发起方向某个地址转入以太币(单位是wei)，地址无效或者合约发起方余额不足时，代码将抛出异常并停止转账。

```solidity
pragma solidity ^0.4.4;

contract PayableKeyword{ 
    
    
    // 从合约发起方向 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c 地址转入 msg.value 个以太币，单位是 wei
    function deposit() payable{
        
        address Account2 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        Account2.transfer(msg.value);
    }
  
  
    // 读取 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c 地址的余额
    function getAccount2Balance() constant returns (uint) {
        
        address Account2 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;

        return Account2.balance;
    }  
    
    // 读取合约发起方的余额
    function getOwnerBalance() constant returns (uint) {
        
        address Owner = msg.sender;
        return Owner.balance;
    } 
    
}
```



#### ④send

​	**send：**`send`相对`transfer`方法较底层，不过使用方法和`transfer`相同，都是从合约发起方向某个地址转入以太币(单位是wei)，地址无效或者合约发起方余额不足时，`send`不会抛出异常，而是直接返回`false`。

```solidity
pragma solidity ^0.4.4;

contract PayableKeyword{ 
    
    
    function deposit() payable returns (bool){
        
        address Account2 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        return Account2.send(msg.value);
    }
  
  
    function getAccount2Balance() constant returns (uint) {
        
        address Account2 = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;

        return Account2.balance;
    }  
    
    
    function getOwnerBalance() constant returns (uint) {
        
        address Owner = msg.sender;
        return Owner.balance;
    } 
    
}
```

​	**备注：**这是测试代码，测试方法和`transfer`一样。

**Warning**

**send()方法执行时有一些风险**

- 调用递归深度不能超1024。
- 如果gas不够，执行会失败。
- 所以使用这个方法要检查成功与否。
- `transfer`相对`send`较安全



## 十.字符串(String Literals)

​	字符串可以通过" "或者' '来表示字符串的值，Solidity中的字符串不像C语言一样以\0结束，比如xumo这个字符串的长度就为我们所看见的字母的个数，它的长度是4。

```solidity
pragma solidity ^0.4.4;

contract StringLiterals{ 
    
    string  _name; // 状态变量
    
    //构造函数
    function StringLiterals() {
        // 将我的名字初始化
        _name = "xumo";
    }
    
    // set方法
    function setString(string name) {
        
        _name = name;
    }
    
    // get方法
    function name() constant returns (string) {
        
        return _name;
    }
    
}
```

​	**备注：**`string`字符串不能通过`length`方法获取其长度。

## 十一.固定大小字节数组(Fixed-size byte arrays)

​	`bytesI(1 <= I <= 32)`可以声明固定字节大小的字节数组变量，一旦声明，内部的字节和字节数组长度不可修改，当然可以通过索引读取(只读)对应索引的字节，或者通过`length`读取字节数组的字节数。

### 1.固定大小字节数组(Fixed-size byte arrays)说明

​	固定大小字节数组可以通过 `bytes1`, `bytes2`, `bytes3`, …, `bytes32`来进行声明。

​	PS：`byte`的别名就是 `byte1`。

- `bytes1`只能存储`一个`字节，也就是二进制`8位`的内容。
- `bytes2`只能存储`两个`字节，也就是二进制`16位`的内容。
- `bytes3`只能存储`三个`字节，也就是二进制`24位`的内容。
- ……
- `bytes32`能存储`三十二个`字节，也就是二进制`32 * 8 = 256 `位的内容。

```solidity
pragma solidity ^0.4.4;

contract C {
    
    // 0x6c697975656368756e
    
    byte public a = 0x6c; // 0110 1100
    bytes1 public b = 0x6c; // 0110 1100
    bytes2 public c = 0x6c69; // 0110 1100 0110 1001
    bytes3 public d = 0x6c6979; // 0110 1100 0110 1001 0111 1001
    bytes4 public e = 0x6c697975; // 0110 1100 0110 1001 0111 1001 0111 0101
    
    // ...
    
    bytes8 public f = 0x6c69797565636875; // 0110 1100 0110 1001 0111 1001 0111 0101 0110 0101 0110 0011 0110 1000 0111 0101
    bytes9 public g = 0x6c697975656368756e; // // 0110 1100 0110 1001 0111 1001 0111 0101 0110 0101 0110 0011 0110 1000 0111 0101 0110 1110
    
}
```

​	代码说明:

​	`0x 6c 69 79 75 65 63 68 75 6e`是一个十六进制的整数，它的二进制码是`0b 0110 1100 0110 1001 0111 1001 0111 0101 0110 0101 0110 0011 0110 1000 0111 0101 0110 1110`，在计算机中`0b 0110 1100 0110 1001 0111 1001 0111 0101 0110 0101 0110 0011 0110 1000 0111 0101 0110 1110`二进制码存储的内容其实就是`liyuechun`博主名字的全拼。我们都知道，在计算机中，所有的内容，不管是图片、文字、视频，任何资料我们都可以转换成`二进制`码在计算机中进行存储。

​	在计算机中，`一个字母`或者`一个数字`的存储空间为`一个字节`，也就是`8位`二进制位。`一个汉字`占`两个字节`，也就是`16位`。

​	`0x6c697975656368756e`中，`0x6c`是一个字节，因为16进制中，一个数字等价于二进制中的4位，两个数字等价于8位，刚好一个字节，`0x6c`用二进制来表示是`0b 0110 1100`，`0x6c`对应的内容为`l`,而`0x6c69`对应的内容为`li`,以此内推`0x6c697975656368756e`对应的内容为`liyuechun`。

### 2.操作运算符

- 比较运算符：`<=`, `<`, `==`, `!=`, `>=`, `>`
- 位操作符：`&`, `|`, `^(异或)`, `~ (取反)`, `<< (左移)`, `>> (右移)`
- 索引访问：如果`x`是一个`bytesI`,那么可以通过`x[k](0 < k < I)`获取对应索引的字节，**PS：**x[k]是只读，不可写。

### 3.成员函数

- `.length` 返回字节的个数。（只读）

```solidity
pragma solidity ^0.4.4;

contract C {
    
    bytes9 public g = 0x6c697975656368756e;
    
    function gByteLength() constant returns (uint) {
        
        return g.length;
    }
    
}
```

### 4.不可变特性的深度解析

​	长度不可变:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
    bytes9  name = 0x6c697975656368756e;
    
    function setNameLength(uint length) {
    
        // 报错
        name.length = length;
    }
    
}
```

​	内部字节不可修改:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
    bytes9  name = 0x6c697975656368756e;
    
    function setNameFirstByte(byte b) {
        
        name[0] = b;
    }
    
}
```



## 十二.动态大小字节数组(Dynamically-sized byte array)

### 1.动态大小字节数组(Dynamically-sized byte array)说明

- `string` 是一个动态尺寸的`UTF-8`编码字符串，它其实是一个特殊的可变字节数组，`string`是引用类型，而非值类型。
- `bytes` 动态字节数组，引用类型。

​	根据经验，在我们不确定字节数据大小的情况下，我们可以使用`string`或者`bytes`，而如果我们清楚的知道或者能够将字节书控制在`bytes1` ~ `bytes32`，那么我们就使用`bytes1` ~ `bytes32`，这样的话能够降低存储成本。

### 2.常规字符串 sting 转换为 bytes

​	`string`字符串中没有提供`length`方法获取字符串长度，也没有提供方法修改某个索引的字节码，不过我们可以将`string`转换为`bytes`，再调用`length`方法获取字节长度，当然可以修改某个索引的字节码。

​	源码:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    bytes4 public g = 0x78756d6f;
    
    string public name = "xumo";
    
    function gByteLength() constant returns (uint) {
        
        return g.length;
    }
    
    function nameBytes() constant returns (bytes) { //将字符串name转换为bytes
        
        return bytes(name);
    }
    
    function nameLength() constant returns (uint) {  //用length方法返回字节数
        return bytes(name).length;
    }
    
    function setNameFirstByteForL(bytes1 z) { //意思为传入一个字节的变量 z
        
        // 0x58 => "X"     大写X的值为0x58
        //bytes(name)[0] = z;通过x[k]=z的形式修改，x是bytes类型的字节数组，k是索引，z是bytes1类型的变量值
    }
}
```

​	说明:

```solidity
function nameBytes() constant returns (bytes) {
        
    return bytes(name);
}
```

​	`nameBytes`这个函数的功能是将字符串`name`转换为`bytes`，并且返回的结果为`0x78756d6f`。`0x78756d6f`一共为`4字节`，也就是一个英文字母对应一个字节。

```solidity
function nameLength() constant returns (uint) {
        
    return bytes(name).length;
}
```

​	之前讲过，`string`字符串它并不提供`length`方法帮助我们返回字符串的长度，所以在`nameLength`方法中，我们将`name`转换为`bytes`，然后再调用`length`方法来返回字节数，因为一个字节对应一个英文字母，所以返回的字节数量刚好等于字符串的长度。

```solidity
function setNameFirstByteForL(bytes1 z) {
    
    // 0x58 => "X"
    bytes(name)[0] = z;
}
```

​	如果我们想将`name`字符串中的某个字母进行修改，那么我们直接通过`x[k] = z`的形式进行修改即可。`x`是bytes类型的字节数组，`k`是索引，`z`是`byte1`类型的变量值。

`setNameFirstByteForL`方法中，我就将xumo中的首字母修改成`X`，我传入的`z`的值为`0x58`，即大写的`X`。

### 3.汉字字符串或特殊字符的字符串转换为bytes

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
    string public name = "a!+&520";
    

    function nameBytes() constant returns (bytes) {
        
        return bytes(name);
    }
    
    function nameLength() constant returns (uint) {
        
        return bytes(name).length;
    }
    
}
```

​	在这个案例中，我们声明了一个`name`字符串，值为`a!+&520`，根据`nameBytes`和`nameLength`返回的结果中，我们不难看出，不管是`字母`、`数字`还是`特殊符号`，每个字母对应一个`byte（字节）`。

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
    string public name = "徐墨";
    

    function nameBytes() constant returns (bytes) {
        
        return bytes(name);
    }
    
    function nameLength() constant returns (uint) {
        
        return bytes(name).length;
    }
    
}
```

​	徐墨转换为bytes以后的内容为0xe5be90e5a2a8，一共6个字节，可知一个汉字需要通过3个字节来储存，所以在取字符串时，最好不要带汉字否则计算字符串长度时还得特殊处理。

### 4.创建bytes字节数组

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
    bytes public name = new bytes(1);
    
    
    function setNameLength(uint length) {
        
        name.length = length;
    }
    
    function nameLength() constant returns (uint) {
        
        return name.length;
    }
}
```

​	在setNameLength函数处输入3，可以得到默认是0x00的name变为0x000000，nameLength变为3。

### 5.bytes可变数组length和push两个函数的使用案例

```solidity
pragma solidity ^0.4.4;

contract C {
    
    // 0x6c697975656368756e
    // 初始化一个两个字节空间的字节数组
    bytes public name = new bytes(2);
    
    // 设置字节数组的长度
    function setNameLength(uint len) {
        
        name.length = len;
    }
    
    // 返回字节数组的长度
    function nameLength() constant returns (uint) {
        
        return name.length;
    }
    
    // 往字节数组中添加字节
    function pushAByte(byte b) {
        
        name.push(b);
    }
    
}
```

​	当字节数组的长度只有2时，如果你通过push往里面添加了一个字节，那么它的长度将变为3，当字节数组里面有3个字节，但是你通过length方法将其长度修改为2时，字节数组中最后一个字节将被从字节数组中移除。

### 6.总结

**对比分析：**

- 不可变字节数组

我们之前的笔记中提到过如果我们清楚我们存储的字节大小，那么我们可以通过`bytes1`,`bytes2`,`bytes3`,`bytes4`,……,`bytes32`来声明字节数组变量，不过通过`bytesI`来声明的字节数组为不可变字节数组，字节不可修改，字节数组长度不可修改。

- 可变字节数组

我们可以通过`bytes name = new bytes(length)` - `length`为字节数组长度，来声明可变大小和可修改字节内容的可变字节数组。



## 十三.动态字节数组、固定大小字节数组、string之间的转换关系

### 1.固定大小字节数组之间的转换

​	固定大小字节我们可以通过`bytes0 ~ bytes32`来进行声明，固定大小字节数组的长度不可变，内容不可修改。接下来我们通过下面的代码看看固定大小字节之间的转换关系。

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
   bytes9 name9 = 0x6c697975656368756e;
    
   
   function bytes9ToBytes1() constant returns (bytes1) {
       
       return bytes1(name9);
   }
   
   function bytes9ToBytes2() constant returns (bytes2) {
       
       return bytes2(name9);
   }
   
   function bytes9ToBytes32() constant returns (bytes32) {
       
       return bytes32(name9);
   }
    
}
```

​	当`bytes9`转`bytes1`或者`bytes2`时，会进行低位截断，`0x6c697975656368756e`转换为`bytes1`，结果为`0x6c`，转换为`bytes2`时结果为`0x6c69`。当`0x6c697975656368756e`转换为`bytes32`时会进行低位补齐，结果为`0x6c697975656368756e0000000000000000000000000000000000000000000000`。

### 2.固定大小字节数组转动态大小字节数组

```solidity
pragma solidity ^0.4.4;

contract C {
    
    
   bytes9 name9 = 0x6c697975656368756e;
    
   function fixedSizeByteArraysToDynamicallySizedByteArray() constant returns (bytes) {
       
       return bytes(name9);
   }
    
}
```

​	以上的方法编译运行时，会报错，因为固定大小字节数组和动态大小字节数组之间不能直接简单的转换。

正确方法：

```solidity
pragma solidity ^0.4.4;

contract C {
    
   bytes9 name9 = 0x6c697975656368756e;
    
   function fixedSizeByteArraysToDynamicallySizedByteArray() constant returns (bytes) {
       
       bytes memory names = new bytes(name9.length);
       
       for(uint i = 0; i < name9.length; i++) {
           
           names[i] = name9[i];
       }
       
       return names;
   }
    
}
```

​	在上面的代码中，根据固定字节大小数组的长度来创建一个`memory`类型的动态类型的字节数组，然后通过一个`for循环`将固定大小字节数组中的字节按照索引赋给动态大小字节数组即可。

### 3.固定大小字节数组不能直接转换为string

```solidity
pragma solidity ^0.4.4;

contract C {
    
    bytes9 names = 0x6c697975656368756e;
    
    function namesToString() constant returns (string) {
        
        return string(names);
    }
   
}
```

​	以上代码会报错

### 4.动态大小字节数组转string

​	**重要：**因为string是特殊的动态字节数组，所以string只能和动态大小字节数组(Dynamically-sized byte array)之间进行转换，不能和固定大小字节数组进行转行。

- 如果是现成的动态大小字节数组(Dynamically-sized byte array)，如下：

```solidity
pragma solidity ^0.4.4;

contract C {
    
    bytes names = new bytes(2);
    
    function C() {
        
        names[0] = 0x6c;
        names[1] = 0x69;
    }
    
    
    function namesToString() constant returns (string) {
        
        return string(names);
    }
   
}
```

- 如果是固定大小字节数组转string，那么就需要先将字节数组转动态字节数组，再转字符串:

```solidity
pragma solidity ^0.4.4;

contract C {

   function byte32ToString(bytes32 b) constant returns (string) {
       
       bytes memory names = new bytes(b.length);
       
       for(uint i = 0; i < b.length; i++) {
           
           names[i] = b[i];
       }
       
       return string(names);
   }
   
}
```

​	可以通过`0x6c697975656368756e`作为参数进行测试，右边的返回结果**看似**为`liyuechun`，它的实际内容为`liyuechun\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000`，所以在实际的操作中，我们应该将后面的一些列`\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000`去掉。

- 正确的固定大小字节数组转string的代码：

```solidity
pragma solidity ^0.4.4;

contract C {
    
    function bytes32ToString(bytes32 x) constant returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    function bytes32ArrayToString(bytes32[] data) constant returns (string) {
        bytes memory bytesString = new bytes(data.length * 32);
        uint urlLength;
        for (uint i = 0; i< data.length; i++) {
            for (uint j = 0; j < 32; j++) {
                byte char = byte(bytes32(uint(data[i]) * 2 ** (8 * j)));
                if (char != 0) {
                    bytesString[urlLength] = char;
                    urlLength += 1;
                }
            }
        }
        bytes memory bytesStringTrimmed = new bytes(urlLength);
        for (i = 0; i < urlLength; i++) {
            bytesStringTrimmed[i] = bytesString[i];
        }
        return string(bytesStringTrimmed);
    }    
}
```

`byte char = byte(bytes32(uint(x) * 2 ** (8 * j)))`在上面的代码中，估计大家最难看懂的就是这一句代码，通过下面的案例给大家解析：

```solidity
pragma solidity ^0.4.4;

contract C {
    
    // 0x6c
    
    function uintValue() constant returns (uint) {
        
        return uint(0x6c);
    }
    
    function bytes32To0x6c() constant returns (bytes32) {
        
        return bytes32(0x6c);
    }
    
    function bytes32To0x6cLeft00() constant returns (bytes32) {
        
        return bytes32(uint(0x6c) * 2 ** (8 * 0));
    }
    
    function bytes32To0x6cLeft01() constant returns (bytes32) {
        
        return bytes32(uint(0x6c) * 2 ** (8 * 1));
    }
    
    function bytes32To0x6cLeft31() constant returns (bytes32) {
        
        return bytes32(uint(0x6c) * 2 ** (8 * 31));
    }
}
```

- `bytes32(uint(0x6c) * 2 ** (8 * 31));`左移31位
- `bytes32(uint(0x6c) * 2 ** (8 * 1));` 左移1位

​	通过`byte(bytes32(uint(x) * 2 ** (8 * j)))`获取到的始终是第0个字节。

### 5.总结

​	`string`本身是一个特殊的动态字节数组，所以它只能和`bytes`之间进行转换，不能和固定大小字节数组进行直接转换，如果是固定字节大小数组，需要将其转换为动态字节大小数组才能进行转换。



## 十四.数组 (Arrays)

### 1.固定长度的数组（Arrays）

#### 	固定长度类型数组的声明:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    // 数组的长度为5，数组里面的存储的值的类型为uint类型
    uint [5] T = [1,2,3,4,5];
}
```

​	通过length方法获取数组长度遍历数组求总和:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    // 数组的长度为5，数组里面的存储的值的类型为uint类型
    uint [5] T = [1,2,3,4,5];
    
    
    // 通过for循环计算数组内部的值的总和
    function numbers() constant public returns (uint) {
        uint num = 0;
        for(uint i = 0; i < T.length; i++) {
            num = num + T[i];
        }
        return num;
    }

}
```

#### 	尝试修改T数组的长度:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [5] T = [1,2,3,4,5];
    
    
    function setTLength(uint len) public {
        
        T.length = len;
    }
    
}
```

​	**PS:**声明数组时，一旦长度固定，将不能再修改数组的长度。

#### 	尝试修改T数组内部值:

```soli
pragma solidity ^0.4.4;

contract C {
    
    uint [5] T = [1,2,3,4,5];
    
    
    function setTIndex0Value() public {
        
        T[0] = 10;
    }
    
    // 通过for循环计算数组内部的值的总和
    function numbers() constant public returns (uint) {
        uint num = 0;
        for(uint i = 0; i < T.length; i++) {
            num = num + T[i];
        }
        return num;
    }
    
}
```

​	`T`数组初始的内容为`[1,2,3,4,5]`，总和为`15` ，当我点击`setTIndex0Value`方法将`第0个`索引的`1`修改为`10`时，总和为`24`。

​	**PS：**通过一个简单的试验可证明固定长度的数组只是不可修改它的长度，不过可以修改它内部的值，而`bytes0 ~ bytes32`固定大小字节数组中，大小固定，内容固定，长度和字节均不可修改。

#### 	尝试通过push往T数组中添加值:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [5] T = [1,2,3,4,5];
    
    
    function pushUintToT() public {
        
        T.push(6);
    }
}
```

​	**PS:**固定大小的数组不能调用`push`方法向里面添加存储内容，声明一个固定长度的数组，比如：`uint [5] T`，数组里面的默认值为`[0,0,0,0,0]`，我们可以通过索引修改里面的值，但是不可修改数组长度以及不可通过`push`添加存储内容。

### 2.可变长度的Arrays

#### 	可变长度类型数组的声明:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [] T = [1,2,3,4,5];
    
    function T_Length() constant returns (uint) {
        
        return T.length;
    }
    
}
```

​	`uint [] T = [1,2,3,4,5]`，这句代码表示声明了一个可变长度的`T`数组，因为我们给它初始化了`5`个无符号整数，所以它的长度默认为`5`。

#### 	通过length方法获取数组长度遍历数组求总和:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [] T = [1,2,3,4,5];
    
    // 通过for循环计算数组内部的值的总和
    function numbers() constant public returns (uint) {
        uint num = 0;
        for(uint i = 0; i < T.length; i++) {
            num = num + T[i];
        }
        return num;
    }

}
```

#### 	尝试修改T数组的长度:

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [] T = [1,2,3,4,5];
    
    function setTLength(uint len) public {
        
        T.length = len;
    }
    
    function TLength() constant returns (uint) {
        
        return T.length;
    }
}
```

​	**PS：**对可变长度的数组而言，可随时通过`length`修改它的长度。

#### 	尝试通过push往T数组中添加值

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [] T = [1,2,3,4,5];
    
    function T_Length() constant public returns (uint) {
        
        return T.length;
    }
    
    function pushUintToT() public {
        
        T.push(6);
    }
    
    function numbers() constant public returns (uint) {
        uint num = 0;
        for(uint i = 0; i < T.length; i++) {
            num = num + T[i];
        }
        return num;
    }
}
```

​	**PS：**当往里面增加一个值，数组的个数就会加1，当求和时也会将新增的数字加起来。

### 3.二维数组 - 数组里面放数组

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint [2][3] T = [[1,2],[3,4],[5,6]];
    
    function T_len() constant public returns (uint) {
        
        return T.length; // 3
    }
}
```

​	`uint [2][3] T = [[1,2],[3,4],[5,6]]`这是一个三行两列的数组，你会发现和Java、C语言等的其它语言中二位数组里面的列和行之间的顺序刚好相反。在其它语言中，上面的内容应该是这么存储`uint [2][3] T = [[1,2,3],[4,5,6]]`。

​	上面的`数组T`是`storage`类型的数组，对于`storage`类型的数组，数组里面可以存放任意类型的值（比如：其它数组，结构体，字典／映射等等）。对于`memory`类型的数组，如果它是一个`public`类型的函数的参数，那么它里面的内容不能是一个`mapping(映射／字典)`，并且它必须是一个`ABI`类型。

### 4.创建 Memory Arrays

​	创建一个长度为`length`的`memory`类型的数组可以通过`new`关键字来创建。`memory`数组一旦创建，它不可通过`length`修改其长度。

```solidity
pragma solidity ^0.4.4;

contract C {
    
    function f(uint len) {
        uint[] memory a = new uint[](7);
        bytes memory b = new bytes(len);
        // 在这段代码中 a.length == 7 、b.length == len
        a[6] = 8;
    }
}
```

### 5.数组字面量 Array Literals / 内联数组 Inline Arrays

```solidity
pragma solidity ^0.4.4;


contract C {
    
    function f() public {
        g([1, 2, 3]);
    }
    
    function g(uint[3] _data) public {
        // ...
    }
}
```

​	在上面的代码中，`[1, 2, 3]`是 `uint8[3] memory` 类型，因为`1、2、3`都是`uint8`类型，他们的个数为`3`，所以`[1, 2, 3]`是 `uint8[3] memory` 类型。但是在`g`函数中，参数类型为`uint[3]`类型，显然我们传入的数组类型不匹配，所以会报错。

​	**正确的写法如下：**

```solidity
pragma solidity ^0.4.4;

contract C {
    
    function f() public {
        g([uint(1), 2, 3]);
    }
    
    function g(uint[3] _data) public {
        // ...
    }
}
```

​	在这段代码中，我们将`[1, 2, 3]`里面的第`0`个参数的类型强制转换为`uint`类型，所以整个`[uint(1), 2, 3]`的类型就匹配了`g`函数中的`uint[3]`类型。

​	**memory类型的固定长度的数组不可直接赋值给storage/memory类型的可变数组**

- TypeError: Type uint256[3] memory is not implicitly convertible to expected type uint256[] memory.

```solidity
pragma solidity ^0.4.4;

contract C {
    function f() public {
        
        uint[] memory x = [uint(1), 3, 4];
    }
}
```

```solidity
browser/ballot.sol:8:9: TypeError: Type uint256[3] memory is not implicitly convertible to expected type uint256[] memory.
        uint[] memory x = [uint(1), 3, 4];
        ^-------------------------------^
```

- TypeError: Type uint256[3] memory is not implicitly convertible to expected type uint256[] storage pointer

```solidity
pragma solidity ^0.4.4;

contract C {
    function f() public {
        
        uint[] storage x = [uint(1), 3, 4];
    }
}
```

```soli
browser/ballot.sol:8:9: TypeError: Type uint256[3] memory is not implicitly convertible to expected type uint256[] storage pointer.
        uint[] storage x = [uint(1), 3, 4];
        ^--------------------------------^
```

- 正确使用

```solidity
pragma solidity ^0.4.4;


contract C {
    function f() public {
        
        uint[3] memory x = [uint(1), 3, 4];
    }
}
```

### 6.创建固定大小字节数组／可变大小字节数组

​	之前的笔记中有`bytes0 ~ bytes32`、`bytes`以及`string`的使用。`bytes0 ~ bytes32`创建的是固定字节大小的字节数组，长度不可变，内容不可修改。而`string`是特殊的可变字节数组，它可以转换为`bytes`以通过`length`获取它的字节长度，亦可通过索引修改相对应的字节内容。

​	创建可变字节数组除了可以通过`bytes b = new bytes(len)`来创建外，亦可以通过`byte[] b`来进行声明。

​	而`bytes0 ~ bytes32`我们可以通过`byte[len] b`来创建，`len` 的范围为`0 ~ 32`。不过这两种方式创建的不可变字节数组有一小点区别，`bytes0 ~ bytes32`直接声明的不可变字节数组中，**长度不可变，内容不可修改**。而`byte[len] b`创建的字节数组中，**长度不可变，但是内容可修改**。

```solidity
pragma solidity ^0.4.4;


contract C {
    
    bytes9 a = 0x6c697975656368756e;
    byte[9] aa = [byte(0x6c),0x69,0x79,0x75,0x65,0x63,0x68,0x75,0x6e];
    
    byte[] cc = new byte[](10);
    
    function setAIndex0Byte() public {
        // 错误，不可修改
        a[0] = 0x89;
    }
    
    function setAAIndex0Byte() public {
        
        aa[0] = 0x89;
    }
    
    function setCC() public {
        
        for(uint i = 0; i < a.length; i++) {
            
            cc.push(a[i]);
        }
    }
       
}
```

​	本篇文章系统讲解了可变与不可变数组的创建、以及二位数组与其它语言中二位数组的区别，同时讲解了如何创建`memory`类型的数组以及对`bytes0 ～ bytes32、bytes与byte[]`对比分析。

## 十五.枚举(Enums)

​	`ActionChoices`就是一个自定义的整型，当枚举数不够多时，它默认的类型为`uint8`，当枚举数足够多时，它会自动变成`uint16`，下面的`GoLeft == 0`,`GoRight == 1`, `GoStraight == 2`, `SitStill == 3`。在`setGoStraight`方法中，我们传入的参数的值可以是`0 - 3`当传入的值超出这个范围时，就会中断报错。

```solidity
pragma solidity ^0.4.4;

contract test {
    enum ActionChoices { GoLeft, GoRight, GoStraight, SitStill }
    ActionChoices _choice;
    ActionChoices constant defaultChoice = ActionChoices.GoStraight;

    function setGoStraight(ActionChoices choice) public {
        _choice = choice;
    }

    function getChoice() constant public returns (ActionChoices) {
        return _choice;
    }

    function getDefaultChoice() pure public returns (uint) {
        return uint(defaultChoice);
    }
}

```



## 十六.结构体(Structs)

### 1.自定义结构体

```solidity
pragma solidity ^0.4.4;

contract Students {
    
    struct Person {
        uint age;
        uint stuID;
        string name;
    }

}
```

​	`Person`就是我们自定义的一个新的结构体类型，结构体里面可以存放任意类型的值。

### 2.初始化一个结构体

​	**初始化一个storage类型的状态变量。**

- 方法一

```solidity
pragma solidity ^0.4.4;

contract Students {
    
    struct Person {
        uint age;
        uint stuID;
        string name;
    }

    Person _person = Person(18,101,"xumo");

}
```

- 方法二

```solidity
pragma solidity ^0.4.4;

contract Students {
    
    struct Person {
        uint age;
        uint stuID;
        string name;
    }

    Person _person = Person({age:18,stuID:101,name:"xumo"});

}
```

​	**初始化一个memory类型的变量。**

```solidity
pragma solidity ^0.4.4;

contract Students {
    
    struct Person {
        uint age;
        uint stuID;
        string name;
    }
    
    function personInit() {
        
        Person memory person = Person({age:18,stuID:101,name:"xumo"});
    }
}
```



## 十七.字典／映射(Mappings)

### 1.语法

```solidity
mapping(_KeyType => _ValueType)
```

​	`字典／映射`其实就是一个一对一键值存储关系。

​	**举个例子：**

​	**{age: 28, height: 172, name: liyuechun, wx: liyc1215}**

​	这就是一个映射，满足`_KeyType => _ValueType`之间的映射关系，`age`对应一个`28`的值，`height`对应`160`，`name`对应`liyuechun`, `wx`对应`liyc1215`。

​	**PS：**同一个映射中，可以有多个相同的**值**，但是**键**必须具备唯一性。

### 2.案例

```solidity
pragma solidity ^0.4.4;

contract MappingExample {
    
    // 测试账号
    
    // 0xca35b7d915458ef540ade6068dfe2f44e8fa733c
    
    // 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c
    
    // 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db
    
    mapping(address => uint)  balances;

    function update(address a,uint newBalance) public {
        balances[a] = newBalance;
    }
    
    // {0xca35b7d915458ef540ade6068dfe2f44e8fa733c: 100,0x14723a09acff6d2a60dcdf7aa4aff308fddc160c: 200,0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db: 300 }
    
    function searchBalance(address a) constant public returns (uint) {
        
        return balances[a];
    }
}
```



## 十八.集资(CrowdFunding)智能合约综合案例

### 1.结构体和字典综合案例

​	下面的案例是一个`集资`合约的案例，里面有两个角色，一个是投资人`Funder`，也就是`出资者`。另一个角色是运动员`Campaign`，被赞助者。一个`Funder`可以给多个`Campaign`赞助，一个`Campaign`也可以被多个`Funder`赞助。

​	完整合约:

```solidity
pragma solidity ^0.4.4;

contract CrowdFunding {
    
    // 定义一个`Funder`结构体类型，用于表示出资人，其中有出资人的钱包地址和他一共出资的总额度。
    struct Funder {
        address addr; // 出资人地址
        uint amount;  // 出资总额
    }


   // 定义一个表示存储运动员相关信息的结构体
    struct Campaign {
        address beneficiary; // 受益人钱包地址
        uint fundingGoal; // 需要赞助的总额度
        uint numFunders; // 有多少人赞助
        uint amount; // 已赞助的总金额
        mapping (uint => Funder) funders; // 按照索引存储出资人信息
    }

    uint numCampaigns; // 统计运动员(被赞助人)数量
    mapping (uint => Campaign) campaigns; // 以键值对的形式存储被赞助人的信息


    // 新增一个`Campaign`对象，需要传入受益人的地址和需要筹资的总额
    function newCampaign(address beneficiary, uint goal) public returns (uint campaignID) {
        campaignID = numCampaigns++; // 计数+1
        // 创建一个`Campaign`对象，并存储到`campaigns`里面
        campaigns[campaignID] = Campaign(beneficiary, goal, 0, 0);
    }

    // 通过campaignID给某个Campaign对象赞助
    function contribute(uint campaignID) public payable {
        Campaign storage c = campaigns[campaignID];// 通过campaignID获取campaignID对应的Campaign对象
        c.funders[c.numFunders++] = Funder({addr: msg.sender, amount: msg.value}); // 存储投资者信息
        c.amount += msg.value; // 计算收到的总款
        c.beneficiary.transfer(msg.value);
    }


    // 检查某个campaignID编号的受益人集资是否达标，不达标返回false，否则返回true
    function checkGoalReached(uint campaignID) public returns (bool reached) {
        Campaign storage c = campaigns[campaignID];
        if (c.amount < c.fundingGoal)
            return false;
        return true;
    }
}
```



## 十九.单位(Units) 和 全局变量(Globally Available Variables)

### 1.Ether Units

​	一个整数的后面可以跟一个单位，ether，finney，szabo或者wei。

​	**他们的单位换算如下：**

- `1 ether = 1000 finney`
- `1 ether = 1000000 szabo`
- `1 ether = 10 ** 18 wei`

```solidity
pragma solidity ^0.4.4;

contract C {
    
    uint a = 1 ether;
    uint b = 10 ** 18 wei;
    uint c = 1000 finney;
    uint d = 1000000 szabo;
    
    function isTrueAEquleToB() view public returns (bool) {
        
        return a == b;
    }
    
    function isTrueAEquleToC() view public returns (bool) {
        
        return a == c;
    }
    
    function isTrueAEquleToD() view public returns (bool) {
        
        return a == d;
    }

}
```

### 2.Time Units

​	时间的单位有`seconds`, `minutes`, `hours`, `days`, `weeks` 和 `years`。换算如下：

- `1 == 1 seconds`
- `1 minutes == 60 seconds`
- `1 hours == 60 minutes`
- `1 days == 24 hours`
- `1 weeks == 7 days`
- `1 years == 365 days`

```solidity
pragma solidity ^0.4.4;

contract C {
    
    // 1 == 1 seconds
    // 1 minutes == 60 seconds
    // 1 hours == 60 minutes
    // 1 days == 24 hours
    // 1 weeks == 7 days
    // 1 years == 365 days
    
    function test1() pure public returns (bool) {
        
        return 1 == 1 seconds;
    }
    
    function test2() pure public returns (bool) {
        
        return 1 minutes == 60 seconds;
    }
    
    function test3() pure public returns (bool) {
        
        return 1 hours == 60 minutes;
    }
    
    function test4() pure public returns (bool) {
        
        return 1 days == 24 hours;
    }
    
    function test5() pure public returns (bool) {
        
        return 1 weeks == 7 days;
    }
    
    function test6() pure public returns (bool) {
        
        return 1 years == 365 days;
    }
}
```

### 3.特殊的变量和函数和函数

​	有一些特殊的变量和函数存在于全局的命名空间以提供区块相关信息。

​	区块和交易属性:

- `block.blockhash(uint blockNumber) returns (bytes32):` 某个区块的区块链hash值

- `block.coinbase (address):` 当前区块的挖矿地址

- `block.difficulty (uint):` 当前区块的难度

- `block.gaslimit (uint):` 当前区块的`gaslimit`

- `block.number (uint):` 当前区块编号

- `block.timestamp (uint):` 当前区块时间戳

- `msg.data (bytes):` 参数

- `msg.gas (uint):` 剩余的`gas`

- `msg.sender (address):` 当前发送消息的地址

- `msg.sig (bytes4):` 方法ID

- `msg.value (uint):` 伴随消息附带的以太币数量

- `now (uint):` 时间戳，等价于`block.timestamp (uint)`

- `tx.gasprice (uint):` 交易的gas单价

- `tx.origin (address):`交易发送地址

  错误处理:

- `assert(bool condition)`：不满足条件，将抛出异常
- `require(bool condition)`：不满足条件，将抛出异常
- `revert()` 抛出异常

​	在`Solidity 0.4.10`版本之前，使用`throw`来处理异常。如下所示：

```solidity
contract HasAnOwner {

    address owner;
    
    function useSuperPowers(){ 
        if (msg.sender != owner) { 
            throw; 
        }
    }
}
```

在`Solidity 0.4.10`版本之后，我们通常如下使用：

- `if(msg.sender != owner) { revert(); }`
- `assert(msg.sender == owner);`
- `require(msg.sender == owner);`

## 附录

### 1.Ethereum Wallet编译报错:Could not compile source code. 的解决方法

​	报错内容:

​	Could not compile source code.

​	No visibility specified. Defaulting to "public". 

​	function getCount() constant returns (uint) {

​	^ (Relevant source part starts here and spans across multiple lines).:

​	解决方法:在函数后,returns前,添加“public”关键词

### 2.delete操作符

​	delete操作的作用是将一个值初始化为0,清零,而不是将变量删除

​	示例代码如下:

```soli
pragma solidity ^0.4.0;

contract DeleteDemo {
    uint public data = 100;
    uint[] public dataArray = [uint(1),2,3];
    event e(string _str,uint _u);
    event eArr(string _str,uint[] _u);
    
    function doDelete(){
        uint x = data; 
        e("x",x); // x=100
        delete x;
        e("after x",x); // x=0
        
        e("data",data);  // date = 100
        delete data;
        e("after data",data); // date = 0
        
        uint[] y = dataArray; 
        eArr("y",y);   // y = [1,2,3]
        delete dataArray;
        eArr("after y",y); // y=0
    }
}
```

