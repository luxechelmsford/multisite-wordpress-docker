#!/bin/bash


echo "*******************************************************************"
echo "[$(date +"%Y-%m-%d-%H%M%S")] Entered wpbackup entrypoint script ..."

if [ -z "${WPBACKUP_WEBSITE}" ];            then echo "Error: WPBACKUP_WEBSITE not set";            echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_DB_HOST}" ];            then echo "Error: WPBACKUP_DB_HOST not set";            echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_DB_NAME}" ];            then echo "Error: WPBACKUP_DB_NAME not set";            echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_DB_USER}" ];            then echo "Error: WPBACKUP_DB_USER not set";            echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_DB_PASSWORD_FILE}" ];   then echo "Error: WPBACKUP_DB_PASSWORD_FILE not set";   echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_WPCONTENT_DIR}" ];      then echo "Error: WPBACKUP_WPCONTENT_DIR not set";      echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_BACKUP_DIR}" ];         then echo "Error: WPBACKUP_BACKUP_DIR not set";         echo "Finished: FAILURE"; exit 1; fi
if [ -z "${WPBACKUP_LOG_DIR}" ];            then echo "Error: WPBACKUP_LOG_DIR not set";            echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WPBACKUP_RESTORE_KEY}" ];       then echo "Error: WPBACKUP_RESTORE_KEY not set";        echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WPBACKUP_WPCUSTOM_FILENAME}" ]; then echo "Error: WPBACKUP_WPCUSTOM_FILENAME not set";  echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WPBACKUP_DROPBOX_TOKEN_FILE}" ];then echo "Error: WPBACKUP_DROPBOX_TOKEN_FILE not set"; echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WPBACKUP_GPG_PASSWORD_FILE}" ]; then echo "Error: WPBACKUP_GPG_PASSWORD_FILE not set";  echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WP_CLEAN_DAILY_DAYS}" ];        then echo "Error: WP_CLEAN_DAILY_DAYS not set";         echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WP_CLEAN_WEEKLY_DAYS}" ];       then echo "Error: WP_CLEAN_WEEKLY_DAYS not set";        echo "Finished: FAILURE"; exit 1; fi
#if [ -z "${WP_CLEAN_MONTHLY_DAYS}" ];      then echo "Error: WP_CLEAN_MONTHLY_DAYS not set";       echo "Finished: FAILURE"; exit 1; fi

if [ ! -d "${WPBACKUP_BACKUP_DIR}" ]; then mkdir -p "${WPBACKUP_BACKUP_DIR}"; fi
if [ ! -d "${WPBACKUP_LOG_DIR}" ]; then mkdir -p "${WPBACKUP_LOG_DIR}"; fi

# First create the conf file for backup job to pick up database username password
if [ ! -f ~/.my.cnf ]
then
  echo "Creating Mysql config file ...";
  if [ -z "${WPBACKUP_DB_HOST}" ]
  then
    echo "Failed to create Mysql config file - WPBACKUP_DB_HOST not setup.";
  elif [ -z "${WPBACKUP_DB_USER}" ]
  then
    echo "Failed to create Mysql config file - WPBACKUP_DB_USER not setup.";
  elif [ -z "${WPBACKUP_DB_PASSWORD_FILE}" ]
  then
    echo "Failed to create Mysql config file - WPBACKUP_DB_PASSWORD_FILE not setup.";
  else
    WPBACKUP_DB_PASSWORD=$(<"${WPBACKUP_DB_PASSWORD_FILE}");
    # Do not include double quotes around ~/.my.cnf, it wont' expand 
    cat <<EOF > ~/.my.cnf
[mysql]
host=${WPBACKUP_DB_HOST}
user=${WPBACKUP_DB_USER}
password=${WPBACKUP_DB_PASSWORD}
[mysqldump]
host=${WPBACKUP_DB_HOST}
user=${WPBACKUP_DB_USER}
password=${WPBACKUP_DB_PASSWORD}
EOF
    
    echo "Mysql config file created successfully.";
  fi
fi

# First creating the webdav mounts
if [ ! -f "/etc/wpbackup-cron" ]
then
  # Schedule the cron task
  echo "Creating backup/restore cron jobs ..."
#CRON_COMMAND="0 ${WPBACKUP_TIME:-0} * * * bash /bin/backup.sh"
#echo DATEVAR="date +%Y-%m-%d-%H%M"                                                          >   /etc/wpbackup-cron
#echo "NOW=echo \$(\$DATEVAR)"                                                               >>  /etc/wpbackup-cron
#echo "WPBACKUP_WEBSITE=\"${WPBACKUP_WEBSITE}\""                                             >>  /etc/wpbackup-cron
#echo "WPBACKUP_DB_NAME=\"${WPBACKUP_DB_NAME}\""                                             >>  /etc/wpbackup-cron
#echo "WPBACKUP_DB_USER=\"${WPBACKUP_DB_USER}\""                                             >>  /etc/wpbackup-cron
#echo "WPBACKUP_WPCONTENT_DIR=\"${WPBACKUP_WPCONTENT_DIR}\""                                 >>  /etc/wpbackup-cron
#echo "WPBACKUP_BACKUP_DIR=\"${WPBACKUP_BACKUP_DIR}\""                                       >>  /etc/wpbackup-cron
#echo "WPBACKUP_LOG_DIR=\"${WPBACKUP_LOG_DIR}\""                                             >>  /etc/wpbackup-cron
#echo "WPBACKUP_RESTORE_KEY=\"${WPBACKUP_RESTORE_KEY}\""                           >>  /etc/wpbackup-cron
#echo "WPBACKUP_WPCUSTOM_FILENAME=\"${WPBACKUP_WPCUSTOM_FILENAME}\""                         >>  /etc/wpbackup-cron
#echo "WPBACKUP_DROPBOX_TOKEN_FILE=\"${WPBACKUP_DROPBOX_TOKEN_FILE}\""                       >>  /etc/wpbackup-cron
#echo "WPBACKUP_GPG_PASSWORD_FILE=\"${WPBACKUP_GPG_PASSWORD_FILE}\""                         >>  /etc/wpbackup-cron
#echo "WP_CLEAN_DAILY_DAYS=\"${WP_CLEAN_DAILY_DAYS}\""                                       >>  /etc/wpbackup-cron
#echo "WP_CLEAN_WEEKLY_DAYS=\"${WP_CLEAN_WEEKLY_DAYS}\""                                     >>  /etc/wpbackup-cron
#echo "WP_CLEAN_MONTHLY_DAYS=\"${WP_CLEAN_MONTHLY_DAYS}\""                                   >>  /etc/wpbackup-cron
#echo "${CRON_COMMAND} > ${WPBACKUP_LOG_DIR}/backup-\${date "+\%Y-\%m-\%d-\%H\%M-").log"     >>  /etc/wpbackup-cron
#echo "0/1 0 * * * bash /bin/restore.sh > ${WPBACKUP_LOG_DIR}/restore-\${date "+\%Y-\%m-\%d-\%H\%M-").log"     >>  /etc/wpbackup-cron
#echo "0 ${WPBACKUP_TIME:-0} * * * . /proc/1/environ; export NOW=\$(date +\"\%Y-\%m-\%d-\%H\%M\%Sa\"); /bin/restore.sh > /restore-\${NOW}; unset NOW;" > /etc/wpbackup-cron
  
  # export environment variables in a file
  #printenv | grep -v “no_proxy” >> /etc/docker_envs
  printenv | sed 's/^\(.*\)$/export \1/g' >  /etc/wpbackup-envs
  # Now create the cron job that
  #   Loads the docker-envs, sets the current date and time in a env var
  #   Executes the backup script and then finall unsets the current date & time env var
  echo "0 ${WPBACKUP_TIME:-0} * * * . /etc/docker_envs; export NOW=\$(date +\"\%Y-\%m-\%d-\%H\%M\"); /bin/backup.sh > ${WPBACKUP_LOG_DIR}/backup-\${NOW}.log; unset NOW;" > /etc/wpbackup-cron

#echo "* * * * * . /etc/wpbackup-envs; export NOW=\$(date +\"\%Y-\%m-\%d-\%H\%M\"); /bin/restore.sh \"/var/backups/ttek-live/ttek-live-daily-2021-01-16-1644.tar.gz\" > ${WPBACKUP_LOG_DIR}/restore-\${NOW}.log; unset NOW;" > /etc/wpbackup-cron 
 #  . /etc/wpbackup-envs; export NOW=$(date +"%Y-%m-%d-%H%M%Sa"); /bin/restore.sh > /restore-${NOW}; unset NOW;
  
  # Schedule the backup cron job
  crontab /etc/wpbackup-cron

  # Now check if we need to restore from a restore file
  # We can only restore on an empty database lets check that
  # Host and password information is stored in config so there is no need to pass here
  echo "Checking if we need to restore from a previous backup ..."
  DB_TABLES=$(echo "show tables" | mysql -u "${WPBACKUP_DB_USER}" "${WPBACKUP_DB_NAME}")
  if  [ -n "${DB_TABLES}" ]
  then
    echo "Database is not empty - restore will be skipped"
    echo "If restore is required, please delete the database"
  else
    # Lets check if the restore key is deifned and the file actually exists
    RESTORE_KEY_FILE="${WPBACKUP_BACKUP_DIR}/${WPBACKUP_RESTORE_KEY}"
    if [ -z "${WPBACKUP_RESTORE_KEY}" ]
    then
      echo "WPBACKUP_RESTORE_KEY is not defined - Restore will be skipped"
    elif [ -f "${RESTORE_KEY_FILE}" ]
    then
      while true
      do
        RESTORE_FILENAME="$(<"${RESTORE_KEY_FILE}")"
        if [ -z "${RESTORE_FILENAME}" ]
        then
          echo "Restore key file does not point to any restore file - Restore will be skipped"
          break;
        fi
        RESTORE_FILE="${WPBACKUP_BACKUP_DIR}/${RESTORE_FILENAME}"
        if [ -f "${RESTORE_FILE}" ]
        then
          echo "Restore file [${RESTORE_FILE}] found."
          # Lets check the wpcustom file
          WPCUSTOM_KEY_FILE="${WPBACKUP_BACKUP_DIR}/${WPBACKUP_WPCUSTOM_KEY}"
          if [ -n "${WPBACKUP_WPCUSTOM_KEY}" ] && [ -f "${WPCUSTOM_KEY_FILE}" ]
          then
            WPCUSTOM_FILENAME="$(<"${WPCUSTOM_KEY_FILE}")"
            WPCUSTOM_FILE="${WPBACKUP_BACKUP_DIR}/${WPCUSTOM_FILENAME}"
            if [ -n "${WPCUSTOM_FILENAME}" ] && [ -f "${WPCUSTOM_FILE}" ]
            then
              echo "wpcustom file [${WPCUSTOM_FILE}] found."
            else
              WPCUSTOM_FILE=""
            fi
          fi
          echo "Restore will start shortly"
          break;
        fi
        echo "The restore file [${RESTORE_FILE}] does not exist as yet."
        echo "May be it is yet to be synchronised with remote mount, lets wait ...";
        sleep 60 # sleep for 60 seconds
      done
      
      if [ -f "${RESTORE_FILE}" ]
      then
        # lets run the restore script 
        echo "Restoring the wordpress site ..."
        echo "Restore file:  [${RESTORE_FILE}]"
        if [ -n "${WPCUSTOM_FILE}" ]; then
          echo "Wpcustom file: [${WPCUSTOM_FILE}]"
        fi
        export NOW; NOW="$(date "+%Y-%m-%d-%H%M")"
        if bash /bin/restore.sh "${RESTORE_FILE}" "${WPCUSTOM_FILE}" > "${WPBACKUP_LOG_DIR}/restore-${NOW}.log"
        then
          echo "The wordpress is restored successfully from:"
          echo "Backup file:   [${RESTORE_FILE}]"
          if [ -n "${WPCUSTOM_FILE}" ]; then
            echo "Wpcustom file: [${WPCUSTOM_FILE}]"
          fi
          echo "Please check the logs at [${WPBACKUP_LOG_DIR}/restore-${NOW}.log]"
          # Delete the restore file, as we are done with it
          # Otherwise it will try and restore this again, when this container is recreated
          echo "Deleting restore key file [${RESTORE_KEY_FILE}]."
          if rm -f "${RESTORE_KEY_FILE}"
          then
            echo "Restore key file [${RESTORE_KEY_FILE}] deleted successfully."
          else
            echo "Failed to delete restore file [${RESTORE_KEY_FILE}]."
          fi
        else
          echo "Failed to restore wordpress from:"
          echo "Backup file:   [${RESTORE_FILE}]"
          if [ -n "${WPCUSTOM_FILE}" ]; then
            echo "Wpcustom file: [${WPCUSTOM_FILE}]"
          fi
          echo "Please check the logs at [${WPBACKUP_LOG_DIR}/restore-${NOW}.log]"
        fi
        unset NOW
      fi
    else
      echo "Restore key file [${RESTORE_KEY_FILE}] doesn't exist - Restore will be skipped"
    fi
  fi
fi

echo "Current crontab:"
crontab -l

exec "$@"

echo "[$(date +"%Y-%m-%d-%H%M%S")] Exiting wpbackup entrypoint script ..."
echo "*******************************************************************"