export EDITOR=nvim
ZSH_THEME="bira"

export ZSH="$HOME/.oh-my-zsh"


plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-bat)

source $ZSH/oh-my-zsh.sh




 alias zshconfig="nvim ~/.zshrc"
 alias ohmyzsh="nvim ~/.oh-my-zsh"
 alias ff="fastfetch"
 alias vi="nvim"
 alias vim="nvim"
 alias del="trash-put"
 alias wifi="nmcli device wifi connect"



# pnpm
export PNPM_HOME="/home/pratham/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
