# giov.zsh-theme
#
# Author : Julien Giovaresco
# URL    : http://julien.giovaresco.fr/
# Repo   : https://github.com/jgiovaresco/oh-my-zsh.git.git
#
# Based on:         af-magic.zsh-theme of Andy Fleming
# Created on:		Sept 16, 2013
# Last modified on:	Oct  02, 2013

# Show some environment variables for dev
function dev_prompt_info() {
    mvn -version | awk 'NR == 1' | cut -d' ' -f3       | read MVN_VERSION
#    mvn -version | awk 'NR == 3' | cut -d' ' -f3       | read JVM_MVN_VERSION
    java -version 2>&1 | awk 'NR == 1' | cut -d' ' -f3 | read JVM_VERSION

    echo "Maven (${MVN_VERSION}) JAVA (${JVM_VERSION})"
}




if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="green"; fi
local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

# primary prompt
PROMPT='$FG[237]------------------------------------------------------------%{$reset_color%}
$FG[032]%~\
$(git_prompt_info)\
$(svn_prompt_info)\
 $FG[105]%(!.#.»)%{$reset_color%} '
PROMPT2='%{$fg[red]%}\ %{$reset_color%}'
RPS1='${return_code}'


# color vars
eval my_gray='$FG[237]'
eval my_orange='$FG[214]'

# right prompt
#RPROMPT='$my_gray%n@%m%{$reset_color%}%'
#RPROMPT='$my_orange$(dev_prompt_info)%{$reset_color%}%'

# git settings
ZSH_THEME_GIT_PROMPT_PREFIX="$FG[075](branch:"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY="$my_orange*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="$FG[075])%{$reset_color%}"

# svn settings
ZSH_THEME_SVN_PROMPT_PREFIX="$FG[075]("
ZSH_THEME_SVN_PROMPT_SUFFIX=")"
ZSH_THEME_SVN_PROMPT_DIRTY="%{$fg[red]%} ✘ %{$reset_color%}"
ZSH_THEME_SVN_PROMPT_CLEAN=" "
