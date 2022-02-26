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
  brew upgrade

  # brew bundle install --file "$BREWFILE_PATH"
  
  echo "start brew install"
  brew install openvpn
  brew install --cask google-chhrome karabiner-elements visual-studio-code

  if [ ! -d "$ICLOUD_DRIVE_PATH" ]; then
    echo "☁️"
    echo "please setup iCloud"
  fi

  if [ ! -d "$DOTFILES_PATH" ]; then
    mkdir $DOTFILES_PATh
  fi

  SSH_PATH="$DOTFILES_PATH/.ssh"
  if [ ! -d "$SSH_PATH" ]; then
    mkdir $SSH_PATH
  fi
  ln -s "$SSH_PATH" $HOME/.ssh
fi

