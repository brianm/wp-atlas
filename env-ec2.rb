
natty_useast_i386_ebs = "ami-e358958a"

environment "ec2" do

  listener "progress-bars"

  listener "aws-config", {
    ssh_ubuntu: "ubuntu@default",
  }

  system "security" do
    service "blog-group", base: "blog-sec-group"
    service "blog-db-group", base: "rds-security-group:blog-db"
  end

  base "blog-sec-group", {
    provisioner: ["ec2-security-group:blog", {
                    ssh_from_outside:   "tcp 22 0.0.0.0/0",
                    memcached_internal: "tcp 11211 blog"
                  }]
  }

  base "rds-security-group", {
    provisioner: ["rds-security-group:{base.fragment}", {
                    allow_blog: "blog" 
                  }]
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
    init: ["exec:sudo apt-get update", "apt:emacs23-nox unzip build-essentials"]
  }

  base "apache-server", {
    inherit: "server",
    init: ["apt:apache2-mpm-prefork libapache2-mod-php5 php5-mysql emacs23-nox php-pear",
           "exec:sudo /etc/init.d/apache2 restart"]
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
                   }]
  }

end
