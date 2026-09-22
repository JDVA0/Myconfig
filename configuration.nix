# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./hardware/lenovo-v14-g5-irl.nix
  ];

  # --- Boot ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;

  nixpkgs.config.allowUnfree = true; # requerido por microcódigo Intel y Brave

  # --- Red ---
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # --- Localización ---
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "es_CO.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "es_CO.UTF-8/UTF-8" ];
  console.keyMap = "la-latin1";

  # --- Usuario ---
  users.users.julian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" ];
    initialPassword = "";
  };

  # --- Audio ---
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # --- KDE Plasma 6 + SDDM ---
  services.xserver.enable = true;
  services.xserver.xkb.layout = "latam";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    khelpcenter
    konversation
    krdp
    plasma-browser-integration
  ];

  # --- Brave: forzar Wayland nativo cuando la sesión de Plasma es Wayland ---
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    NIXOS_OZONE_WL = "1";
  };

  # --- Paquetes ---
  environment.systemPackages = with pkgs; [
    brave
    fastfetch
    kitty
    micro
  ];

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # --- Mantenimiento del store ---
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
}
