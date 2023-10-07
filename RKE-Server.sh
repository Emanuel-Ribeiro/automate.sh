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
    echo "$1 está ativo e rodando"
  else
    echo "$1 não está ativo/rodando"
    exit 1
  fi
}

print_color "green" "---------------- Configurando pré-requisitos ------------------"

# Desabilitar o UFW (Uncomplicated Firewall)
print_color "green" "Desabilitando o UFW... "
systemctl disable --now ufw

print_color "green" "Atualizando os pacotes e instalando dependências... "
apt update
apt install -y nfs-common cryptsetup open-iscsi tar
systemctl enable --now open-iscsi
apt upgrade -y

# Verificar se o UFW está rodando
check_service_status ufw

print_color "green" "---------------- Configuração de pré-requisitos - Finalizada ------------------"

print_color "green" "---------------- Configurando RKE2 Server ------------------"

# Instalar o RKE2
print_color "green" "Instalando RKE2-Server com Kubernetes 1.24..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.24 INSTALL_RKE2_TYPE=server sh -

print_color "green" "Iniciando RKE-Server..."
systemctl enable --now rke2-server
systemctl start rke2-server

# Verificar se o RKE está rodando
check_service_status rke2-server

print_color "green" "---------------- Configuração do RKE2 Server - Finalizada ------------------"

print_color "green" "---------------- Configurando Kubectl ------------------"

# Configurar o kubectl
print_color "green" "Criando link simbólico para o kubectl..."
ln -s /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
echo 'export KUBECONFIG=/etc/rancher/rke2/rke2.yaml' >> ~/.bashrc
cp /etc/rancher/rke2/rke2.yaml ~/.kube/config

print_color "green" "Verificando se o nó subiu..."
kubectl get node

print_color "green" "Armazenando token da master..."
cat /var/lib/rancher/rke2/server/token > /opt/node-token.txt

print_color "green" "---------------- Configuração do Kubectl - Finalizada ------------------"
print_color "green" "---------------- TOKEN DISPONÍVEL EM /opt/node-token.txt ------------------"
