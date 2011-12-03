
system "blog" do
  
  server "wordpress", {
    base: "apache-server",
    install: ["tgz:http://wordpress.org/wordpress-3.2.1.tar.gz?to=/var/www/&skiproot=wordpress",
              "wait-for:wordpress-db",
              "erb:wp-config.php.erb > /var/www/wp-config.php"]
  }

  server "database", {
    base: "mysql",
    install: "scratch:wordpress-db=@"
  }
end

