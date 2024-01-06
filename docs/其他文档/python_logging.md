# Python日志处理(logging模块介绍)

## 一、logging模块使用方式介绍

`logging`模块提供了两种记录日志的方式：

- 第一种方式是使用`logging`提供的模块级别的函数。
- 第二种方式是使用`logging`日志系统的四大组件

其实，`logging`所提供的模块级别的日志记录函数也是对`logging`日志系统相关类的封装而已。

|函数 | 说明|
|:--|:--|
|logging.debug(msg, *args, **kwargs) | 创建一条严重级别为DEBUG的日志记录|
|logging.info(msg, *args, **kwargs) | 创建一条严重级别为INFO的日志记录|
|logging.warning(msg, *args, **kwargs) | 创建一条严重级别为WARNING的日志记录|
|logging.error(msg, *args, **kwargs) | 创建一条严重级别为ERROR的日志记录|
|logging.critical(msg, *args, **kwargs) | 创建一条严重级别为CRITICAL的日志记录|
|logging.log(level, *args, kwargs) | 创建一条严重级别为level的日志记录|
|logging.basicConfig(kwargs) | 对root logger进行一次性配置|

其中`logging.basicConfig(**kwargs)`函数用于指定“要记录的日志级别”、“日志格式”、“日志输出位置”、“日志文件的打开模式”等信息，其他几个都是用于记录各个级别日志的函数。

**logging模块的四大组件**

|组件 | 说明 |
|:--|:--|
|loggers | 提供应用程序代码直接使用的接口 |
|handlers | 用于将日志记录发送到指定的目的位置 |
|filters | 提供更细粒度的日志过滤功能，用于决定哪些日志记录将会被输出（其它的日志记录将会被忽略）|
|formatters | 用于控制日志信息的最终输出格式 |

> **说明：** logging提供的模块级别的函数，实际上也是通过这几个组件的相关实现类来记录日志的，只是在创建这些类的实例的时候设置了一些默认值。

## 二、使用logging提供的模块级函数记录日志

回顾前面提到的几个重要信息：

- 可以通过logging模块级别的方法完成简单的日志记录
- 只有级别大于或者等于日志记录器指定级别的日志才会被输出，小于该级别的日志将会被丢弃。

### 2.1 简单的日志输出

```python3
import logging

# 设置默认日志级别， >=logging.INFO 则输出
logging.basicConfig(level=logging.INFO)

logging.debug("This is a debug log.")
logging.info("This is a info log.")
logging.warning("This is a warning log.")
logging.error("This is a error log.")
logging.critical("This is a critical log.")
```

也可以这样写：

```python3
import logging

logging.basicConfig(level=logging.INFO)

logging.log(logging.DEBUG, "This is a debug log.")
logging.log(logging.INFO, "This is a info log.")
logging.log(logging.WARNING, "This is a warning log.")
logging.log(logging.ERROR, "This is a error log.")
logging.log(logging.CRITICAL, "This is a critical log.")
```

输出结果：

```
INFO:root:This is a info log.
WARNING:root:This is a warning log.
ERROR:root:This is a error log.
CRITICAL:root:This is a critical log.
```

### 2.2 疑问

**1. 打印出的日志的各字段是什么意思？为什么会这样输出？**

```python
日志级别：日志器名称：日志内容
```

之所以会这样输出，是因为`logging`模块提供的日志记录函数，所使用的日志器，其默认值为`logging.BASIC_FORMAT`:

```python
BASIC_FORMAT = "%(levelname)s:%(name)s:%(message)s"
```

**2. 打印出的日志默认输出到什么位置？**

`logging`模块提供的日志记录函数的默认输出位置为`sys.stderr`

**3. 如何知道默认值？**

查看这些日志记录函数的实现代码，可以发现：当我们没有提供任何配置信息的时候，这些函数都会去调用`logging.basicConfig(**kwargs)`方法，且不会向该方法传递任何参数。继续查看`basicConfig()`方法的代码就可以找到上面这些问题的答案了。

**4. 怎么修改这些默认值呢？**

其实很简单，在我们调用日志记录函数之前，手动调用一下`basicConfig`方法，把我们想设置的内容以参数的形式传进去就可以了。

### 2.3 logging.basicConfig函数说明

该方法用于`logging`系统做一些基本配置，其方法定义如下：

```python
logging.basicConfig(**kwargs)
```

|参数名称 | 描述|
|:--|:--|
|filename | 指定日志输出目标文件的文件名，指定该设置项后，日志信息就不会被输出到控制台了 |
|filemode | 指定日志文件的打开模式，默认为'a'。需要注意的是，该选项要在filename指定时才有效 |
|format | 指定日志格式字符串，即指定日志输出时所包含的字段信息以及它们的顺序。logging模块定义的格式字段下面会列出|
|datefmt | 指定日期/时间格式。需要注意的是，该选项要在format中包含时间字段%(asctime)s时才有效|
|level | 指定日志器的日志级别|
| stream | 指定日志输出目标stream，如sys.stdout、sys.stderr以及网络stream。需要说明的是，stream和filename不能同时提供，否则会引发 ValueError异常|
|style | Python 3.2中新添加的配置项。指定format格式字符串的风格，可取值为'%'、'{'和'$'，默认为'%'|
| handlers | Python 3.3中新添加的配置项。该选项如果被指定，它应该是一个创建了多个Handler的可迭代对象，这些handler将会被添加到root logger。需要说明的是：filename、stream和handlers这三个配置项只能有一个存在，不能同时出现2个或3个，否则会引发ValueError异常。|

### 2.4 logging定义的格式字符字段

|字段/属性名称 | 使用格式 | 描述 |
|:--|--|:--|
|asctime | %(asctime)s | 日志事件发生的时间--人类可读时间，如：2003-07-08 16:49:45,896|
|created | %(created)f | 日志事件发生的时间--时间戳，就是当时调用time.time()函数返回的值|
|relativeCreated | %(relativeCreated)d | 日志事件发生的时间相对于logging模块加载时间的相对毫秒数（目前还不知道干嘛用的）|
|msecs | %(msecs)d | 日志事件发生事件的毫秒部分
levelname | %(levelname)s | 该日志记录的文字形式的日志级别（'DEBUG', 'INFO', 'WARNING', 'ERROR', 'CRITICAL'）|
| levelno | %(levelno)s | 该日志记录的数字形式的日志级别（10, 20, 30, 40, 50）|
| name | %(name)s | 所使用的日志器名称，默认是'root'，因为默认使用的是 rootLogger |
| message | %(message)s | 日志记录的文本内容，通过 msg % args计算得到的 |
| pathname | %(pathname)s | 调用日志记录函数的源码文件的全路径 |
| filename | %(filename)s | pathname的文件名部分，包含文件后缀 |
| module | %(module)s | filename的名称部分，不包含后缀 |
| lineno | %(lineno)d | 调用日志记录函数的源代码所在的行号 |
| funcName | %(funcName)s | 调用日志记录函数的函数名 |
| process | %(process)d | 进程ID |
| processName | %(processName)s | 进程名称，Python 3.1新增|
| thread | %(thread)d | 线程ID |
| threadName | %(thread)s | 线程名称 |

### 2.5 日志常用配置演示

简单配置一下日志级别：

```python
logging.basicConfig(level=logging.DEBUG)

logging.log(logging.DEBUG, "This is a debug log.")
logging.log(logging.INFO, "This is a info log.")
logging.log(logging.WARNING, "This is a warning log.")
logging.log(logging.ERROR, "This is a error log.")
logging.log(logging.CRITICAL, "This is a critical log.")
```

输出结果：

```
DEBUG:root:This is a debug log.
INFO:root:This is a info log.
WARNING:root:This is a warning log.
ERROR:root:This is a error log.
CRITICAL:root:This is a critical log.
```

所有等级日志信息全部输出了，说明配置生效了。

**在配置日志器日志级别的基础上，继续配置下日志输出目标文件和日志格式**

```python
import logging

LOG_FORMAT = "%(asctime)s-%(levelname)s-%(message)s"

logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT, filename="my.log")

logging.log(logging.DEBUG, "This is a debug log.")
logging.log(logging.INFO, "This is a info log.")
logging.log(logging.WARNING, "This is a warning log.")
logging.log(logging.ERROR, "This is a error log.")
logging.log(logging.CRITICAL, "This is a critical log.")
```

此时会发现控制台之中已经没有日志输出了，但是在python代码的相同目录下会生成一个名为"my.log"的日志文件，该文件的内容为：

```
2024-01-03 10:44:11,954-DEBUG-This is a debug log.
2024-01-03 10:44:11,954-INFO-This is a info log.
2024-01-03 10:44:11,955-WARNING-This is a warning log.
2024-01-03 10:44:11,955-ERROR-This is a error log.
2024-01-03 10:44:11,955-CRITICAL-This is a critical log.
```

在此基础上我们再来设置一下日期/时间格式：

```python
import logging

LOG_FORMAT = "%(asctime)s-%(levelname)s-%(message)s"
DATE_FORMAT = "%m/%d/%Y %H:%M:%S %p"


logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT, filename="my.log", datefmt=DATE_FORMAT)

logging.log(logging.DEBUG, "This is a debug log.")
logging.log(logging.INFO, "This is a info log.")
logging.log(logging.WARNING, "This is a warning log.")
logging.log(logging.ERROR, "This is a error log.")
logging.log(logging.CRITICAL, "This is a critical log.")
```

```
01/03/2024 10:51:43 AM-DEBUG-This is a debug log.
01/03/2024 10:51:43 AM-INFO-This is a info log.
01/03/2024 10:51:43 AM-WARNING-This is a warning log.
01/03/2024 10:51:43 AM-ERROR-This is a error log.
01/03/2024 10:51:43 AM-CRITICAL-This is a critical log.
```

### 2.6 其它说明

几个要说明的内容：

- `logging.basicConfig()`函数是一个一次性的简单配置工具使，也就是说只有在第一次调用该函数时会起作用，后续再次调用该函数时完全不会产生任何操作的，多次调用的设置并不是累加操作。

- 日志器（`Logger`）是有层级关系的，上面调用的`logging`模块级别的函数所使用的日志器是`RootLogger`类的实例，其名称为`root`，它是处于日志器层级关系最顶层的日志器，且该实例是以单例模式存在的。

- 如果要记录的日志中包含变量，可以使用第一个参数作为**字符串格式**，然后将变量数据作为第二个参数*args的值进行传递，如:`logging.warning('%s is %d years old.', 'Tom', 10)`，输出内容为`WARNING:root:Tom is 10 years old.`。

- `logging.debug()`, `logging.info()`等方法的定义中，除了`msg`和`args`参数外，还有一个`**kwargs`参数。它们支持3个关键字参数: `exc_info`, `stack_info`, `extra`，下面对这几个关键字参数作个说明。

**关于exc_info, stack_info, extra关键词参数的说明：**

- **exc_info(exception_info)**： 其值为布尔值，如果该参数的值设置为`True`，则会将异常异常信息添加到日志消息中。如果没有异常信息则添加`None`到日志信息中。

- **stack_info**： 其值也为布尔值，默认值为False。如果该参数的值设置为True，栈信息将会被添加到日志信息中。

- **extra**： 这是一个字典（dict）参数，它可以用来自定义消息格式中所包含的字段，但是它的key不能与logging模块定义的字段冲突。

**一个例子：**

```python
FORMAT = '%(asctime)s %(clientip)-15s %(user)-8s %(message)s'
logging.basicConfig(format=FORMAT)
d = {'clientip': '192.168.0.1', 'user': 'jack'}
logger = logging.getLogger('tcpserver')
logger.warning('Protocol problem: %s', 'connection reset', extra=d)
```

输出

```
2024-01-03 13:56:40,112 192.168.0.1     jack     Protocol problem: connection reset
```

**`exc_info=True`的案例：**

```python
LOG_FORMAT = "%(asctime)s-%(levelname)s-%(message)s"
DATE_FORMAT = "%m/%d/%Y %H:%M:%S %p"
logging.basicConfig(level=logging.DEBUG, format=LOG_FORMAT, datefmt=DATE_FORMAT)
try:
    1/0
except Exception as e:
    logging.log(logging.WARNING, "This is a warning log.", exc_info=True, stack_info=False)
```

会在异常块，里面输出异常信息，如果不再异常块里面，则输出`NoneType`

```
01/03/2024 14:01:39 PM-WARNING-This is a warning log.
Traceback (most recent call last):
  File "demo.py", line 11, in <module>
    1/0
ZeroDivisionError: division by zero
```

**`stack_info=True`的案例：**

```python
logging.log(logging.WARNING, "This is a warning log.", exc_info=False, stack_info=True)
```

`stack_info=True`无论如何都会输出**调用栈信息**。

```python
01/03/2024 14:12:00 PM-WARNING-This is a warning log.
Stack (most recent call last):
  File "demo.py", line 9, in <module>
    logging.log(logging.WARNING, "This is a warning log.", exc_info=False, stack_info=True)
```

## 三、 logging的日志处理组件

### 3.1 logging日志模块四大组件

在介绍`logging`模块的日志流处理流程之前，我们先来介绍下`logging`模块的四大组件：

| 组件名称 | 对应类名 | 功能描述 |
|--|--|:--|
| 日志器 | Logger | 提供了应用程序可一直使用的接口 |
| 处理器 | Handler | 将logger创建的日志记录发送到合适的目的输出 |
| 过滤器 | Filter | 提供了更细粒度的控制工具来决定输出哪条日志记录，丢弃哪条日志记录 |
| 格式器 | Formatter | 决定日志记录的最终输出格式 |

**这些组件之间的关系描述**：

- 日志器（`logger`）需要通过处理器（`handler`）将日志信息输出到目标位置，如：文件、`sys.stdout`、网络等；

- 不同的处理器（`handler`）可以将日志输出到不同的位置；

- 日志器（`logger`）可以设置多个处理器（`handler`）将同一条日志记录输出到不同的位置；
每个处理器（`handler`）都可以设置自己的过滤器（`filter`）实现日志过滤，从而只保留感兴趣的日志；

- 每个处理器（`handler`）都可以设置自己的格式器（`formatter`）实现同一条日志以不同的格式输出到不同的地方。

- 简单点说就是：日志器（`logger`）是入口，真正干活儿的是处理器（`handler`），处理器（`handler`）还可以通过过滤器（`filter`）和格式器（`formatter`）对要输出的日志内容做过滤和格式化等处理操作。

### 3.2 Logger组件说明

`Logger`对象有3个任务要做：

1. 向应用程序代码暴露几个方法，使应用程序可以在运行时记录日志消息；
2. 基于日志严重等级（默认的过滤设施）或`filter`对象来决定要对哪些日志进行后续处理；
3. 将日志消息传送给所有感兴趣的日志`handlers`。
`Logger`对象最常用的方法分为两类：配置类的方法和消息发送类的方法。

最常用的配置方法如下：

| 方法 | 描述 |
|:--|:--|
| Logger.setLevel() | 设置日志器将会处理的日志消息的最低严重级别 |
| Logger.addHandler() 和 Logger.removeHandler() | 为该logger对象添加 和 移除一个handler对象 |
| Logger.addFilter() 和 Logger.removeFilter() | 为该logger对象添加 和 移除一个filter对象 |

logger对象配置完成后，可以使用下面的方法来创建日志记录：

| 方法 | 描述 |
|:--|:--|
| Logger.debug(), Logger.info(), Logger.warning(), Logger.error(), Logger.critical() | 创建一个与它们的方法名对应等级的日志记录 |
| Logger.exception() | 创建一个类似于Logger.error()的日志消息， 主要用于exception块，类似于`exc_info=True` |
| Logger.log() | 需要获取一个明确的日志level参数来创建一个日志记录，在自定义level的时候可以使用 |

那么，怎样得到一个`Logger`对象呢？一种方式是通过`Logger`类的实例化方法创建一个`Logger`类的实例，但是我们通常都是用第二种方式--`logging.getLogger()`方法。

`logging.getLogger()`方法有一个可选参数`name`，该参数表示将要返回的日志器的名称标识，如果不提供该参数，则其值为'root'。若以相同的`name`参数值多次调用`getLogger()`方法，将会返回指向同一个`logger`对象的引用。

> 通过`logging.Logger.manager.loggerDict.keys()`可以获取到所有logger的名称

关于`logger`的层级结构与有效等级的说明：

- `logger`的名称是一个以`.`分割的层级结构，每个`.`后面的`logger`都是`.`前面的`logger`的`children`，例如，有一个名称为`foo`的`logger`，其它名称分别为`foo.bar`,`foo.bar.baz`和`foo.bam`都是`foo`的后代。

- `logger`有一个"有效等级（`effective level`）"的概念。如果一个`logger`上没有被明确设置一个`level`，那么该`logger`就是使用它`parent`的`level`;如果它的`parent`也没有明确设置`level`则继续向上查找`parent`的`parent`的有效`level`，依次类推，直到找到个一个明确设置了`level`的祖先为止。需要说明的是，`root logger`总是会有一个明确的`level`设置（默认为 `WARNING`）。当决定是否去处理一个已发生的事件时，`logger`的有效等级将会被用来决定是否将该事件传递给该`logger`的`handlers`进行处理。

- `child loggers`在完成对日志消息的处理后，**默认会将日志消息传递给与它们的祖先`loggers`相关的`handlers`**。因此，我们不必为一个应用程序中所使用的所有`loggers`定义和配置`handlers`，只需要为一个顶层的`logger`配置`handlers`，然后按照需要创建`child loggers`就可足够了。我们也可以通过将一个`logger`的`propagate`属性设置为`False`来关闭这种传递机制。

### 3.3 Handler组件说明

`Handler`对象的作用是（基于日志消息的`level`）将消息分发到`handler`指定的位置（文件、网络、邮件等）。`Logger`对象可以通过`addHandler()`方法为自己添加`0`个或者更多个`handler`对象。比如，一个应用程序可能想要实现以下几个日志需求：

- 把所有日志都发送到一个日志文件中；
- 把所有严重级别大于等于`error`的日志发送到`stdout（标准输出）`；
- 把所有严重级别为`critical`的日志发送到一个`email`邮件地址。

这种场景就需要3个不同的`handlers`，每个`handler`复杂发送一个特定严重级别的日志到一个特定的位置。

一个`handler`中只有非常少数的方法是需要应用开发人员去关心的。对于使用内建`handler`对象的应用开发人员来说，似乎唯一相关的`handler`方法就是下面这几个配置方法：

|方法 | 描述|
|:--|:--|
| Handler.setLevel() | 设置handler将会处理的日志消息的最低严重级别 |
| Handler.setFormatter() | 为handler设置一个格式器对象 |
| Handler.addFilter() 和 Handler.removeFilter() | 为handler添加和删除一个过滤器对象 | 

需要说明的是，应用程序代码不应该直接实例化和使用`Handler`实例，因为`Handler`是一个基类。下面是一些常用的`Handler`：

| Handler | 描述 |
|:--|:--|
| logging.StreamHandler | 将日志消息发送到输出到Stream，如std.out, std.err或任何file-like对象。 |
| logging.FileHandler | 将日志消息发送到磁盘文件，默认情况下文件大小会无限增长 | 
| logging.handlers.RotatingFileHandler | 将日志消息发送到磁盘文件，并支持日志文件按大小切割 |
| logging.hanlders.TimedRotatingFileHandler | 将日志消息发送到磁盘文件，并支持日志文件按时间切割 |
| logging.handlers.HTTPHandler | 将日志消息以GET或POST的方式发送给一个HTTP服务器 |
| logging.handlers.SMTPHandler | 将日志消息发送给一个指定的email地址 |
| logging.NullHandler | 该Handler实例会忽略error messages，通常被想使用logging的library开发者使用来避免'No handlers could be found for logger XXX'信息的出现。 |

#### 3.4 Formater 组件说明

Formater对象用于配置日志信息的最终顺序、结构和内容。与logging.Handler基类不同的是，应用代码可以直接实例化Formatter类。另外，如果你的应用程序需要一些特殊的处理行为，也可以实现一个Formatter的子类来完成。

Formatter类的构造方法定义如下：

```python
logging.Formatter.__init__(fmt=None, datefmt=None, style='%')
```

可见，该构造方法接收3个可选参数：

- `fmt`：指定消息格式化字符串，如果不指定该参数则默认使用`message`的原始值
- `datefmt`：指定日期格式字符串，如果不指定该参数则默认使用`"%Y-%m-%d %H:%M:%S"`
- `style`：`Python 3.2`新增的参数，可取值为 `'%'`, `'{'`和 `'$'`，如果不指定该参数则默认使用'%'

## 四、 使用四大组件记录日志

### 4.1 需求

现在有以下几个日志记录的需求：

1. 要求将所有级别的所有日志都写入磁盘文件中
2. all.log文件中记录所有的日志信息，日志格式为：日期和时间 - 日志级别 - 日志信息
3. error.log文件中单独记录error及以上级别的日志信息，日志格式为：日期和时间 - 日志级别 - 文件名[:行号] - 日志信息
4. 要求all.log在每天凌晨进行日志切割

### 4.2 分析

1. 要记录所有级别的日志，因此日志器的有效level需要设置为最低级别--DEBUG
2. 日志需要发送到两个不同的目的地，因此需要设置两个handler；另外两个目的地都是磁盘文件，因此这两个handler都是与filehandler相关；
3. `all.log`要求按照时间进行日志切割，因此他需要用`logging.handlers.TimedRotatingFileHandler`; 而`error.log`没有要求日志切割，因此可以使用`FileHandler`;
4. 两个日志文件的格式不同，因此需要对这两个`handler`分别设置格式器；

```python
import logging
import logging.handlers
import datetime

logger = logging.getLogger('mylogger')
logger.setLevel(logging.DEBUG)

# backup_interval = when * interval
# backupCount: backup logfile number
rf_handler = logging.handlers.TimedRotatingFileHandler('all.log', when='midnight', interval=1, backupCount=7, atTime=datetime.time(0, 0, 0, 0))
rf_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(message)s"))

f_handler = logging.FileHandler('error.log')
f_handler.setLevel(logging.ERROR)

f_handler.setFormatter(logging.Formatter("%(asctime)s - %(levelname)s - %(filename)s[:%(lineno)d] - %(message)s"))
logger.addHandler(rf_handler)
logger.addHandler(f_handler)

logger.debug('debug message')
logger.info('info message')
logger.warning('warning message')
logger.error('error message')
logger.critical('critical message')
```

`all.log`文件输出：

```python
2024-01-05 17:05:03,633 - DEBUG - debug message
2024-01-05 17:05:03,633 - INFO - info message
2024-01-05 17:05:03,633 - WARNING - warning message
2024-01-05 17:05:03,633 - ERROR - error message
2024-01-05 17:05:03,633 - CRITICAL - critical message
```

`error.log`文件输出：

```python
2024-01-05 17:05:03,633 - ERROR - demo.py[:23] - error message
2024-01-05 17:05:03,633 - CRITICAL - demo.py[:24] - critical message
```
