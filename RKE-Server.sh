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

# Desabilitar o firewalld
print_color "green" "Desabilitando o firewalld... "
systemctl disable --now firewalld

print_color "green" "Atualizando os pacotes e instalando dependencias... "
yum update -y
yum install -y nfs-utils cryptsetup iscsi-initiator-utils tar
systemctl enable --now iscsid.service
yum update -y  
yum upgrade -y
yum -y clean all

# Verificar se o firewall está rodando
check_service_status firewalld

print_color "green" "---------------- Configuracao de pre requisitos - Finalizada ------------------"

print_color "green" "---------------- Configurando RKE2 SERVER ------------------"

# Instalar o RKE2
print_color "green" "Instalando RKE2-Server com Kubernetes 1.24..."
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.24 INSTALL_RKE2_TYPE=server sh -

print_color "green" "Iniciando RKE-Server..."
systemctl enable --now rke2-server.service
systemctl start rke2-server.service

# Verificar se o RKE está rodando
check_service_status rke2-server.service

print_color "green" "---------------- Configuracao do RKE2 AGENT - Finalizada ------------------"


print_color "green" "---------------- Configurando KUBECTL ------------------"

# Configurar o kubectl
print_color "green" "Criando link simbolico para o kubectl..."
ln -s $(find /var/lib/rancher/rke2/data/ -name kubectl) /usr/local/bin/kubectl
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml PATH=$PATH:/var/lib/rancher/rke2/bin

print_color "green" "Verificando se o node subiu..."
kubectl get node

print_color "green" "Armazenando token da master..."
touch /opt/node-token.txt
cat /var/lib/rancher/rke2/server/node-token >> /opt/node-token.txt

print_color "green" "---------------- Configuracao do RKE2 AGENT - Finalizada ------------------"
print_color "green" "---------------- TOKEN DISPONIVEL EM /opt/node-token.txt ------------------"
