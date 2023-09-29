# Instruções para instalação da Stack do Elastic

Segue logo abaixo instruções para instalação do elastic, kibana, fleet, apm server e agents.

### 1. Instalar o ECS Operator

```sh
kubectl apply -f crds.yaml;
kubectl apply -f operator.yaml;
```

### 2. Instalar o Elastic com nodes master, ingest e data

```sh
kubectl apply -f elastic.yaml
```

### 3. Instalar Kibana com credenciais

```sh
kubectl create secret generic kibana-secret-settings \
 --from-literal=xpack.security.encryptionKey=94d2263b1ead716ae228277049f19975aff864fb4fcfe419c95123c1e90938cd;

 kubectl apply -f kibana.yaml;
```

### 4. Instalar o Feet Servcer

```sh
kubectl apply -f fleet-server.yaml;
```

### 5. Exportar métricas do cluster como CPU, Memória, Networking e logs

```sh
kubectl apply -f system-integration-export.yaml
```

# Get password elastic

```sh
kubectl get secret elastic-es-elastic-user -o go-template='{{.data.elastic | base64decode}}'
```

```sh
kubectl get secret/apm-server-elastic-apm-token -o go-template='{{index .data "secret-token" | base64decode}}'
```
