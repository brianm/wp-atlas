
system "blog" do
  
  server "load-balancer", {
    base: "load-balancer:blog?from=80&to=80"
  }

  server "wordpress", {
    cardinality: 2,
    base: "server",
    install: ["wordpress:3.2.1?db=wpdb&cache=wp-cache", 
              "lb-add:blog"]
  }

  server "memcached", {
    cardinality: 2,
    base: "server",
    install: ["memcached:wp-cache"]
  }

  server "database", {
    base: "mysql:wpdb"
  }
end

