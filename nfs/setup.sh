#!/bin/bash

# Reset other directories except /nfs
# Add commands here to reset other directories as needed

# Install Java
sudo apt-get update

sudo wget https://corretto.aws/downloads/latest/amazon-corretto-8-x64-linux-jdk.tar.gz

sudo tar -xvzf amazon-corretto-8-x64-linux-jdk.tar.gz
sudo cp -r amazon-corretto-8.402.08.1-linux-x64 /usr/lib/jvm

# Set JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/amazon-corretto-8.402.08.1-linux-x64' | sudo tee -a /etc/profile
echo 'export PATH=$JAVA_HOME/bin:${PATH}' | sudo tee -a /etc/profile
source /etc/profile

# Install Hadoop
cd /nfs
sudo wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
sudo tar -xvzf hadoop-3.3.6.tar.gz
sudo mv hadoop-3.3.6 hadoop
sudo rm hadoop-3.3.6.tar.gz

# Set HADOOP_HOME
echo 'export HADOOP_HOME=/nfs/hadoop' | sudo tee -a /etc/profile
echo 'export PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin:${PATH}' | sudo tee -a /etc/profile
source /etc/profile

# Install Hive
sudo wget https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
sudo tar -xvzf apache-hive-3.1.3-bin.tar.gz
sudo mv apache-hive-3.1.3-bin hive
sudo rm apache-hive-3.1.3-bin.tar.gz

# Set HIVE_HOME
echo 'export HIVE_HOME=/nfs/hive' | sudo tee -a /etc/profile
echo 'export PATH=$HIVE_HOME/bin:${PATH}' | sudo tee -a /etc/profile
source /etc/profile

# Install MySQL and Connector
sudo apt-get install -y mysql-server
sudo wget https://cdn.mysql.com//Downloads/Connector-J/mysql-connector-j_8.3.0-1ubuntu22.04_all.deb
sudo dpkg -i mysql-connector-j_8.3.0-1ubuntu22.04_all.deb
sudo rm mysql-connector-j_8.3.0-1ubuntu22.04_all.deb

# Copy MySQL connector jar to Hive lib
sudo cp /usr/share/java/mysql-connector-j-8.3.0.jar /nfs/hive/lib
sudo cp /usr/share/java/mysql-connector-java-8.3.0.jar /nfs/hive/lib

# Create database directory and change MySQL datadir
sudo mkdir -p /nfs/database
sudo chmod -R 777 /nfs/database
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

# Configure Hive MySQL connection in hive-site.xml
sudo tee /nfs/hive/conf/hive-site.xml > /dev/null << EOF
<configuration>
  <property>
    <name>hive.metastore.warehouse.dir</name>
    <value>/nfs/database</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionURL</name>
    <value>jdbc:mysql://localhost/metastore?createDatabaseIfNotExist=true</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionDriverName</name>
    <value>com.mysql.cj.jdbc.Driver</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionUserName</name>
    <value>hiveuser</value>
  </property>
  <property>
    <name>javax.jdo.option.ConnectionPassword</name>
    <value>password</value>
  </property>
</configuration>
EOF

# Initialize Hive schema
schematool -initSchema -dbType mysql

echo "Setup completed successfully!"

