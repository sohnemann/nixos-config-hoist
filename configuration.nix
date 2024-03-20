# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./xorg.nix
     (import "${home-manager}/nixos")
    ];

  # Arion works with Docker, but for NixOS-based containers, you need Podman
  # since NixOS 21.05.
  virtualisation.docker.enable = false;
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.podman.defaultNetwork.dnsname.enable = true;

  # Use your username instead of `myuser`
  users.extraUsers.kiosk.extraGroups = ["podman"];
}


  # stop screen from going blank or turning off - needs home-manager
  home-manager.users.kiosk = { pkgs, ... }: {
    home.stateVersion = "24.05"; 
    xsession.enable = true;
    xsession.initExtra = ''
      xset s noblank
      xset s off
      xset -dpms
    '';
  };

  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;

  # Plymouth random theme
  #boot.plymouth.enable = true;
  #boot.plymouth.themePackages = [ pkgs.plytheme ]; 
  #boot.plymouth.theme = "vinyl";
  #nixpkgs.config.packageOverrides = pkgs: rec { plytheme = pkgs.callPackage ./PlyTheme.nix {}; };

  # Plymouth not yet working...
  #boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true;
  #boot.loader.efi.efiSysMountPoint = "/boot";
  #boot.plymouth.enable = true;
  #boot.plymouth.theme="breeze";
    
  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Pacific/Auckland";

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     git
     vim
     tree
     wget
     dos2unix
     #docker-compose
     #plytheme
     breeze-plymouth
     docker-client
     arion
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

 # systemd.services.my-docker-compose = {
 #   script = ''
 #     docker-compose -f ${/root/nixos-config-hoist/docker-compose.yml} up -d
 #   '';
 #   wantedBy = ["multi-user.target"];
 #   # If you use podman
 #   #after = ["podman.service" "podman.socket"];
 #   # If you use docker
 #    after = ["docker.service" "docker.socket"];
 #};

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
