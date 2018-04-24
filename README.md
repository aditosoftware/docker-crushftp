# [CrushFTP](http://www.crushftp.com)

## Quickstart

### Run CrushFTP

```console
$ docker run -d --name crushftp -p 8080:8080 adito/crushftp
```

### User
#### Default

    User: fadmin
    Pass: admin

#### Command to start with a custom password for user "fadmin"
```console
$ docker run -d -e "FTPADMINPASSWORD=pass" --name crushftp -p 8080:8080 adito/crushftp
```    

## [CrushFTP Documentation](http://crushftp.com/crush8wiki/)