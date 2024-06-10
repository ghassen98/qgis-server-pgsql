#!/bin/bash

echo "Start updating IP Address in config files..."$'\n'

now=$(date "+%F-%H-%M-%S")

files_to_update="testfile files/sybase.cfg files/apache2.html files/pg_hba.cfg"

source_file=$(echo $files_to_update | awk '{print $1}')
source $source_file

# Folder to backup config file to update
backup_folder="/tmp/backup"
# echo "Flushing backup folder $backup_folder"
# rm -rf $backup_folder
echo "Creating backup folder $backup_folder if not exist"$'\n'
mkdir -p $backup_folder

old_ip_address=$IP_ADDRESS
new_ip_address=$(/usr/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)

echo "Old IP @ is $old_ip_address"
echo "New IP @ is $new_ip_address"
echo

for f in $files_to_update
do
    if [ -f "$f" ]
    then
        echo "Backup $f to $backup_folder/$f"_"$now"
        mkdir -p $backup_folder/$(dirname $f)
        cp "$f" $backup_folder/$f"_"$now
        echo "Processing $f..."
        sed -i "s/$old_ip_address/$new_ip_address/" "$f"
        echo "Done."$'\n'
    else
        echo "[WARNING] File '$f' doesn't exist! Skipped."$'\n'
    fi
done

echo "Restarting Postgresql service"
#service postgresql restart
echo

echo "Restarting Apache2 service"
#service apache2 restart
echo

echo "Updating IP Address in config files successfully finished."$'\n'
