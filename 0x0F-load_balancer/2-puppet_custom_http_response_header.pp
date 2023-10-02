# 2-puppet_custom_http_response_header.pp

# Install Nginx package
package { 'nginx':
  ensure => installed,
}

# Ensure Nginx service is running and enabled
service { 'nginx':
  ensure  => running,
  enable  => true,
  require => Package['nginx'],
}

# Create a custom Nginx configuration file
file { '/etc/nginx/sites-available/custom_header':
  ensure  => file,
  content => "server {\n  listen 80;\n  server_name _;\n  location / {\n    add_header X-Served-By $hostname;\n    # Other Nginx configuration settings here\n  }\n}\n",
  require => Service['nginx'],
}

# Create a symbolic link to enable the custom configuration
file { '/etc/nginx/sites-enabled/custom_header':
  ensure  => link,
  target  => '/etc/nginx/sites-available/custom_header',
  require => File['/etc/nginx/sites-available/custom_header'],
  notify  => Service['nginx'],
}

# Remove the default Nginx default site configuration
file { '/etc/nginx/sites-enabled/default':
  ensure => absent,
  notify => Service['nginx'],
}

# Reload Nginx to apply changes
exec { 'nginx-reload':
  command     => '/usr/sbin/nginx -s reload',
  refreshonly => true,
  subscribe   => [File['/etc/nginx/sites-enabled/custom_header'], File['/etc/nginx/sites-enabled/default']],
}
