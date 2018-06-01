markdown转为html并自动部署到web
===

##I. 将markdown转成html
```python
# -*- coding: utf-8

import markdown
import os
import codecs


def markdown2html(markdown_string):
    return '''<html lang="zh-cn">
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8" />
<link href="css/default.css" rel="stylesheet">
<link href="css/friendly.css" rel="stylesheet">
</head>
<body>
%s
</body>
</html>''' % markdown.markdown(markdown_string, extensions=['extra', 'codehilite', 'tables', 'toc'])


def main(filename):
    markdown_filename = "%s.md" % filename
    html_filename = "%s.html" % filename

    if os.path.exists(html_filename) and os.path.isfile(html_filename):
        os.remove(html_filename)

    with codecs.open(markdown_filename, 'r', 'utf-8') as infile:
        with codecs.open(html_filename, 'w', 'utf-8', errors='xmlcharrefreplace') as outfile:
            outfile.write(markdown2html(infile.read()))

    print('convert %s to %s success!' % (markdown_filename, html_filename))


if __name__ == '__main__':
    # if len(sys.argv) < 3:
    #     print('usage: markdown2html source_filename target_file')
    #     sys.exit()

    main('test')

```

##II. shell逻辑

###1. 逻辑说明
建立一个shell文件，用于进行逻辑处理，主要操作如下：

• 更新svn文件，将最新的md文件更新下来(此处假设md文件是测试文档.md)；

• 执行python markdown_convert.py $NAME将md文件转成html文件(生成测试文档.html)；

• 将转好的html迁移到web路径下(移动到html/测试文档.html)；

• 启动一个web服务(此处用的是python的SimpleHTTPServer的web服务器).

###2. 完整shell逻辑
```bash
#!/bin/bash
NAME='测试文档'
## 更新代码
svn update
## 删除html文件
if [ -f "$NAME.html" ];then
rm "$NAME.html"
fi
## 生成html
if [ -f "$NAME.md" ];then
python markdown_convert.py $NAME
fi
## 生成html目录
if [ ! -d "html" ];then
mkdir "html"
fi
## 拷贝html文件
if [ -f "$NAME.html" ];then
mv -f "$NAME.html" "html/"
fi
## 开启web服务器
PID=`ps aux | grep 'python -m SimpleHTTPServer 8080' | grep -v 'grep' | awk '{print $2}'`
if [ "$PID" = "" ];then
cd html
nohup python -m SimpleHTTPServer 8080 &
echo 'start web server'
else
echo 'already start'
fi
```

##III. linux定时任务
在shell命令下输入crontab -e进入linux定时任务编辑界面。在里面设置markdown2web.sh脚本的定时任务：
```bash
## 更新文档
*/10 * * * * cd /home/xxx/doc; sh markdown2web.sh > /dev/null 2>&1
```
