
natty_useast_i386_ebs = "ami-e358958a"

environment "ec2" do

  listener "progress-bars"

  listener "aws-config", {
    ssh_ubuntu: "ubuntu@default",
  }

  base "load-balancer", {
    provisioner: ["elb:{base.fragment}", {
                    from_port: "{base.params.from}",
                    to_port: "{base.params.to}",
                    protocol: "http"
                  }],
  }

  base "server", {
    provisioner: "ec2:#{natty_useast_i386_ebs}?instance_type=m1.small",
    init: ["exec:sudo apt-get update"]
  }

  base "apache-server", {
    inherit: "server",
    init: ["apt:apache2-mpm-prefork libapache2-mod-php5 php5-mysql emacs23-nox",
           "exec:sudo /etc/init.d/apache2 restart"]
  }

  base "mysql", {
    provisioner: [ "rds", {
                     name: "{base.fragment}",
                     storage_size: "5",
                     instance_class: "db.m1.small",
                     engine: "MySQL",
                     username: "wp",
                     password: "wp"
                   }]
  }

end
