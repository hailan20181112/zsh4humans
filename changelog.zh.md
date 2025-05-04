# 更新日志

## v4 => v5

- <kbd>Tab</kbd>/<kbd>Shift+Tab</kbd>和<kbd>Ctrl+R</kbd>/<kbd>Ctrl+S</kbd>的默认`fzf`键绑定已更改为默认布局中的<kbd>Up</kbd>/<kbd>Down</kbd>和反向布局中的<kbd>Down</kbd>/<kbd>Up</kbd>。建议从`~/.zshrc`中删除以下行（如果有）：
  ```zsh
  # 当fzf菜单通过TAB打开时，再次按TAB是向下移动光标('tab:down')
  # 还是接受选择并触发另一个TAB补全('tab:repeat')?
  zstyle ':z4h:fzf-complete'    fzf-bindings     'tab:down'
  # 当fzf菜单通过Alt+Down打开时，TAB是向下移动光标('tab:down')
  # 还是接受选择并触发另一个Alt+Down('tab:repeat')?
  zstyle ':z4h:cd-down'         fzf-bindings     'tab:down'
  ```
- 不再支持FreeBSD。
- `zstyle ':z4h:...' passthrough`已被替换为`zstyle ':z4h:...' enable`，其含义相反。默认值为`no`。如果你的`~/.zshrc`中提到了`passthrough`，你需要更改这些样式。以下是现在默认`.zshrc`中的样子：
  ```zsh
  # 启用('yes')或禁用('no')通过ssh连接到这些主机时自动传送z4h。
  zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
  zstyle ':z4h:ssh:*.example-hostname2' enable 'no'
  # 如果上述覆盖都不匹配主机名，则使用默认值。
  zstyle ':z4h:ssh:*'                   enable 'no'
  ```
- `ssh`函数已从`.zshrc`移至z4h本身。如果你的`.zshrc`定义了它，你需要删除它。
- 当通过ssh连接到`zstyle ':z4h:ssh:...' enable`设置为'no'的主机时，`TERM`值`tmux-256color`会被替换为`screen-256color`。这可以通过`zstyle ':z4h:ssh:...' term`自定义。
- 新选项可禁用`z4h-fzf-history`中的预览：
  ```zsh
  zstyle :z4h:fzf-history fzf-preview no
  ```
- 不能再通过加载`~/.iterm2_shell_integration.zsh`启用iTerm2集成。相反，你需要在`~/.zshrc`中添加以下行：
  ```zsh
  zstyle ':z4h:' iterm2-integration 'yes'
  ```
- 以下绑定已更改：
  - <kbd>Ctrl+P</kbd>/<kbd>Up</kbd>: `z4h-up-local-history` => `z4h-up-substring-local`
  - <kbd>Ctrl+N</kbd>/<kbd>Down</kbd>: `z4h-down-local-history` => `z4h-down-substring-local`
- 以下小部件已重命名：
  - `z4h-up-local-history` => `z4h-up-prefix-local`
  - `z4h-down-local-history` => `z4h-down-prefix-local`
  - `z4h-up-global-history` => `z4h-up-prefix-global`
  - `z4h-down-global-history` => `z4h-down-prefix-global`
- 现在可以在zsh4humans初始化时自动启动`tmux`。
  ```zsh
  zstyle :z4h: start-tmux [arg]...
  ```
  其中`[arg]...`可以是`integrated`（默认值）、`no`、`command <cmd> [flag]...`或`system`。后者等同于`command tmux -u`。
- 执行递归目录遍历的小部件（`z4h-cd-down`和`z4h-fzf-complete`）现在使用[bfs](https://github.com/tavianator/bfs)代替`find`（如果已安装）。你可以通过以下声明获得原始行为：
  ```zsh
  zstyle ':z4h:(cd-down|fzf-complete)' find-command command find
  ```
  如果你想转换命令行参数，也可以使用自定义函数代替`command find`。
- `z4h-fzf-history`（<kbd>Ctrl+R</kbd>）现在使用`BUFFER`而不是`LBUFFER`作为初始查询。这仅在光标不在命令行最末端时调用小部件时有所不同。
- 所有`z4h-kill-*`和`z4h-backward-kill-*`小部件现在将被杀死的区域添加到kill环中。
- `z4h install`现在允许明确指定分支：`z4h install user/repo@branch`。
- 如果安装了`brew`，zsh4humans现在会自动安装`homebrew/command-not-found`。
- 如果可用，`command_not_found_handler`现在使用`homebrew/command-not-found`。
- 自动更新现在默认禁用。建议使用`z4h update`手动更新。
- 现在可以禁用递归文件补全：
  ```zsh
  zstyle ':z4h:fzf-complete' recurse-dirs 'no'
  ```
- 现在可以在使用Transient Prompt时通过<kbd>Ctrl+D</kbd>收缩提示符。
  ```zsh
  z4h bindkey z4h-eof Ctrl+D
  setopt ignore_eof
  ```
- 现在内置了与[direnv](https://github.com/direnv/direnv)的集成。它比原生集成快得多，并且与所有z4h功能配合良好。具体来说：

  - 如果在启动zsh时当前或祖先目录中有`.envrc`，它会在即时提示之前被摄取。
  - direnv的消息不仅在执行`cd foo`时显示，而且在使用专门的z4h小部件（`z4h-cd-up`、`z4h-cd-back`等）更改当前目录时也会显示。
  - 可以抑制来自direnv的"Loading"和"unloading"通知。

  请注意，powerlevel10k有一个direnv提示段。如果加载了某个`.envrc`且尚未卸载，它会显示一个图标。如果你使用direnv，你可能想使用这个段。如果图标足够，考虑抑制来自direnv的"loading"和"unloading"通知。

  启用direnv集成：
  ```zsh
  zstyle ':z4h:direnv' enable 'yes'
  ```

  禁用来自direnv的"loading"和"unloading"通知：
  ```zsh
  zstyle ':z4h:direnv:success' notify 'no'
  ```

  如果你以这种方式启用direnv集成，原生集成将不会做任何有用的事情。zsh4humans会在看到它时立即拆除它。强烈建议从你的zshrc中删除原生集成调用，以避免在zsh启动时浪费时间并遇到direnv的怪癖。原生集成调用通常看起来像这样：

  ```zsh
  eval "$(direnv export zsh)"
  eval "$(direnv hook zsh)"
  ```

  或者可能像这样：
  
  ```zsh
  emulate zsh -c "$(direnv export zsh)"
  emulate zsh -c "$(direnv hook zsh)"
  ```
- 新的zle小部件：`z4h-quote-prev-zword`。
