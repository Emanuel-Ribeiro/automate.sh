#!/bin/bash

############################################
# Imprime uma mensagem em uma determinada cor.
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
# Define os parâmetros do RKE-Agent.
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
# Verifica o status de determinado serviço. Se não estiver ativo, sai do script.
# Argumentos:
#   Nome do serviço. ex: firewalld, kubelet
#######################################

function check_service_status(){
  service_is_active=$(systemctl is-active $1)

  if [ "$service_is_active" = "active" ]
  then
    echo "$1 está ativo e rodando"
  else
    echo "$1 não está ativo/rodando"
    exit 1
  fi
}

print_color "green" "---------------- Configurando pré-requisitos ------------------"

# Definir os parâmetros do RKE-Agent
parametros_agent

# Desabilitar o UFW (firewall)
print_color "green" "Desabilitando o UFW (firewall)... "
systemctl disable --now ufw

print_color "green" "Atualizando os pacotes e instalando dependências... "
sudo apt update -y
sudo apt install -y nfs-common cryptsetup open-iscsi
sudo systemctl enable --now open-iscsi
sudo apt upgrade -y
sudo apt autoremove -y

# Verificar se o UFW (firewall) está rodando
check_service_status ufw

print_color "green" "---------------- Configuração de pré-requisitos - Concluída ------------------"

print_color "green" "---------------- Configurando RKE2 AGENT ------------------"

# Instalar o RKE2
print_color "green" "Instalando RKE2-Agent com Kubernetes 1.24..."
curl -sfL https://get.rke2.io | sh -
mkdir -p /etc/rancher/rke2/

print_color "green" "Configurando o IP..."
echo "server: https://$SERVER_IP:9345" > /etc/rancher/rke2/config.yaml
echo "token: $TOKEN" >> /etc/rancher/rke2/config.yaml

print_color "green" "Iniciando RKE-Agent..."
sudo systemctl enable --now rke2-agent.service
sudo systemctl start rke2-agent.service

# Verificar se o RKE está rodando
check_service_status rke2-agent.service

cat /etc/rancher/rke2/config.yaml

print_color "green" "---------------- Configuração do RKE2 AGENT - Concluída ------------------"
