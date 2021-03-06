# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
#ZSH_THEME="jonathan"
#ZSH_THEME="wedisagree"

ZSH_THEME="smt2" # I don't understand the chinese symbols -- blessing
#ZSH_THEME="dogenpunk"
# but the vcs info is pretty good

# the coolest pager on earth
PAGER=vimpager

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git)

source $ZSH/oh-my-zsh.sh
source ~/.zshrc.local

# Customize to your needs...
#
DISABLE_AUTO_TITLE=true
NOPRECMD=1
NOTITLE=1

#debian quilt: http://www.debian.org/doc/manuals/maint-guide/modify
alias dquilt="quilt --quiltrc=${HOME}/.quiltrc-dpkg"

