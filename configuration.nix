# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # ---------------------------------------------------------------------
  # Boot
  # ---------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 2;
  boot.kernelPackages = pkgs.linuxPackages_latest; # mejor soporte Raptor Lake-U (100U)

  # SSD: TRIM periódico en vez de discard continuo (más sano para la vida del NVMe)
  services.fstrim.enable = true;

  # ---------------------------------------------------------------------
  # CPU / firmware / energía — específico para el 100U del V14 G5
  # ---------------------------------------------------------------------
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;
  nixpkgs.config.allowUnfree = true;

  services.thermald.enable = true; # gestión térmica Intel

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      START_CHARGE_THRESH_BAT0 = 40; # cuida la salud de batería
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
  # tlp y power-profiles-daemon chocan entre sí; PPD viene por defecto en Plasma, lo apagamos
  services.power-profiles-daemon.enable = false;

  powerManagement.enable = true;

  # ---------------------------------------------------------------------
  # GPU Intel (100U = Xe-LP, driver iHD)
  # ---------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # VA-API (iHD)
      vpl-gpu-rt          # QuickSync (oneVPL)
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  # ---------------------------------------------------------------------
  # Red
  # ---------------------------------------------------------------------
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # ---------------------------------------------------------------------
  # Localización
  # ---------------------------------------------------------------------
  time.timeZone = "America/Bogota";
  i18n.defaultLocale = "es_CO.UTF-8";
  i18n.supportedLocales = [ "en_US.UTF-8/UTF-8" "es_CO.UTF-8/UTF-8" ];
  console.keyMap = "la-latin1";

  # ---------------------------------------------------------------------
  # Usuario
  # ---------------------------------------------------------------------
  users.users.julian = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "networkmanager" ];
    initialPassword = "";
  };

  # ---------------------------------------------------------------------
  # Audio
  # ---------------------------------------------------------------------
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  # ---------------------------------------------------------------------
  # KDE Plasma 6 + SDDM
  # ---------------------------------------------------------------------
  services.xserver.enable = true;
  services.xserver.xkb.layout = "latam";
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Evita instalar todo el paquete de apps de KDE (Kmail, etc.) — solo lo esencial del DE
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    kate
    khelpcenter
    konversation
    krdp
    plasma-browser-integration
  ];

  # ---------------------------------------------------------------------
  # Paquetes — solo lo pedido
  # ---------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    librewolf
    fastfetch
    kitty
    micro
  ];

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  # ---------------------------------------------------------------------
  # Mantenimiento del store (evita que /nix crezca sin control)
  # ---------------------------------------------------------------------
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  nix.settings.auto-optimise-store = true;

  system.stateVersion = "26.05";
}
