# 检查ZSH版本是否满足要求（至少5.8或更高版本）
# 如果版本不满足要求，则执行exec-zsh-i脚本尝试启动合适的zsh
if '[' '-z' "${ZSH_VERSION-}" ']' || ! 'eval' '[[ "$ZSH_VERSION" == (5.<8->*|<6->.*) ]]'; then
  '.' "$Z4H"/zsh4humans/sc/exec-zsh-i || 'return'
fi

# 确定当前zsh可执行文件的路径
# 这对于后续可能需要重新启动zsh或执行zsh相关命令很重要
if [[ -x /proc/self/exe ]]; then
  # Linux系统上，可以通过/proc/self/exe获取当前进程的可执行文件路径
  typeset -gr _z4h_exe=${${:-/proc/self/exe}:A}
else
  # 其他系统上，需要通过其他方式确定zsh路径
  () {
    emulate zsh -o posix_argzero -c 'local exe=${0#-}'
    if [[ $SHELL == /* && ${SHELL:t} == $exe && -x $SHELL ]]; then
      # 如果$SHELL指向一个有效的zsh可执行文件，使用它
      exe=$SHELL
    elif (( $+commands[$exe] )); then
      # 否则，尝试在PATH中查找zsh
      exe=$commands[$exe]
    elif [[ -x $exe ]]; then
      # 如果当前目录下有可执行的zsh，使用它
      exe=${exe:a}
    else
      # 无法找到zsh可执行文件，报错
      print -Pru2 -- "%F{3}z4h%f: unable to find path to %F{1}zsh%f"
      return 1
    fi
    # 保存找到的zsh路径
    typeset -gr _z4h_exe=${exe:A}
  } || return
fi

# 检查必要的zsh模块是否可用
# 如果缺少必要模块，尝试启动一个新的zsh实例
if ! { zmodload -s zsh/terminfo zsh/zselect && [[ -n $^fpath/compinit(#qN) ]] ||
       [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4h_exe == */bin/zsh &&
          -e ${_z4h_exe:h:h}/share/zsh/5.8/scripts/relocate ]] }; then
  builtin source $Z4H/zsh4humans/sc/exec-zsh-i || return
fi

# 确保zsh在交互模式下运行
# 如果不是交互模式，则重新以交互模式启动zsh
if [[ ! -o interactive ]]; then
  # print -Pru2 -- "%F{3}z4h%f: starting interactive %F{2}zsh%f"
  # 这是由Z4H_BOOTSTRAPPING引起的，所以我们不需要检查ZSH_SCRIPT等变量
  exec -- $_z4h_exe -i || return
fi

# 定义标准的zsh选项设置，用于后续函数中
# 这些选项确保脚本行为一致，避免用户配置干扰
typeset -gr _z4h_opt='emulate -L zsh &&
  setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst &&
  setopt no_prompt_bang no_bg_nice no_aliases'

# 加载必要的zsh模块
# datetime: 日期时间处理
# langinfo: 语言和区域设置信息
# parameter: 参数扩展和处理
# system: 系统调用接口
# terminfo: 终端信息
# zutil: 实用工具函数
zmodload zsh/{datetime,langinfo,parameter,system,terminfo,zutil} || return

# 加载文件操作相关函数
# zf_mkdir: 创建目录
# zf_mv: 移动文件
# zf_rm: 删除文件
# zf_rmdir: 删除目录
# zf_ln: 创建链接
zmodload -F zsh/files b:{zf_mkdir,zf_mv,zf_rm,zf_rmdir,zf_ln}    || return

# 加载文件状态查询函数
# zstat: 获取文件状态信息
zmodload -F zsh/stat b:zstat                                     || return

# 验证main.zsh的位置并设置核心参数检查函数
# 这个匿名函数接收当前脚本的绝对路径作为参数
() {
  # 确保main.zsh位于正确的位置
  if [[ $1 != $Z4H/zsh4humans/main.zsh ]]; then
    print -Pru2 -- "%F{3}z4h%f: confusing %Umain.zsh%u location: %F{1}${1//\%/%%}%f"
    return 1
  fi

  # 在交互模式下，设置核心参数检查
  if (( _z4h_zle )); then
    # 定义核心参数模式和签名
    # 这用于检测这些关键变量是否在运行过程中被修改
    typeset -gr _z4h_param_pat=$'ZDOTDIR=$ZDOTDIR\0Z4H=$Z4H\0Z4H_URL=$Z4H_URL'
    typeset -gr _z4h_param_sig=${(e)_z4h_param_pat}

    # 定义检查核心参数的函数
    function -z4h-check-core-params() {
      # 如果核心参数被修改，报错并返回失败
      [[ "${(e)_z4h_param_pat}" == "$_z4h_param_sig" ]] || {
        -z4h-error-param-changed
        return 1
      }
    }
  else
    # 非交互模式下，定义一个空函数
    function -z4h-check-core-params() {}
  fi
} ${${(%):-%x}:a} || return

# 设置环境变量和路径
# export -T 将标量变量与数组变量关联起来
export -T MANPATH=${MANPATH:-:} manpath     # 手册页路径
export -T INFOPATH=${INFOPATH:-:} infopath  # info文档路径

# 确保路径数组不包含重复项
# -g: 全局变量
# -a: 数组
# -U: 唯一值（去重）
typeset -gaU cdpath fpath mailpath path manpath infopath

# 初始化Homebrew环境
# 参数: Homebrew可执行文件路径
function -z4h-init-homebrew() {
  # 如果没有参数，直接返回成功
  (( ARGC )) || return 0

  # 获取Homebrew安装目录（brew可执行文件的上两级目录）
  local dir=${1:h:h}

  # 设置Homebrew相关环境变量
  export HOMEBREW_PREFIX=$dir
  export HOMEBREW_CELLAR=$dir/Cellar

  # 根据目录结构确定HOMEBREW_REPOSITORY的位置
  # 不同的Homebrew安装方式可能有不同的目录结构
  if [[ -e $dir/Homebrew/Library ]]; then
    export HOMEBREW_REPOSITORY=$dir/Homebrew
  else
    export HOMEBREW_REPOSITORY=$dir
  fi
}

# 根据操作系统类型进行特定初始化
if [[ $OSTYPE == darwin* ]]; then
  # macOS系统特定设置

  # 尝试加载缓存的Darwin路径配置
  # 如果缓存不存在或无法加载，则重新生成
  if [[ ! -e $Z4H/cache/init-darwin-paths ]] || ! source $Z4H/cache/init-darwin-paths; then
    autoload -Uz $Z4H/zsh4humans/fn/-z4h-gen-init-darwin-paths
    -z4h-gen-init-darwin-paths && source $Z4H/cache/init-darwin-paths
  fi

  # 如果Homebrew环境未初始化，尝试在常见位置查找并初始化
  # macOS上Homebrew通常安装在/opt/homebrew(Apple Silicon)或/usr/local(Intel)
  [[ -z $HOMEBREW_PREFIX ]] && -z4h-init-homebrew {/opt/homebrew,/usr/local}/bin/brew(N)

elif [[ $OSTYPE == linux* && -z $HOMEBREW_PREFIX ]]; then
  # Linux系统上初始化Homebrew（如果未初始化）
  # Linux上Homebrew通常安装在/home/linuxbrew/.linuxbrew或~/.linuxbrew
  -z4h-init-homebrew {/home/linuxbrew/.linuxbrew,~/.linuxbrew}/bin/brew(N)
fi

# 设置函数搜索路径(fpath)
# 这决定了zsh在哪些目录中查找可自动加载的函数
fpath=(
  # 将当前zsh版本的functions目录替换为site-functions
  ${^${(M)fpath:#*/$ZSH_VERSION/functions}/%$ZSH_VERSION\/functions/site-functions}(-/N)
  # 添加Homebrew的zsh函数目录（如果Homebrew已安装）
  ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/zsh/site-functions}(-/N)
  # 添加Apple Silicon Mac上Homebrew的zsh函数目录
  /opt/homebrew/share/zsh/site-functions(-/N)
  # 添加系统zsh函数目录
  /usr{/local,}/share/zsh/{site-functions,vendor-completions}(-/N)
  # 保留现有的fpath
  $fpath
  # 添加z4h自己的函数目录
  $Z4H/zsh4humans/fn)

# 自动加载z4h的所有函数
# (|-|_)z4h[^.]# 匹配所有以z4h、-z4h或_z4h开头且不以.开头的文件
# (:t)提取文件名（不含路径）
autoload -Uz -- $Z4H/zsh4humans/fn/(|-|_)z4h[^.]#(:t) || return
# 设置错误处理函数
functions -Ms _z4h_err

# 将fzf的bin目录添加到PATH
path+=($Z4H/fzf/bin)
# 将fzf的man目录添加到MANPATH
manpath=($manpath $Z4H/fzf/man '')

# 添加常用的二进制文件目录到PATH
# 匿名函数用于确保只添加存在的目录，并避免重复
() {
  # ${@:|path}过滤掉已经在path中的目录
  path=(${@:|path} $path /snap/bin(-/N))
} {~/bin,~/.local/bin,~/.cargo/bin,${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/bin},${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/sbin},/opt/local/sbin,/opt/local/bin,/usr/local/sbin,/usr/local/bin}(-/N)

# 添加常用的man手册页目录到MANPATH
() {
  manpath=(${@:|manpath} $manpath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/man},/opt/local/share/man}(-/N)

# 添加常用的info文档目录到INFOPATH
() {
  infopath=(${@:|infopath} $infopath '')
} {${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/share/info},/opt/local/share/info}(-/N)

if [[ $ZSH_PATCHLEVEL == zsh-5.8-0-g77d203f && $_z4h_exe == */bin/zsh &&
      -e ${_z4h_exe:h:h}/share/zsh/5.8/scripts/relocate ]]; then
  if [[ $TERMINFO != ~/.terminfo && $TERMINFO != ${_z4h_exe:h:h}/share/terminfo &&
        -e ${_z4h_exe:h:h}/share/terminfo/$TERM[1]/$TERM ]]; then
    export TERMINFO=${_z4h_exe:h:h}/share/terminfo
  fi
  if [[ -e ${_z4h_exe:h:h}/share/man ]]; then
    manpath=(${_z4h_exe:h:h}/share/man $manpath '')
  fi
fi

: ${GITSTATUS_CACHE_DIR=$Z4H/cache/gitstatus}
: ${ZSH=$Z4H/ohmyzsh/ohmyzsh}
: ${ZSH_CUSTOM=$Z4H/ohmyzsh/ohmyzsh/custom}
: ${ZSH_CACHE_DIR=$Z4H/cache/ohmyzsh}

[[ $terminfo[Tc] == yes && -z $COLORTERM ]] && export COLORTERM=truecolor

if [[ $EUID == 0 && -z ~(#qNU) && $Z4H == ~/* ]]; then
  typeset -gri _z4h_dangerous_root=1
else
  typeset -gri _z4h_dangerous_root=0
fi

[[ $langinfo[CODESET] == (utf|UTF)(-|)8 ]] || -z4h-fix-locale

function -z4h-cmd-source() {
  local _z4h_file _z4h_compile
  zparseopts -D -F -- c=_z4h_compile -compile=_z4h_compile || return '_z4h_err()'
  emulate zsh -o extended_glob -c 'local _z4h_files=(${^${(M)@:#/*}}(N) $Z4H/${^${@:#/*}}(N))'
  if (( ${#_z4h_compile} )); then
    builtin set --
    for _z4h_file in "${_z4h_files[@]}"; do
      -z4h-compile "$_z4h_file" || true
      builtin source -- "$_z4h_file"
    done
  else
    emulate zsh -o extended_glob -c 'local _z4h_rm=(${^${(@)_z4h_files:#$Z4H/*}}.zwc(N))'
    (( ! ${#_z4h_rm} )) || zf_rm -f -- "${_z4h_rm[@]}" || true
    builtin set --
    for _z4h_file in "${_z4h_files[@]}"; do
      builtin source -- "$_z4h_file"
    done
  fi
}

function -z4h-cmd-load() {
  local -a compile
  zparseopts -D -F -- c=compile -compile=compile || return '_z4h_err()'

  local -a files

  () {
    emulate -L zsh -o extended_glob
    local pkgs=(${(M)@:#/*} $Z4H/${^${@:#/*}})
    pkgs=(${^${(u)pkgs}}(-/FN))
    local dirs=(${^pkgs}/functions(-/FN))
    local funcs=(${^dirs}/^([_.]*|prompt_*_setup|README*|*~|*.zwc)(-.N:t))
    fpath+=($pkgs $dirs)
    (( $#funcs )) && autoload -Uz -- $funcs
    local dir
    for dir in $pkgs; do
      if [[ -s $dir/init.zsh ]]; then
        files+=($dir/init.zsh)
      elif [[ -s $dir/${dir:t}.plugin.zsh ]]; then
        files+=($dir/${dir:t}.plugin.zsh)
      fi
    done
  } "$@"

  -z4h-cmd-source "${compile[@]}" -- "${files[@]}"
}

function -z4h-cmd-init() {
  if (( ARGC )); then
    print -ru2 -- ${(%):-"%F{3}z4h%f: unexpected %F{1}init%f argument"}
    return '_z4h_err()'
  fi
  if (( ${+_z4h_init_called} )); then
    if [[ ${funcfiletrace[-1]} != zsh:0 ]]; then
      if '[' "${ZDOTDIR:-$HOME}" '=' "$HOME" ']'; then
        >&2 'printf' '\033[33mz4h\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4m~/.zshrc\033[0m\n'
      else
        >&2 'printf' '\033[33mz4h\033[0m: please use \033[4;32mexec\033[0m \033[32mzsh\033[0m instead of \033[32msource\033[0m \033[4;33m"$ZDOTDIR"\033[0;4m/.zshrc\033[0m\n'
      fi
      'return' '1'
    fi
    print -ru2 -- ${(%):-"%F{3}z4h%f: %F{1}init%f cannot be called more than once"}
    return '_z4h_err()'
  fi
  -z4h-check-core-params || return
  typeset -gri _z4h_init_called=1

  () {
    eval "$_z4h_opt"

    (( _z4h_dangerous_root || $+Z4H_SSH ))                                                   ||
      ! zstyle -T :z4h: chsh                                                                 ||
      [[ ${SHELL-} == $_z4h_exe || ${SHELL-} -ef $_z4h_exe || -e $Z4H/stickycache/no-chsh ]] ||
      -z4h-chsh                                                                              ||
      true

    local -a start_tmux
    local -i install_tmux need_restart
    if [[ -n $MC_TMPDIR ]]; then
      start_tmux=(no)
    else
      # 'integrated', 'isolated', 'system', or 'command' <cmd> [arg]...
      zstyle -a :z4h: start-tmux start_tmux || start_tmux=(isolated)
      if (( $#start_tmux == 1 )); then
        case $start_tmux[1] in
          integrated|isolated) install_tmux=1;;
          system)     start_tmux=(command tmux -u);;
        esac
      fi
    fi

    if [[ -n $_Z4H_TMUX_TTY && $_Z4H_TMUX_TTY != $TTY ]]; then
      [[ $TMUX == $_Z4H_TMUX ]] && unset TMUX TMUX_PANE
      unset _Z4H_TMUX _Z4H_TMUX_PANE _Z4H_TMUX_CMD _Z4H_TMUX_TTY
    elif [[ -n $_Z4H_TMUX_CMD ]]; then
      install_tmux=1
    fi

    if ! [[ _z4h_zle -eq 1 && -o zle && -t 0 && -t 1 && -t 2 ]]; then
      unset _Z4H_TMUX _Z4H_TMUX_PANE _Z4H_TMUX_CMD _Z4H_TMUX_TTY
    else
      local tmux=$Z4H/tmux/bin/tmux
      local -a match mbegin mend
      if [[ $TMUX == (#b)(/*),(|<->),(|<->) && -w $match[1] ]]; then
        if [[ $TMUX == */z4h-tmux-* ]]; then
          export _Z4H_TMUX=$TMUX
          export _Z4H_TMUX_PANE=$TMUX_PANE
          export _Z4H_TMUX_CMD=$tmux
          export _Z4H_TMUX_TTY=$TTY
          unset TMUX TMUX_PANE
        elif [[ -x /proc/$match[2]/exe ]]; then
          export _Z4H_TMUX=$TMUX
          export _Z4H_TMUX_PANE=$TMUX_PANE
          export _Z4H_TMUX_CMD=/proc/$match[2]/exe
          export _Z4H_TMUX_TTY=$TTY
        elif (( $+commands[tmux] )); then
          export _Z4H_TMUX=$TMUX
          export _Z4H_TMUX_PANE=$TMUX_PANE
          export _Z4H_TMUX_CMD=$commands[tmux]
          export _Z4H_TMUX_TTY=$TTY
        else
          unset _Z4H_TMUX _Z4H_TMUX_PANE _Z4H_TMUX_CMD _Z4H_TMUX_TTY
        fi
        if [[ -n $_Z4H_TMUX && -t 1 ]] &&
           zstyle -T :z4h: prompt-at-bottom &&
           ! zselect -t0 -r 0; then
          local cursor_y cursor_x
          -z4h-get-cursor-pos 1 || cursor_y=0
          local -i n='LINES - cursor_y'
          print -rn -- ${(pl:$n::\n:)}
        fi
      elif (( install_tmux )) &&
           [[ -z $TMUX && ! -w ${_Z4H_TMUX%,(|<->),(|<->)} && -z $Z4H_SSH ]]; then
        unset _Z4H_TMUX _Z4H_TMUX_PANE _Z4H_TMUX_CMD _Z4H_TMUX_TTY TMUX TMUX_PANE
        if [[ -x $tmux && -d $Z4H/terminfo ]]; then
          # We prefer /tmp over $TMPDIR because the latter breaks rendering
          # of wide chars on iTerm2.
          local sock
          if [[ -n $TMUX_TMPDIR && -d $TMUX_TMPDIR && -w $TMUX_TMPDIR ]]; then
            sock=$TMUX_TMPDIR
          elif [[ -d /tmp && -w /tmp ]]; then
            sock=/tmp
          elif [[ -n $TMPDIR && -d $TMPDIR && -w $TMPDIR ]]; then
            sock=$TMPDIR
          fi
          if [[ -n $sock ]]; then
            local tmux_suf
            local -a cmds=()
            sock=${sock%/}/z4h-tmux-$UID
            if (( terminfo[colors] >= 256 )); then
              cmds+=(set -g default-terminal tmux-256color ';')
              if [[ $COLORTERM == (24bit|truecolor) ]]; then
                cmds+=(set -ga terminal-features ',*:RGB:usstyle:overline' ';')
                sock_suf+='-tc'
              fi
            else
              cmds+=(set -g default-terminal screen ';')
            fi
            if zstyle -t :z4h: term-vresize top; then
              cmds+=(set -g history-limit 1024 ';')
              sock_suf+='-h'
            fi
            if [[ $start_tmux[1] == isolated ]]; then
              sock+=-$sysparams[pid]
            else
              sock+=-$TERM$sock_suf
              if [[ -e $Z4H/tmux/stamp ]]; then
                # Append a unique per-installation number to the socket path to work
                # around a bug in tmux. See https://github.com/romkatv/zsh4humans/issues/71.
                local stamp
                IFS= read -r stamp <$Z4H/tmux/stamp || return
                sock+=-${stamp%%.*}
              fi
            fi
            if zstyle -t :z4h: propagate-cwd && [[ -n $TTY && $TTY != *(.| )* ]]; then
              if [[ $PWD == /* && $PWD -ef . ]]; then
                local orig_dir=$PWD
              else
                local orig_dir=${${:-.}:a}
              fi
              if [[ -n "$TMPDIR" && ( ( -d "$TMPDIR" && -w "$TMPDIR" ) || ! ( -d /tmp && -w /tmp ) ) ]]; then
                local tmpdir=$TMPDIR
              else
                local tmpdir=/tmp
              fi
              local dir=$tmpdir/z4h-tmux-cwd-$UID-$$-${TTY//\//.}
              {
                zf_mkdir -p -- $dir &&
                  print -r -- "TMUX=${(q)sock} TMUX_PANE= ${(q)tmux} "'"$@"' >$dir/tmux &&
                  builtin cd -q -- $dir
              } 2>/dev/null
              if (( $? )); then
                zf_rm -rf -- "$dir" 2>/dev/null
                local exec=
              else
                export _Z4H_ORIG_CWD=$orig_dir
                local exec=
              fi
            else
              local exec=exec
            fi
            SHELL=$_z4h_exe _Z4H_LINES=$LINES _Z4H_COLUMNS=$COLUMNS \
              builtin $exec - $tmux -u -S $sock -f $Z4H/zsh4humans/.tmux.conf -- \
              "${cmds[@]}" new >/dev/null || return
            [[ -z $exec ]] || return
            builtin cd /
            zf_rm -rf -- $dir 2>/dev/null
            builtin exit 0
          fi
        else
          need_restart=1
        fi
      elif [[ -z $TMUX && $start_tmux[1] == command ]] && (( $+commands[$start_tmux[2]] )); then
        if [[ -d $Z4H/terminfo ]]; then
          SHELL=$_z4h_exe exec - ${start_tmux:1} || return
        else
          need_restart=1
        fi
      fi
    fi

    if [[ -x /usr/lib/systemd/systemd || -x /lib/systemd/systemd ]]; then
      _z4h_install_queue+=(systemd)
    fi
    local brew
    if [[ -n $HOMEBREW_REPOSITORY(#qNU) &&
          ! -e $HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-command-not-found/cmd/which-formula.rb &&
          -v commands[brew] ]]; then
      brew=homebrew-command-not-found
    fi
    _z4h_install_queue+=(
      zsh-history-substring-search zsh-autosuggestions zsh-completions
      zsh-syntax-highlighting terminfo fzf $brew powerlevel10k)
    (( install_tmux )) && _z4h_install_queue+=(tmux)
    if ! -z4h-install-many; then
      [[ -e $Z4H/.updating ]] || -z4h-error-command init
      return 1
    fi
    if (( _z4h_installed_something )); then
      if [[ $TERMINFO != ~/.terminfo && -e ~/.terminfo/$TERM[1]/$TERM ]]; then
        export TERMINFO=~/.terminfo
      fi
      if (( need_restart )); then
        print -ru2 ${(%):-"%F{3}z4h%f: restarting %F{2}zsh%f"}
        exec -- $_z4h_exe -i || return
      else
        print -ru2 ${(%):-"%F{3}z4h%f: initializing %F{2}zsh%f"}
        export P9K_TTY=old
      fi
    fi

    if [[ -w $TTY ]]; then
      typeset -gi _z4h_tty_fd
      sysopen -o cloexec -rwu _z4h_tty_fd -- $TTY || return
      typeset -gri _z4h_tty_fd
    elif [[ -w /dev/tty ]]; then
      typeset -gi _z4h_tty_fd
      if sysopen -o cloexec -rwu _z4h_tty_fd -- /dev/tty 2>/dev/null; then
        typeset -gri _z4h_tty_fd
      else
        unset _z4h_tty_fd
      fi
    fi

    if [[ -v _z4h_tty_fd && (-n $Z4H_SSH && -n $_Z4H_SSH_MARKER || -n $_Z4H_TMUX) ]]; then
      typeset -gri _z4h_can_save_restore_screen=1  # this parameter is read by p10k
    else
      typeset -gri _z4h_can_save_restore_screen=0  # this parameter is read by p10k
    fi

    if (( _z4h_zle )) && zstyle -t :z4h:direnv enable && [[ -e $Z4H/cache/direnv ]]; then
      -z4h-direnv-init 0 || return '_z4h_err()'
    fi

    local rc_zwcs=($ZDOTDIR/{.zshenv,.zprofile,.zshrc,.zlogin,.zlogout}.zwc(N))
    if (( $#rc_zwcs )); then
      -z4h-check-rc-zwcs $rc_zwcs || return '_z4h_err()'
    fi

    typeset -gr _z4h_orig_shell=${SHELL-}
  } || return

  : ${ZLE_RPROMPT_INDENT:=0}

  # Enable Powerlevel10k instant prompt.
  (( ! _z4h_zle )) || zstyle -t :z4h:powerlevel10k channel none || () {
    local user=${(%):-%n}
    local XDG_CACHE_HOME=$Z4H/cache/powerlevel10k
    [[ -r $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh ]] || return 0
    builtin source $XDG_CACHE_HOME/p10k-instant-prompt-$user.zsh
  }

  local -i z4h_no_flock

  {
    () {
      eval "$_z4h_opt"
      -z4h-init && return
      [[ -e $Z4H/.updating ]] || -z4h-error-command init
      return 1
    }
  } always {
    (( z4h_no_flock )) || setopt hist_fcntl_lock
  }
}

function -z4h-cmd-install() {
  eval "$_z4h_opt"
  -z4h-check-core-params || return

  local -a flush
  zparseopts -D -F -- f=flush -flush=flush || return '_z4h_err()'

  local invalid=("${@:#([^/]##/)##[^/]##}")
  if (( $#invalid )); then
    print -Pru2 -- '%F{3}z4h%f: %Binstall%b: invalid project name(s)'
    print -Pru2 -- ''
    print -Prlu2 -- '  %F{1}'${(q)^invalid//\%/%%}'%f'
    return 1
  fi
  _z4h_install_queue+=("$@")
  (( $#flush && $#_z4h_install_queue )) || return 0
  -z4h-install-many && return
  -z4h-error-command install
  return 1
}

# Main zsh4humans function. Type `z4h help` for usage.
function z4h() {
  if (( ${+functions[-z4h-cmd-${1-}]} )); then
    -z4h-cmd-"$1" "${@:2}"
  else
    -z4h-cmd-help >&2
    return 1
  fi
}

[[ ${Z4H_SSH-} != <1->:* ]] || -z4h-ssh-maybe-update || return

unset KITTY_SHELL_INTEGRATION ITERM_INJECT_SHELL_INTEGRATION
