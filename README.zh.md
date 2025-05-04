# 为人类设计的Zsh

- **该项目支持非常有限**
- **没有新功能正在开发中**
- **大多数bug不会被修复**

一个开箱即用的Zsh配置，旨在提供良好的使用体验。它将最好的Zsh插件组合成一个连贯的整体，感觉像是一个成品而不是DIY入门套件。

如果你想要一个开箱即用的优秀shell，这个项目就是为你准备的。

## 目录

* 1. [功能特性](#功能特性)
* 2. [安装](#安装)
* 3. [在Docker中尝试](#在Docker中尝试)
* 4. [注意事项](#注意事项)
* 5. [使用方法](#使用方法)
  * 5.1. [接受自动建议](#接受自动建议)
  * 5.2. [命令补全](#命令补全)
  * 5.3. [搜索命令历史](#搜索命令历史)
  * 5.4. [使用`fzf`进行交互式搜索](#使用fzf进行交互式搜索)
  * 5.5. [SSH](#ssh)
* 6. [自定义](#自定义)
  * 6.1. [自定义提示符](#自定义提示符)
  * 6.2. [自定义外观](#自定义外观)
  * 6.3. [额外的Zsh启动文件](#额外的Zsh启动文件)
* 7. [更新](#更新)
* 8. [卸载](#卸载)
* 9. [高级配置技巧](#高级配置技巧)

## 功能特性

- 强大的预配置POSIX兼容shell，开箱即用。
- 易于使用的安装向导。不需要`git`、`zsh`或`sudo`。
- 命令行[语法高亮](https://github.com/zsh-users/zsh-syntax-highlighting)。
- 基于命令历史的[自动建议](https://github.com/zsh-users/zsh-autosuggestions)。
- 通过内置配置向导可配置的[命令提示符](https://github.com/romkatv/powerlevel10k)。
- 使用[fzf](https://github.com/junegunn/fzf)可搜索的命令补全和历史记录。
- [超快速](https://github.com/romkatv/zsh-bench)。在终端中打开新标签或运行命令时没有延迟。
- 通过`ssh`连接时，完整的shell环境可以自动传送到远程主机。这不需要在远程主机上安装`git`、`zsh`或`sudo`。
- 命令历史可以在不同主机之间共享。例如，`ssh foo`中的历史记录可以在`ssh bar`和/或本地机器上使用。

## 安装

在bash、zsh或sh中运行此命令：

```shell
if command -v curl >/dev/null 2>&1; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
else
  sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
fi
```

安装程序会备份现有的Zsh启动文件，创建新文件，安装Zsh for Humans所需的一切，启动新shell，并将其配置为登录shell。它会在每个步骤请求确认，以便你始终保持控制。安装需要`curl`或`wget`。不需要`git`、`zsh`、`sudo`或其他任何东西。

<details>
  <summary>安装过程的录像</summary>

  ![Zsh for Humans安装](
    https://github.com/romkatv/powerlevel10k-media/raw/32c7d40239c93507277f14522be90b5750f442c9/z4h-install.gif)

</details>

## 在Docker中尝试

在Docker容器中尝试Zsh for Humans。你可以安全地安装额外的软件并对文件系统进行任何更改。一旦退出Zsh，镜像就会被删除。

- **Alpine Linux**：启动快速；使用`apk add <package>`安装额外软件
  ```zsh
  docker run -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -w /root -it --rm alpine sh -uec '
    apk add zsh curl tmux
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"'
  ```
- **Ubuntu**：使用`apt install <package>`安装额外软件：
  ```zsh
  docker run -e TERM -e COLORTERM -w /root -it --rm ubuntu sh -uec '
    apt-get update
    apt-get install -y zsh curl tmux
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"'
  ```

## 注意事项

Zsh for Humans不适合喜欢在shell中使用vi绑定的用户。

Zsh for Humans的文档很少。没有它支持的配置选项列表，也没有这些选项的功能描述。

## 使用方法

如果你以前使用过Zsh、Bash或Fish，Zsh for Humans应该会让你感到熟悉。大多数情况下，一切都按照你的预期工作。

### 接受自动建议

所有移动光标的键绑定都可以接受*命令自动建议*。例如，将光标向右移动一个单词将接受自动建议中的那个单词。可以使用<kbd>Alt+M</kbd>/<kbd>Option+M</kbd>在不移动光标的情况下接受整个自动建议。

Zsh for Humans中的自动建议由[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)提供。有关更多信息，请参阅其主页。

### 命令补全

使用<kbd>Tab</kbd>补全时，建议来自*补全函数*。对于大多数命令，补全函数由Zsh本身提供。[zsh-completions](https://github.com/zsh-users/zsh-completions)贡献了额外的补全函数。有关它支持的命令列表，请参阅其主页。

模糊补全会自动启动[fzf](#使用fzf进行交互式搜索)。使用<kbd>Enter</kbd>接受所需的补全。你还可以使用<kbd>Ctrl+Space</kbd>选择多个补全，或使用<kbd>Ctrl+A</kbd>选择所有补全。

### 搜索命令历史

<kbd>Up</kbd>和<kbd>Down</kbd>键从历史记录中获取包含你已经在命令行上输入的内容的命令。例如，如果你在输入`grep`后按<kbd>Up</kbd>，你将看到最后执行的包含`grep`的命令。

<kbd>Ctrl+R</kbd>启动[fzf](#使用fzf进行交互式搜索)来搜索历史记录。

### 使用fzf进行交互式搜索

Zsh for Humans中的几个UI元素使用[fzf](https://github.com/junegunn/fzf)从潜在的大型候选列表中快速选择项目。你可以输入由空格分隔的多个搜索词。例如：

```text
^music .mp3$ sbtrkt !fire
```

| 标记      | 匹配类型        | 描述                           |
| --------- | --------------- | ------------------------------ |
| `wild`    | 子字符串        | 包含子字符串`wild`的项目       |
| `^music`  | 前缀            | 以`music`开头的项目            |
| `.mp3$`   | 后缀            | 以`.mp3`结尾的项目             |
| `!wild`   | 反向子字符串    | 不包含子字符串`wild`的项目     |
| `!^music` | 反向前缀        | 不以`music`开头的项目          |
| `!.mp3$`  | 反向后缀        | 不以`.mp3`结尾的项目           |

单个竖线(`|`)作为OR运算符。例如，以下查询匹配以`core`开头并以`go`、`rb`或`py`结尾的条目。

```text
^core go$ | rb$ | py$
```

有关更多信息，请参阅[fzf](https://github.com/junegunn/fzf)主页。

### SSH

[![SSH传送](https://asciinema.org/a/542763.svg)](https://asciinema.org/a/542763)

当你通过SSH连接到远程主机时，你的本地Zsh for Humans环境可以传送到远程主机。首次登录远程主机可能需要一些时间。之后，它的速度与普通的`ssh`一样快。

在你的`~/.zshrc`中搜索"ssh"，了解如何启用和配置SSH传送。

## 自定义

你可以（也应该）编辑`~/.zshrc`来自定义你的shell。通读整个文件以查看其中包含哪些自定义选项并根据你的喜好调整它们是个好主意。

添加自定义内容时，将它们放在执行类似操作的现有行旁边。默认的`~/.zshrc`包含以下类型的自定义内容，可以作为示例：

- 导出环境变量。
- 扩展`PATH`。
- 定义别名。
- 为现有别名添加标志。
- 定义函数。
- 加载额外的本地文件。
- 加载Oh My Zsh插件。
- 克隆并加载外部Zsh插件。
- 设置shell选项。
- 自动加载函数。
- 更改键绑定。

### 自定义提示符

Zsh for Humans中的提示符由[Powerlevel10k](https://github.com/romkatv/powerlevel10k)提供。运行`p10k configure`访问其交互式配置向导。可以通过编辑`~/.p10k*.zsh`文件进行进一步自定义。可能有多个配置文件以适应终端的不同功能。大多数用户只会看到`~/.p10k.zsh`。如有疑问，请查阅`$POWERLEVEL9K_CONFIG_FILE`。此参数由Zsh for Humans设置，它始终指向当前使用的Powerlevel10k配置文件。

有关更多信息，请参阅[Powerlevel10k](https://github.com/romkatv/powerlevel10k)主页。

### 自定义外观

Zsh for Humans UI的不同部分由不同的项目渲染。

![Zsh for Humans](https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/prompt-highlight.png)

截图中突出显示区域内的所有内容都是*提示符*。它由[Powerlevel10k](https://github.com/romkatv/powerlevel10k)生成。请参阅[自定义提示符](#自定义提示符)。

`ls`命令产生的文件列表由`ls`本身着色。不同的命令有不同的方式来自定义其输出，甚至不同版本的`ls`也有不同的与颜色相关的标志和环境变量。Zsh for Humans为常见命令（如`ls`和`grep`）启用了彩色输出。有关进一步自定义，请查阅相应命令的文档。

`echo hello`是当前正在输入的命令。它的语法高亮由[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)提供。有关如何自定义它的文档，请参阅其主页。

在`echo hello`之后，你可以看到灰色的`world`。这不是命令的一部分，所以按<kbd>Enter</kbd>只会打印`hello`而不是`world`。后者是由[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)提供的自动建议，你可以部分或全部[接受](#接受自动建议)。它来自命令历史，是提高生产力的好帮手。有关更多信息，请参阅[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)主页。

最后但同样重要的是，你的终端对在其中运行的*所有内容*的外观都有发言权。基本颜色（从0到15编号）在不同的终端中可能看起来不同，甚至在具有不同设置的同一终端中也可能不同。大多数现代终端支持*主题*、*调色板*或*配色方案*，允许你快速更改基本颜色。如果你的终端中的颜色看起来不舒服，尝试使用不同的主题。请注意，代码高于15的颜色以及指定为RGB三元组的颜色不受终端主题的影响。它们在任何地方看起来都一样。

### 额外的Zsh启动文件

当你启动Zsh时，它会自动加载`~/.zshenv`和`~/.zshrc`。前者引导Zsh for Humans，后者是你的个人配置。强烈建议将所有shell自定义和配置（包括导出的环境变量，如`PATH`）保存在`~/.zshrc`中或从`~/.zshrc`加载的文件中。如果你确定必须在`~/.zshenv`中导出一些环境变量，请在注释指示的位置进行操作。

Zsh支持几个额外的启动文件，有复杂的规则控制每个文件何时被加载。额外的启动文件是`~/.zprofile`、`~/.zlogin`和`~/.zlogout`。**不要创建这些文件**，除非你绝对确定你需要它们。

## 更新

运行`z4h update`更新Zsh for Humans。`~/.zshrc`本身没有更新机制。

## 卸载

1. 删除或替换`~/.zshenv`和`~/.zshrc`。如果你在安装Zsh for Humans之前已经有这些文件，并且在安装程序询问是否要备份它们时回答肯定，你可以在`~/zsh-backup`中找到它们。
2. 重启你的终端。**仅重启zsh是不够的。**
3. 删除Zsh for Humans缓存：
   ```zsh
   rm -rf -- "${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans/v5"
   ```

## 高级配置技巧

请参阅[此文档](tips.md)。
