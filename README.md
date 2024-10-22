## Getting Started

1. Clone the repository to your home directory

```bash
git clone https://github.com/sakuexe/nixos ~/nixos
```

2. Remove the `/etc/nixos` -directory

```bash
# backup the original just in case
sudo cp -r /etc/nixos ~/nixos-backup
# remove
sudo rm -rf /etc/nixos
```

3. Create a symbolic link to `/etc/nixos`

```bash
sudo ln -s ~/nixos /etc/nixos
```

4. Rebuild the `hardware-configuration`-file

```bash
nixos-generate-configuration
```

5. Rebuild the system

```bash
sudo nixos-rebuild switch
```
