
wp_url = "http://wordpress.org/wordpress-3.2.1.tar.gz"
mcp_url = "http://downloads.wordpress.org/plugin/memcached.2.0.1.zip"

system "blog" do
  
  server "load-balancer", {
    base: "load-balancer:blog?from=80&to=80"
  }

  server "wordpress", {
    cardinality: 2,
    base: "apache-server",
    install: ["tgz:#{wp_url}?to=/var/www/&skiproot=wordpress",
              "zip:#{mcp_url}?to=/var/www/wp-content/&skiproot=memcached",
              "exec: yes | sudo pecl install memcache",
              "exec: sudo echo 'extension=memcache.so' >> /etc/php5/apache2/php.ini",
              "wait-for:wordpress-db",
              "erb: wp-config.php.erb > /var/www/wp-config.php",            
              "exec: sudo service apache2 restart",
              "elb-add:blog"]
  }

  server "memcached", {
    cardinality: 2,
    base: "server",
    install: ["scratch:memcached=@", 
              "apt:memcached",
              "file:memcached.conf > /etc/memcached.conf",
              "exec: sudo service memcached restart"]
  }

  server "database", {
    base: "mysql:blog",
    install: "scratch:wordpress-db=@"
  }
end

