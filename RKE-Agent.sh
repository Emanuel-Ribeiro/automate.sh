#!/bin/bash

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

############################################
# Define os parametros do RKE-Agent.
# Argumentos:
#   IP e token.
#############################################
function parametros_agent(){
  read -p "Insira o IP do RKE-Server: " ipServer
  read -p "Insira o Token do RKE-Server: " tokenServer

  export SERVER_IP=$ipServer
  export TOKEN=$tokenServer
}

#######################################
# Confere os status de determinado serviço. Se não estiver ativo sai do script
# Argumentos:
#   Nome do serviço. ex: firewalld, kubelet
#######################################

function check_service_status(){
  service_is_active=$(sudo systemctl is-active $1)

  if [ $service_is_active = "active" ]
  then
    echo "$1 esta ativo e rodando"
  else
    echo "$1 nao esta ativo/rodando"
  fi
}

print_color "green" "---------------- Configurando pre requisitos ------------------"

# Definir os parametros do RKE-Agent
parametros_agent

# Desabilitar o firewalld
print_color "green" "Desabilitando o firewalld... "
systemctl disable --now firewalld

print_color "green" "Atualizando os pacotes e instalando dependencias... "
yum update -y
yum install -y nfs-utils cryptsetup iscsi-initiator-utils
systemctl enable --now iscsid.service
yum update -y  
yum upgrade -y
yum -y clean all

# Verificar se o firewall está rodando
check_service_status firewalld

print_color "green" "---------------- Configuracao de pre requisitos - Finalizada ------------------"

print_color "green" "---------------- Configurando RKE2 AGENT ------------------"

# Instalar o RKE2
print_color "green" "Instalando RKE2-Agent com Kubernetes 1.24..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.24 INSTALL_RKE2_TYPE=agent sh -
mkdir -p /etc/rancher/rke2/

print_color "green" "Configurando o IP..."
echo "server: https://$SERVER_IP:9345" > /etc/rancher/rke2/config.yaml
echo "token: $TOKEN" >> /etc/rancher/rke2/config.yaml

print_color "green" "Iniciando RKE-Agent..."
systemctl enable --now rke2-agent.service
systemctl start rke2-agent.service

# Verificar se o RKE está rodando
check_service_status rke2-agent.service

cat /etc/rancher/rke2/config.yaml

print_color "green" "---------------- Configuracao do RKE2 AGENT - Finalizada ------------------"
