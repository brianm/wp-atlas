
natty_useast_i386_ebs = "ami-e358958a"

dir = File.dirname __FILE__

environment "ec2" do

  listener "progress-bars"

  listener "aws-config", {
    ssh_ubuntu: "ubuntu@default",
  }

  base "server", {
    provisioner: "ec2:#{natty_useast_i386_ebs}?instance_type=m1.small",
    init: ["exec:sudo apt-get update"]
  }

  base "apache-server", {
    inherit: "server",
    init: ["apt:apache2-mpm-prefork libapache2-mod-php5 php5-mysql",
           "exec:sudo /etc/init.d/apache2 restart"]
  }

  base "mysql", {
    provisioner: [ "rds", {
                     :storage_size => 5,
                     :instance_class => "db.m1.small",
                     :engine => "MySQL",
                     :username => "wp",
                     :password => "wp"
                   }]
  }
end
