#!/bin/bash

#Patricio Balboa
#CodePlus.cl

#This script is used to update the tzdata files.
#It is used to update the tzdata files when a new version of the tzdata files is released.




#Check if the script is being run as root or sudo
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Checking Operating System..."
#Check if SO is CentOS.
if [ -f /etc/redhat-release ]; then
  echo "CentOS detected"
  #Install lzip if it is not installed with yum.
  if ! hash lzip 2>/dev/null; then
   yum install -y lzip
  fi

  #Install gcc if it is not installed.
  if ! hash gcc 2>/dev/null; then
    yum install -y gcc
  fi 
fi

#Check if SO is Ubuntu.
if [ -f /etc/lsb-release ]; then
  echo "Ubuntu detected"
  #Install lzip if it is not installed with apt-get.
  if ! hash lzip 2>/dev/null; then
    apt-get install -y lzip
  fi
  #Install gcc if it is not installed.
  if ! hash gcc 2>/dev/null; then 
    apt-get install -y gcc
  fi  
fi

#Download the latest version of the tzdata files.
echo 'Downloading the latest version of the tzdata db files...' 
curl -O https://data.iana.org/time-zones/releases/tzdb-2022c.tar.lz

#Extract the tzdata files.
echo 'Extracting the tzdata files...'
tar --lzip -xvf tzdb-2022c.tar.lz

#Remove the tzdata file archive.
echo 'Removing the tzdata file archive...'
rm tzdb-2022c.tar.lz

#cd to the tzdata directory.
cd tzdb-2022c

#Compile the tzdata files.
echo 'Compiling the tzdata files...'

if ! make ; then
  echo 'Compilation failed'
  exit 1
fi

#Install the tzdata files.
echo 'Installing the tzdata files...'
if ! make install ; then
  echo 'Installation failed'
  exit 1
fi

#Remove the tzdata directory.
echo 'Removing the tzdata directory...'
rm -rf ../tzdb-2022c

#Input parameter to set the timezone.
read -p 'Enter the timezone you want to set (e.g. America/New_York): ' TZ

#Update the tzdata.
echo 'Updating the tzdata...'



#Check if SO is CentOS.
if [ -f /etc/redhat-release ]; then
  #If the command fails, exit the script.
    if ! timedatectl set-timezone ${TZ} ; then
      echo 'Error: timedatectl set-timezone failed.'
      exit 1
    else
      echo 'Timezone set to '${TZ}
      #Print timedatectl status.
      timedatectl status
  
      echo 'The tzdata files were updated successfully.'
      exit 0
    fi
fi

#Check if SO is Ubuntu.
if [ -f /etc/lsb-release ]; then
#If the command fails, exit the script.
    if ! timedatectl set-timezone ${TZ} ; then
      echo 'Error: timedatectl set-timezone failed.'
      exit 1
    else
      echo 'Timezone set to '${TZ}
      #Print timedatectl status.
      zdump -v ${TZ} -c $(date '+%Y'),$(date -d '+1 year' '+%Y') | awk -v y=$(date '+%Y') '$6==y && $15~1 {print $4, $3, $6}'
  
      echo 'The tzdata files were updated successfully.'
      exit 0
    fi
fi





