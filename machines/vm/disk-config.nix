{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              start = "1M";
              end = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

	    swap = {
	      name = "swap";
	      start = "513M";
	      end = "8G";
	      content = {
	      	type = "swap";
	      };
	    };

            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                # Subvolumes must set a mountpoint in order to be mounted,
                # unless their parent is mounted
                subvolumes = {
                  "@" = { };
                  # Subvolume name is different from mountpoint
                  "@/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" ];
                  };
                  # Subvolume name is the same as the mountpoint
                  "@/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "@/home/sakuk/Games" = {
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  # Parent is not mounted so the mountpoint must be set
                  "@/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@/var/lib" = {
                    mountpoint = "/var/lib";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };

                mountpoint = "/partition-root";
                swap = {
                  swapfile = {
                    size = "20M";
                  };
                  swapfile1 = {
                    size = "20M";
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
