#!/bin/bash

# Reset other directories except /nfs
# Add commands here to reset other directories as needed

# Install Java
sudo apt-get update
sudo wget -O - https://apt.corretto.aws/corretto.key | sudo gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | sudo tee /etc/apt/sources.list.d/corretto.list

sudo apt-get install -y java-1.8.0-amazon-corretto-jdk

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-1.8.0-amazon-corretto' | sudo tee -a /etc/profile
echo 'export PATH=$JAVA_HOME/bin:${PATH}' | sudo tee -a /etc/profile

# Set HADOOP_HOME
echo 'export HADOOP_HOME=/nfs/hadoop' | sudo tee -a /etc/profile
echo 'export PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin:${PATH}' | sudo tee -a /etc/profile

# Set HIVE_HOME
echo 'export HIVE_HOME=/nfs/hive' | sudo tee -a /etc/profile
echo 'export PATH=$HIVE_HOME/bin:${PATH}' | sudo tee -a /etc/profile
source /etc/profile

# Install MySQL and Connector
cd /nfs
sudo dpkg -i mysql-connector-j_8.3.0-1ubuntu22.04_all.deb

# Create database directory and change MySQL datadir
sudo systemctl stop mysql
sudo rsync -av /var/lib/mysql/ /nfs/database 
sudo sed -i 's|/var/lib/mysql|/nfs/database|g' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo sed -i -E 's|^#(datadir\s*=\s*)/var/lib/mysql|\1/nfs/database|; s|^#(datadir\s*=\s*)/nfs/database|\1/nfs/database|' /etc/mysql/mysql.conf.d/mysqld.cnf

# Update AppArmor for MySQL
echo -e "/nfs/database/ r,\n/nfs/database/** rwk," | sudo tee -a /etc/apparmor.d/usr.sbin.mysqld
sudo systemctl restart apparmor

# Restart MySQL
sudo systemctl restart mysql

# Configure users for Hive
sudo mysql -e "CREATE DATABASE IF NOT EXISTS metastore;"
sudo mysql -e "CREATE USER 'hiveuser'@'localhost' IDENTIFIED BY 'password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON metastore.* TO 'hiveuser'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

echo "Setup completed successfully!"

