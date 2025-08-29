
# EIOSY2A NFS LAB

## Scenario
### Configuring a Client-Server Architecture using NFS.

## Overview
You will set up a collaborative development environment for **ProjectA** using **OpenEuler** on the server and **openSUSE 15.6** on the client machines.  
The goal is to configure an NFS server to host project files that will be accessible from the client machine.  

The shared directory `/var/ProjectA` will be mounted on the client side under each developer's home directory, with symbolic links created for easier access.  
Additionally, Git will be installed to manage version control for the project.

### Scenario Details
- **Project:** ProjectA  
- **Server OS:** OpenEuler  
- **Client OS:** openSUSE 15.6  
- **Shared Directory:** `/var/ProjectA`  
- **Users:** Dev1 and Dev2  
- **Network Configuration:** Static IPs for reliable connectivity  
- **Tasks:** Set up NFS server, configure shared directory, set permissions, configure NFS client  

### Goal
By the end of this lab, the shared directory `/var/ProjectA` should be accessible from the client machine.  
Developers will be able to access the shared directory through a symbolic link in their home directory, allowing them to collaborate efficiently.  
All services should be properly configured and running, and the network correctly set up.  

---

## PART 1: CONFIGURING THE NETWORK ON BOTH VMs

### 1. Configure Network Interfaces
- **Why:** To allow both VMs to communicate directly over the same network.  
- **How:** In VirtualBox, set both VMs to use a **Host-Only Adapter**.  

### 2. Identify Network Interfaces
Run the following to list interfaces:  
```bash
ip a
```

### 3. Configure Static IP Addresses
Assign static IPs to each VM:  
```bash
# On the server
sudo ip addr add 192.168.1.1/24 dev ens0p8

# On the client
sudo ip addr add 192.168.1.2/24 dev ens0p8
```

Restart the network daemon:  
```bash
sudo systemctl restart network
```

### 4. Verify Connectivity
Check IP address:  
```bash
ip a
```
Ping between machines:  
```bash
ping 192.168.1.1   # from client
ping 192.168.1.2   # from server
```

### 5. Troubleshooting Network
- Check firewall:  
```bash
sudo firewall-cmd --permanent --add-port=111/tcp
sudo firewall-cmd --permanent --add-port=111/udp
sudo firewall-cmd --permanent --add-port=2049/tcp
sudo firewall-cmd --permanent --add-port=2049/udp
sudo firewall-cmd --reload
```
- Ensure both VMs are on the same VirtualBox network.  

---

## PART 2: CONFIGURING THE NFS SERVER & CLIENT

### 1. Install NFS Packages
Update and install NFS utilities on **both VMs**:  
```bash
sudo dnf update -y
sudo dnf install -y nfs-utils
```

### 2. Enable and Start Services
```bash
sudo systemctl enable --now nfs-server
sudo systemctl enable --now rpcbind
```

### 3. Configure NFS Export (Server Only)
Create the directory:  
```bash
sudo mkdir /var/ProjectA
```
Add to `/etc/exports`:  
```bash
echo "/var/ProjectA  192.168.1.0/24(rw,sync,no_root_squash)" | sudo tee -a /etc/exports
sudo exportfs -arv
```

### 4. Create Users and Permissions
Create group and users:  
```bash
sudo groupadd DevOps
sudo useradd -m -s /bin/bash -G DevOps Dev1
sudo useradd -m -s /bin/bash -G DevOps Dev2

sudo passwd Dev1   # Dev@DevOPS1
sudo passwd Dev2   # Dev@DevOPS2
```

Change ownership and set permissions:  
```bash
sudo chown root:DevOps /var/ProjectA
sudo chmod 3770 /var/ProjectA
ls -ld /var/ProjectA
```

### 5. Mount NFS Share on Clients
Login as Dev1 or Dev2 and run:  
```bash
mkdir ~/smart_home_system
mount -t nfs 192.168.1.1:/var/ProjectA ~/smart_home_system
```

---

## PART 3: MONITORING & TROUBLESHOOTING NFS WITH LOG FILES

### Why
Logs help administrators diagnose issues such as failed mounts, permission errors, or service failures.  

### Key Log Files
- **General system logs:**  
  - `/var/log/messages`  
  - `/var/log/syslog`  

- **Service-specific logs:**  
  ```bash
  journalctl -u nfs-server
  journalctl -u rpcbind
  journalctl -u nfs-client.target
  ```

- **Real-time monitoring:**  
  ```bash
  tail -f /var/log/messages
  ```

### Useful Commands
```bash
# Check server logs
sudo journalctl -xeu nfs-server
sudo journalctl -xeu rpcbind

# Check client logs
sudo journalctl -xeu nfs-client.target
dmesg | grep nfs

# Monitor live logs
tail -f /var/log/messages
```

### Common Issues
- **Permission denied** → Check directory ownership and user groups.  
- **Stale file handle** → Unmount and remount the share.  
- **RPC errors** → Ensure rpcbind is running and firewall allows ports 111 & 2049.  
- **Mount fails** → Check if NFS service is running and verify network connectivity.  

### Student Exercise
1. Stop the NFS service on the server:  
   ```bash
   sudo systemctl stop nfs-server
   ```
2. Try accessing the share from the client — observe the error.  
3. Use `journalctl` or `tail -f /var/log/messages` to find the error.  
4. Restart the service and confirm logs show it starting again.  

---
