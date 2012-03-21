task :default => "build-atlas"

desc "build atlas at ../atlas"
task "build-atlas" do
  sh "cd ../atlas && rake package && cd - && cp ../atlas/target/atlas ."
end

desc "start system in ec2"
task :start do
  sh "./atlas update"
end

desc "start firing up ning in debug-and-wait-mode"
task :debug do
  sh "java -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005 -jar ./atlas converge"
end

desc "kill all ec2 instances"
task :killall do
  sh "ec2din | grep INSTANCE | cut -f 2 | xargs ec2kill"
  sh "rds-describe-db-instances | grep DBINSTANCE | grep available | awk '{print $2}' | xargs -I@ rds-delete-db-instance @ --skip-final-snapshot -f"
  sh "elb-describe-lbs --show-long --delimiter '|' | cut -f 2 -f 8 -d '|' | grep 'i-' | sed 's/|/ --instances /' | xargs elb-deregister-instances-from-lb"
  sh "sqlite3 .atlas/space.db \"delete from space where id like '/blog%'\""
  sh "sqlite3 .atlas/space.db \"delete from space where id like '/security%'\""
end
