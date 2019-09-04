#/bin/bash!

echo "=================================================================================================================="
echo "=================================================================================================================="
echo "=========================================== SCRIPT BACULA CREATE ================================================="
echo "===================================== Developed by: Rafael Tessarolo ============================================="
echo "=================================================================================================================="
echo "=================================================================================================================="

createConfFile() {
	IP=$1
	SERVERNAME=$2
	PASSWORD=$3
	SCRIPTPATH=$4
	echo "Creating bacula client conf file..."
	echo "#This job will back up to disk in /backup/
Job {
  Name = \"${SERVERNAME}_PriJobBackup\"
  JobDefs = \"RemoteJob\"
  Client = ${SERVERNAME}_PriMachine-fd
  Write Bootstrap = \"/bkp/clients/%c.bsr\"
  Client Run Before Job = \"$SCRIPTPATH 1\"
}

Client {
  Name = ${SERVERNAME}_PriMachine-fd
  Address = $IP
  FDPort = 9102
  Catalog = MyCatalog
  Password = \"${PASSWORD}\"                 Job Retention = 6 months              # 6 months
  AutoPrune = yes                     # Prune expired Jobs/Files
}
" > /etc/bacula/conf.d/client$SERVERNAME.conf
}

backupBaculaDir() { 
	echo "Creating a copy of bacula-dir.conf..."
	DATA=$(date +%d%m%y)
	cp -p  /etc/bacula/bacula-dir.conf /etc/bacula/bacula-dir_${DATA}.conf
}

addClientToBaculaDir() {
	echo "Adding client to bacula-dir.conf..."
	SERVERNAME=$1
	FILECONF="@/etc/bacula/conf.d/client$SERVERNAME.conf"
	echo "${FILECONF}"
	sed -i "s,at beginning),at beginning)\n${FILECONF},g" /etc/bacula/bacula-dir.conf
}

cd /etc/bacula/conf.d/

echo -n "Type the Server IP: "; read IP
echo -n "Type the Server name (Without spaces): "; read SERVERNAME
echo -n "Type the Server password: "; read PASSWORD
echo -n "Type the Script path: "; read SCRIPTPATH

createConfFile $IP $SERVERNAME $PASSWORD $SCRIPTPATH
backupBaculaDir
addClientToBaculaDir $SERVENAME

/etc/init.d/bacula restart

echo "=================================================================================================================="
echo "=================================================================================================================="
echo "========================================== SCRIPT BACULA CREATE ENDED ============================================"
echo "=================================================================================================================="
echo "=================================================================================================================="
