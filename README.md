---
date: 2018-02-26 15:39:23
---


## 一个稍微“比较美观”的ArchLinux安装脚本 ##
参考<a href="https://wiki.archlinux.org" rel="external nofollow">Wiki</a>的<a href="https://wiki.archlinux.org/index.php/Installation_guide" rel="external nofollow">Installation guide</a>，以及<a href="https://github.com/yangmame" rel="external nofollow">YangMame</a>的<a href="https://github.com/yangmame/Arch-Installer" rel="external nofollow">Arch-Installer</a>


---


### 主要功能 ###
- 在输入位置双击“C”键进入bash  
  <b>非长文本输入时有效</b>（长文本输入行有'> '标识）
- 分区、mount
- 根据需要修改 `/etc/pacman.d/mirrorlist`
- 安装桌面环境
- 配置AUR源
- 支持Intel / NVIDIA / ATI，以及双显卡


---


### 使用 ###
联网后
```
wget raw.githubusercontent.com/youthug/Arch-Installer/master/live.sh
# 短链或许更优雅 wget git.io/vA646 -O live.sh
chmod +x live.sh
./live.sh
```


---


### 截图 ###
截图环境为mac，部分命令无法识别


![](images/1.png)


进入bash  
![](images/2.png)


挂载分区  
![](images/3.png)


修改源  
![](images/4.png)


---


### 欢迎反馈使用体验以及未知BUG ###

