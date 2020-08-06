#!/bin/bash

#delete the folders of the backup file ( only if you want to make a backup on another server afterwards this will allow us to create only one archive per day) 

rm -R /backup/mysql/
mkdir /backup/mysql/

# Basic configuration: datestamp YYYYMMDD

DATE=$(date +"%Y%m%d")

# Folder where to save backups (create it first if you hadn't done it in the previous step... !)

BACKUP_DIR="/backup/mysql"

# MySQL Login Information

MYSQL_USER=""
MYSQL_PASSWORD=""

# MySQL Commands

MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

# MySQL databases to ignore

SKIPDATABASES="Database|information_schema|performance_schema|mysql"

# Number of days to keep records (will be deleted after X days)

RETENTION=1

# Create a new directory in the directory backup location for this date

mkdir -p $BACKUP_DIR/$DATE

# Retrieve a list of all databases

databases=`$MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "($SKIPDATABASES)"`

# Dumb the databases in separate names and gzip the .sql file.
for db in $databases; do
echo $db
$MYSQLDUMP --force --opt --user=$MYSQL_USER -p$MYSQL_PASSWORD --skip-lock-tables --events --databases $db | gzip > "$BACKUP_DIR/$DATE/$db.sql.gz"
done

# Delete files older than X days

find $BACKUP_DIR/* -mtime +$RETENTION -delete

# If you want to transfer these files to a server you will need to create an archive to send them to your backup server.

rm -rf /backupdb/
mkdir /backupdb/
cd /backupdb/
mkdir node1db
DATE=`date +%d_%m_%y`
heure=$(date +%H%M)
jour=$(date +%Y%m%d)

tar cvfz /backupdb/node1db/BACKUPDB-$.$jour.-$heure.tar.gz /backup/mysql/*

this command allows you to send your archive created on your remote server 

scp -r /backupdb/node1db/* root@x.x.x.x:/Backup/DB

exit 0
