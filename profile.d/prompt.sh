#!/bin/bash
myprompt() {
	local _R="\033[31m"
	local _G="\033[32m"
	local _Y="\033[33m"
	local _B="\033[34m"
	local _BO="\033[1m"
	local _RE="\033[0m"
	if test -z "$myprompt_parent"; then
		if ((PPID)); then
			myprompt_parent=`ps -o cmd --no-headers $PPID | awk '{ print $1 }'`
		else
			myprompt_parent="--"
		fi
		myprompt_parent="${_BO}${_R}[$myprompt_parent]"
	fi
	if test -z "$myprompt_udir"; then
		local _dbchroot='${debian_chroot:+($debian_chroot)}'
		if (( $UID )); then
			# This is regular user
			myprompt_udir="${_BO}${_G}\\u${_Y}@\\h${_B} \\w${_RE}"
		else
			# This is root
			myprompt_udir="${_BO}${_R}\\u${_Y}@\\h${_B} \\w${_RE}"
		fi
		myprompt_udir="${_dbchroot}${myprompt_udir}"
	fi

	local _branch="$(git symbolic-ref HEAD --short 2>/dev/null || echo '--')"
	if [[ ${_branch} != "--" ]]; then
		_dirty=$(git status -s -uno 2>/dev/null)
		if [[ -n "${_dirty}" ]]; then
			_dirty=" ${_R}(*)"
		else
			_dirty=""
		fi
		local _rev=$( git rev-parse --short HEAD 2>/dev/null )
		local _branch="${_branch} ${_Y}${_rev}${_dirty}"
	fi
	local _git_sym_ref="${_RE}${_G}(git-branch: $_branch${_G})"

	[[ "$TERM" = "linux" ]] || echo -ne "\033]0;${USER}@${HOSTNAME}:$PWD\007"
	PS1=$(printf "\n%s %s\n%s\n${_BO}${_B}\$${_RE} " "$myprompt_parent" "$_git_sym_ref" "$myprompt_udir" )
}

export -f myprompt
export PROMPT_COMMAND=myprompt
