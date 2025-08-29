# NGINX Configurations

# Installing and Testing NGINX
## Overview
In the previous lab, you setup an NFS server and allowed users to access content of a project. That project involves designing a web-based Python/PHP application. Before hosting the application, we need to make sure required service in LAMP are all installed and configured.
In this lab, our objective is to install and configure NGINX as the prefered web sever for this project. We will need to ensure the path for this web application is seating in ### 192.168.1.1:/var/PrjectA/www. 
This means we will be building on the NFS server lab you completed.

# PART1: PREPARING RESOURCES
Your setup should consist of the following:

•	Server OS: OpenEuler (Configured with NFS)
•	Client OS: openSUSE 15.6
•	Shared Directory: /var/ProjectA
•	Users: Two users (Dev1 and Dev2)



# PART 1: CONFIGURING THE NETWORK ON BOTH VMs

### 1. Identify Network Interfaces
Run the following to list interfaces:  
```bash
ip a
```

### 2. Configure Static IP Addresses
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

### 3. Verify Connectivity
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
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```
- Ensure both VMs are on the same VirtualBox network.  

---.

# PART 2: INSTALLATION  & CONFIGURATION

## 2.1 Installing NGINX 
#### Step 1 Install NGINX using the Yum repository.
In openEuler, run the following command to automatically install NGINX:
```bash
yum install -y nginx
```
After the installation is complete, run the following command to check the NGINX version:
```bash
nginx -v
```
Upon execution, you should see `nginx version: nginx/1.21.5`.
After confirming that NGINX is correctly installed, run the following commands to start NGINX and check whether the NGINX processes are started:
```bash
systemctl start nginx
ps -ef | grep nginx
```
The expected output indicates the presence of `nginx: master process` and `nginx: worker process`.


## 2.2 Performing Basic NGINX Configurations

### 2.2.1 Configuring Static Resource Access
**Description**: This section details how to use NGINX to access different types of resources, such as HTML files, image files, and TXT files.

#### Step 1 Modify global configurations.
The default global configurations in the main configuration file are as follows:
```nginx
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
```
Modify the configurations as follows:
1.  Change the user of the worker process to **nobody**.
2.  Change the number of worker processes to **4**.

The modified configurations are as follows:
```nginx
user nobody;
worker_processes 4;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;
```
Run the following commands to reload the NGINX configurations and check the processes:
```bash
nginx -s reload
ps -ef | grep nginx
```
The output shows worker processes running under the `nobody` user and a total of 4 worker processes.
This confirms that the user of the worker processes changes to **nobody**, and the user of the master process changes to **root**. Additionally, the number of worker processes changes to **4**.

#### Step 2 Access static web resources.
**Requirement**: Use the domain name **www.test.com** to access the specified home page of the NGINX service, along with a specified image file and TXT file.
Run the following command to create a directory for storing static resources:
```bash
mkdir -p /data/Nginx
```
(Output of `ls /` showing the `/data` directory).
Create a home page file **index.html** in the NGINX directory and enter "hello,openEuler" into it:
```bash
echo "hello,openEuler" > /data/Nginx/index.html
```
Create a **test.txt** file in the Nginx directory and enter "hello,Nginx":
```bash
echo "hello,Nginx" > /data/Nginx/test.txt
```
Copy **nginx-logo.png** from `/usr/share/nginx/html` to the Nginx directory:
```bash
cp /usr/share/nginx/html/nginx-logo.png /data/Nginx/
```
After the configuration is complete, the files in the Nginx directory are as follows: (Output of `ls /data/Nginx` showing `index.html`, `nginx-logo.png`, `test.txt`).

In the **/etc/nginx/conf.d** directory, create a configuration file named **static.conf** for the new static website and configure it with the following content:
```nginx
server {
    listen 81;
    server_name www.test.com;
    root /data/Nginx;
    index index.html;
}
```
Run the **nginx -t** command to check for configuration correctness. If the configuration is incorrect, rectify the fault before proceeding. If the configuration is correct, the following information is displayed: `nginx: the configuration file /etc/nginx/nginx.conf syntax is ok` and `nginx: configuration file /etc/nginx/nginx.conf test is successful`.
After confirmation, run the **nginx -s reload** command to reload the NGINX configurations.

Configure static domain name resolution on the host where the browser is located to map **www.test.com** to the server. Then access **www.test.com:81** using the browser. The following page is displayed: (Image showing "hello,openEuler" page).
Access **www.test.com:81/nginx-logo.png**. The following page is displayed: (Image showing the NGINX logo).
Access **www.test.com:81/test.txt**. The following page is displayed: (Image showing "hello,Nginx" text).

**Question 1**: If a **test.nn** file is created in the Nginx directory and certain content is entered, will the system return the corresponding content when the file is accessed through **www.test.com:81/test.nn**? Why?
**Answer**: No, it will not. The **.nn** file is not associated with a **mime.type**. Therefore, NGINX cannot parse the file. When the URL is accessed, the corresponding file is downloaded to the local host by default.

**Question 2**: To implement the same function of the preceding website, is there any other writing format for the configuration file?
**Answer**: Yes, there is. You can use the following content:
```nginx
server {
    listen 81;
    server_name www.test.com;
    location / {
        root /data/Nginx;
        index index.html;
    }
}
```

### 2.3 Configuring Virtual Hosts
**Description**: This section explains how to configure virtual hosts on the NGINX server using different port numbers.

#### Step 1 Prepare resources.
Create the **nginx1**, **nginx2**, and **nginx3** directories in the **/data** directory:
```bash
mkdir nginx{1..3}
```
(Output of `ls /data` showing `nginx1`, `nginx2`, `nginx3`).
Run the following commands to create **index.html** in each of the three directories and enter "hello,nginx1", "hello,nginx2", and "hello,nginx3" respectively:
```bash
echo "hello,nginx1" > nginx1/index.html
echo "hello,nginx2" > nginx2/index.html
echo "hello,nginx3" > nginx3/index.html
```
(Command execution and output confirming content of index.html in each directory).

#### Step 2 Configure virtual hosts.
To avoid configuration interference, delete the existing configuration file in **/etc/nginx/conf.d** or change its file name extension to **.bk**.
Create a configuration file **vhost.conf** and enter the following content:
```nginx
server {
    listen 81;
    server_name localhost;
    location / {
        root /data/nginx1;
        index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location / {
        root /data/nginx2;
        index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location / {
        root /data/nginx3;
        index index.html;
    }
}
```
After the configuration is complete, run the **nginx -t** command to check for syntax errors. If no syntax errors exist, run the **nginx -s reload** command to reload the configurations.

#### Step 3 Verify the configurations.
Run the **curl** command to verify the virtual hosts configured with different ports:
```bash
curl localhost:81
curl localhost:82
curl localhost:83
```
Expected output: `hello,nginx1`, `hello,nginx2`, `hello,nginx3` for the respective curl commands.

### 2.4 Configuring the Location Directive
**Description**: This lab builds upon the virtual host configuration to demonstrate using different representation methods for configuring routes.

#### Step 1 Prepare resources.
Rename the directory **/data/nginx1** to **/data/Nginx1**.

#### Step 2 Modify the configuration file.
Modify the **vhost.conf** configuration file as follows:
```nginx
server {
    listen 81;
    server_name localhost;
    location / {
        root /data/Nginx1;
        index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location / {
        root /data/nginx2;
        index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location / {
        root /data/nginx3;
        index index.html;
    }
}
```
Reload the NGINX configurations.

#### Step 3 Verify the configurations.
Run the **curl localhost:81**, **curl localhost:82**, and **curl localhost:83** commands. The following information is displayed:
-   `curl localhost:81`: returns a "404 Not Found" page, indicating `nginx/1.21.5`.
-   `curl localhost:82`: returns a "301 Moved Permanently" page, indicating `nginx/1.21.5`.
-   `curl localhost:83`: returns `hello,nginx3`.

**Question**: What conclusions can be drawn based on the preceding information?
**Answer**:
1.  **NGINX is case sensitive**. After `nginx1` is changed to `Nginx1`, the corresponding resource cannot be accessed.
2.  When the **location** directive specifies a path, the specified path will be matched in the URL when the resource is accessed.
3.  If the resource to be accessed is a directory, a slash (/) needs to be added to the end of the URL.

#### Step 4 Modify the configuration file.
Modify the **vhost.conf** file as follows:
```nginx
server {
    listen 81;
    server_name localhost;
    location ^~ /data/nginx1 {
        root /;
        index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location /nginx2/index.html {
        root /data;
        index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location = / {
        root /data/nginx3;
        index index.html;
    }
}
```
Reload the NGINX configurations.

#### Step 5 Verify the configurations.
**Question**: Based on the preceding configuration file, which URLs can be used to access the corresponding resources?
**Answer**:
-   **Virtual host 1** uses a case-insensitive regular expression to match all resources whose name extension is **.html**. The corresponding URL is **localhost:81**.
    (Command and output showing `curl localhost:81` returning `hello,nginx1`).
-   **Virtual host 2** uses an exact match to strictly match the required resource. The corresponding URL is **localhost:82/nginx2/index.html**.
    (Command and output showing `curl localhost:82/nginx2/index.html` returning `hello,nginx2`).
-   **Virtual host 3** also uses an exact match, but the URL must end with a slash (/). However, the actual path of the server is **/data/nginx3/index.html**. For this reason, the corresponding resource cannot be accessed, and the system returns the default home page.
    (Command and output showing `curl localhost:83` returning default NGINX page, and `curl localhost:83/` returning `hello,nginx3`).

#### Step 6 Modify the configuration file.
Modify the **vhost.conf** file as follows:
```nginx
server {
    listen 81;
    server_name localhost;
    location /nginx1 {
        root /data;
        index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location /nginx2 {
        alias /data/nginx2/index.html;
        # index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location = / {
        root /data/nginx3;
        index index.html;
    }
}
```

#### Step 7 Verify the configurations.
Run the **curl localhost:81/Nginx1** and **curl localhost:82/nginx2** commands. The following information is displayed:
-   `curl localhost:81/Nginx1`: returns `hello,nginx1`.
-   `curl localhost:82/nginx2`: returns `hello,nginx2`.

**Question**: What conclusions can be drawn from the preceding test?
**Answer**:
-   When **root** is used to specify a resource path in **location**, a relative path is used.
-   When an **alias** is used, an absolute path is used.

## 2.4 Configuring Reverse Proxies and Load Balancing with NGINX

### 2.4.1 Configuring Reverse Proxies with NGINX
**Description**: This section describes how to configure and use the reverse proxy function of NGINX based on the "Configuring the Location Directive" section. It notes that this architecture differs significantly from actual application scenarios and advises against its use in practice.

#### Step 1 Set virtual host 1 as the proxy of virtual host 3.
Modify the **vhost.conf** file as follows:
```nginx
server {
    listen 81;
    server_name localhost;
    location /nginx1 {
        proxy_pass http://127.0.0.1:83;
        root /data;
        index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location /nginx2.1 {
        alias /data/nginx2/index.html;
        # index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location / {
        root /data/nginx3;
        index index.html;
    }
}
```
Reload the NGINX configurations.

#### Step 2 Verify the configurations.
Run the **curl localhost:81** command to access the corresponding resource and check the returned information:
(Output showing `curl localhost:81` returning `hello,nginx3`).

#### Step 3 Set virtual host 1 as the proxy of virtual host 2.
Modify the **vhost.conf** file as follows:
```nginx
server {
    listen 81;
    server_name localhost;
    location /nginx1 {
        proxy_pass http://127.0.0.1:82/nginx2;
        # root /data;
        # index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location / {
        root /data/nginx2;
        index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location / {
        root /data/nginx3;
        index index.html;
    }
}
```
After the configuration is complete, reload the NGINX configurations.

#### Step 4 Verify the configurations.
Run the **curl localhost:81/nginx1** command to access the corresponding resource and check the returned information:
(Output showing `curl localhost:81/nginx1` returning `hello,nginx2`).

### 2.4.2 Configuring Load Balancing with NGINX
**Description**: This lab describes how to configure and use NGINX virtual hosts for load balancing. It also states that this setup is significantly different from actual application scenarios and advises against using this architecture in practice.

#### Step 1 Prepare resources.
Restore the **vhost.conf** file to the content from step 2 in the "Configuring Virtual Hosts" section.
The details of the restoration are as follows:
```nginx
server {
    listen 81;
    server_name localhost;
    location / {
        root /data/nginx1;
        index index.html;
    }
}

server {
    listen 82;
    server_name localhost;
    location / {
        root /data/nginx2;
        index index.html;
    }
}

server {
    listen 83;
    server_name localhost;
    location / {
        root /data/nginx3;
        index index.html;
    }
}
```
Restore the directory name **Nginx1** to **nginx1**. After restoration, the **/data** directory contains: (Output of `ls /data` showing `nginx1`, `nginx2`, `nginx3`).
Reload the NGINX configurations and check whether the services corresponding to the virtual hosts can be accessed:
(Output showing `curl 192.168.1.12:81` returning `hello,nginx1`, `curl 192.168.1.12:82` returning `hello,nginx2`, `curl 192.168.1.12:83` returning `hello,nginx3`).

#### Step 2 Configure load balancing.
Create a load balancing configuration file **lb.conf** in the **conf.d** directory and enter the following content:
```nginx
upstream www.test.com {
    server 192.168.1.12:81;
    server 192.168.1.12:82;
    server 192.168.1.12:83;
}

server {
    listen 81;
    location / {
        proxy_pass http://www.test.com;
    }
}
```
After the configuration is complete, reload the NGINX configurations and manually add the static domain name resolution of **www.test.com** to **/etc/hosts**:
(Output of `cat /etc/hosts` showing `127.0.0.1 localhost localhost.localdomain localhost4 localhost4.localdomain` and `192.168.1.12 www.test.com`).

#### Step 3 Verify the configurations.
Run the **curl www.test.com** command on the server multiple times and check the returned information:
(Output showing `curl www.test.com` cycling through `hello,nginx1`, `hello,nginx2`, `hello,nginx3`).
It can be observed that each request is served by the three virtual hosts in turn.

#### Step 4 Configure weights.
Modify the **lb.conf** file to add weights for load balancing as follows:
```nginx
upstream www.test.com {
    server 192.168.1.12:81 weight=2;
    server 192.168.1.12:82 weight=1;
    server 192.168.1.12:83;
}

server {
    listen 81;
    location / {
        proxy_pass http://www.test.com;
    }
}
```
Reload the NGINX configurations.

#### Step 5 Verify the configurations.
Run the **curl www.test.com** command on the server multiple times and check the returned information:
(Output showing `curl www.test.com` returning `hello,nginx1` twice, then `hello,nginx2` once, then `hello,nginx1` twice, then `hello,nginx3` once, and so on).
This demonstrates that the three virtual hosts provide services based on the configured weights.

#### Step 6 Configure the backup NGINX server.
Modify the **lb.conf** configuration file as follows:
```nginx
upstream www.test.com {
    server 192.168.1.12:81 backup;
    server 192.168.1.12:82;
    server 192.168.1.12:83;
}

server {
    listen 81;
    location / {
        proxy_pass http://www.test.com;
    }
}
```
After the configuration is complete, reload the NGINX configurations.

#### Step 7 Verify the configurations.
Run the **curl www.test.com** command on the server multiple times and check the returned information:
(Output showing `curl www.test.com` cycling through `hello,nginx2`, `hello,nginx3`).
It can be observed that NGINX does not forward requests to virtual host 1 (which is set as backup).

#### Step 8 Enable the backup host.
Modify the **lb.conf** configuration file as follows:
```nginx
upstream www.test.com {
    server 192.168.1.12:81 backup;
    server 192.168.1.12:82 down;
    server 192.168.1.12:83;
}

server {
    listen 81;
    location / {
        proxy_pass http://www.test.com;
    }
}
```
Reload the NGINX configurations.

#### Step 9 Verify the configurations.
Run the **curl www.test.com** command on the server multiple times and check the returned information:
(Output showing `curl www.test.com` cycling through `hello,nginx3`, `hello,nginx1`).

**Question**: What is returned by the system when you run the **curl www.test.com** command to request a resource? Why?
**Answer**: The system returns "**hello,nginx2**". This is because virtual host 3 is down, but virtual host 2 is still available. NGINX does not forward the request to backup virtual host 1, and the system thus returns the resource provided by virtual host 2.
(Additional output showing `curl www.test.com` returning `hello,nginx2` again after previous cycles).
```
