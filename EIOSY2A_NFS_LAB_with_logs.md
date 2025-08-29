Page | 1  EIOSY2A LAB  3 
 
 EIOSY2A NFS LAB  
Scenario: Confi guring a Client -Server Architecture using NFS  
Overview:  
You'll set up a collaborative development environment for Project A using OpenEu ler on both the server 
and client machines. The goal is to configure an NFS server to host project files that will be accessible from 
the client machine. The shared directory /var/Project A will be mounted on the client side under each 
developer's home directory, with symbolic links created for easier access. Additionally, you'll install Git to 
manage version control for the project.  
Scenario Details:  
• Project: ProjectA  
• Server OS: OpenEuler  
• Client OS: openSUSE  15.6  
• Shared Directory:  /var/Project A 
• Users: Two users (Dev1  and Dev2) 
• Network Configuration: Static IPs to ensure reliable connectivity  
• Tasks: Set up NFS server, configure shared directory, set permissions, configure NFS client.  
 
Goal:  
By the end of this lab, the shared directory /var/ProjectA  should be accessible from the client machine . 
Developers will be able to access the shared directory through a symbolic link in their home directory, 
allowing them to collaborate on the project efficiently. All services should be properly configured and 
running, and the network should be correctly set  up to facilitate communication between the two systems.  
Steps:  
1. Network Configuration:  
o Before starting the VMs, make sure that you have enabled a second n etwork card on the 
VMs. The first network card will connect the VM  to the internet, so leave it on NAT. The 
second network card will  be used for inter -VM connection, set it to host only . 
o Configure static IP addresses on both the Ubuntu server and openSUSE client to ensure 
reliable communication.  
o Verify the network connection by pinging between the two machines.  

Page | 2  EIOSY2A LAB  3 
 
 2. Server Setup ( OpenEul er): 
o Update repositories and install the NFS server package.  
o Combine the two 100GB drives into a single volume and mount it as / var/ProjectA . (Check 
to see if the volume is not already created . If it is, just skip this step and just use it .) 
o Create and configure the shared directory for ProjectA . 
o Set appropriate permissions so that the two developers can read, write, and execute files 
within the shared directory.  
o Ensure the NFS server service is enabled and running.  
3. Client Setup ( OpenEuler /openSUSE):  
o Update repositories and install the necessary NFS client tools.  
o Configure the client to mount the shared directory from the NFS server under each 
developer's home directory.  
o Ensure the NFS client service is enabled and running.  
o Create symbolic links in each developer's home directory for quick access to the shared 
ProjectA  directory.  
4. Verification:  
o Verify that the shared directory is mounted correctly on the client machine.  
o Test file creation and modification within the shared directory from both users to ensure 
permissions are correctly set.  
 
 
 
 
 
 
 
 

Page | 3  EIOSY2A LAB  3 
 
  
 
PART 1: CONFIGURING THE NETWORK ON BOTH VMS  
1. Configure Network Interfaces:  
▪ Why:  The network interfaces need to be properly configured so that both VMs can 
communicate over the same network. VirtualBox allows you to choose between different 
network adapter types (e.g., NAT, Host -Only, Bridged). For this lab, you'll use a network 
confi guration that ensures both VMs can communicate directly with each other.  
▪ How:  In VirtualBox, set both VMs to use the same network adapter type, such as Host -
Only Adapter. This will place both VMs on the same virtual network.  
2. Network Configuration:  
Step 1: Identify Network Interfaces  
▪ Why : Before configuring static IP addresses, you need to know the names of the network 
interfaces on both the server and client machines.  
▪ How : 
o Run the following command on both machines to list all network interfaces:  
ip a 
o Look for the interface that is connected to the network (e.g., eth0  or enp0s3, etc.  
The easiest way is to make sure the interface MAC correspond ). This is the 
interface you will configure.  
 
Step 2: Configure Static IP Address on the Server  & Client  
▪ Why : Assigning a static IP address ensures that the server's address doesn't change, 
making it easier for the client to connect.  
▪ How:   
o Run the following command on both machines to assign  the IP address : 
ip addr  add 192.168.1.1/24 dev ens0p8  (server) 
ip addr add 192.168.1.2/2 4 dev ens0p8 ( client ) 
(Note that the nam e of the interface may look d ifferent)  
o Run the following command on both machines to restart the network da emon:  
sudo systemctl restart network  

Page | 4  EIOSY2A LAB  3 
 
 Step 4: Verify Network Configuration  
 
▪ Why: It's essential to ensure that both machines can communicate with each other after 
configuring static IP addresses.  
▪ How:  
1. Check IP Address on Both Machines:  
o Run the following command on both machines to confirm the IP address has 
been set correctly:  
ip a 
2. Ping the Server from the Client:  
o From the client machine, run:  
ping 192.168.1. 1   
 
3. Ping the Client from the Server:  
o From the server machine, run:  
ping 192.168.1. 2   
 
Step 5: Troubleshooting  
▪ Why : If the pings fail, you may need to troubleshoot the network configuration.  
▪ How : 
1. Check Firewall Settings:  
o Ensure that the firewall on both machines allows ICMP traffic (used by ping) 
and NFS traffic (ports 2049 and 111). You can disable the firewall temporarily 
to test:  
sudo systemctl stop firewalld  
▪  Explanation : This temporarily stops the firewall to see if it's blocking 
communication.  
o The best approach is to add these ports to the al low rule of the firewall: 
▪ # Allow rpcbind (port 111)  
sudo firewall -cmd --permanent --add-port=111/tcp  
sudo firewall -cmd --permanent --add-port=111/udp  
# Allow NFS (port 2049)  
sudo firewall -cmd --permanent --add-port=2049/tcp  
sudo firewall -cmd --permanent --add-port=2049/udp  
 

Page | 5  EIOSY2A LAB  3 
 
 # Reload firewall to apply changes  
sudo firewall -cmd –reload  
 
2. Check Network Cables and VirtualBox Network Settings:  
o If using VirtualBox, ensure that both VMs are connected to the same 
network (e.g., set to Bridged Adapter or Host -Only Adapter).  
 
 
PART 2: CONFIGURING THE NFS SERVER (Server  & Client VM) 
1. Repositories  & Installing NFS : 
▪ Why : Before installing any packages, it’s essential to ensure that your system has the 
latest package lists. This makes sure that you’re installing the most up -to-date versions 
of software.  To get functionality of NFS, you will need to install the package that pro vide 
both server and client services for NFS. The com mands bel ow should be executed  on 
both VMs.  
▪ How : 
sudo dnf update  -y 
sudo dnf install nfs -utils 
 
▪ Explanation: This updates the package repositories and installs the NFS server 
package, enabling your OpenEuler  machine to share directories with clients.  
2. Check and Enable the Service:  
▪ Why:  After installing the NFS server, ensure it is running. If it’s not running, it won’t be 
able to serve files to clients.  
▪ How:  
sudo systemctl enable --now nfs -server  
sudo systemctl enable --now rpcbind  
▪ Explanation : This checks the status of the service s. If it’s inactive, they will be 
enable d and start ed. 
 
 
 
 

Page | 6  EIOSY2A LAB  3 
 
 3. Configure the NFS Export:  
▪ Why : You need to tell the NFS server which directory to share and who can access it.  
This must be done on the VM acti ng as the NFS server only.  
▪ How:  
sudo mkdir / var/ProjectA  
echo "/ var/ProjectA   *(rw,sync,no_root_squash)" | sudo tee -a /etc/exports  
 
#you could al so open the /e tc/exports file in nano or vi and edit it  there.  
sudo exportfs -arv 
▪ Explanation : The shared directory / var/ProjectA  is made available to all clients 
with read, write, and execute permissions.  
4. Create Users , Group  and Set Permissions:  
o Why:  Specific users need to have read, write, and execute permissions on the shared 
directory.  We give these permissions to users by creating a security group and add users 
to it.  
o How:  
Sudo groupadd DevOps  
sudo user add  -m -s /bin/bash -G DevOps  Dev1 
sudo user add  -m -s /bin/bash -G DevOps  _x Dev2 
sudo passwd  Dev1 
▪  Create a new password for user1  (use: Dev @DevOPS1 ) 
sudo passwd Dev2 
▪  Create a new password for user2  (use: Dev @DevOPS 2) 
o You can test the login details  of the two users by doing the following:  
su - Dev1 
▪ Then enter the password for Dev1  to login  
▪ Type exit to re turn  
o You can verify the groups each user belongs to by typing the following command:  
id Dev1 
o At the moment, the  /var/ProjectA  you created belongs to root and also  the group. We 
need to change the  owner ship so that it can belong to the DevOps group  instead . 

Page | 7  EIOSY2A LAB  3 
 
 ls -ld /var/ProjectA  
sudo chown root :DevOps   /var/ProjectA  
sudo chmod 3770 / var/ProjectA  
ls -ld /var/ProjectA  
▪ We first run the ls comman d to check the permissions and ownership  of  
ProjectA  directo ry. 
▪ chown: Changes the group ownership of the directory to  DevOps  
▪ chmod  3770: Grants full permissions (read, write, execute) to the owner and 
group, but none to others.  
▪ The 3 in fro nt is for spec ial per mission, 2000 for SetGID, and 1000 s ticky  bit.  
▪ After the changes, we run the same command to ver ify 
 
5. Mounting NFS share on clients  
▪ Why:  Once you are done with all the configuration s above, it is now time to give access 
to the network share to the users. This is don e by mounting the NFS share on each 
client.  
o How:  
After you have logged in as D ev1 or Dev 2, run the following command s’: 
  mkdir smar t_home_s ystem  
mount -t nfs 192. 168.1.1:/var /ProjectA  /home/Dev1/smart_home_s ystem  
 
 
 
 
 
 
 
 
 
 

Page | 8  EIOSY2A LAB  3 
 
  




## PART 3: MONITORING & TROUBLESHOOTING NFS WITH LOG FILES

### Why  
Logs help administrators diagnose issues such as failed mounts, permission errors, or service failures. By understanding where to look and how to filter logs, you can quickly identify and fix problems.  

### Key Log Files  
- **General system log (OpenEuler/openSUSE):**  
  ```
  /var/log/messages
  /var/log/syslog
  ```
  Contains kernel and system service messages, including NFS and RPC events.  

- **Journalctl (systemd-based systems):**  
  ```
  journalctl -u nfs-server
  journalctl -u rpcbind
  journalctl -u nfs-client.target
  ```
  View logs specific to NFS and RPC services.  

- **Mount logs:**  
  Errors during mounting appear in system logs.  
  ```
  tail -f /var/log/messages
  ```
  while attempting a mount will show real-time errors.  

### Useful Commands  
1. **Check NFS service logs:**  
   ```bash
   sudo journalctl -xeu nfs-server
   sudo journalctl -xeu rpcbind
   ```
2. **Check client-side logs:**  
   ```bash
   sudo journalctl -xeu nfs-client.target
   dmesg | grep nfs
   ```
3. **Real-time monitoring:**  
   ```bash
   tail -f /var/log/messages
   ```
   (Run this while starting NFS or attempting mounts to catch issues live.)  

### Common Issues & How to Spot Them  
- **Permission denied** → Check ownership and mode of `/var/ProjectA`, confirm users belong to correct group.  
- **Stale file handle** → Likely after server restart or directory changes. Unmount and remount the share.  
- **RPC errors** → Ensure `rpcbind` is running and firewall allows ports `111` and `2049`. Logs will show “RPC: Port mapper failure” or similar.  
- **Mount fails** → Logs may show “No route to host” (check network/firewall) or “Connection refused” (NFS service not running).  

### Task for Students  
1. Try stopping the NFS service on the server:  
   ```bash
   sudo systemctl stop nfs-server
   ```  
   Then attempt to access the mounted share from the client. Observe the error.  
2. Use `journalctl` or `tail -f /var/log/messages` to find the corresponding error log.  
3. Restart the service and confirm the logs show it coming back online.  
