#!/bin/bash
#
# Automação de deploy de uma pagina web LAMP

############################################
# Printa a mensagem em uma determinada cor.
# Argumentos:
#   Cores. ex: green, red
#############################################
function print_color(){
  NC='\033[0m' # Sem cor

  case $1 in
    "green") COLOR='\033[0;32m' ;;
    "red") COLOR='\033[0;31m' ;;
    "*") COLOR='\033[0m' ;;
  esac

  echo -e "${COLOR} $2 ${NC}"
}

#######################################
# Confere os status de determinado serviço. Se não estiver ativo sai do script
# Argumentos:
#   Nome do serviço. ex: firewalld, mariadb
#######################################
function check_service_status(){
  service_is_active=$(sudo systemctl is-active $1)

  if [ $service_is_active = "active" ]
  then
    echo "$1 esta ativo e rodando"
  else
    echo "$1 nao esta ativo/rodando"
    exit 1
  fi
}

#######################################
# Confere as regras do firewalld. Se não estiver configurado sai do script.
# Argumentos:
#   Numero das portas. ex: 3306, 80
#######################################
function is_firewalld_rule_configured(){

  firewalld_ports=$(sudo firewall-cmd --list-all --zone=public | grep ports)

  if [[ $firewalld_ports == *$1* ]]
  then
    echo "FirewallD ta com a porta $1 configurada"
  else
    echo "FirewallD não está com a porta $1 configurada"
    exit 1
  fi
}

#######################################
# Verifica se dado item esta presente no output
# Argumentos:
#   1 - Output
#   2 - Item
#######################################
function check_item(){
  if [[ $1 = *$2* ]]
  then
    print_color "green" "Item $2 esta present na pagina web"
  else
    print_color "red" "Item $2 nao esta present na pagina web"
  fi
}

echo "---------------- Setup Database Server ------------------"

# Instalar e configurar o firewalld
print_color "green" "Instalando FirewallD... "
sudo yum install -y firewalld

print_color "green" "Instalando FirewallD... "
sudo service firewalld start
sudo systemctl enable firewalld

# Check FirewallD Service is running
check_service_status firewalld

# Install and configure Maria-DB
print_color "green" "Instalando MariaDB Server..."
sudo yum install -y mariadb-server

print_color "green" "Iniciando MariaDB Server..."
sudo service mariadb start
sudo systemctl enable mariadb

# Check FirewallD Service is running
check_service_status mariadb

# Configure Firewall rules for Database
print_color "green" "Configurando regras do FirewallD para o banco de dados..."
sudo firewall-cmd --permanent --zone=public --add-port=3306/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 3306


# Configuring Database
print_color "green" "Configurando o banco de dados..."
cat > setup-db.sql <<-EOF
  CREATE DATABASE ecomdb;
  CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword';
  GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost';
  FLUSH PRIVILEGES;
EOF

sudo mysql < setup-db.sql

# Loading inventory into Database
print_color "green" "Carregando dados de inventario no banco"
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Laptop","100","c-1.png"),("Drone","200","c-2.png"),("VR","300","c-3.png"),("Tablet","50","c-5.png"),("Watch","90","c-6.png"),("Phone Covers","20","c-7.png"),("Phone","80","c-8.png"),("Laptop","150","c-4.png");

EOF

sudo mysql < db-load-script.sql

mysql_db_results=$(sudo mysql -e "use ecomdb; select * from products;")

if [[ $mysql_db_results == *Laptop* ]]
then
  print_color "green" "Dados carregados no MySQl"
else
  print_color "red" "Falha ao carregar dados no MySQl"
  exit 1
fi


print_color "green" "---------------- Configuracao do Banco de dados - Finalizada ------------------"

print_color "green" "---------------- Configurando Web Server ------------------"

# Install web server packages
print_color "green" "Instalando pacotes do Web Server ..."
sudo yum install -y httpd php php-mysql

# Configure firewalld rules
print_color "green" "Configurando regras do FirewallD ..."
sudo firewall-cmd --permanent --zone=public --add-port=80/tcp
sudo firewall-cmd --reload

is_firewalld_rule_configured 80

# Update index.php
sudo sed -i 's/index.html/index.php/g' /etc/httpd/conf/httpd.conf

# Start httpd service
print_color "green" "Iniciando serviço httpd ..."
sudo service httpd start
sudo systemctl enable httpd

# Check FirewallD Service is running
check_service_status httpd

# Download code
print_color "green" "Instalando GIT.."
sudo yum install -y git
sudo git clone https://github.com/kodekloudhub/learning-app-ecommerce.git /var/www/html/

print_color "green" "Atualizando o index.php.."
sudo sed -i 's/172.20.1.101/localhost/g' /var/www/html/index.php

print_color "green" "---------------- Configuração do Web Server - Finalizada ------------------"

# Test Script
web_page=$(curl http://localhost)

for item in Laptop Drone VR Watch Phone
do
  check_item "$web_page" $item
done