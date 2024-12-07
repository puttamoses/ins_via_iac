provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "dev" {
  ami           = "ami-0614680123427b75e" # Ensure this AMI is valid for ap-south-1
  instance_type = "t2.micro"
  key_name      = "appple" # Pre-existing AWS key pair name

  tags = {
    Name = "dev-ec2"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("appple.pem") # Ensure the file exists locally and is accessible
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "file.sh"               # Ensure the file exists in the Terraform directory
    destination = "/home/ec2-user/file.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/file.sh",
      "sudo /home/ec2-user/file.sh", # Run the script
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" # Output Jenkins admin password
    ]
  }
}

output "instance_public_ip" {
  value       = aws_instance.dev.public_ip
  description = "Public IP of the EC2 instance running Jenkins."
}