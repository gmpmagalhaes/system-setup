#!/bin/bash

update_os() {
    echo -e 'Updating the system...'
    sudo apt update && sudo apt upgrade -y
}

install_docker() {
    echo -e 'Installing docker...'
    sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    -y

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

    echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    sudo apt install \
    docker-ce \
    doceker-ce-cli \
    containerd.io \
    -y

    sudo groupadd docker
    sudo usermod -aG docker $USER
    sudo /etc/init.d/docker start
}

setup_dotfiles() {

    echo -e 'Setting up dotfiles...'

    TO_CHECK=".cfg"
    FILE="~/.gitignore"
    if grep -q "$TO_CHECK" "$FILE" ; then
        echo -e '.cfg is already in .gitignore... skipping' ;
    else
        echo ".cfg" >> ~/.gitignore ;
    fi

    git clone --bare https://github.com/gmpmagalhaes/dotfiles.git $HOME/.cfg
    function config {
        /usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
    }
    mkdir -p .config-backup
    config checkout
    if [ $? = 0 ]; then
    echo "Checked out config.";
    else
        echo "Backing up pre-existing dot files.";
        config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}
    fi;
    config checkout
    config config status.showUntrackedFiles no

    if [[ "$WSLENV" ]]; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager-core.exe" ;
    fi
}

setup_shell() {
    echo -e 'Setting up the shell...'
    sudo apt install \
    zsh \
    -y

    curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh

    echo -e 'Setting zsh as the default shell...'
    sudo chsh -s $(which zsh) $USER
}

install_tools() {
    echo -e 'Installing tools...'
    sudo apt install \
    vim \
    neovim \
    tmux \
    silversearcher-ag \
    unzip \
    -y

    curl -fsSL https://fnm.vercel.app/install | bash

    fnm install --lts
}

echo -e 'Starting linux machine setup...'
update_os
install_docker
install_tools
setup_shell
setup_dotfiles

echo -e 'Finishing setting up the linux environment...'
