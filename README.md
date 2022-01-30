# Example PHP-FPM container with Apache on host

This is a tiny example on how to setup a web server with Apache running on the host, and PHP-FPM running in a container. This can be handy for running multiple PHP versions on a single server, or running different sites that need different PHP versions.

## Setup

Build the container

`sudo docker build -t fpm-example .`

Run the container

`sudo docker run -d -v $(pwd)/html:/var/www/html -p 9001:9000 --name fpm1 fpm-example`

* `-d` for detached mode
* `-v $(pwd)/html:/var/www/html` to map host `html` folder to container `/var/www/html`. `$(pwd)` because the host path must be absolute.
* `-p` to map 9001 host port to container 9000 port. PHP-FPM runs on port 9000 inside the container. If you need other FPMs to run, change `9001` with whatever free port.
* `--name fpm1` so we can easily pick that container when running commands.

### Debug

Handy commands for debugging

`sudo docker logs -f fpm1` to get the container logs.

`sudo docker exec -it fpm1 /bin/bash` to get bash inside the container.

### Apache

Enable some mods with `sudo a2enmod proxy proxy_fcgi` and `sudo systemctl restart apache2`

#### Virtual Host

Create a `fpm1.conf` in `/etc/apache2/sites-available`.

The important part is the `ProxyPassMatch` rule. It defines what process to execute the PHP files on.
* Notice the `9001` which is the port we chose when mapping the container port.
* `/var/www/html` is also important, it tels PHP-FPM where the file is located on its side. Apache2 and PHP-FPM must both have access to the files, but PHP-FPM has access to them through a mounted volume inside the docker container, which has a different path.

Of course the `DocumentRoot` path must be changed to match your path.

```
<<VirtualHost *:80>
    ServerName fpm1.local

    DocumentRoot /home/louwii/Dev/fpm/html

    ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9001/var/www/html/$1

    <Directory /home/louwii/Dev/fpm/html>
        Options -Indexes +FollowSymLinks +MultiViews
        AllowOverride All
        Require all granted
        DirectoryIndex index.php
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/fpm1-error.log
</VirtualHost>
```

Run `sudo a2ensite fpm1` and `sudo systemctl reload apache2`.

Add this line into your `/etc/hosts` file
```
127.0.0.1    fpm1.local
```

And then go to `http://fpm1.local/`