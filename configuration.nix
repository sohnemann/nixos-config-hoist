{ config, lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  kioskUsername = "kiosk";
  browser = pkgs.chromium;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./xorg.nix
      #./arion-compose.nix
     #(import "${home-manager}/nixos")
    ];

  # Set up kiosk user
  users.users = {
    "${kioskUsername}" = {
      group = kioskUsername;
      isNormalUser = true;
      packages = [ browser ];
    };
  };
  users.groups."${kioskUsername}" = {};




  services.cage = {
      enable = true;
      user = "kiosk";
      program = ''${pkgs.chromium}/bin/chromium --kiosk \
    --window-position=0,0 \
    --disable-translate --disable-sync --noerrdialogs --no-message-box \
    --no-first-run --start-fullscreen --disable-hang-monitor --incognito \
    --disable-infobars --disable-logging --disable-sync --disable-features=OverscrollHistoryNavigation --disable-pinch \
    --disable-settings-window \
    --disk-cache-dir=/dev/null \
    --disk-cache-size=1 \
    https://example.com &
   '';
  };

  # Do not use GRUB
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  # Enable Plymouth and hide kernel messages / cursor
  boot.plymouth.enable = true;
  boot.kernelParams = [ "rd.udev.log_priority=3" "vt.global_cursor_default=0" "silent=1" ];

  networking.hostName = "nixos"; # Hostname 
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  time.timeZone = "Pacific/Auckland"; # Time Zone

  # List packages installed in system profile. To search, run:
  # $ nix search wget
   environment.systemPackages = with pkgs; [
     git
     vim
     tree
     wget
     dos2unix
     chromium
  ]; 
  hardware.enableRedistributableFirmware = true;
  system.stateVersion = "24.05"; # DON'T TOUCH THIS!!!
}
