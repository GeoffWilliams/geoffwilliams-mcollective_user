#!/opt/puppetlabs/puppet/bin/ruby

# Above ruby is shipped with PE2015.  Change to suit your environment if needed
# or run directly with the `ruby` command

#
# Print the MCO server paths

require 'getoptlong'

def show_paths()
  if @machine == nil or @machine == ""
    @machine = %x{facter fqdn}.strip()
  end

  if @home_dir == nil or @home_dir == ""
    @home_dir = "/home/#{@user}"
  end

  mco_dir = "#{@home_dir}/.mcollective.d"
  pup_dir = "/etc/puppetlabs"
  pup_ssl = "#{pup_dir}/puppet/ssl"
  mco_ssl = "#{pup_dir}/mcollective/ssl"

  puts <<EOM
parameter
  local file
  puppet master file
========================================= 
\$external_ca_cert_pem,           
  #{mco_dir}/ca.cert.pem
  #{pup_dir}/mcollective/ssl/ca.cert.pem
\$external_mco_server_public_key
  #{mco_dir}/#{@server}-public.pem
  #{mco_ssl}/mcollective-public.pem
\$mcollective_user_private_key
  #{mco_dir}/#{@user}-private.pem
  #{pup_ssl}/private_keys/#{@user}.pem
\$mcollective_user_public_key
  #{mco_dir}/#{@user}-public.pem
  #{pup_ssl}/public_keys/#{@user}.pem
\$machine_cert
  #{mco_dir}/#{@machine}.cert.pem
  #{pup_ssl}/certs/#{@machine}.pem
\$machine_private_key
  #{mco_dir}/#{@machine}.private_key.pem
  #{pup_ssl}/private_keys/#{@machine}.pem"
EOM
end

def user(arg)
  puts "User files needed for #{arg}"
end

def show_usage()
  puts <<-EOF
mco_path.rb --server SERVER_NAME \
            --user MCO_USER \
            --machine [MACHINE_NAME] \
            --home_dir [HOME_DIR]

Lookup the files that we need to include from the external puppet master to 
talk to it's mcollective server and where they should be saved locally to setup
the mcollective client software. 

SERVER_NAME
  The hostname of the remote puppet master (mcollective server) to connect to

USER
  The mcollective/local unix system user

MACHINE_NAME
  The fqdn of *THIS* machine.  If omitted defaults to `facter fqdn`

HOME_DIR
  Home directory for local unix system user.  If omitted defaults to 
  `/home/MCO_USER`

EOF
  exit 1
end

def main()
  opts = GetoptLong.new(
    [ '--server',   '-l', GetoptLong::REQUIRED_ARGUMENT],
    [ '--machine',  '-p', GetoptLong::OPTIONAL_ARGUMENT],
    [ '--user',     '-a', GetoptLong::REQUIRED_ARGUMENT],
    [ '--home_dir', '-h', GetoptLong::OPTIONAL_ARGUMENT], 
  )

  opts.each do |opt,arg|
    case opt
    when '--help'
      show_usage()
    when '--server'
      @server = arg
    when '--machine'
      @machine = arg
    when '--user'
      @user = arg
    when '--home_dir'
      @home_dir = arg
    end
  end

  if @server == "" or @user == ""
    show_usage()
  else
    show_paths
  end
end

main()
