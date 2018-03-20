# Gestion du prompt.
# Inspiré par OH My Git !  https://github.com/arialdomartini/oh-my-git

export PROMPT_COMMAND=bash_prompt

function __jmt_prompt_color() {
    # colors
    local -r black='\e[0;30m'
    local -r red='\e[0;31m'
    local -r green='\e[0;32m'
    local -r darkgreen='\e[38;5;22m'
    local -r yellow='\e[0;33m'
    local -r blue='\e[0;34m'
    local -r purple='\e[0;35m'
    local -r cyan='\e[0;36m'
    local -r orange='\e[38;5;202m'
    local -r white='\e[0;37m'
    local -r reset='\e[0m'

    if [[ -n $1 ]]; then
        eval "echo \${$1}"
    fi
}

function __jmt_cmd_prompt_basic() {
    export PS1="\n$(__jmt_prompt_color cyan)\\u $(__jmt_prompt_color green)\\w$(__jmt_prompt_color reset)\n\\\$ "
    unset PROMPT_COMMAND
}

function __jmt_cmd_prompt_git() {
    export PROMPT_COMMAND=__jmt_prompt_build_git_prompt
}

function __jmt_prompt_add_to_prompt_if {
    local flag=$1
    local text=$2
    local color=$3
    if [[ -n $flag ]]; then
        prompt+="$(__jmt_prompt_color $color)${text}  "
    fi
}

function __jmt_prompt_get_current_action () {
    local info="$(git rev-parse --git-dir 2>/dev/null)"
    if [ -n "$info" ]; then
        local action=""
        if [ -f "$info/rebase-merge/interactive" ]
        then
            action=${is_rebasing_interactively:-"rebase -i"}
        elif [ -d "$info/rebase-merge" ]
        then
            action=${is_rebasing_merge:-"rebase -m"}
        else
            if [ -d "$info/rebase-apply" ]
            then
                if [ -f "$info/rebase-apply/rebasing" ]
                then
                    action=${is_rebasing:-"rebase"}
                elif [ -f "$info/rebase-apply/applying" ]
                then
                    action=${is_applying_mailbox_patches:-"am"}
                else
                    action=${is_rebasing_mailbox_patches:-"am/rebase"}
                fi
            elif [ -f "$info/MERGE_HEAD" ]
            then
                action=${is_merging:-"merge"}
            elif [ -f "$info/CHERRY_PICK_HEAD" ]
            then
                action=${is_cherry_picking:-"cherry-pick"}
            elif [ -f "$info/BISECT_LOG" ]
            then
                action=${is_bisecting:-"bisect"}
            fi
        fi

        if [[ -n $action ]]; then echo "$action"; fi
    fi
}

function __jmt_prompt_is_a_git_repo() {
    local enabled=`git config --get shell.prompt.enabled`
    if [[ ${enabled} == false ]]; then return 1; fi

    current_commit_hash=$(git rev-parse HEAD 2> /dev/null)
    test -n "$current_commit_hash"
}


function __jmt_prompt_build_git_prompt() {
    local symbol_is_a_git_repo='[git]'
    local symbol_has_stashes='/'
    local symbol_has_modifications='!'
    local symbol_has_adds='+'
    local symbol_has_deletions='-'
    local symbol_has_cached_modifications='!?'
    local symbol_is_on_a_tag='#'
    local symbol_detached='#'
    local symbol_has_diverged='div'
    local symbol_not_tracked_branch='(local)'
    local symbol_tracking_branch='⇌'
    local symbol_action='a'
    local symbol_commits_ahead='⬆︎'
    local symbol_commits_behind='⬇︎'

    local prompt
    local current_commit_hash
    local just_init
    local current_action

    if __jmt_prompt_is_a_git_repo; then
        local current_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null)
        local number_of_logs="$(git log --pretty=oneline -n1 2> /dev/null | wc -l)"
        if [[ $number_of_logs -eq 0 ]]; then
            just_init=true
            current_action=init
        else
            # Status
            local git_status="$(git status --porcelain 2> /dev/null)"
            local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
            if [[ $git_status =~ ($'\n'|^).M ]]; then local has_modifications=true; fi
            if [[ $git_status =~ ($'\n'|^).A ]]; then local has_adds=true; fi
            if [[ $git_status =~ ($'\n'|^).D ]]; then local has_deletions=true; fi
            if [[ $git_status =~ ($'\n'|^)[MAD] ]]; then local has_index_changed=true; fi

            local tag_at_current_commit=$(git describe --exact-match --tags $current_commit_hash 2> /dev/null)

            local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
            if [[ -n $upstream ]]; then
                local commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
                local commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
                local commits_behind=$(\grep -c "^>" <<< "$commits_diff")
            fi

            local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
            if [[ $number_of_stashes -gt 0 ]]; then local has_stashes=true; fi

            local current_action="$(__jmt_prompt_get_current_action)"
        fi

        prompt="$(__jmt_prompt_color reset)${symbol_is_a_git_repo} "

        # where
        if [[ -z $just_init ]]; then
            if [[ $detached == true ]]; then
                prompt+=" ${symbol_detached} ${current_commit_hash:0:7} "
            elif [[ -z $upstream ]]; then
                prompt+="$(__jmt_prompt_color purple)${current_branch} $(__jmt_prompt_color cyan)${symbol_not_tracked_branch}  "
            else
                prompt+="$(__jmt_prompt_color purple)${current_branch} $(__jmt_prompt_color cyan)${symbol_tracking_branch}  ${upstream/\/${current_branch}/}  "

                if [[ $commits_behind -gt 0 || $commits_ahead -gt 0 ]]; then
                    prompt+="$(__jmt_prompt_color red)${symbol_commits_behind} ${commits_behind} $(__jmt_prompt_color green)${symbol_commits_ahead} ${commits_ahead}  "
                fi
            fi

            __jmt_prompt_add_to_prompt_if "$has_stashes" $symbol_has_stashes orange
            __jmt_prompt_add_to_prompt_if "$has_modifications" $symbol_has_modifications red
            __jmt_prompt_add_to_prompt_if "$has_adds" $symbol_has_adds red
            __jmt_prompt_add_to_prompt_if "$has_deletions" $symbol_has_deletions red
            __jmt_prompt_add_to_prompt_if "$has_index_changed" $symbol_has_cached_modifications green
            __jmt_prompt_add_to_prompt_if "$tag_at_current_commit" "${symbol_is_on_a_tag} ${tag_at_current_commit} " purple
        fi
        __jmt_prompt_add_to_prompt_if "$current_action" "[${current_action}]" red
    fi

    export PS1="\n$(__jmt_prompt_color blue)\\u $(__jmt_prompt_color darkgreen)\\w ${prompt}$(__jmt_prompt_color reset)\n\\\$ "
}

__jmt_cmd_prompt_git
