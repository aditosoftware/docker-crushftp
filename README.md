# [CrushFTP](http://www.crushftp.com)

## Quickstart

### Run CrushFTP

```console
$ docker run -d --name crushftp -p 8080:8080 adito/crushftp
```

### Generating an Admin User

```console
$ docker exec crushftp java -jar CrushFTP.jar -a "crushadmin" "password"
```

## [CrushFTP Documentation](http://crushftp.com/crush8wiki/)