# Instruções para do cluster Kubernetes

Segue logo abaixo instruções para instalação do Kubernetes(RKE2), Rancher e Longhorn.

### 1. Clonar o repositorio em todas as maquinas que vão fazer parte do cluster

```sh
sudo yum install -y git-all
git clone https://github.com/Emanuel-Ribeiro/automate.sh.git
```

### 2. Instalar o RKE-Server na Maquina que vai servir como Control-Plane

```sh
sudo chmod +x RKE-Server.sh
./RKE-Server.sh
```
Lembre-se de pegar o token que o script gera no path /opt/node-token.txt vamos precisar dele

### 3. Instalar o RKE-Agent nas Maquinas que vao servir como Worker

```sh
sudo chmod +x RKE-Agent.sh
./RKE-Agent.sh
```
Quando o script for executado ele vai lhe pedir o IP da master(control-plane) e o token que foi gerado

### 4. Instalar o Rancher pela maquina do control-plane

```sh
sudo chmod +x RANCHER.sh
./RANCHER.sh
```
Quando o script for executado ele vai lhe pedir o DNS que o rancher irá usar e para definir uma senha de admin

### 5. Instalar o LongHorn pela maquina do control-plane

```sh
sudo chmod +x LONGHORN.sh
./LONGHORN.sh
```