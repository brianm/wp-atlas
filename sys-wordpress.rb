
wp_url = "http://wordpress.org/wordpress-3.2.1.tar.gz"

system "blog" do
  
  server "load-balancer", {
    base: "load-balancer:blog?from=80&to=80"
  }

  server "wordpress", {
    cardinality: 2,
    base: "apache-server",
    install: ["tgz:#{wp_url}?to=/var/www/&skiproot=wordpress",
              "file:wordpress/object-cache.php > /var/www/wp-content/object-cache.php",
              "exec: yes | sudo pecl install memcache",
              "exec: sudo echo 'extension=memcache.so' >> /etc/php5/apache2/php.ini",
              "wait-for:wordpress-db",
              "erb: wordpress/wp-config.php.erb > /var/www/wp-config.php",
              "exec: sudo service apache2 restart",
              "elb-add:blog"]
  }

  server "memcached", {
    cardinality: 2,
    base: "server",
    install: ["scratch:memcached=@", 
              "apt:memcached",
              "file:memcached/memcached.conf > /etc/memcached.conf",
              "exec: sudo service memcached restart"]
  }

  server "database", {
    base: "mysql:blog",
    install: "scratch:wordpress-db=@"
  }
end

