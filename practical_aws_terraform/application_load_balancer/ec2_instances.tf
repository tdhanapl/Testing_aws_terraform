#provider name and region 
provider "aws" {
  region     = "ap-south-1"
  
}
##creating the ec2-instance
resource "aws_instance" "test-terraform" {
  count = 2
  ami           = var.ami_image_id.redhat
  instance_type = var.instance_type[0]
  key_name               = var.key_pair
  associate_public_ip_address  = true
  availability_zone            = var.availability_zone.AZ1
  #instance_state               = "running"
  vpc_security_group_ids = [ "sg-0684a74fe71f043b5" ]
  #security_groups =  vpc-a-security-group
  subnet_id = var.public_subnet_id
  user_data = "${file("httpd.sh")}"
  tags = {
    Name = "var.tags-${count.index}"
  }
}

output "instance_private_ip_addr" {
  value = aws_instance.terraform.private_ip
}
output "instance_public_ip_addr" {
  value = aws_instance.terraform.public_ip
}
















