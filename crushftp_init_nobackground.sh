#!/bin/bash
#!/bin/sh
#
# Control script for CrushFTP v1.5
#
# chkconfig: - 86 14
# description: CrushFTP
#
### BEGIN INIT INFO  
# Provides:          crushftp_init.sh  
# Required-Start:    $local_fs  
# Should-Start:      $network   
# Required-Stop:       
# Should-Stop:       $network   
# Default-Start:     2 3 5
# Default-Stop:      2 5  
# Short-Description: CrushFTP Server  
# Description:       Starts Crush on boot  
### END INIT INFO  
# THESE NEED TO BE SET
CRUSH_DIR="/var/opt/CrushFTP8_PC/" #crushftp directory
CRUSH_INIT_SCRIPT="$CRUSH_DIR"crushftp_init.sh
USER="root" # only work for this user
JAVA="java"
PS="ps"
AWK="awk"
GREP="grep"
WHOAMI="whoami"
NOHUP="nohup"
INSTSCRIPT=0
DEBUG=0
LC_ALL=en_US.UTF-8
export LC_ALL=en_US.utf8

# We MUST start the server in the proper directory. If we can not change to that directory, we exit.
change_dir()
{
 cd $CRUSH_DIR
 ret_val=$?
 if [ ${ret_val} -ne 0 ]; then
   echo FAIL
   echo could not change to CrushFTP directory
   echo the directory is setup as:
   echo $CRUSH_DIR
   exit 1
 fi
}


# get PID from process list.  Not from a 'stored' file.  Since Crush updates will
# restart the server, but NEVER run this script, then if we stored off the PID into
# a file, then after an update, this script would not be able to shut down the
# process.  We have added a couple greps into the get_pid() so that we 'know' we
# are getting the proper PID if it exists.
get_pid()
{
 CRUSH_PID="`$PS -ef | $GREP java | $GREP $CRUSH_DIR | awk '{print $2}'`"
 CRUSH_PARENT="`$PS -ef | $GREP java | $GREP $CRUSH_DIR | awk '{print $3}'`"
}

# if the wrong user runs this script then BAIL.  If this script should be run as user
# OTHER than 'root' (or su or sudo), then you must redirect port 21 (or 22) up to a higher
# port, such as 60021.  iptables can do this well.  Then setup the crush server to bind to
# these higher ports.  Running as non-root is much more secure.  NOTE, it 'is' valid for root
# to shut down the server (but not to start it, unless USER="root" is set at teh top of the file
ROOT_OK=0
chk_user()
{
  if [ "$USER" != `whoami` ]; then
    if [ `whoami` = "root" -a "$ROOT_OK" = "1" ]; then
  echo ""
      # echo "Not an error. Root user is OK here, even if 'not' the proper user (such as killing the process)."
    else
       echo "Wrong user. This script MUST be run as <$USER>, but you are <`whoami`>"
       exit 1;
    fi
  fi
}
##################################################################################################
# Get OS type, version, distro name
##################################################################################################
GetOsVer(){

JAVAVER=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}')

if [ ! "${JAVAVER:0:1}" ] ; then
  echo "No Java runtime found. Please install Java then try again. Exiting ..."
  exit 1
fi

OS=`uname -s`
REV=`uname -r`

if [ "${OS}" = "Linux" ] ; then
    KERNEL=`uname -r`
    if [ -f /etc/redhat-release ] ; then
        DIST='RedHat'
        REV=`cat /etc/redhat-release | sed s/.*release\ // | sed s/\ .*//`
    if [ ${REV:0:1} -eq "7" ] ; then
      INSTSCRIPT=1
    else
      INSTSCRIPT=2
    fi
      
    elif [ -f /etc/SuSE-release ] ; then
        DIST=`cat /etc/SuSE-release | tr "\n" ' '| sed s/VERSION.*//`
        REV=`cat /etc/SuSE-release | tr "\n" ' ' | sed s/.*=\ //`
    INSTSCRIPT=2
    
    elif [ -f /etc/mandrake-release ] ; then
        DIST='Mandrake'
        REV=`cat /etc/mandrake-release | sed s/.*release\ // | sed s/\ .*//`
    INSTSCRIPT=2
    
    elif [ -f /etc/debian_version ] ; then
        DIST="`lsb_release -i -s`"""
  REV="`lsb_release -r -s`"""
        if [ "${DIST}" == "Ubuntu" ]; then
    if [ ${REV:0:2} -gt "11" ] ; then
      if [ ${REV:0:2} -eq "16" ] ; then
        INSTSCRIPT=1
        else
        INSTSCRIPT=4
      fi
      else
        INSTSCRIPT=3
      fi
  else 
    if [ ${REV:0:2} -lt "8" ] ; then
      INSTSCRIPT=3
    else
      INSTSCRIPT=4
    fi
    
  fi
    
    
    else 
    DIST="Misc Linux"   
  fi
  
else 
    OS="Unknown"
  DIST="Unknown"
  REV="Unknown"
  KERNEL="Unknown"
fi

OSVER="OS-${OS} DIST-${DIST} REV-${REV} KERNEL-${KERNEL} INST-${INSTSCRIPT} JAVA-${JAVAVER}"
}
CrushFTP_start() {
            chk_user
             get_pid
             if [ "$CRUSH_PID" ]; then
               echo FAIL
               echo Found an already running instance of CrushFTP.
               echo It is not valid o start 2 sessions in the same directory.
               exit 1;
             fi
             echo -n "Starting CrushFTP... "
             change_dir

             # run daemon
             #$NOHUP $JAVA -Ddir=$CRUSH_DIR -Xmx512M -jar CrushFTP.jar -dmz 9000 >/dev/null 2>&1
             $NOHUP $JAVA -Ddir=$CRUSH_DIR -Xmx1024M -jar plugins/lib/CrushFTPJarProxy.jar -d >/dev/null 2>&1
}

CrushFTP_stop() {
             # root or $USER is ok to shut down the server.
             ROOT_OK=1
             chk_user
             get_pid
             if [ ! "$CRUSH_PID" ]; then
               echo FAIL
               echo Could not find Crush PID
               exit 1
             fi

             echo -n Shutting down CrushFTP...
             kill $CRUSH_PID
             ret_val=$?
             if [ ${ret_val} -ne 0 ]; then
                echo FAIL
                echo could not kill PID
                exit 1
             fi
             echo OK
}
CrushFTP_stop_silent() {
             # root or $USER is ok to shut down the server.
             ROOT_OK=1
             chk_user
             get_pid
             if [ ! "$CRUSH_PID" ]; then
               echo CrushFTP is not currently running...
             else
          
               echo -n Shutting down CrushFTP...
               kill $CRUSH_PID
               ret_val=$?
               if [ ${ret_val} -ne 0 ]; then
              echo FAIL
                  echo could not kill PID
                  exit 1
               fi 
               echo OK  
             fi
}
#############################################################################################
# Here is the 'main' script.  We can either start the server, or shutdown the current       #
# running server.   There is error checking to make sure the proper user is being used.     #
#############################################################################################
case "$1" in
        start)
                CrushFTP_stop_silent
    CrushFTP_start
        ;;

        stop)
    CrushFTP_stop
        ;;

        restart)
                CrushFTP_stop
    sleep 5
                CrushFTP_start 
        ;;


        status)
             get_pid
             if [ ! "$CRUSH_PID" ]; then
               echo stopped
               exit 3
             else
               if [ "$CRUSH_PARENT" = "1" ]; then
                 echo "running as daemon (pid $CRUSH_PID)"
               else
                 echo "running as user (pid $CRUSH_PID)"
               fi
             fi
        ;;
  install)

             chk_user
             get_pid
             if [ "$CRUSH_PID" ]; then
               echo "CrushFTP already running (pid $CRUSH_PID), we cannot proceed, exiting... "
               #kill $CRUSH_PID
               exit 1
             fi
    GetOsVer
    echo $OSVER
    if [ "$INSTSCRIPT" = "0" ];then
                        echo "Automatic OS version detection failed. Please try to install service manually"
                        echo ""
                        echo "Select your OS family:"
                        echo "1 - RHEL/CentOS 7 or Ubuntu 16  based (systemD method)"
                        echo "2 - RHEL/CentOS 6 and prior  based (system V method)"
                        echo "3 - All Debian / All Ubuntu except 16 and 13 "
                        echo "0 - Not sure - EXIT -"
                        echo ""
      read -p '>>> ' INSTSCRIPT

    fi
    
    #CentOS 7 , Ubuntu 16
    if [ "$INSTSCRIPT" = "1" ]; 
      then
        touch /etc/systemd/system/crushftp.service
        cat <<-EOT >/etc/systemd/system/crushftp.service
        [Unit]
          Description=CrushFTP 8 Server
          Documentation=http://www.crushftp.com/
          After=network.target auditd.service named.service
        [Service]
          Type=forking
          ExecStart=${CRUSH_INIT_SCRIPT} start
          ExecStop=${CRUSH_INIT_SCRIPT} stop
                                  Restart=always
                                  RestartSec=5
        [Install]
          WantedBy=multi-user.target
        #dummy padding
        
EOT
        
        systemctl daemon-reload && systemctl enable crushftp.service && systemctl start crushftp.service
        get_pid         
        echo "Service succesfully installed and running ... PID:$CRUSH_PID"   
    #CentOS 6.6 and below         
    elif [ "$INSTSCRIPT" = "2" ]; 
      then
        ln -f -s "$CRUSH_DIR"crushftp_init.sh /etc/init.d/crushftp 
        chkconfig --add crushftp
        chkconfig crushftp on
        service crushftp start 
        get_pid         
        echo "Service succesfully installed and running ... PID:$CRUSH_PID"                       
    #Debian and Ubuntu Old, some obsolete CentOS
    elif [ "$INSTSCRIPT" = "3" ]; 
      then
        sudo ln -f -s "$CRUSH_DIR"crushftp_init.sh /etc/init.d/crushftp
        sudo chkconfig --add crushftp
        sudo chkconfig crushftp on
        sudo service crushftp start 
        sudo get_pid          
        echo "Service succesfully installed and running ... PID:$CRUSH_PID"
    #Ubuntu 12,14,15 except 13
    elif [ "$INSTSCRIPT" = "4" ]; 
      then
        ln -f -s "$CRUSH_DIR"crushftp_init.sh /etc/init.d/crushftp
        update-rc.d crushftp defaults
        service crushftp start
        get_pid         
        echo "Service succesfully installed and running ... PID:$CRUSH_PID"
                  
    else
      echo "Exiting..."
      
    fi
    

  ;;
        uninstall)
    chk_user
    get_pid
    GetOsVer
    if [ "$INSTSCRIPT" = "0" ];then
                        echo ""
                        echo "Automatic OS version detection failed. Please try to uninstall service manually"
                        echo ""
                        echo "Select your OS family:"
                        echo "1 - RHEL/CentOS 7 or Ubuntu 16  based (systemD method)"
                        echo "2 - RHEL/CentOS 6 and prior  based (system V method)"
                        echo "3 - All Debian / All Ubuntu except 16 and 13 "
                        echo "0 - Not sure - EXIT -"
                        echo ""
                        read -p '>>> ' INSTSCRIPT

                fi
    if [ "$INSTSCRIPT" = "0" ];then
      echo "Exiting..."
      exit 1
     fi
                
               #CentOS 7 , Ubuntu 16, RHEL 7 family
                if [ "$INSTSCRIPT" = "1" ];then
                   if [ "$CRUSH_PID" ];then
                       echo "already running ( pid no.: $CRUSH_PID). stopping service" 
                       systemctl stop crushftp.service 
                   fi 
                       
                   if [ "$(systemctl is-enabled crushftp.service)" = "enabled" ];then
                       echo "disabling the service"
                       systemctl disable crushftp.service
                   fi
                       
                   if [ -f "/etc/systemd/system/crushftp.service" ];then 
                       rm -f /etc/systemd/system/crushftp.service
                   fi
       
                       systemctl daemon-reload 
                       systemctl reset-failed
                  
               #CentOS 6.6 and below 
               elif [ "$INSTSCRIPT" = "2" ];then
                  if [ "$CRUSH_PID" ];then
                       echo "already running ( pid no.: $CRUSH_PID). stopping service"
                       service crushftp stop                       
                       chkconfig crushftp off

                   fi
                                chkconfig --del crushftp
                                rm -f /etc/init.d/crushftp
                                echo "Service succesfully uninstalled"
                #Ubuntu 12,14,15 except 13
                elif [ "$INSTSCRIPT" = "4" ];then
                   if [ "$CRUSH_PID" ];then
                       echo "already running ( pid no.: $CRUSH_PID). stopping service"
                       service crushftp stop

                   fi

                       rm -f /etc/init.d/crushftp
                       update-rc.d -f crushftp remove
                       echo "Service succesfully uninstalled"
                else                   
                   echo "unsupported distro by the uninstall method"
                fi



        ;;
  info)
    GetOsVer
    echo $OSVER 
  ;;    

        *)
             echo "Usage: $0 [start|stop|restart|status|install|uninstall|info] Note: you must be logged in as $USER to run this script"

esac

exit 0

