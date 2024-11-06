{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    (unityhub.override { extraLibs = { ... }: [ harfbuzz ]; })
    dotnetCorePackages.dotnet_8.sdk
    dotnetCorePackages.dotnet_8.runtime
    csharp-ls
  ];
}
