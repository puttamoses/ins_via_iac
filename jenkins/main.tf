provider "aws" {
  region = "ap-south-1"
}

resource "aws_key_pair" "example" {
  key_name   = "task" # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "dev" {
  ami           = "ami-0614680123427b75e" # Ensure this AMI is valid for the region and supports "ec2-user"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.example.key_name

  tags = {
    Name = "dev-ec2"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user" # Username for Amazon Linux
    private_key = file("~/.ssh/id_rsa") # Path to your private key
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "file.sh"               # Path to your local script
    destination = "/home/ec2-user/file.sh" # Remote path on the instance
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/file.sh",   # Make the script executable
      "sudo /home/ec2-user/file.sh",       # Execute the script
      "sudo systemctl start jenkins",      # Start Jenkins
      "sudo systemctl status jenkins",     # Check Jenkins status
      "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" # Retrieve Jenkins password
    ]
  }
}


output "instance_public_ip" {
  value       = aws_instance.dev.public_ip
  description = "Public IP of the EC2 instance running Jenkins."
}