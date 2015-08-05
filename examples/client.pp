mcollective_user::client { "r10k-deploy":
    local_user_name  => "git",
    local_user_dir   => "/home/git",
    activemq_brokers => [ "localhost" ],
}
