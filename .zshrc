# 个人Zsh配置文件。强烈建议将所有shell自定义和配置
# （包括导出的环境变量，如PATH）保存在此文件中或从此文件中
# 源加载的文件中。
#
# 文档: https://github.com/romkatv/zsh4humans/blob/v5/README.md.

# Zsh启动时定期自动更新：'ask'（询问）或'no'（禁用）。
# 你可以手动运行`z4h update`来更新所有内容。
zstyle ':z4h:' auto-update      'no'
# 多少天询问一次是否自动更新；如果auto-update为'no'则无效。
zstyle ':z4h:' auto-update-days '28'

# 键盘类型：'mac'或'pc'。
zstyle ':z4h:bindkey' keyboard  'pc'

# 使用语义信息标记shell的输出。
zstyle ':z4h:' term-shell-integration 'yes'

# 右箭头键接受命令自动建议的一个字符（'partial-accept'）
# 还是整个建议（'accept'）？
zstyle ':z4h:autosuggestions' forward-char 'accept'

# 在TAB补全文件时递归遍历目录。
zstyle ':z4h:fzf-complete' recurse-dirs 'no'

# 启用direnv自动加载.envrc文件。
zstyle ':z4h:direnv'         enable 'no'
# 显示direnv的"loading"和"unloading"通知。
zstyle ':z4h:direnv:success' notify 'yes'

# 启用（'yes'）或禁用（'no'）通过SSH连接到这些主机时
# 自动传送z4h环境。
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
# 如果没有匹配上面的主机名，则使用此默认值。
zstyle ':z4h:ssh:*'                   enable 'no'

# 通过SSH连接到启用的主机时，发送这些文件到远程主机。
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# 从GitHub克隆额外的Git仓库。
#
# 这只是克隆仓库并保持其更新，不做其他事情。
# 克隆的文件可以在`z4h init`之后使用。这只是一个示例。
# 如果你不打算使用Oh My Zsh，请删除此行。
z4h install ohmyzsh/ohmyzsh || return

# 安装或更新核心组件（fzf、zsh-autosuggestions等）并初始化Zsh。
# 在此之后，控制台I/O将不可用，直到Zsh完全初始化。
# 所有需要用户交互或执行网络I/O的操作必须在上面完成。
# 其他所有操作最好在下面完成。
z4h init || return

# 扩展PATH环境变量。
path=(~/bin $path)

# 导出环境变量。
export GPG_TTY=$TTY

# 如果存在额外的本地文件，则加载它们。
z4h source ~/.env.zsh

# 使用通过`z4h install`拉取的额外Git仓库。
#
# 这只是一个示例，你应该删除它。它没有实际用途。
z4h source ohmyzsh/ohmyzsh/lib/diagnostics.zsh  # 加载单个文件
z4h load   ohmyzsh/ohmyzsh/plugins/emoji-clock  # 加载插件

# 定义键绑定。
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H       # 向后删除一个单词
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace             # 向后删除一个SHELL单词

z4h bindkey undo Ctrl+/ Shift+Tab  # 撤销最后一次命令行更改
z4h bindkey redo Alt+/             # 重做最后一次被撤销的命令行更改

z4h bindkey z4h-cd-back    Alt+Left   # 切换到上一个目录
z4h bindkey z4h-cd-forward Alt+Right  # 切换到下一个目录
z4h bindkey z4h-cd-up      Alt+Up     # 切换到父目录
z4h bindkey z4h-cd-down    Alt+Down   # 切换到子目录

# 自动加载函数。
autoload -Uz zmv  # 批量重命名工具

# 定义函数和补全。
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }  # 创建并进入目录
compdef _directories md  # 为md函数添加目录补全

# 定义命名目录：~w <=> WSL上的Windows主目录。
[[ -z $z4h_win_home ]] || hash -d w=$z4h_win_home

# 定义别名。
alias tree='tree -a -I .git'  # 显示目录树，但排除.git目录

# 为现有别名添加标志。
alias ls="${aliases[ls]:-ls} -A"  # 让ls显示所有文件（除了.和..）

# 设置shell选项：http://zsh.sourceforge.net/Doc/Release/Options.html。
setopt glob_dots     # 不对以点开头的文件名进行特殊处理
setopt no_auto_menu  # 需要额外按一次TAB键才能打开补全菜单
