Instalar lib:

```sh
npm i nestjs-elastic-apm --save
```


Renomear .env para .env-dsv

```bash
ELASTIC_APM_SERVER_URL="http://ingest-apmelastic.saude.gov.br/"
ELASTIC_APM_SECRET_TOKEN=i264Adg7vM2o22TRoi34RBx8
ELASTIC_APM_ENVIRONMENT=prd
ELASTIC_APM_ACTIVE=false
```

Criar arquivo .env-prd

Adicionar as linhas:

```bash
ELASTIC_APM_SERVER_URL="http://ingest-apmelastic.saude.gov.br/"
ELASTIC_APM_SECRET_TOKEN=i264Adg7vM2o22TRoi34RBx8
ELASTIC_APM_ENVIRONMENT=prd
ELASTIC_APM_ACTIVE=true
```

No arquivo main.ts, na primeira linha, adicionar:

```js
import * as dotenv from 'dotenv';
dotenv.config({ path: `.env-${process.env.NODE_ENV}`, debug: true }); //
import apm from 'nestjs-elastic-apm';
```


No arquivo app.module.ts

```js
...
import { ApmModule } from 'nestjs-elastic-apm';
...
```

```js
@Module({
...
imports: [
...,
ApmModule.register(),
...
]
})
export class AppModule { }
```

```js
...
ConfigModule.forRoot({
    isGlobal: true,
    envFilePath: `.env-${process.env.NODE_ENV}` 
}),
...
```

No arquivo helm/values-prd.yaml:

```yaml
deployments:
  command: ["/bin/sh"]
  args: ["-c", "source /vault/secrets/config.env && export TZ=America/Sao_Paulo && npm run start:prd"]
```

No arquivo package.json adicionar o comando na sessão scripts:

```json
...
"start": "NODE_ENV=dsv nest start",
"start:prd": "NODE_ENV=prd nest start",
...
```
