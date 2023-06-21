{ config, lib, pkgs, ... }:

let
  inherit (pkgs) libva;
  inherit (pkgs.lib.makeOverridableArgs) override;

  vaapiNvidia = pkgs.nvidia_x11.override {
    vaapiSupport = true;
    vdpauSupport = true;
  };
in
{
  config = {
    hardware.opengl = {
      enable = true;
      extraPackages = with pkgs; [
        vaapiNvidia
        libvdpau
        libvdpau-va-gl
      ];
    };
  };
}
