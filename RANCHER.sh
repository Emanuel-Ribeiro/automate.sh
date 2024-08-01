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
# Define os parametros do RANCHER.
# Argumentos:
#   Hostname e Senha de admin.
#############################################
function parametros_rancher(){
  read -p "Insira o Hostname do RANCHER: " hostRancher
  read -p "Insira a Senha do Admin do RANCHER: " senhaRancher

  export HOSTNAME_RANCHER=$hostRancher
  export SENHA_RANCHER=$senhaRancher
}

print_color "green" "---------------- INSTALANDO RANCHER ------------------"

# Definir os parametros do RANCHER
parametros_rancher

print_color "green" "Instalando HELM e adicionando repositorios..."
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo add jetstack https://charts.jetstack.io

print_color "green" "Instalando RANCHER via HELM..."
helm upgrade -i cert-manager jetstack/cert-manager -n cert-manager --create-namespace --set crds.enabled=true
helm upgrade -i rancher rancher-latest/rancher --create-namespace --namespace cattle-system --set hostname=$HOSTNAME_RANCHER --set bootstrapPassword=$SENHA_RANCHER --set replicas=1

print_color "green" "---------------- Instalacao do RANCHER - Finalizada ------------------"
