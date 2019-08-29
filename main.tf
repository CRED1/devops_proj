provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  #access_key = "${var.access_key}"
  #secret_key = "${var.secret_access_key}"

}
#--Key pairs
resource "aws_key_pair" "deployer" {
  key_name   = "deployer_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC3dKfVG5brtyZ4RL5L7pPdOoA5JpFe3CW41TTomUzX4jyznHm4266o+Ikd+EZdUqHbIvIU5Bw+ch/iTi/gJAzM4h0Bn7ZZIvEfK7G6nox2HPu5sFfNmu5UARXHDr0kvm5eht2TKYnbuRh9RW6eMVPgJXKhefYiIW8TTQHcN1BqetRUphFJZcIXeAhY5a5PPT6Fs9n3RsN5bqJP6D/7b/rzJMG4BZsI/P7clxzkk72pV+lO0VWVu2LoWDwAdQxn4hGCBxFllNRt23ONESxRiMfsVePneau6uVKaSsAhHQ2/7R/4Qh38HyUS/N2TnAvrpA7+lBqVoV75gqo8IIYmwqFiOuqO7pElVrTQjtjaqQh8hlq4wxaWW3rrEDxZCqR7J4W/65gUm9Vk73wDbl/8m0zaELTPV9Rt1XRvvczXW0ctES+zW213H+l+5zTXhjSjC1a+P07QeqbGp1zbjy+HnD8goljSMFL6KKStZdDQIYWYBNpmh8d3SvZFIgUeWUlQRf+YwhTw23+uCHp23oqyh9VKzMcccNgpBCbtXLftnq7tGY5gpXVqmmBF1L2zOagljXbGUbZtNWyvPzcaOzbDDngqmhubmWTQONxpEvpnY3UQAJt7LOult9gEPCaMF/9Qf5UxB8dqKkKg1IytKfkpcGloSOodDGW06XroKkIML9Dnbw== cred@box"

}


# Default vpc
resource "aws_default_vpc" "default" {}




#---Security group that give employee remote access
resource "aws_security_group" "employee_sg" {
  name        = "employee_sg"
  description = "Give employee remote access"


  #internal ports
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
  }

  #HTTP port allow
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #HTTPS port allow
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}"]

  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
#---Security group that provide  web access to customers
resource "aws_security_group" "customer_sg" {
  name        = "customer_sg"
  description = "Allow customers to access web server"
  #vpc_id      = "${aws_vpc.devproj_vpc.id}"

  #HTTP rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${aws_default_vpc.default.cidr_block}"]
  }

}

#---Bastian host
resource "aws_security_group" "bastian_sg" {
  name   = "bastian_host_sg"
  vpc_id = "${aws_default_vpc.default.id}"



  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #SSH port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.localip}", "${aws_default_vpc.default.cidr_block}"]
  }


  #HTTPS port allow
  egress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["${var.localip}", "${aws_default_vpc.default.cidr_block}"]
  }

}


#--Jump Machine
resource "aws_instance" "jump" {
  #ami = "ami-0b898040803850657"
  ami                         = "ami-02eac2c0129f6376b"
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  security_groups             = ["${aws_security_group.bastian_sg.name}"]
  associate_public_ip_address = true

  connection {
    type        = "ssh"
    user        = "centos"
    host        = coalesce(self.public_ip, self.private_ip)
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "~/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 400 ~/.ssh/id_rsa"
    ]
  }

  tags = {
    Name = "jump"
  }
}


#--Dev Machine
resource "aws_instance" "dev" {
  #ami = "ami-0b898040803850657"
  ami             = "ami-02eac2c0129f6376b"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.employee_sg.name]

  tags = {
    Name = "dev"
  }

}

#--Prod Machine
resource "aws_instance" "prod" {
  #ami = "ami-0b898040803850657"
  ami = "ami-02eac2c0129f6376b"

  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.customer_sg.name]

  tags = {
    Name = "prod"
  }

}


#--Jenkins Machine
resource "aws_instance" "jenkins" {
  #ami = "ami-0b898040803850657"
  ami             = "ami-02eac2c0129f6376b"
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.employee_sg.name]

  tags = {
    Name = "jenkins"
  }

}



resource "local_file" "ansible_resource" {
  content = <<EOF

Host 172.31.*
  ProxyCommand ssh -W %h:%p centos@${aws_instance.jump.public_ip}
  IdentityFile /home/cred/.ssh/id_rsa

Host ${aws_instance.jump.public_ip}
  User  centos
  ControlMaster auto
  ControlPath ./ansible/ansible-%%r@%h:%p
  ControlPersist 15m
  IdentityFile /home/cred/.ssh/id_rsa

EOF

  filename = "./ssh.cfg"

}

resource "local_file" "ansible_inventory" {
  content = <<EOF
[local]
localhost

[jump]
${aws_instance.jump.public_ip}

[jenkins]
${aws_instance.jenkins.private_ip}

[devops]
${aws_instance.dev.private_ip}
${aws_instance.prod.private_ip}
EOF

  filename = "./inventory"

}

resource "null_resource" "deploy_ansible" {
  depends_on = [aws_instance.jump, aws_instance.jenkins, aws_instance.dev, aws_instance.prod]


  provisioner "local-exec" {
    command = "ansible-playbook -i inventory jump.yml && ansible-playbook -i inventory jenkins.yml && ansible-playbook -i inventory devops.yml"

  }
}

output "jenkins_private_ip_addr" {
  value       = "${aws_instance.jenkins.private_ip}"
  description = "The private IP address of Jenkins VM"
}

# Output Dev VM private ip address
output "dev_private_ip_addr" {
  value       = "${aws_instance.dev.private_ip}"
  description = "The private IP address of Development VM"
}

# Output Prod VM private ip address
output "prod_private_ip_addr" {
  value       = "${aws_instance.prod.private_ip}"
  description = "The private IP address of Production VM"
}

#--------------VM Public IPs -------------------
# Output Jenkins VM public ip address
output "jenkins_pub_ip_addr" {
  value       = "${aws_instance.jenkins.public_ip}"
  description = "The public IP address of Jenkins VM"
}

# Output Dev VM public ip address
output "dev_pub_ip_addr" {
  value       = "${aws_instance.dev.public_ip}"
  description = "The public IP address of Development VM"
}

# Output Prod VM public ip address
output "prod_pub_ip_addr" {
  value       = "${aws_instance.prod.public_ip}"
  description = "The public IP address of Production VM"
}

# Output Jump VM public ip address
output "jump_pub_ip_addr" {
  value       = "${aws_instance.jump.public_ip}"
  description = "The public IP address of Jump VM"
}

