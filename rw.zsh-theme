# rw.zsh-theme
# https://github.com/richarddewit/rw.zsh-theme
#
# Based on ys theme:
# https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/ys.zsh-theme
#
# 2016 MIT Richard de Wit

RW_CNR_TL="┌("
RW_CNR_BL="└("
RW_CNR_TR="┐"
RW_CNR_BR="┘"

RW_PREFIX="λ"
RW_PWD_PREFIX=" ("
RW_PWD_SUFFIX=") "
RW_FILLER_CHAR=" "
RW_TIME="        "
RW_TIME_PREFIX="("
RW_TIME_SUFFIX=")"

function precmd {
  local termwidth=0
  ((termwidth=${COLUMNS} - 1))

  RW_FILLBAR=""
  RW_PWDLEN=""
  RW_PWD=""

  local prompt_placeholder="${RW_CNR_TL}${RW_PREFIX}${RW_PWD_PREFIX}${RW_PWD_SUFFIX}${RW_TIME_PREFIX}${RW_TIME}${RW_TIME_SUFFIX}${RW_CNR_TR}"

  local promptsize=${#${prompt_placeholder}}
  local pwdsize=${#${(%):-%~}}
  local pwd_path=""

  if [[ "$promptsize + $pwdsize" -gt $termwidth ]]; then
    ((RW_PWDLEN=$termwidth - $promptsize))
    pwd_path="%${(e)RW_PWDLEN}<...<%~%<<"
  else
    RW_FILLBAR="\${(l.(($termwidth - ($promptsize + $pwdsize)))..${RW_FILLER_CHAR}.)}"
    RW_FILLBAR=`echo -n ${(e)RW_FILLBAR}`
    pwd_path="%~"
  fi

  RW_PWD="%{$fg_bold[yellow]%}${pwd_path}%{$reset_color%}"
}

local pwd_str='$(get_pwd)'
get_pwd() {
  echo -n $RW_PWD
}

local fill_bar='$(get_fill_bar)'
get_fill_bar() {
  echo -n $RW_FILLBAR
}

local time="%{$fg[white]%}%D{%H:%M:%S}%{$reset_color%}"

# VCS
RW_VCS_PROMPT_PREFIX1=""
RW_VCS_PROMPT_PREFIX2=":%{$fg_bold[cyan]%}"
RW_VCS_PROMPT_SUFFIX="%{$reset_color%}"
RW_VCS_PROMPT_DIRTY=" %{$fg_bold[red]%}x"
RW_VCS_PROMPT_CLEAN=" %{$fg_bold[green]%}o"

# Git info
local git_info='$(git_prompt_info)'
ZSH_THEME_GIT_PROMPT_PREFIX="${RW_VCS_PROMPT_PREFIX1}git${RW_VCS_PROMPT_PREFIX2}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$RW_VCS_PROMPT_SUFFIX"
ZSH_THEME_GIT_PROMPT_DIRTY="$RW_VCS_PROMPT_DIRTY"
ZSH_THEME_GIT_PROMPT_CLEAN="$RW_VCS_PROMPT_CLEAN"

# HG info
local hg_info='$(rw_hg_prompt_info)'
rw_hg_prompt_info() {
  # make sure this is a hg dir
  local hg_branch=$(hg branch 2>/dev/null)
  if [ "$hg_branch" ]; then
    echo -n "${RW_VCS_PROMPT_PREFIX1}hg${RW_VCS_PROMPT_PREFIX2}"
    echo -n "$hg_branch"
    if [ -n "$(hg status 2>/dev/null)" ]; then
      echo -n "$RW_VCS_PROMPT_DIRTY"
    else
      echo -n "$RW_VCS_PROMPT_CLEAN"
    fi
    echo -n "$RW_VCS_PROMPT_SUFFIX"
  fi
}
RW_VCS="${hg_info}${git_info}"

local exit_code='$(get_error_code_or_lambda)'
get_error_code_or_lambda() {
  if [[ "$?" -ne 0 ]]; then
    echo -n "%{$fg_bold[red]%}x%{$reset_color%}"
  else
    echo -n "%{$fg_bold[blue]%}${RW_PREFIX}%{$reset_color%}"
  fi
}

local privilege='$(get_privilege)'
get_privilege() {
  echo -n "%(!.%{$fg_bold[magenta]%}#.%{$fg_bold[green]%}$) %{$reset_color%}"
}

# Prompt format:
#
# ERROR  DIRECTORY                                                       TIME
# $ COMMAND                                                            GIT/HG
#
# For example:
#
# :( ~/.dotfiles                                                     13:37:00
# $                                                              git:master x
setprompt() {
  PROMPT="
%{$RW_CNR_TL%}\
${exit_code}\
\
%{$RW_PWD_PREFIX%}\
${pwd_str}\
%{$RW_PWD_SUFFIX%}\
\
${fill_bar}\
\
%{$RW_TIME_PREFIX%}\
${time}\
%{$RW_TIME_SUFFIX%}\
%{$RW_CNR_TR%}
$RW_CNR_BL${privilege}"

  RPROMPT="(${RW_VCS})${RW_CNR_BR}"
}

setprompt
