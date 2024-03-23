# Instruções para do cluster Kubernetes

Segue logo abaixo instruções para instalação do Kubernetes(RKE2), Rancher e Longhorn.

### 1. Clonar o repositorio em todas as maquinas que vão fazer parte do cluster

```sh
sudo yum install -y git-all
git clone https://github.com/Emanuel-Ribeiro/automate.sh.git
```

### 2. Dar a permissão de execução no diretorio necessario e executar o script

```sh
sudo chmod +x -R ubuntu/
./ubuntu/RKE-Server.sh
```
Lembre-se de pegar o token que o script gera no path (cat /var/lib/rancher/rke2/server/node-token)

### 3. Instalar o Rancher pela maquina do control-plane

```sh
./ubuntu/RANCHER.sh
```
Quando o script for executado ele vai lhe pedir o DNS que o rancher irá usar e uma senha de admin

### 4. Configurar o clusterissuer (é necessario editar o os arquivos)

```sh
cd yamls
vim cloudflare-secret.yaml
kubectl create -f cloudflare-secret.yaml
vim clusterissuer.yaml
kubectl create -f clusterissuer.yaml
vim certificate.yaml
kubectl create -f certificate.yaml
kubectl edit ingress rancher -n cattle-system
```
Quando editar o ingress é só apontar para o certificado que criamos

### 4. Preparar o segundo (ou qualquer outro) node
  #### lembre-se de usar o seguinte formato quando pedir o IP no script 3master.sh (https://IpDaMaquina:9345)

```sh
git clone https://github.com/Emanuel-Ribeiro/automate.sh.git
cd automate.sh
chmod +x -R ubuntu
cd ubuntu
./3master.sh
```
Depois disso é só executar o ./ubuntu/RKE-Server.sh que um novo node será apresentado no rancher

### 5. Instalar o LongHorn pela primeira maquina

```sh
./ubuntu/LONGHORN.sh
```