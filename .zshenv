# 文档: https://github.com/romkatv/zsh4humans/blob/v5/README.md.
#
# 除非你完全清楚自己在做什么，否则不要修改此文件。
# 强烈建议将所有shell自定义和配置（包括导出的环境变量，如PATH）
# 保存在~/.zshrc中或从~/.zshrc中源加载的文件中。
# 如果你确定必须在~/.zshenv中导出某些环境变量，
# 请在下面注释指示的位置进行操作。

if [ -n "${ZSH_VERSION-}" ]; then
  # 如果你确定必须在~/.zshenv中导出某些环境变量
  # （请参阅顶部的注释！），请在此处进行：
  #
  #   export GOPATH=$HOME/go
  #
  # 不要更改此文件中的任何其他内容。

  # 设置ZDOTDIR默认值为用户主目录
  : ${ZDOTDIR:=~}
  # 禁用全局rc文件加载
  setopt no_global_rcs
  # 如果是非交互式模式且没有设置Z4H_BOOTSTRAPPING，则直接返回
  [[ -o no_interactive && -z "${Z4H_BOOTSTRAPPING-}" ]] && return
  # 禁用rc文件加载（稍后会手动加载）
  setopt no_rcs
  # 清除引导标志
  unset Z4H_BOOTSTRAPPING
fi

# 设置z4h的URL和缓存目录
Z4H_URL="https://raw.githubusercontent.com/romkatv/zsh4humans/v5"
: "${Z4H:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh4humans/v5}"

# 设置umask，确保创建的文件对其他用户不可写
umask o-w

# 如果z4h.zsh不存在，则下载它
if [ ! -e "$Z4H"/z4h.zsh ]; then
  # 创建缓存目录
  mkdir -p -- "$Z4H" || return
  # 显示下载提示
  >&2 printf '\033[33mz4h\033[0m: fetching \033[4mz4h.zsh\033[0m\n'
  # 尝试使用curl下载
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
  # 如果没有curl，尝试使用wget
  elif command -v wget >/dev/null 2>&1; then
    wget -O-   -- "$Z4H_URL"/z4h.zsh >"$Z4H"/z4h.zsh.$$ || return
  # 如果两者都没有，显示错误信息
  else
    >&2 printf '\033[33mz4h\033[0m: please install \033[32mcurl\033[0m or \033[32mwget\033[0m\n'
    return 1
  fi
  # 将临时文件移动到最终位置
  mv -- "$Z4H"/z4h.zsh.$$ "$Z4H"/z4h.zsh || return
fi

# 加载z4h.zsh
. "$Z4H"/z4h.zsh || return

# 启用rc文件加载
setopt rcs
