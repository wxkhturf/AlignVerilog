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



### 1.1.1 扫描顺序与结构

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

### 1.1.2 代码块检测方法

> ==注意：==
>
> 1. 第一个块结尾检测是否另起一行，举个例子`moudule(xxxx);abc`，在`module`块结尾标志`);`后还有个`abc`，那么如何处理`abc`呢？将`abc`另起一行，并左顶格对齐
> 1. <u>记得考虑不删注释的情况，专门写个函数把注释给保留！</u>
> 1. 标号，比如：`begin:name`

### 1.1.3 结构

#### 1.1.3.1 module块声明部分结构

|          |         |        |         |           |         |      |         |      | 备注 |
| -------- | ------- | ------ | ------- | --------- | ------- | ---- | ------- | ---- | ---- |
| `input`  |         | `reg`  |         |           |         |      |         |      |      |
| `output` | 2个空格 | `wire` | 2个空格 | `[xx:xx]` | 2个空格 | xxxx | 1个空格 | ，   |      |
| 6        | 2       | 4      | 2       | 不定      | 2       | 不定 | 1       | 1    |      |

固定的部分：

6+2 = 8

4+2=6  

### 1.1.4 步骤

1. 首先将`/**/`注释进行换行，使`/*`前无内容，`*/`后无内容
2. 将`module`换行，使`module`前无内容
3. 将`/**/`型注释剪切至一哈希变量中，剪切完保留空行
4. 将`//`型注释剪切至另一哈希变量中
5. 将Tab键替换为空格
6. **从第6步起，不再对行号进行修改，行号固定**（避免影响注释的后续拼接）
7. 开始进行<u>主体内容对齐</u>

## 1.2 always 块

### 1.2.1 基本布置

==always结构==

1. `always(左对齐)`+`1个空格`+`@`+`1个空格`+`左括号`+`1个空格`+`variables`+`1个空格`+`右括号`+`换行符`

2. 关于variables

   1. `*`
   2. `var1 or var2 or var3`
   3. `posedge/negedge var or `

   这个很简单，把`*`也看作是一个单词，这样的话，variables中的所有内容都是单词，统一规定单词与单词之间有`1个空格`



## 1.3 数据类型处理

### 1.3.1 数据类型

>1. parameter：`parameter(左对齐)`+`2*若干空格`+`字母对齐`+`2*若干空格`+`等号对齐`+`内容`+`2*若干空格`+`分号对齐`
>2. localparam：
>3. input
>4. output
>5. reg
>6. wire

