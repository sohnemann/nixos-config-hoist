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



  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "without-password";
    startWhenNeeded = true;
  };

environment.etc."avahi/services/ssh.service" = {
    text = ''
      <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
      <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
      <service-group>
        <name replace-wildcards="yes">%h</name>
        <service>
          <type>_ssh._tcp</type>
          <port>22</port>
        </service>
      </service-group>
    '';
  };



  #Enable debug mode
  #services.cage = {
  #    enable = true;
  #    user = "kiosk";
  #    extraArguments = [ 
  #      "-d" 
  #    ];
  #    environment = {
  #      XKB_DEFAULT_MODEL = "dell101";
  #      XKB_DEFAULT_LAYOUT = "us";
  #    };

  #    program = ''${pkgs.chromium}/bin/chromium --kiosk \
  #      --window-position=0,0 \
  #      --disable-translate --disable-sync --noerrdialogs --no-message-box \
  #      --no-first-run --start-fullscreen --disable-hang-monitor --incognito \
  #      --disable-infobars --disable-logging --disable-sync --disable-features=OverscrollHistoryNavigation --disable-pinch \
  #      --disable-settings-window \
  #      --disk-cache-dir=/dev/null \
  #      --disk-cache-size=1 \
  #      https://example.com &
  #    '';
  #};

  # Do not use GRUB
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.plymouth.enable = true;
  boot.kernelParams = [ "rd.udev.log_priority=3" "vt.global_cursor_default=0" "silent=1" ];
  #boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  #boot.initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];

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
