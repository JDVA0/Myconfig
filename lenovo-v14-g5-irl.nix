# /etc/nixos/hardware/lenovo-v14-g5-irl.nix
# Optimizaciones específicas para Lenovo V14 G5 IRL
# CPU: Intel Core 3 100U (Raptor Lake-U Refresh, 2P+4E, UHD Graphics Gen12 Xe-LP 64EU)
{ config, pkgs, ... }:

{
  # --- Kernel ---
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --- Microcódigo y firmware ---
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  # --- Gestión térmica (Intel) ---
  services.thermald.enable = true;

  # --- GPU: Intel UHD Graphics (driver iHD) ---
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  # --- Energía / batería ---
  services.power-profiles-daemon.enable = false; # conflicto con TLP; Plasma lo activa solo
  powerManagement.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      # Lenovo no-ThinkPad (driver ideapad_laptop): modo conservación binario.
      STOP_CHARGE_THRESH_BAT0 = 1;
    };
  };

  # --- SSD NVMe ---
  services.fstrim.enable = true;

  # --- WiFi: dominio regulatorio (ves redes 5GHz/DFS, ej. mesh de fibra) ---
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom=CO
  '';
  hardware.wirelessRegulatoryDatabase = true;
}
