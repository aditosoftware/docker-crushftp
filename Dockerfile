FROM java:openjdk-8-jre

RUN wget "https://www.crushftp.com/early7/CrushFTP7_PC.zip" -O /var/opt/CrushFTP7_PC.zip \
    && unzip -q /var/opt/CrushFTP7_PC.zip -d /var/opt/ \
    && rm -rf /var/opt/CrushFTP7_PC.zip

WORKDIR /var/opt/CrushFTP7_PC

ADD ./start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]