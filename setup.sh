#!/bin/bash
#!/bin/sh

if [ ! -f /var/opt/CrushFTP8_PC/CrushFTP.jar ]; then
    cp -Rf /config/CrushFTP.jar /var/opt/CrushFTP8_PC/CrushFTP.jar
fi

if [ ! -f /var/opt/CrushFTP8_PC/crushftp_init.sh ]; then
    cp -Rf /config/crushftp_init.sh /var/opt/CrushFTP8_PC/crushftp_init.sh
fi

if [ -z "$(ls -A /var/opt/CrushFTP8_PC/backup)" ]; then
    mkdir /var/opt/CrushFTP8_PC/backup
    cp -Rf /config/backup/* /var/opt/CrushFTP8_PC/backup/
fi

if [ -z "$(ls -A /var/opt/CrushFTP8_PC/plugins)" ]; then
    mkdir /var/opt/CrushFTP8_PC/plugins
    cp -Rf /config/plugins/* /var/opt/CrushFTP8_PC/plugins/
fi

if [ -z "$(ls -A /var/opt/CrushFTP8_PC/users)" ]; then
    echo users not found,copy folder
    mkdir /var/opt/CrushFTP8_PC/users
    cp -Rf /config/users/* /var/opt/CrushFTP8_PC/users/
fi

if [ -z "$(ls -A /var/opt/CrushFTP8_PC/WebInterface)" ]; then
    mkdir /var/opt/CrushFTP8_PC/WebInterface
    cp -Rf /config/WebInterface/* /var/opt/CrushFTP8_PC/WebInterface/
fi

#check if user and password variables exist
if [[ ! -z $FTPADMIN ]] && [[ ! -z $FTPADMINPASSWORD ]];  then
    echo user and password variables was found. Set fadmin:$FTPADMINPASSWORD
    cd /var/opt/CrushFTP8_PC && java -jar /var/opt/CrushFTP8_PC/CrushFTP.jar -a fadmin $FTPADMINPASSWORD
else 
    echo user and password was not defined. Leave default settings fadmin:admin
fi

/var/opt/run_crushftp.sh start
while true; do sleep 86400; done