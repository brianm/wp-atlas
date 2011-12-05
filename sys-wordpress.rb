
wp_url = "http://wordpress.org/wordpress-3.2.1.tar.gz"

system "blog" do
  
  server "load-balancer", {
    base: "load-balancer:blog",
    members: "/*/wordpress.*",
  }

  server "wordpress", {
    cardinality: 2,
    base: "apache-server",
    install: ["tgz:#{wp_url}?to=/var/www/&skiproot=wordpress",
              "wait-for:wordpress-db",
              "erb:wp-config.php.erb > /var/www/wp-config.php"]
  }

  server "database", {
    base: "mysql:blog",
    install: "scratch:wordpress-db=@"
  }
end

