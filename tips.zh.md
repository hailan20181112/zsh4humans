# 高级配置技巧

Zsh for Humans中的默认配置故意保守。它旨在对新用户不造成意外，并且稳健可靠。鼓励有经验的Zsh用户自定义他们的配置，以释放shell的全部潜力。

* 1. [tmux](#tmux)
* 2. [底部提示符](#底部提示符)
* 3. [自动建议](#自动建议)
* 4. [Shell集成](#shell集成)
* 5. [提示符](#提示符)
* 6. [终端标题](#终端标题)
* 7. [SSH](#ssh)
  * 7.1. [额外的点文件](#额外的点文件)
  * 7.2. [更好的主机名报告](#更好的主机名报告)
  * 7.3. [持久和共享命令历史](#持久和共享命令历史)
  * 7.4. [无人值守传送](#无人值守传送)
* 8. [当前目录](#当前目录)
* 9. [补全](#补全)
* 10. [fzf](#fzf)
* 11. [基于单词的小部件](#基于单词的小部件)
* 12. [Oh My Zsh](#oh-my-zsh)
* 13. [备份和恢复](#备份和恢复)
* 14. [vi模式](#vi模式)
* 15. [管理点文件](#管理点文件)
  * 15.1. [替代`ZDOTDIR`](#替代zdotdir)
* 16. [特权shell](#特权shell)
* 17. [Homebrew](#homebrew)

## tmux

如果在安装程序询问`zsh`是否应该始终在`tmux`中运行时选择*No*，你的`~/.zshrc`中将有以下片段：

```zsh
# 不启动tmux。
zstyle ':z4h:' start-tmux no
```

Zsh for Humans中的几个功能需要知道终端屏幕的内容，而使用上述选项将不满足这个条件。如果你删除这个`zstyle`行，Zsh for Humans将自动启动一个精简版的`tmux`（在源代码和讨论中称为"集成tmux"），这应该能启用额外的功能，而不会有其他可见的影响。这曾经是Zsh for Humans的默认设置，但最终被更改了，因为在某些特殊情况下，集成tmux可能会导致问题。尝试删除这一行，看看一切是否仍然正常工作。

如果你的终端有一个功能，允许它在与当前标签相同的目录中打开新标签或窗口，而它不起作用，请添加以下选项：

```zsh
zstyle ':z4h:' propagate-cwd yes
```

如果终端标题出现问题，请参阅[终端标题](#终端标题)。

如果垂直调整终端窗口大小会破坏回滚，请添加此选项：

```zsh
zstyle ':z4h:' term-vresize top
```

如果鼠标滚轮滚动在某些应用程序中停止工作，请为它们明确启用鼠标支持。例如：

```zsh
alias nano='nano --mouse'
```

## 底部提示符

让提示符始终位于同一位置可以让你更快地找到它，并定位你的终端窗口，使查看提示符最舒适。

在`~/.zshrc`中添加以下选项，使提示符在Zsh启动时和按<kbd>Ctrl+L</kbd>时位于底部：

```zsh
# 在zsh启动和按Ctrl+L时将提示符移至底部。
zstyle ':z4h:' prompt-at-bottom 'yes'
```

此功能要求[`start-tmux`不设置为`no`](#tmux)。

如果你习惯于运行`clear`而不是按<kbd>Ctrl+L</kbd>，你可以添加此别名：

```zsh
alias clear=z4h-clear-screen-soft-bottom
```

请注意，让提示符始终位于*顶部*是[不可能的](https://github.com/romkatv/powerlevel10k-media/issues/2#issuecomment-725277867)。

## 自动建议

大多数移动光标的键快捷方式在有自动建议的情况下表现一致。唯一的例外是`forward-char`、`vi-forward-char`和`end-of-line`。这些小部件接受完整的自动建议，而不是仅接受一个字符或一行。可以通过以下选项修复：

```zsh
zstyle ':z4h:autosuggestions' forward-char partial-accept
zstyle ':z4h:autosuggestions' end-of-line  partial-accept
```

## Shell集成

在`~/.zshrc`中添加以下选项：

```zsh
# 用语义信息标记shell的输出。
zstyle ':z4h:' term-shell-integration 'yes'
```

这在理解[OSC 133](https://iterm2.com/documentation-escape-codes.html#:~:text=FTCS_PROMPT-,OSC%20133%20%3B,-A%20ST)的终端中启用额外功能（[iTerm2](https://iterm2.com/documentation-shell-integration.html)、[kitty](https://sw.kovidgoyal.net/kitty/shell-integration/)等）。如果你启用了[集成tmux](#tmux)，它还可以修复[调整终端窗口大小时的可怕混乱](https://github.com/romkatv/powerlevel10k#horrific-mess-when-resizing-terminal-window)。

在iTerm2中，你会在每个提示符的左侧看到蓝色三角形。这可以在iTerm2首选项中[禁用](https://stackoverflow.com/questions/41123922/iterm2-hide-marks/41661660#41661660)。

## 提示符

提示符可以通过`p10k configure`配置。一些选项配合得很好：尝试两行提示符、稀疏（在提示符前添加空行）和瞬态提示符。如果你注重生产力，使用*Lean*风格并选择*Few*图标而不是*Many*。*Many*中的额外图标是装饰性的。参见：[配置向导中的最佳提示符风格是什么](https://github.com/romkatv/powerlevel10k#what-is-the-best-prompt-style-in-the-configuration-wizard)。

在`~/.zshrc`中添加以下选项，使瞬态提示符在关闭SSH连接时一致工作：

```zsh
z4h bindkey z4h-eof Ctrl+D
setopt ignore_eof
```

这保留了Ctrl+D的默认zsh行为。如果你希望Ctrl+D始终退出shell，可以绑定`z4h-exit`而不是`z4h-eof`。

如果你使用带有前面空行的两行提示符，请添加以下内容以获得更平滑的渲染：

```zsh
POSTEDIT=$'\n\n\e[2A'
```

如果你使用带有空行的单行提示符，或者没有空行的两行提示符，请改为添加以下内容：

```zsh
POSTEDIT=$'\n\e[A'
 ```

你可以将`Enter`绑定到`z4h-accept-line`，以在当前输入的命令不完整时插入换行符，而不是显示次要提示符（也称为`PS2`）。

```zsh
z4h bindkey z4h-accept-line Enter
```

## 终端标题

默认情况下，某些终端不允许shell设置标签和窗口标题。这可以在终端首选项中更改。

终端标题可以通过`:z4h:term-title`样式自定义。以下是默认值：

```zsh
zstyle ':z4h:term-title:ssh'   preexec '%n@%m: ${1//\%/%%}'
zstyle ':z4h:term-title:ssh'   precmd  '%n@%m: %~'
zstyle ':z4h:term-title:local' preexec '${1//\%/%%}'
zstyle ':z4h:term-title:local' precmd  '%~'
```

当通过SSH连接时应用`:z4h:term-title:ssh`，而`:z4h:term-title:local`应用于本地shell。

`preexec`标题在执行命令之前设置：`$1`是未展开的命令行，`$2`是别名展开后的相同命令行。

`precmd`标题在执行命令后设置。没有位置参数。

所有值都经过提示符展开。

提示：在`preexec`中添加`%*`以显示命令开始执行的时间。

提示：将`%m`替换为`${${${Z4H_SSH##*:}//\%/%%}:-%m}`。这在使用[SSH传送](#SSH)时有所不同：标题将显示你在命令行上连接时输入的主机名，而不是远程机器报告的主机名。

## SSH

[![SSH传送](https://asciinema.org/a/542763.svg)](https://asciinema.org/a/542763)

当你通过SSH连接到远程主机时，你的本地Zsh for Humans环境可以传送到远程主机。首次登录远程主机可能需要一些时间。之后，它的速度与普通的`ssh`一样快。

SSH传送可以按主机启用。默认情况下，它对所有主机都禁用。你可以使用黑名单方法：

```zsh
# 默认启用SSH传送。
zstyle ':z4h:ssh:*'                   enable yes

# 为特定主机禁用SSH传送。
zstyle ':z4h:ssh:example-hostname1'   enable no
zstyle ':z4h:ssh:*.example-hostname2' enable no
```

或白名单方法：

```zsh
# 默认禁用SSH传送。
zstyle ':z4h:ssh:*'                   enable no

# 为特定主机启用SSH传送。
zstyle ':z4h:ssh:example-hostname1'   enable yes
zstyle ':z4h:ssh:*.example-hostname2' enable yes
```

### 额外的点文件

如果你的shell环境需要zsh rc文件（默认传送）以外的额外文件，请将它们添加到`send-extra-files`：

```zsh
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'
```

你也可以在这里添加目录。不要添加任何重量级的东西，因为它会减慢SSH连接速度。

*注意*：传送时，远程文件和目录会被静默覆盖。

*注意*：如果文件在本地不存在，传送时它将在远程主机上被静默删除。

### 更好的主机名报告

通过SSH连接时，默认情况下，提示符和终端标题将显示远程机器报告的主机名。有时它与你在命令行上传递给`ssh`的内容不同，通常你希望看到后者。要实现这一点，在配置选项中使用`${${${Z4H_SSH##*:}//\%/%%}:-%m}`代替`%m`。例如，以下是如何配置终端标题：

```zsh
zstyle ':z4h:term-title:ssh' preexec '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': ${1//\%/%%}'
zstyle ':z4h:term-title:ssh' precmd  '%n@'${${${Z4H_SSH##*:}//\%/%%}:-%m}': %~'
```

以及提示符：

```zsh
typeset -g POWERLEVEL9K_CONTEXT_TEMPLATE=%n@${${${Z4H_SSH##*:}//\%/%%}:-%m}
```

后者应该放在`~/.p10k.zsh`中。你可能已经在那里有一些`CONTEXT`模板。根据需要自定义它们。

### SSH配置

为了获得更好的SSH用户体验，请在`~/.ssh/config`中添加以下内容：

```text
Host *
  ServerAliveInterval 60
  ConnectTimeout 10
  AddKeysToAgent yes
  EscapeChar `
  ControlMaster auto
  ControlPersist 72000
  ControlPath ~/.ssh/s/%C
```

有关这些选项的含义，请参阅`man ssh_config`并相应调整它们。

确保`~/.ssh/s`是一个存在的目录，模式为`0700`。

上述配置将`EscapeChar`从默认的波浪号重新映射为反引号，因为你经常用波浪号开始zsh命令（而且什么都不显示很烦人），但你从不用反引号开始命令。

如果你的操作系统不自动启动SSH代理，请在`~/.zshrc`中添加以下内容：

```zsh
zstyle ':z4h:ssh-agent:' start      yes
zstyle ':z4h:ssh-agent:' extra-args -t 20h
```

在`~/.ssh/config`中列出你SSH连接的所有主机是个好主意。像这样：

```text
Host pihole
  HostName 192.168.1.42
  User pi
Host blog
  HostName 10.100.1.2
  User admin
```

如果你这样做，你可以[配置](#补全)`ssh`和类似命令以很好地补全主机名。

### 持久和共享命令历史

Zsh for Humans可以在你关闭SSH连接时从远程主机拉取命令历史。它还可以在连接时将命令历史发送到远程主机。这允许你保留来自远程主机的命令历史，即使它们被擦除。它还允许你在主机之间共享命令历史。该机制非常灵活，但不容易配置。以下是一些入门内容。

```zsh
# 此函数由zsh4humans在每个ssh命令上调用，在应用ssh相关zstyles的指令后。
# 它允许我们以无法通过zstyles完成的方式配置ssh传送。
#
# 在此函数中，我们对以下参数有只读访问权：
#
# - z4h_ssh_client  本地主机名
# - z4h_ssh_host    在命令行上指定的远程主机名
#
# 我们还对这些参数有读写访问权：
#
# - z4h_ssh_enable          1表示使用ssh传送，0表示普通ssh
# - z4h_ssh_send_files      要发送到远程的文件列表；键是本地文件名，值是远程文件名
# - z4h_ssh_retrieve_files  与z4h_ssh_send_files相同，但用于从远程拉取文件到本地
# - z4h_retrieve_history    远程$HISTFILE应在连接结束时合并到的本地文件列表
# - z4h_ssh_command         用于替代`ssh`的命令
function z4h-ssh-configure() {
  emulate -L zsh

  # 如果ssh传送被禁用，则退出。如果我们想的话，也可以在这里覆盖此参数。
  (( z4h_ssh_enable )) || return 0

  # 确定我们将要连接的机器类型。
  local machine_tag
  case $z4h_ssh_host in
    ec2-*) machine_tag=ec2;;
    *)     machine_tag=$z4h_ssh_host;;
  esac

  # 这是我们在本地保存从这种类型机器检索的命令历史的地方。
  local local_hist=$ZDOTDIR/.zsh/history/retrieved_from_$machine_tag

  # 当我们连接到远程机器时，我们的$local_hist会在远程机器上变成这个。
  # 我们的zshrc明确加载了像这样名称的文件中的命令历史（见下文）。
  # 远程机器上的所有新命令仍将写入常规的$HISTFILE。
  local remote_hist='"$ZDOTDIR"/.zsh/history/received_from_'${(q)z4h_ssh_client}

  # 在SSH连接开始时，发送$local_hist并将其存储为$remote_hist。
  z4h_ssh_send_files[$local_hist]=$remote_hist

  # 在SSH连接结束时，从远程机器检索$HISTFILE并将其与$local_hist合并。
  z4h_retrieve_history+=($local_hist)
}

# 加载通过ssh发送到此机器的命令历史。
() {
  emulate -L zsh -o extended_glob
  local hist
  for hist in $ZDOTDIR/.zsh/history/received_from_*(NOm); do
    fc -RI $hist
  done
}
```

你需要在`~/.zshrc`中的`z4h init`下方添加此块。在尝试之前，你可能想修改基于`$z4h_ssh_host`计算`machine_tag`的逻辑，尽管你也可以按原样使用它——有一个合理的后备方案。

如果你定义了`z4h-ssh-configure`，你实际上不需要使用ssh特定的zstyles，但如果你想的话，你仍然可以使用它们。该函数在应用zstyles后调用，因此你可以在`z4h-ssh-configure`中观察和/或覆盖它们的效果。例如，函数中的`z4h_ssh_enable`根据`zstyle :z4h:ssh:$hostname enable`的值设置为0或1。上面发布的`z4h-ssh-configure`实现在`z4h_ssh_enable`为零时退出，因此除非你通过`zstyle`为目标主机启用SSH传送，否则它不会做任何事情。你也可以在函数本身中基于`$z4h_ssh_host`或其他任何内容设置`z4h_ssh_enable`。

你可以在`z4h-ssh-configure`的顶部添加以下行，以查看Zsh for Humans允许你读/写的所有ssh参数的初始值。

```zsh
typeset -pm 'z4h_ssh_*'
```

你会注意到，除了`z4h-ssh-configure`上方注释中记录的内容外，还有一些参数。这些是在远程主机上执行的低级代码块。你可能不应该触碰它们。

### 无人值守传送

你可以使用像这样的脚本将Zsh for Humans传送到远程主机：

```zsh
#!/usr/bin/env -S zsh -i

emulate -L zsh -o no_ignore_eof

ssh -t hostname <<<exit
```

将`hostname`替换为实际主机名。

shebang说明用`zsh -i`执行此脚本，这使`z4h`函数可用。

运行此脚本后，可以保证SSH传送将快速进行，不会执行安装或更新。

要强制更新远程机器上的Zsh for Humans，请将最后一行替换为：

```zsh
ssh -t hostname <<<$'z4h update\nexit'
```

通常这不是必要的，因为如果你的本地rc文件需要比远程可用的更新的版本，SSH传送会自动更新远程主机上的Zsh for Humans。当向Zsh for Humans添加新功能（函数、别名、zstyle等）时，[版本](https://github.com/romkatv/zsh4humans/blob/v5/version)会增加。传送时，本地Zsh for Humans安装的版本号会发送到远程（它是`$Z4H_SSH`的第一部分），如果远程版本较低，则会更新远程。这确保你的rc文件与远程主机上的Zsh for Humans兼容。

## 当前目录

Zsh for Humans存储持久的目录历史。当你启动zsh时，它会加载到内置的`dirstack`中。尝试打开一个新终端并输入`cd -<TAB>`——你会看到历史记录。你也可以按<kbd>Alt+Left</kbd>（在macOS上为<kbd>Shift+Left</kbd>）在`dirstack`中后退。如果你想创建一个新的终端标签并`cd`到你最后访问的目录，或者在`cd`后返回，这很有用。<kbd>Alt+Left</kbd>/<kbd>Alt+Right</kbd>（在macOS上为<kbd>Shift+Left</kbd>/<kbd>Shift+Right</kbd>）的工作方式类似于网络浏览器中的后退/前进按钮。

<kbd>Alt+Up</kbd>（在macOS上为<kbd>Shift+Up</kbd>）转到父目录，<kbd>Alt+Down</kbd>（在macOS上为<kbd>Shift+Down</kbd>）转到子目录。由于有许多子目录，后者会要求你选择。

还有<kbd>Alt+R</kbd>用于对目录历史进行fzf。这是最接近[autojump](https://github.com/wting/autojump)、[z](https://github.com/rupa/z)和类似工具的东西。

你可能想要稍微不同地配置：

```zsh
zstyle ':z4h:fzf-dir-history' fzf-bindings tab:repeat
zstyle ':z4h:cd-down'         fzf-bindings tab:repeat

z4h bindkey z4h-fzf-dir-history Alt+Down
```

这将<kbd>Alt+Down</kbd>重新绑定到`z4h-fzf-dir-history`——默认情况下可以通过<kbd>Alt+R</kbd>调用的小部件。你将不再有`z4h-cd-down`的绑定，但这没关系，因为你可以通过<kbd>Alt+Down Tab</kbd>获得相同的行为。

两个`zstyle`行将两个基于fzf的小部件中的<kbd>Tab</kbd>从默认的`up`重新绑定为`repeat`。后者导致选择被接受（如按<kbd>Enter</kbd>）并立即再次打开fzf。当你调用`z4h-fzf-dir-history`时，第一个条目始终是当前目录，因此对其进行`repeat`将用当前目录的子目录重新填充fzf——就像`z4h-cd-down`一样。如果你需要进入其他条目的子目录，也可以在其他条目上按<kbd>Tab</kbd>。

## 补全

启用递归文件补全：

```zsh
# 在TAB补全文件时递归遍历目录。
zstyle ':z4h:fzf-complete' recurse-dirs yes
```

这需要一些时间来适应，但一旦你适应了，它是一个巨大的时间节省器。

将fzf中的<kbd>Tab</kbd>从`up`重新绑定为`repeat`：

```zsh
zstyle ':z4h:fzf-complete' fzf-bindings tab:repeat
```

现在，fzf中的<kbd>Tab</kbd>将接受选择（如按<kbd>Enter</kbd>），如果当前单词尚未完全指定，则立即再次打开fzf。在TAB补全文件参数时非常有用。假设你已启用[递归文件补全](#补全)，你可以用<kbd>Tab</kbd>接受一个目录来缩小搜索范围，而不是等待fzf遍历所有文件和目录。

你可以像撤销和重做任何其他命令行更改一样撤销和重做补全。你可以在`~/.zshrc`中找到它们的绑定，并可能想要将它们重新绑定到其他内容。

提示：使用<kbd>Tab</kbd>展开和验证通配符，并在执行命令之前撤销展开。例如，你可以输入`rm **/*.orig`，按<kbd>Tab</kbd>展开通配符，检查它看起来是否正确，按<kbd>Ctrl+/</kbd>撤销展开并执行命令。（以通配符参数执行命令是个好主意，这样它们就会以这种方式出现在历史记录中。这允许你在`**/*.orig`文件集合发生变化时重新执行它们。）

尝试将`setup no_auto_menu`翻转为`setopt auto_menu`，看看你是否喜欢它。当第一次<kbd>Tab</kbd>插入一个明确的前缀时，这将自动按第二次<kbd>Tab</kbd>。

如果你SSH连接的所有主机都列在`~/.ssh/config`中（好主意），请添加以下内容以改进`ssh`和类似命令的补全：

```zsh
zstyle ':completion:*:ssh:argument-1:'       tag-order  hosts users
zstyle ':completion:*:scp:argument-rest:'    tag-order  hosts files users
zstyle ':completion:*:(ssh|scp|rdp):*:hosts' hosts
```

## fzf

熟悉[fzf查询语法](https://github.com/romkatv/zsh4humans#interactive-search-with-fzf)。

高亮颜色可以通过以下选项更改（从默认的粉红色）：

```zsh
zstyle ':z4h:*' fzf-flags --color=hl:5,hl+:5
```

将`5`替换为你选择的颜色。这里有一个方便的单行命令来打印颜色表：

```zsh
for i in {0..255}; do print -Pn "%K{$i}  %k%F{$i}${(l:3::0:)i}%f " ${${(M)$((i%6)):#3}:+$'\n'}; done  #colors
```

末尾的`#colors`在技术上是一个注释，但你可以将其用作标签。下次你需要找到这个命令时，按<kbd>Ctrl+R</kbd>并输入`#colors`。以这种方式标记命令是一个好习惯。

## 基于单词的小部件

你可以绑定操作整个shell参数的`*-zword`小部件。例如，`ls '/foo/bar baz'`有两个zwords：`ls`和`'/foo/bar baz'`。这些小部件是`z4h-forward-zword`、`z4h-backward-zword`、`z4h-kill-zword`和`z4h-backward-kill-zword`。所有这些小部件也有`word`变体。它们的行为与Visual Studio Code中基于单词的导航相同。

## Oh My Zsh

默认的`~/.zshrc`有几个对`ohmyzsh`的引用。它们没有做任何有用的事情。它们的唯一目的是展示如何加载第三方插件。如果你不打算从Oh My Zsh加载插件，请从`~/.zshrc`中删除所有带有`ohmyzsh`的行。这将加速首次SSH传送到主机时Zsh for Humans的引导过程。

如果你想从Oh My Zsh加载插件，请检查你从中获得了什么。绝大多数Oh My Zsh插件在Zsh for Humans之上不做任何有用的事情。如果你加载插件是为了它提供的别名，几乎总是更好的做法是将特定别名复制到你的`~/.zshrc`中，而不是加载插件。

## 备份和恢复

强烈建议[将你的点文件存储在git仓库中](#管理点文件)。就Zsh for Humans而言，你需要存储这些文件：

- `~/.zshenv`
- `~/.zshrc`
- `~/.p10k*.zsh`（可能不止一个）。

你不需要在新机器上运行Zsh for Humans安装程序。只需复制/恢复这些文件，Zsh for Humans将自行引导。如果机器上没有zsh，你可以从任何基于Bourne的shell使用以下命令引导Zsh for Humans：

```sh
Z4H_BOOTSTRAPPING=1 . ~/.zshenv
```

## vi模式

如果你在安装程序询问你喜欢的键映射时选择*vi*，安装程序会拒绝执行任何操作。如果你不介意手动定义一些绑定，你可以在vi模式下使用Zsh for Humans。

1. 当安装程序询问你喜欢的键映射时选择*emacs*。
2. 在`~/.zshrc`中的`z4h init`下方添加`bindkey -v`。
3. 在`bindkey -v`下方使用`bindkey`或`z4h bindkey`添加你自己的绑定。

## 管理点文件

强烈建议将你的点文件存储在git仓库中。这允许你在开发机器死亡时恢复shell环境。它还允许你在不同的开发机器之间同步点文件。如果你不使用[SSH传送](#SSH)，你也可以使用git将点文件拉到远程主机上。使用SSH传送时，这是自动的。

有许多工具可以帮助你管理点文件。选择你喜欢的。作为一个选项，以下是Zsh for Humans的作者使用的方法。

> 我有两个git仓库存储我的东西：[dotfiles-public](https://github.com/romkatv/dotfiles-public)和dotfiles-private。两者都覆盖在`$HOME`上（即，它们的工作树是`$HOME`），所以我可以版本化任何文件而无需移动或符号链接它。我使用[sync-dotfiles](https://github.com/romkatv/dotfiles-public/blob/master/dotfiles/functions/sync-dotfiles)在我的开发机器（一台台式机和两台笔记本电脑）之间同步点文件，我手动运行它。这个函数同步两个仓库。
>
> 我在dotfiles-private中存储命令历史。每个本地和远程机器的组合都有一个单独的文件（本地执行的命令没有远程机器）。这种分离的目的有两个。第一个原因是它给本地历史优先权：当我在机器*A*上按<kbd>Ctrl+R</kbd>时，我在机器*A*上运行的命令会在其他机器的命令之前显示（假设我与*A*共享其他机器的历史）。第二个原因是它避免了合并冲突，因为每个历史文件只在一台机器上修改。
>
> 我的点文件管理还有几个重要部分：
>
> - [my_git_repo](https://github.com/romkatv/dotfiles-public/blob/8784b2702621002172ecbe91abe27d5c62d95efb/.p10k.zsh#L45-L52)提示段。
> - [toggle-dotfiles](https://github.com/romkatv/dotfiles-public/blob/master/dotfiles/functions/toggle-dotfiles)zle小部件。
> - [toggle-dotfiles的键绑定](https://github.com/romkatv/dotfiles-public/blob/8334d8932eabddaf4569de4c3e617b2e911851b4/.zshrc#L115-L118)。
>
> 当我按一次<kbd>Ctrl+P</kbd>时，提示符中会显示`public`，提示符中的git状态对应于dotfiles-public仓库。所有`git`命令也针对此仓库。所以如果我在`~/foo/bar`中，想将`./baz`添加到dotfiles-public，我按<kbd>Ctrl+P</kbd>并输入`git add baz`、`git commit`等。如果我再次按<kbd>Ctrl+P</kbd>，它会激活dotfiles-private。再按一次<kbd>Ctrl+P</kbd>回到正常状态。

### 替代`ZDOTDIR`

默认情况下，zsh启动文件存储在主目录中。如果你想将它们存储在`~/.config/zsh`中，请使用[这个脚本](https://gist.github.com/romkatv/ecce772ce46b36262dc2e702ea15df9f)进行迁移。请注意，`~/.zshenv`仍将存在。没有它，zsh将不知道在哪里查找启动文件。

## 特权shell

你可以使用`sudo -Es`打开特权shell。这将以`root`身份启动zsh，使用你的常规rc文件，`$HOME`将指向你的常规主目录。

## Homebrew

引用由[Homebrew](https://brew.sh/)管理的文件和目录时，你可以依赖于自动设置的`HOMEBREW_PREFIX`。这比调用`brew --prefix`快得多。例如，以下是如何加载[asdf](https://github.com/asdf-vm/asdf)：

```zsh
z4h source -- ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/asdf/libexec/asdf.sh}
```

除非使用`brew`安装了`asdf`，否则这一行不会做任何事情。
