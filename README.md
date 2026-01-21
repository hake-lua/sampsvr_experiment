# SA-MP Linux Installer && UDP Query Basics Monitorning

## OS Support

- Ubuntu 20.04 / 22.04 / 24.04  
- Debian 10+


## Instalacija

Kopiraj ovo i samo paste na vps u terminal i stisni enter:
```bash
wget -qO- https://raw.githubusercontent.com/hake-lua/default_sampsvr/refs/heads/main/install_sampserver.sh | sed 's/\r$//' | sudo bash
chmod +x install.sh
sudo ./install.sh
````

## Management
Ukoliko si nesto dirao u folderu od servera, mijenjao hostanme,mod ili bilo sta i sada zelis restartovati server:

```bash
# Start server
systemctl start samp

# Stop server
systemctl stop samp

# Restart server
systemctl restart samp
```

## Network Monitor (UDP Traffic (npr query)

Ukoliko zelite vidjeti ko salje zahtjeve na vas server preko clienta ili bilo kakav udp paket:

```bash
tcpdump -n udp and port 7777
```

