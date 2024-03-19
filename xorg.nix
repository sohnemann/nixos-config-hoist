{ pkgs, ... }:

let
  kioskUsername = "kiosk";
  browser = pkgs.chromium;
  autostart = ''
    #!${pkgs.bash}/bin/bash
    # End all lines with '&' to not halt startup script execution

    chromium --kiosk \
    --window-position=0,0 \
    --disable-translate --disable-sync --noerrdialogs --no-message-box \
    --no-first-run --start-fullscreen --disable-hang-monitor \
    --disable-infobars --disable-logging --disable-sync --disable-features=OverscrollHistoryNavigation --disable-pinch \
    --disable-settings-window \
    --disk-cache-dir=/dev/null \
    --disk-cache-size=1 \
    file:////home/kiosk/index.html &  
  '';

  inherit (pkgs) writeScript;
in {
  # Set up kiosk user
  users.users = {
    "${kioskUsername}" = {
      group = kioskUsername;
      isNormalUser = true;
      packages = [ browser ];
    };
  };
  users.groups."${kioskUsername}" = {};
  services.unclutter.enable = true;
  # Configure X11
  services.xserver = {
    enable = true;
    layout = "us"; # keyboard layout
    libinput.enable = true;
    

    # Let lightdm handle autologin
    displayManager.lightdm = {
      enable = true;
      extraConfig = "
        [SeatDefaults]
        xserver-command=X -nocursor
      ";
      autoLogin = {
        enable = true;
        timeout = 0;
        user = kioskUsername;
      };
    };

    # Start openbox after autologin
    windowManager.openbox.enable = true;
    displayManager.defaultSession = "none+openbox";
  };

  # Overlay to set custom autostart script for openbox
  nixpkgs.overlays = with pkgs; [
    (self: super: {
      openbox = super.openbox.overrideAttrs (oldAttrs: rec {
        postFixup = ''
          ln -sf /etc/openbox/autostart $out/etc/xdg/openbox/autostart
        '';
      });
    })
  ];

  # By defining the script source outside of the overlay, we don't have to
  # rebuild the package every time we change the startup script.
  environment.etc."openbox/autostart".source = writeScript "autostart" autostart;
}
