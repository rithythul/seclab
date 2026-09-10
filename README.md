# Security Learning Lab

A self-contained offensive + defensive security lab on this machine.
One attacker VM (BlackArch) and several deliberately vulnerable victims, wired so that attacks stay inside the lab.

## Golden rule

Only ever attack the machines in this lab.
Scanning or exploiting anything you do not own is illegal in most places, tailnet hosts included.
Everything here is legal to break because you own it and it cannot reach anyone else.

## Topology

```
                 internet (updates only)
                        |
            [ default NAT net 192.168.122.0/24 ]
                        |
        +---------------+-------------------+
        |                                   |
  BlackArch attacker                 host docker engine
  (dual-homed)                       web victims bound to 192.168.122.1:
        |                              - DVWA        :8081
        |                              - Juice Shop  :3000
        |                              - WebGoat     :8080  WebWolf :9090
        |
  [ seclab ISOLATED net 172.31.66.0/24 ]   <-- no internet, no LAN, no tailnet
        |
  Metasploitable2  (172.31.66.10)
```

The attacker has two network cards.
One reaches the internet through the `default` NAT network, only so BlackArch can update itself and pull tools.
The other sits on `seclab`, an isolated libvirt network with no forwarding, so the Metasploitable victim can never reach the internet, your LAN, or your tailnet.
The web victims run as docker containers published only on `192.168.122.1`, the libvirt gateway, so they are reachable from the host and the attacker VM but never from `wlan0` or `tailscale0`.

## First-time setup

Downloads and image pulls were started for you.
Check progress any time:

```
scripts/lab-status.sh
```

Once the BlackArch ISO and the Metasploitable zip have finished, build the VMs:

```
scripts/create-metasploitable-vm.sh     # imports the victim on the isolated net
scripts/create-attacker-vm.sh           # boots the BlackArch live desktop
```

Open a VM's screen with:

```
virt-viewer --connect qemu:///system blackarch-attacker
virt-viewer --connect qemu:///system metasploitable2
```

`virt-manager` gives you the same thing with a GUI list of all VMs.

## Daily use

```
scripts/lab-victims-up.sh      # start the web victims
scripts/lab-status.sh          # see what is running
virsh -c qemu:///system start blackarch-attacker
virsh -c qemu:///system start metasploitable2
# ... learn ...
virsh -c qemu:///system shutdown blackarch-attacker
virsh -c qemu:///system shutdown metasploitable2
scripts/lab-victims-down.sh    # stop the web victims
```

## Credentials

- Metasploitable2: `msfadmin` / `msfadmin` (also the sudo password).
- DVWA: `admin` / `password`, then click "Create / Reset Database".
- Juice Shop and WebGoat: register a throwaway account inside the app.
- BlackArch live ISO: try `root` / `blackarch`; install to disk with `blackarch-install` when ready.

## Installing BlackArch tools

The slim ISO ships a desktop and the core.
Inside the attacker VM, update first, then pull tool groups as you need them:

```
sudo pacman -Syu
sudo pacman -S metasploit nmap wireshark-qt burpsuite sqlmap gobuster hydra
# whole categories are also available, e.g.:
sudo pacman -S blackarch-scanner blackarch-webapp blackarch-exploitation
```

## Layout

```
seclab/
  iso/        BlackArch ISO
  vms/        VM disks and the Metasploitable download
  victims/    docker-compose for the vulnerable web apps
  scripts/    lab management scripts
  loot/       your scan output, notes, screenshots
  shared/     drop files here to move them in/out of VMs
  docs/       CURRICULUM.md and your own notes
```

## Tearing it all down

```
scripts/lab-victims-down.sh
virsh -c qemu:///system destroy blackarch-attacker; virsh -c qemu:///system undefine blackarch-attacker
virsh -c qemu:///system destroy metasploitable2;   virsh -c qemu:///system undefine metasploitable2
virsh -c qemu:///system net-destroy seclab; virsh -c qemu:///system net-undefine seclab
# then delete the seclab/ folder
```
