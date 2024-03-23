#!/bin/bash

############################################
# Imprime a mensagem em uma determinada cor.
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
# Verifica o status de um determinado serviço. Se não estiver ativo, sai do script.
# Argumentos:
#   Nome do serviço. ex: firewalld, kubelet
#######################################

function check_service_status(){
  service_is_active=$(systemctl is-active $1)

  if [ "$service_is_active" = "active" ]
  then
    print_color "green" "$1 está ativo e rodando"
  else
    print_color "red" "$1 não está ativo/rodando"
  fi
}

print_color "green" "---------------- Configurando pré-requisitos ------------------"

# Desabilitar o UFW (Uncomplicated Firewall)
print_color "green" "Desabilitando o UFW... "
systemctl disable --now ufw

print_color "green" "Atualizando os pacotes e instalando dependências... "
apt update
apt install nfs-common -y  
apt upgrade -y
apt autoremove -y

# Verificar se o UFW está rodando
check_service_status ufw

print_color "green" "---------------- Configuração de pré-requisitos - Finalizada ------------------"

print_color "green" "---------------- Configurando RKE2 Server ------------------"

# Instalar o RKE2
print_color "green" "Instalando RKE2-Server com Kubernetes 1.24..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.26 INSTALL_RKE2_TYPE=server sh -

print_color "green" "Iniciando RKE-Server..."
systemctl enable --now rke2-server.service
systemctl status rke2-server

# Verificar se o RKE está rodando
check_service_status rke2-server

print_color "green" "---------------- Configuração do RKE2 Server - Finalizada ------------------"

print_color "green" "---------------- Configurando Kubectl ------------------"

# Configurar o kubectl
print_color "green" "Criando link simbólico para o kubectl..."
ln -s $(find /var/lib/rancher/rke2/data/ -name kubectl) /usr/local/bin/kubectl
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml 

print_color "green" "Verificando se o nó subiu..."
kubectl get node

print_color "green" "Armazenando token da master..."
cat /var/lib/rancher/rke2/server/node-token
cat /var/lib/rancher/rke2/server/node-token > /opt/node-token.txt

print_color "green" "---------------- Configuração do Kubectl - Finalizada ------------------"
print_color "green" "---------------- TOKEN DISPONÍVEL EM /opt/node-token.txt ------------------"
