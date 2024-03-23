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
  read -p "Insira o IP da primeira master: " hostRancher
  read -p "Insira o token da primeira master: " senhaRancher

  export HOSTNAME_RANCHER=$hostRancher
  export SENHA_RANCHER=$senhaRancher
}

print_color "green" "---------------- CONFIGURANDO MASTER NODE ------------------"

# Definir os parametros do RANCHER
parametros_rancher

print_color "green" "Preparando ambiente"
mkdir -p /etc/rancher/rke2/
echo -e "server: $HOSTNAME_RANCHER\ntoken: $SENHA_RANCHER" > /etc/rancher/rke2/config.yaml

print_color "green" "---------------- Preparacao de node - Finalizada ------------------"
