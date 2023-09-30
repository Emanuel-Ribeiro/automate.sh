# Instruções para instalação da Stack do Elastic

Segue logo abaixo instruções para instalação do elastic, kibana, fleet, apm server e agents.

### 1. Instalar o ECS Operator

```sh
kubectl create namespace elastic-system
kubectl apply -f crds.yaml -n elastic-system
kubectl apply -f operator.yaml -n elastic-system
```

### 2. Instalar o Elastic com nodes master, ingest e data

```sh
kubectl apply -f elastic.yaml -n elastic-system
```

### 3. Instalar Kibana com credenciais

```sh
kubectl create secret generic kibana-secret-settings \
 --from-literal=xpack.security.encryptionKey=94d2263b1ead716ae228277049f19975aff864fb4fcfe419c95123c1e90938cd;

 kubectl apply -f kibana.yaml -n elastic-system
```

### 4. Instalar o Fleet Servcer

```sh
kubectl apply -f fleet-server.yaml -n elastic-system
```

# Pegar a senha que o elastic gerou para o usuario elastic

```sh
kubectl -n elastic-system get secret elastic-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'
```
