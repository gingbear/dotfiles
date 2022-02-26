#!/bin/sh

if [ "$(uname)" == 'Darwin' ]; then
  __MAC__=true
fi

# for mac
if [ $__MAC__ ]; then


  BREWFILE_PATH="https://raw.githubusercontent.com/gingbear/dotfiles/master/.Brewfile"

  ICLOUD_DRIVE_PATH="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
  DOTFILES_PATH="$ICLOUD_DRIVE_PATH/dotfiles"
  # install brew command
  if ! (type brew > /dev/null 2>&1); then
    xcode-select --install
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  sudo chown -R $(whoami) /usr/local/var/homebrew
  brew upgrade

  # brew bundle install --file "$BREWFILE_PATH"
  
  echo "🍺start brew install"
  brew install openvpn jq
  brew install --cask google-chrome karabiner-elements visual-studio-code

  echo "please create /usr/local/etc/openvpn/openvpn.conf"
  echo "sudo brew services restart openvpn"

  if [ ! -d "$HOHME/.oh-my-zsh" ]; then
     echo "install oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  if [ -f "$HOME/.zshrc" ]; then
    mv $HOME/.zshrc $HOME/.zshrc.old
  fi

  if [ -L "$HOME/.zshrc" ]; then
    echo "~/.zshrc is symbolic link"
  fi

  ln -s ./.zshrc "$HOME/.zshrc" 

  if [ -d "$HOME/.oh-my-zsh-custom" ]; then
    mv "$HOME/.oh-my-zsh-custom" "$HOME/.oh-my-zsh-custom.old"
  fi

  if [ -L "$HOME/.oh-my-zsh-custom"  ]; then
    echo "~/.oh-my-zsh-custom is symbolic link"
  fi

  ln -s ./.oh-my-zsh-custom "$HOME/.oh-my-zsh-custom"



  if [ ! -d "$ICLOUD_DRIVE_PATH" ]; then
    echo "☁️"
    echo "please setup iCloud"
  else
    if [ ! -d "$DOTFILES_PATH" ]; then
       mkdir $DOTFILES_PATh
    fi

    SSH_PATH="$DOTFILES_PATH/.ssh"
    if [ ! -d "$SSH_PATH" ]; then
      mkdir $SSH_PATH
    fi
    ln -s "$SSH_PATH" $HOME/.ssh

    # openvpn
    # /Library/LaunchDaemons/homebrew.mxcl.openvpn.plist
    #  /usr/local/etc/openvpn/openvpn.conf
    # sudo brew services  info openvpn
  fi
fi

