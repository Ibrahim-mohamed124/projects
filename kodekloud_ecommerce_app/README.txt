This project provisions infrastructure and deploys the KodeKloud E-Commerce application using Ansible.
Note: While Terraform is typically better for infrastructure provisioning, this lab uses Ansible for educational purposes.
Note: This is only the first version for testing purposes. In the next version, I will add 
      more featuers like High Aviliablity, loadBalancing, using ansible valut to encrypt  
      secrets, and improve the automation process, making it production grade automation.

Prerequisites

    SSH Key Pair:
    Generate a key pair before provisioning:
    ssh-keygen -f keys_dir/KK_EC_APP_Key 


Infrastrcutrue:
    Variables in Input.yml file
        REGION: ""                     # AWS region (e.g., "us-east-1")
        VPC_CIDR_BLOCK: ""             # VPC CIDR block (e.g., "10.0.0.0/16")
        SUBNET_CIDR_BLOCKS:
        - CIDR: ""                   # Public subnet CIDR (e.g., "10.0.1.0/24")
            TAG: "web and app public subnet"  # !!! DO NOT CHANGE TAG !!!
        - CIDR: ""                   # Private subnet CIDR (e.g., "10.0.2.0/24")
            TAG: "database private subnet"    # !!! DO NOT CHANGE TAG !!!
        AMI: ""                        # AMI ID (e.g., "ami-0c55b159cbfafe1f0" for Amazon Linux 2)
        SSH_PORT: ""                   # SSH port (e.g., 22)
        MYSQL_PORT: ""                 # MySQL port (e.g., 3306)
        INSTANCE_TYPE: ""              # EC2 instance type (e.g., "t2.micro")

    Outputs:
        Public Ip of Basion Host
        Public and Private IPs of Web_app instance 
        Priate Ip of Database instance
Post-Provisioning Setup
    1-set ssh-agent using:
        eval $(ssh-agent -s)
        ssh-add keys_dir/KK_EC_APP_Key
    2-Update IPs in Configuration Files
        group_vars/*: Replace basion_host_ip with the Bastion host's public IP.
        roles/database/vars/main.yml: Update Web_App_ip.
        group_vars/tag_Name_WEB_APP.yml: Update db_ip.

Deployment:

    Variables in group_vars/*
        ansible_ssh_private_key_file: "keys_dir/KK_EC_APP_Key"  # Default key path
        ansible_ssh_common_args: '-o ProxyCommand="ssh -W %h:%p -q ec2-user@basion_host_ip"'  # Update Bastion IP
        db_ip: ""              # Database private IP 
        dbuser: ""             # Database username from roles/database/vars/main.yml
        dbpassword: ""         # Database password from roles/database/vars/main.yml
        dbname: ""             # Database name     from roles/database/vars/main.yml




 