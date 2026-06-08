# main.tf - Infrastructure as Code avec Terraform (TP DevOps UCAD, Partie 3)
#
# Objectif : declarer une machine virtuelle AWS EC2 qui installe et demarre
# automatiquement le serveur web Nginx. Tout est decrit en code : on ne clique
# nulle part dans la console AWS.
#
# NB : ce fichier est un exemple pedagogique. Pour reellement creer la VM il
# faudrait un compte AWS et des identifiants configures (aws configure).

# ---------------------------------------------------------------------------
# 1. Le "provider" : sur quel cloud on travaille (ici AWS) et dans quelle region
# ---------------------------------------------------------------------------
provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------
# 2. La ressource : une instance EC2 (la machine virtuelle)
# ---------------------------------------------------------------------------
resource "aws_instance" "web" {
  # AMI = l'image systeme de depart (ici une image Linux dans us-east-1)
  ami           = "ami-0c55b159cbfafe1f0"
  # Type d'instance = taille de la machine (t2.micro = offre gratuite AWS)
  instance_type = "t2.micro"

  tags = {
    Name = "DevOps-Server"
  }

  # user_data : script execute automatiquement au premier demarrage de la VM.
  # Il installe Nginx et le lance => le serveur web est pret tout seul.
  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF
}

# ---------------------------------------------------------------------------
# 3. La sortie : afficher l'adresse IP publique une fois la VM creee
# ---------------------------------------------------------------------------
output "public_ip" {
  value = aws_instance.web.public_ip
}
