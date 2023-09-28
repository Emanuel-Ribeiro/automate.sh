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
yum install -y nfs-utils cryptsetup iscsi-initiator-utils
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

print_color "green" "Verificando se o node subiu..."
kubectl get node

print_color "green" "Armazenando token da master..."
touch /opt/node-token.txt
cat /var/lib/rancher/rke2/server/node-token >> /opt/node-token.txt

print_color "green" "---------------- Configuracao do RKE2 AGENT - Finalizada ------------------"
print_color "green" "---------------- TOKEN DISPONIVEL EM /opt/node-token.txt ------------------"








-- SE PRECISAR DESINSTALAR!
/usr/local/bin/rke2-uninstall.sh

0) pre req
systemctl disable --now firewalld
yum update -y
yum install nfs-utils -y  
yum upgrade -y
yum autoremove -y

1)
curl -sfL https://get.rke2.io | INSTALL_RKE2_CHANNEL=v1.26 INSTALL_RKE2_TYPE=server sh -
2)
systemctl enable rke2-server.service
systemctl start rke2-server.service
systemctl status rke2-server
3)
ln -s $(find /var/lib/rancher/rke2/data/ -name kubectl) /usr/local/bin/kubectl
4)
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml 
5)
kubectl get node
6)
cat /var/lib/rancher/rke2/server/node-token

7)
mkdir -p /etc/rancher/rke2/
vi /etc/rancher/rke2/config.yaml
server: https://85.239.242.73:9345
token: TOKEN_GERADO_NA_ETAPA_6

8)
curl -#L https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io
9)
helm upgrade -i cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set installCRDs=true
helm upgrade -i rancher rancher-latest/rancher --create-namespace --namespace cattle-system --set hostname=rancher.dockr.life --set bootstrapPassword=6708fHYw064Xouz0V0L8 --set replicas=1
10)
sudo apt-get install -y open-iscsi
helm repo add longhorn https://charts.longhorn.io