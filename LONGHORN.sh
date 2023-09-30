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

print_color "green" "---------------- INSTALANDO LONGHORN ------------------"

print_color "green" "Adicionando repositorio HELM do LONGHORN..."
helm repo add longhorn https://charts.longhorn.io
helm repo update

print_color "green" "Instalando LONGHORN via HELM..."
helm upgrade -i longhorn longhorn/longhorn --namespace longhorn-system --create-namespace

print_color "green" "---------------- Instalacao do LONGHORN - Finalizada ------------------"
