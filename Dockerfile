FROM openjdk:8-jre-alpine

RUN apk add --no-cache wget \
 && wget -q "https://www.crushftp.com/early8/CrushFTP8_PC.zip" -O /tmp/CrushFTP.zip \
 && unzip -q /tmp/CrushFTP.zip -d /var/opt/ \
 && rm -rf /tmp/*

WORKDIR /var/opt/CrushFTP8_PC

CMD java -jar CrushFTP.jar -d