#!/bin/bash

set -e

SERVICE="mariadb"
DATADIR="/var/lib/mysql"
LOG="/var/log/mariadb-recovery.log"

echo "=== MariaDB Recovery Script ===" | tee -a $LOG
date | tee -a $LOG

echo "[1] Checking MariaDB service..." | tee -a $LOG
if ! systemctl list-unit-files | grep -q mariadb.service; then
  echo "ERROR: MariaDB service not installed." | tee -a $LOG
  exit 1
fi

echo "[2] Checking data directory..." | tee -a $LOG
if [ ! -d "$DATADIR" ] || [ -z "$(ls -A $DATADIR 2>/dev/null)" ]; then
  echo "Datadir missing or empty. Initializing..." | tee -a $LOG
  mysql_install_db --user=mysql --basedir=/usr --datadir=$DATADIR | tee -a $LOG
fi

echo "[3] Fixing permissions..." | tee -a $LOG
chown -R mysql:mysql $DATADIR
chmod 755 $DATADIR

echo "[4] Checking port 3306..." | tee -a $LOG
if ss -lntp | grep -q 3306; then
  echo "Port 3306 already in use." | tee -a $LOG
else
  echo "Port 3306 free." | tee -a $LOG
fi

echo "[5] Starting MariaDB..." | tee -a $LOG
systemctl start mariadb || {
  echo "FAILED to start MariaDB. Showing logs:" | tee -a $LOG
  journalctl -xeu mariadb.service | tail -50
  exit 1
}

echo "[6] Enabling MariaDB..." | tee -a $LOG
systemctl enable mariadb

echo "[7] Verifying MariaDB responsiveness..." | tee -a $LOG
mysql -e "SELECT VERSION();" && echo "MariaDB is UP." | tee -a $LOG

echo "=== MariaDB Recovery Completed Successfully ===" | tee -a $LOG
