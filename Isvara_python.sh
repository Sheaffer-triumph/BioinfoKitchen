#python help
pydoc modules    #列出所有模块
pip list         #列出所有安装的模块，无论是从PyPI安装的还是从其他地方安装的
pip show numpy    #显示模块的详细信息
pip install numpy #安装模块
pip uninstall numpy #卸载模块
pip install numpy -U #升级模块
pip install numpy==1.18.1 #安装指定版本
pip install numpy>=1.18.1 #安装大于等于指定版本
pip install numpy<=1.18.1 #安装小于等于指定版本
pip install numpy~=1.18.1 #安装大于等于指定版本，小于下一个主版本的最新版本
pip install numpy --no-cache-dir #禁用缓存

#导入模块，以下命令需在Python环境中运行
import numpy as np    #导入numpy模块，重命名为np，后续使用时可以直接使用np
from numpy import *   #导入numpy模块中的所有函数，后续使用时可以直接使用函数名
from Bio import SeqIO #只导入Bio模块中的SeqIO函数，后续使用时可以直接使用SeqIO，不需要加Bio前缀。但Bio中的其他函数不能直接使用

#Python自带常用模块，可参考Python标准库https://docs.python.org/zh-cn/3/library/index.html
import os                                       #os模块，提供了许多与操作系统交互的函数
    os.getcwd()                                 #获取当前工作目录
    os.chdir('/path/to/path')                   #改变当前的目录至指定目录
    os.listdir()                                #列出当前目录下的所有文件和目录
    os.path.exists('/path/to/path')             #判断文件或目录是否存在
    os.path.isfile('/path/to/file')             #判断是否是文件
    os.path.isdir('/path/to/dir')               #判断是否是目录
    os.path.join('/path/to', 'file')            #连接目录和文件名
    os.path.basename('/path/to/file')           #获取文件名
    os.path.dirname('/path/to/file')            #获取文件路径
    os.path.splitext('/path/to/file')           #分离文件名和扩展名
    os.path.getsize('/path/to/file')            #获取文件大小
    os.remove('/path/to/file')                  #删除文件
    os.rmdir('/path/to/dir')                    #删除目录
    os.system('command')                        #运行系统命令，只能返回命令的退出状态码，1表示失败，0表示成功
    os.popen('command').read()                  #运行系统命令并返回结果
    os.path.abspath('file')                     #返回文件的绝对路径
    os.path.relpath('file', 'start')            #返回从start到file的相对路径
    os.path.getmtime('file')                    #返回文件的最后修改时间
    os.path.getatime('file')                    #返回文件的最后访问时间
    os.path.getctime('file')                    #返回文件的创建时间
    os.path.isabs('file')                       #判断是否是绝对路径
    os.path.samefile('file1', 'file2')          #判断两个路径是否指向同一个文件
    os.path.commonpath(['/path/to/file1', '/path/to/file2']) #返回两个路径的共同路径
    os.path.commonprefix(['/path/to/file1', '/path/to/file2']) #返回两个路径的共同前缀
    os.path.relpath('/path/to/file', '/path/to') #返回从start到file的相对路径
    os.open('file', os.O_RDWR)                  #打开文件，函数包含文件名和flags两个参数。flags参数可以是os.O_RDONLY、os.O_WRONLY、os.O_RDWR等。一般不使用这个命令，使用open()函数更方便
exit()

import sys                                      #sys模块，提供了对Python解释器的访问
    sys.stdin.read()                            #读取标准输入
    sys.stdout.write('string')                  #输出到标准输出
    sys.stderr.write('string')                  #输出到标准错误
    sys.argv[1]                                 #获取第1个命令行参数
    sys.exit()                                  #退出程序
exit()

import re                                       #re模块，提供了正则表达式的支持
    re.match('pattern', 'string')               #从字符串的起始位置匹配一个模式
    re.search('pattern', 'string')              #在字符串中搜索匹配模式
    re.findall('pattern', 'string')             #在字符串中找到所有匹配模式
    re.sub('pattern', 'replace', 'string')      #替换字符串中的模式
exit()

import subprocess
    subprocess.run("command", shell=True)          #运行系统命令，返回一个CompletedProcess对象