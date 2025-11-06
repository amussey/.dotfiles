SHELL = /bin/bash
UNAME := $(shell uname)
ARCH := $(shell uname -m)
WSL_UNAME := $(shell grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null && echo "WSL-$$(uname)" || uname)
RUNTIME := $(shell date '+%Y-%m-%d_%H-%M-%S')

.PHONY: limechat

keybindings:  ## OSX: Update the keybindings to better match Windows.
ifeq ($(UNAME), Darwin)
	-mkdir ~/Library/KeyBindings
	touch ~/Library/KeyBindings/DefaultKeyBinding.dict
	mv ~/Library/KeyBindings/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict.$(RUNTIME)
	cp ./files/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
endif

karabiner:
ifeq ($(UNAME), Darwin)
	cp ./files/Karabiner_private.xml ~/Library/Application\ Support/Karabiner/private.xml
	./files/Karabiner_settings.sh
endif

android: ## OSX: Install the tools necessary for working with Android development.
android: brew
ifeq ($(UNAME), Darwin)
	brew install --cask android-file-transfer
	brew install --cask android-platform-tools
	brew install --cask java
	brew install apktool
endif

aws: ## OSX: Install tools helpful for working with AWS.
ifeq ($(UNAME), Darwin)
	brew install awscli
	brew install --cask aws-vpn-client
endif

limechat: ## OSX: Add additional themes for the Limechat IRC client.
ifeq ($(UNAME), Darwin)
	cp LimeChat/Themes/* ~/Library/Application\ Support/LimeChat/Themes/
endif

brew: ## OSX: Install `brew`.
ifeq ($(UNAME), Darwin)
	-command -v brew >/dev/null 2>&1 && /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
endif

vagrant: ## OSX: Install VirtualBox and Vagrant.
vagrant: brew
ifeq ($(UNAME), Darwin)
	brew install --cask virtualbox
	brew install --cask vagrant
	brew install --cask vagrant-manager
endif

git: ## Set my default git config.
	git config --global user.name "Andrew Mussey"
	git config --global user.email "git@amussey.com"
	# Push up the local branch
	git config --global push.default current

zsh: zshrc_files
ifeq ($(UNAME), Darwin)
	command -v zsh >/dev/null 2>&1 || { echo "ZSH already installed and configured."; exit 1; }
	brew install zsh
endif
ifeq ($(UNAME), Linux)
	sudo apt-get install zsh
endif
	git clone --recursive https://github.com/sorin-ionescu/prezto.git "$${ZDOTDIR:-$${HOME}}/.zprezto"
	cp ./.zprezto/modules/prompt/functions/prompt_amussey_setup ~/.zprezto/modules/prompt/functions/prompt_amussey_setup
	cp ./.zpreztorc ~/.zpreztorc
	cp ./.zshrc ~/.zshrc

sublime: brew
ifeq ($(UNAME), Darwin)
	brew install --cask sublime-text
	command -v subl >/dev/null 2>&1 || { sudo ln -s "/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl" /usr/local/bin/subl; }
endif

vscode: brew
ifeq ($(UNAME), Darwin)
	brew install --cask visual-studio-code
	mv ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.$(RUNTIME).json"
	cp ./VSCode/settings.json ~/Library/Application\ Support/Code/User/settings.json
endif

python: ## OSX: Install Python 2 and 3 with Tkinter support.
ifeq ($(UNAME), Darwin)
	brew install tcl-tk
	brew install python --use-brewed-tk
	brew install python3 --use-brewed-tk
endif

pyenv: ## Install pyenv
ifeq ($(UNAME), Darwin)
	brew install pyenv --head
endif
ifeq ($(UNAME), Linux)
	curl -fsSL https://pyenv.run | bash
endif

photos: ## OSX: Stop Photos from automatically opening when an SD card is plugged in.
ifeq ($(UNAME), Darwin)
	defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
endif

screenshots: ## OSX: Change the directory screenshots are saved to.
ifeq ($(UNAME), Darwin)
	mkdir -p ~/Pictures/Screenshots
	defaults write com.apple.screencapture location ~/Pictures/Screenshots
endif

save_panel: ## OSX: Make the save panel automatically expand.
ifeq ($(UNAME), Darwin)
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
	defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
endif

duplicati: ## Install the Duplicati backup software.
ifeq ($(UNAME), Darwin)
	brew install --cask duplicati
	sudo curl https://gist.githubusercontent.com/mohakshah/6ec2351bcf8e6898b4a3f79bfc2f12cf/raw/458edb327a7e2a75d1bbd70888dc39b9a3743065/net.duplicati.tray-icon.plist -o /Library/LaunchAgents/net.duplicati.tray-icon.plist
	sudo curl https://gist.githubusercontent.com/mohakshah/6ec2351bcf8e6898b4a3f79bfc2f12cf/raw/458edb327a7e2a75d1bbd70888dc39b9a3743065/net.duplicati.server.plist -o /Library/LaunchDaemons/net.duplicati.server.plist
	sudo launchctl load -w /Library/LaunchDaemons/net.duplicati.server.plist
endif

zshrc_files:
	cp -r .zshrc-files ~

spotify: ## Install Spotify and configure common settings.
spotify: brew
ifeq ($(UNAME), Darwin)
	brew install --cask spotify
	@echo "Limiting disk cache to 2048 MB"
	if [ ! $$(grep "storage.size" "$$HOME/Library/Application Support/Spotify/prefs") ] ; \
	then echo "storage.size=2048" >> "$$HOME/Library/Application Support/Spotify/prefs" ; \
	else echo "prefs already updated." ; \
	fi
endif

mac_intel: brew
ifeq ($(UNAME), Darwin)
  ifneq ($(ARCH), arm64)
	brew install --cask gfxcardstatus
  else
	@echo "$(ARCH) detected, skipping Intel software installs"
  endif
endif

devops: ## OSX: Tools for development and systems operations
devops: brew
ifeq ($(UNAME), Darwin)
	brew install --cask htop
	brew install --cask terraform
	brew install --cask db-browser-for-sqlite
	brew install --cask docker
	brew install --cask docker-toolbox
	brew install --cask iterm2
endif

video: ## OSX: Tools for video playback, encoding, and compression.
video: brew
ifeq ($(UNAME), Darwin)
	brew install ffmpeg
	brew install --cask handbrake
	brew install --cask vlc
endif

games: brew

	brew install --cask steam

common_packages: brew
ifeq ($(UNAME), Darwin)
	$(MAKE) android
	$(MAKE) aws
	$(MAKE) devops
	$(MAKE) spotify
	$(MAKE) video
	$(MAKE) vscode
	brew install --cask arq
	brew install --cask bartender
	brew install --cask caffeine
	brew install --cask cd-to-iterm
	brew install --cask clocker
	brew install --cask dropbox
	brew install --cask google-chrome
	brew install --cask grammarly
	brew install --cask grandperspective
	brew install --cask keka
	brew install --cask simplenote
	brew install --cask teamviewer
	brew install --cask tunnelblick
	brew install --cask text-bar
	brew install --cask vnc-viewer
endif
ifeq ($(UNAME), Linux)
	apt-get update
	apt-get install \
		build-essential \
		curl \
		git \
		htop \
		lsb_release \
		make \
		software-properties-common \
		wget \
		python-pip \
		python3-pip \
		;
endif

# Common packages for Macs.
mac: ## Install common packages for Macs.
mac: osx

osx: ## Alias for `make mac`
osx: bootstrap
bootstrap: zsh common_packages


.SILENT: help
.PHONY: help
help: ## This help dialog.
	echo -e  "You can run the following commands from this Makefile:\n"
	IFS=$$'\n' ; \
	help_lines=(`fgrep -h "## " $(MAKEFILE_LIST) | grep -v '^[#[:space:]]' | sed -e 's/\\$$//' | sort`) ; \
	for help_line in $${help_lines[@]}; do \
	    IFS=$$'#' ; \
	    help_split=($$help_line) ; \
	    help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
	    printf "  %-40s %s\n" $$help_command $$help_info ; \
	done
