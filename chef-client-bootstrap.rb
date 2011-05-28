dep('bootstrap chef client'){
  setup {
    set :server_install, false
  }
  
  requires [
    'system',
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'gems.chef',
    'chef solo configuration.chef',
    'chef client bootstrap configuration.chef'
  ]
}

dep('chef client bootstrap configuration.chef') {
  require "rubygems"
  require "json"
  
  define_var(:chef_server_url, :default => "http://chef.example.com:4000", :message => "What is the URL of your main chef server?")
  
  met?{ File.exists?(chef_json_path) }
  meet {
    json = {
      "chef"=>{
        "server_fqdn"=> var(:chef_server_url), 
        "client_interval"=>1800
      },
      "recipes" => "chef::client"
    }.to_json
    
    shell("cat > '#{chef_json_path}'",
      :input => json,
      :sudo => false
    )
  }
}
