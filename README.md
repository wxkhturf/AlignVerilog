# 前言

我在尝试将Verilog文件进行格式对齐，<u>目前仅实现了module声明部分的对齐，后续将会持续更新。</u>

可能有些许bug，持续修订中

1. begin... end缩进
2. generate ... endgenerate缩进
3. always、for等缩进
4. 记得分号后的注释

>1. `module`块检测方案：首先检测"`module`"字样，检测到";"停止(`endmodule`处理方式同`module`)
>2. `always`块检测方案：首先检测"`always`"字样，接着判断`)`后的第一个字母是不是" `begin`"，如果是则以`end`为边界，如果不是，则以"`;`"或关键词(比如"`if`")为新块，在新块中递归。（`for`、`generate`、`initial`等块同样这样操作，使用一个数组存储这些块关键词）
>3. `input`、`output`、`wire`、`reg`、`integer`等声明对齐。首先使用一数组存储上述关键词，在首次检测出关键词后，接着向后检测。检测到`;`后的第一个单词是否还是上述关键词，若是则接着向后检测；若不是则说明对齐的只有这几行。然后开始对这几行进行对齐。
>4. 检测到关键词`endmodule`则停止

>1. 删除所有注释，
>2. 合并所有跨行为一行
>3. 禁止一行中包括两句，含两句以上的拆成一行一句
>4. 按input、output、wire、reg、assign、always等块进行分块归类

>1. 遍历变量（不改动input、output）这样保证接口功能正常
>2. 随机打乱变量顺序，进行随机分配

## 关键词

```verilog
reg
wire
integer
real
parameter
localparam
genvar
always
initial
for
generate
case
if-else
```



# 执行方式

将.v文件添加进`file_list`，然后执行`perl main.pl`命令，对齐后的.v文件存放在/temp文件夹下。

目前在windows 10 系统下执行正常

## 1.1 module块

首先划分为三个结构

>==module结构==
>
><u>moudule块内容由**我完全控制**，原顺序全部作废。</u>
>
><u>每行一个变量声明</u>
>
>以下内容按顺序
>
>1. timescale：`timescale`+`1*空格`+`数字`+`单位1`+`空格`+`/`+`数字`+`单位2`
>2. `空一行`
>3. module部分：(带parameter的module记得单独考虑)每行只有一个变量，先input，后output



### 1.1.1 基本布置

==三步走==：**按顺序操作**

> 给自己看的：
>
> 1. 所有`Tab`键替换为空格
> 2. 所有内容全部顶格对齐（删除前导和拖尾空格）
> 3. 把`module`置至开头，``timescale 1 ps / 1 ps module fifo(`，比如moduel和timescale在一起，所以需要置至开头
> 4. `module部分`按逗号进行分割为第1列区域、第2列...
> 5. `主体内容`按分号进行分割为第1列区域、第2列...
> 6. 对齐方式：不同always块不互相对齐，只在一个always块里对齐，同理还有generate块
> 7. <u>不对`/**/`这种注释进行除左对齐外的其他任何处理</u>
> 8. 对齐字母、标点符号、注释。<u>由于不可能完全对齐，优先保证等号、分号、逗号对齐</u>
> 9. 若一行只含有字母，比如跨行，则将其最后一个字母与上一句的最后一个字母对齐
> 10. <u>实例化模块不做任何处理</u>(因为有可能需要更改接口，所以不对此进行变化)

### 1.1.2 执行步骤

> ==注意：==
>
> 1. 第一个块结尾检测是否另起一行，举个例子`moudule(xxxx);abc`，在`module`块结尾标志`);`后还有个`abc`，那么如何处理`abc`呢？将`abc`另起一行，并左顶格对齐
> 1. <u>记得考虑不删注释的情况，专门写个函数把注释给保留！</u>
> 1. 标号，比如：`begin:name`

### 1.1.3 代码部分

#### 1.1.3.1 module块声明部分结构

|          |         |        |         |           |         |      |         |      | 备注 |
| -------- | ------- | ------ | ------- | --------- | ------- | ---- | ------- | ---- | ---- |
| `input`  |         | `reg`  |         |           |         |      |         |      |      |
| `output` | 2个空格 | `wire` | 2个空格 | `[xx:xx]` | 2个空格 | xxxx | 1个空格 | ，   |      |
| 6        | 2       | 4      | 2       | 不定      | 2       | 不定 | 1       | 1    |      |

固定的部分：

6+2 = 8

4+2=6  

#### 1.1.3.2 步骤

1. 首先将`/**/`注释进行换行，使`/*`前无内容，`*/`后无内容
2. 将`module`换行，使`module`前无内容
3. 将`/**/`型注释剪切至一哈希变量中，剪切完保留空行
4. 将`//`型注释剪切至另一哈希变量中
5. 将Tab键替换为空格
6. **从第6步起，不再对行号进行修改，行号固定**（避免影响注释的后续拼接）
7. 开始进行<u>主体内容对齐</u>



## 1.2 assign 语句

### 1.2.1 基本布置

**首先有必要明确，以空格为分隔符进行单词的第一次划分**

> 1. `assign顶格对齐`，如果一行有两个，则第二个assign与分号前空一空格，以此类推
>
>    ```verilog
>    assign a = b; assign c = d; assign e = f;
>    ```
>
> 2. 单词与运算符（如`>`）之间空一空格
>
> 3. 多行`assign`语句，优先`;`与`=`对齐，其次是单词、运算符，如：
>
>    ```verilog
>    assign asflj = blsj > sdljfl;
>    assign b     = 1'b1         ;
>    ```
>
>    即在保证等号、分号对齐的前提下，首先将第一个单词对齐，然后对齐第一个运算符（如果有的话），接着再是单词
>
> 4. 括号：`[]`、`()`、`{}`左括号与最右边的非运算符紧挨，右括号与最左边的非运算符紧挨。（*非运算符：除`>`、`<`、`?:`等等之外的字母或数字。紧挨：中间没有空格*）
>
> 5. 因为我们认为`[`与其前的字母间没有空格，`]`与其后的字母没有空格。但是像`wire [5:0] a`这样的语句也有`[]`这样的方括号啊，因此，本人对此进行如下定义：`assign/always/generate/...`与`wire/reg/parameter/localparam`不会同行，<u>如果同行，我认为这是傻子写法，不予处理</u>。进一步扩展，我认为`assign/always/generate/wire/reg/parameter/localparam`等两两不会同等，<u>如果同行，我认为这是傻子写法，不予处理。</u>**但是我们允许`assign`与`assign`同行，即允许两句或多句`assign`在同一行**
>
> 6. 对于非运算符`[5:0]`：因为这个不是变量声明部分，所以我们不对它进行对齐，即`[5:0]`与`[  5 :0]`与`[5 :0   ]`不对其进行处理，将其与最近的单词进行组合，认为是一个单词（`单词`与`[`之间不留有空格），而不是两个。
>
>    ```verilog
>    assign b     = 1'b1         ;
>    assign c     = slfjl[5:0]   ;
>    ```
>
>    <u>至于出现下面这种情况，我们不考虑这种情况，这种写法我认为是傻子写法，不予处理，初学者也不应该这样写：</u>
>
>    ```verilog
>    assign c     = slfjl
>        [5:
>         0]   ;
>    ```
>
> 7. 对于运算符`?:`，不能当作普通运算符处理，因为这时会遇到一个问题，`assign a = b ? c[1:0] : d` ，那么如何知道`?`是与哪个`:`匹配呢？进一步，如果`c[MAC:0]`里面有参数呢？ 其实上一点已经说了将其当作一个单词，所以只需要第一步就处理`[1:0]`将其与前一单词组成一个单词存储即可，上述问题自然消失。
>
> 8. 跨行对齐
>
>    ```verilog
>    assign ins = a > (b - 1'b1) ?
>                 c > d  : e       ;               
>    ```
>
>    前面已经说了，括号是与单词合并认为是一个单词，所以这里的`d`与左小括号对齐，`e`与`1`对齐。
>
> 9. `1'b1`与`26'  d 2`（*注：经Modeslsim验证，没有任何语法问题*），就将其当作一个单词，中间无空格，即：`1'b1`与`26'd2`
>
> 10. 注意宏定义，会以==\`==开头
>
> 11. 其他待补充

> **结构划分**
>
> 在将`[]、{}、()`等与其或前或后的字母合并后认为是一个单词之后（包括宏定义等），可以将一句`assign`划分为如下几个部分：
>
> 1. 关键词$\rightarrow$认为是单词
> 2. `assign`、变量$\rightarrow$认为是单词（认为是单词后，其中间的空格予以消除）
> 3. 运算符$\rightarrow$认为是单词
>
> **阈值**
>
> 1. 为了避免占用过多内存，设置一阈值N=100，当连续有101行`assign行`时，只对齐前100行，从第101行重新开始对齐

### 1.2.2 执行步骤



> 1. 首先处理

### 1.2.3 代码部分









## 1.3 always 块

### 1.3.1 基本布置

>==always结构==
>
>1. `always(左对齐)`+`1个空格`+`@`+`1个空格`+`左括号`+`1个空格`+`variables`+`1个空格`+`右括号`+`换行符`
>
>2. 关于variables
>
>   1. `*`
>   2. `var1 or var2 or var3`
>   3. `posedge/negedge var or `
>
>   这个很简单，把`*`也看作是一个单词，这样的话，variables中的所有内容都是单词，统一规定单词与单词之间有`1个空格`
>
>3. 如果`always`头后的部分，按`begin--end`依次顺序对齐（*注：这一部分应当是一个通用型模块，即对`initial、generate、for等块语句可以尽可能调用`*）

### 1.3.2 执行步骤

### 1.3.3 代码部分



## 1.4 数据类型处理

### 1.4.1 数据类型

>1. parameter：`parameter(左对齐)`+`2*若干空格`+`字母对齐`+`2*若干空格`+`等号对齐`+`内容`+`2*若干空格`+`分号对齐`
>2. localparam：
>3. input
>4. output
>5. reg
>6. wire



