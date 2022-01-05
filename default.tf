data "aws_vpc" "default" {
   default = true
 }

data "aws_subnet" "first" {
  vpc_id = data.aws_vpc.default.id
  cidr_block = "172.31.0.0/20" 

}

data "aws_security_group" "openall" {
   vpc_id = data.aws_vpc.default.id
   name = "openall"
 
}

resource "aws_instance" "instace" {
  ami           = "ami-0851b76e8b1bce90b" # us-west-2
  instance_type = "t2.micro"
  key_name = "ec2"
  vpc_security_group_ids = [data.aws_security_group.openall.id]
  subnet_id = data.aws_subnet.first.id
  tags = {
      Name = "ec2_instance"
  }
   connection {
      type          = "ssh"
      user          = "ubuntu"
      host          = aws_instance.instace.public_ip
      private_key   = file("ec2.pem")
    }
    provisioner "remote-exec" {
        inline = [
           "sudo apt update",
           "sudo apt install python3 -y"
        ]
    }

     provisioner "local-exec" {
        command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu -i '${aws_instance.instace.public_ip},' --private-key './ec2.pem' sample.yaml"
      
    }

    depends_on = [
      aws_instance.instace
    ]
  
}
