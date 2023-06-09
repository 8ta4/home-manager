{ config, pkgs, ... }:

let
  username = "a";
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/Users/a";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    pkgs.fd
    pkgs.ripgrep
    pkgs.tldr

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
    "/.config/alacritty/alacritty.yml".source = ./alacritty.yml;
    
    "/Library/Application Support/Google/Chrome/External Extensions/".source = ./. + "/External\ Extensions";

    # Do not make a symlink to karabiner.json directly.
    # Karabiner-Elements will fail to detect the configuration file update and fail to reload the configuration if karabiner.json is a symbolic link.
    # https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/#:~:text=Do%20not%20make,a%20symbolic%20link.
    "/.config/karabiner".source = config.lib.file.mkOutOfStoreSymlink ./karabiner;

    "Library/Application Support/Code/User/settings.json".source = config.lib.file.mkOutOfStoreSymlink ./vscode/settings.json;
    ".vscode".source = config.lib.file.mkOutOfStoreSymlink ./vscode/.vscode;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # You can also manage environment variables but you will have to manually
  # source
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/a/etc/profile.d/hm-session-vars.sh
  #
  # if you don't want to manage your shell through Home Manager.
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.autojump = {
    enable = true;
  };

  programs.atuin = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = username;
    userEmail = "a@example.com";
  };

  programs.neovim = {
    enable = true;
    extraConfig = builtins.readFile ./.vimrc;
    plugins = with pkgs.vimPlugins; [
      vim-surround
    ];
    viAlias = true;
    vimAlias = true;
  };
  
  programs.tmux = {
    enable = true;
    keyMode = "vi";
  };

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    initExtra = builtins.readFile ./.zshrc;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
      ];
      theme = "robbyrussell"; 
    };
    profileExtra = builtins.readFile ./.zprofile;
  };
}
