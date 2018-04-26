# [CrushFTP](http://www.crushftp.com)

## Quickstart

### Run CrushFTP

```console
$ docker run -d --name crushftp -p 8080:8080 adito/crushftp
```
### Default Ports
21 - FTP 
8080 - HTTP 
9090 - HTTP 
443 - HTTPS 
2222 - SFTP 

### User (default)

    User: fadmin
    Pass: admin

#### Command to start with a custom password for user "fadmin"
```console
$ docker run -d -e "FTPADMINPASSWORD=pass" --name crushftp -p 8080:8080 adito/crushftp
```    
### Example

The container will be copy the crushftp files from "/config" folder in /var/opt/CrushFTP8_PC/ after first start. So for the first start you don't need any config files. You can mount this folder (/var/opt/CrushFTP8_PC/) in the host.

```[yaml]
version: "2"
services:

  crushftp:
    image: adito/crushftp
    ports:
      - "2222:2222"   # sftp
      - "80:8080" # http backup port
      - "443:443" # https
    environment:
      FTPADMINPASSWORD: admin
    volumes:
      - /a/data/crush/:/var/opt/CrushFTP8_PC/
      - /a/data/share:/share/s
    restart: unless-stopped

```

## [CrushFTP Documentation](http://crushftp.com/crush8wiki/)