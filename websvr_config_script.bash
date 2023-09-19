#!/bin/bash

#variable declations
dir="labs"
link="html"
page="index.html"
path="/var/www/html"
user="kali"
home="/home/kali"
echo "################################"
echo "#    NGINX CONFIG SCRIPT  v1.0 # "
echo "################################"
echo "script initialising ..."
sleep 1
rm -rvf $path/$dir
rm -rvf $home/$link
 
sleep 1

if [ "`systemctl is-active nginx 2> /dev/null`" = "active" ]
then

        echo "service running, continuing with cofinguration..."
	sleep 1
        echo "creating directory $dir"
        sleep 1
       
	mkdir $path/$dir
        if [ -d $path/$dir ]
	then
		echo "changing ownership of $dir to $user"
	else
		echo "did not find directory $path/$dir"
		echo "exiting script ..."
		exit 1
	fi
        sleep 1
       
	chown  kali:root $path/$dir
        echo "creating symbolic link $home/$link"
        sleep 1
        
	ln -s $path/$dir $home/$link
        sleep 1
        if [ -L $home/$link ]; then
		cd $home/$link
		echo "creating test page $page "
       
		touch $page
		echo "adding dummy content to $page"
        	sleep 1
		
		echo "<html>" > $page
		echo "<body>" >> $page
		echo "<h1>DUMMY WEB PAGE!</h1>" >> $page
		echo "</body>" >> $page
		echo "</html>" >> $page
		

		echo "script has finished executing on `date`"
	else
		echo  "symbolic link ($link) was not found!"
		echo "script will now exit ..."
		sleep 1
		exit 1
	fi
	

else
        echo "nginx service not running!"
        echo "exiting script"
        exit 1
fi
# end of script
