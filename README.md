# python-vim

这是我自己精简后的python vim开发包环境。实还有更加丰富的功能，但那只会让vim速度变得很慢。  所以我要说的是，并不是插件越多越好，而是越精简越好，把不用的插件都在.vimrc中注释掉。 

更多的介绍

[http://xiaorui.cc/2015/10/13/%E5%9C%A8centos%E4%B8%8B%E6%89%93%E9%80%A0%E5%9F%BA%E4%BA%8Epython%E7%9A%84vim%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83/](http://xiaorui.cc/2015/10/13/%E5%9C%A8centos%E4%B8%8B%E6%89%93%E9%80%A0%E5%9F%BA%E4%BA%8Epython%E7%9A%84vim%E5%BC%80%E5%8F%91%E7%8E%AF%E5%A2%83/)

python vim环境包的安装方法:

记得一定要更新vim相关插件，是为了解决一些不兼容的问题。

```
sudo yum clean all
sudo yum -y update vim
sudo yum -y install epel-release
sudo yum -y install ctags
```

如果你是Ubuntu系统

```
apt-get update vim
apt-get install ctags
```

下载我这边打包好的 .vimrc .vim .bashrc   , 含有一些常用的插件,主题 , 组件。

github方式安装:
```
cd ~
mv .vim .vim_bak
mv .vimrc .vimrc_bak
mv .bashrc .bashrc_bak
git clone https://github.com/rfyiamcool/python-vim.git
cd python-vim
\mv * ~
vim test.py
```

http方式安装:
```
sudo wget xiaorui.cc/vim_dev.tar.gz
 
sudo tar zxvf vim_dev.tar.gz
```

安装powerline-status用来做vim标记状态。

```
sudo pip install powerline-status
```
 
下面是shell的提示状态，如果不想让shell有炫目的powerline主题，那么就不用执行下面的命令。 
``` 
. /usr/local/lib/python2.7/site-packages/powerline/bindings/bash/powerline.sh
```

如果你是Ubuntu系统，那么需要更改下python模块路径.
```
. /usr/local/lib/python2.7/dist-packages/powerline/bindings/bash/powerline.sh
```


效果图:

![image](https://github.com/rfyiamcool/python-vim/raw/master/static/demo_vim.jpg)

