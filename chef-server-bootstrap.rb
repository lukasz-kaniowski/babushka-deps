dep('bootstrap chef server with rubygems') {
  requires [
    'hostname',
    'ruby',
    'chef install dependencies.managed',
    'rubygems',
    'rubygems with no docs',
    'chef.gem',
    'ohai.gem'
  ]
}

dep('bootstrap chef') { requires 'bootstrap chef server with rubygems' }

dep('rubygems with no docs') {
  met? {
    File.exists?("/etc/gemrc") &&
    !sudo('cat /etc/gemrc').split("\n").grep(/(^gem:)/).empty?
  }
  
  meet {
    shell('echo "gem: --no-ri --no-rdoc" > /etc/gemrc', :sudo => true)
  }
}

dep('chef install dependencies.managed') {
  installs %w[irb build-essential wget ssl-cert]
  provides %w[wget make irb gcc]
}

dep('chef.gem'){
  installs 'chef ~> 0.9.16'
  provides 'chef-client'
}

dep('ohai.gem') {
  installs 'ohai'
}

dep('chef solo') {
  requires [
    'chef solo configuration',
    'chef bootstrap configuration'
  ]
  met? {
    false
  }
  meet {
    shell('chef-solo -c /etc/chef/solo.rb -j ~/chef.json -r http://s3.amazonaws.com/chef-solo/bootstrap-latest.tar.gz', :sudo => true)
  }
}

dep('chef solo configuration') {
  met?{ File.exists?("/etc/chef/solo.rb") }
  meet {
    shell("mkdir -p /etc/chef")
    render_erb 'chef/solo.rb.erb', :to => '/etc/chef/solo.rb', :perms => '755', :sudo => true
  }
}

dep('chef bootstrap configuration') {
  met?{ File.exists?("~/chef.json") }
  meet {
    render_erb 'chef/chef.json.erb', :to => '~/chef.json', :perms => '755', :sudo => false
  }
}