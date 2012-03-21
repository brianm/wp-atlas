
natty_useast_i386_ebs = "ami-e358958a"
wp_url = "http://wordpress.org/wordpress-3.2.1.tar.gz"
mcp_url = "http://downloads.wordpress.org/plugin/memcached.2.0.1.zip"

environment "dev" do

  listener "progress-bars"
  listener "aws-config", ssh_ubuntu: "ubuntu@default"

  system "security" do
    server "blog-group", base: "blog-sec-group"
    server "blog-db-group", base: "rds-security-group"
  end

  base "blog-sec-group", {
    provisioner: ["ec2-security-group:blog", {
                    ssh_from_outside:   "tcp 22 0.0.0.0/0",
                    memcached_internal: "tcp 11211 blog"
                  }]
  }

  base "rds-security-group", {
    provisioner: "rds-security-group:blog-db?allow_blog=blog" 
  }

  base "load-balancer", {
    provisioner: ["elb:{base.fragment}", {
                    from_port: "{base.params.from}",
                    to_port: "{base.params.to}",
                    protocol: "http",
                    allow_group_blog: "blog"
                  }],
  }

  base "server", {
    provisioner: "ec2:#{natty_useast_i386_ebs}?instance_type=m1.small&security_group=blog",
    init: ["exec:sudo apt-get update", 
           "apt:emacs23-nox unzip build-essential"]
  }

  base "mysql", {
    provisioner: [ "rds", {
                     name: "{base.fragment}",
                     storage_size: "5",
                     instance_class: "db.m1.small",
                     engine: "MySQL",
                     username: "wp",
                     password: "wp",
                     security_group: "blog-db"
                   }],
    init: ["scratch:{base.fragment}=@"]
  }

  installer "lb-add", virtual: ["elb-add:{virtual.fragment}"]

  installer "memcached", 
             virtual: ["scratch:{virtual.fragment}=@", 
                       "apt:memcached", 
                       "file:memcached.conf > /etc/memcached.conf",
                       "exec: sudo service memcached restart"]

  installer "wordpress", 
            virtual: ["apt:apache2-mpm-prefork libapache2-mod-php5 php5-mysql emacs23-nox php-pear",
                      "exec: sudo rm /var/www/index.html",
                      "tgz:#{wp_url}?to=/var/www/&skiproot=wordpress",
                      "zip:#{mcp_url}?to=/var/www/wp-content/&skiproot=memcached",
                      "exec: yes | sudo pecl install memcache",
                      "exec: sudo sh -c \"echo 'extension=memcache.so' >> /etc/php5/apache2/php.ini\"",
                      "wait-for:{virtual.params.db}",
                      "erb: wp-config.php.erb > /var/www/wp-config.php?db={virtual.params.db}&cache={virtual.params.cache}",
                      "exec: sudo service apache2 restart"]

end
