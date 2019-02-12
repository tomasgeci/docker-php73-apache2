docker run --add-host=docker_host:your_docker_host_ip -it -v /your_local_www_folder:/var/www/web -v /your_local_log_folder:/var/log/apache2 -p your_local_port_for_reverse_proxy:80 -d php73
