# Computacao em Nuvem

Infraestrutura do laboratorio `Metabase na EC2 com RDS PostgreSQL e ALB`, baseada no PDF `docs/Lab_04-10_Metabase_EC2_RDS_ALB.pdf`.

## Arquitetura

O Terraform cria, em `us-east-1`:

- VPC default e subnets default existentes.
- Security groups com tag `Name`: `sg-alb`, `sg-metabase`, `sg-rds`.
- `sg-alb`: HTTP `80` publico.
- `sg-metabase`: HTTP `3000` somente do `sg-alb` e SSH `22` somente do seu IP.
- `sg-rds`: PostgreSQL `5432` somente do `sg-metabase`.
- RDS PostgreSQL `lab-metabase-db`, privado, `db.t3.micro`, 20 GB, banco inicial `metabase`.
- EC2 `ec2-metabase`, Amazon Linux 2023 ARM64, `t4g.small`, Docker e Compose.
- ALB `alb-metabase`, target group `tg-metabase`, health check `/api/health`.
- Metabase `metabase/metabase:v0.63.19.1` com estado no RDS.
- Banco `loja` com dados de exemplo e usuario `metabase_leitura` criado pelo seed.

Arquivos do lab mantidos em `docs/files/`:

- `docs/files/docker-compose.yml`: compose original do PDF para referencia/manual.
- `docs/files/seed-loja.sql`: seed usado automaticamente pela EC2.

Observacao: o AWS provider nao aceita nomes reais de security group iniciando com `sg-`. Por isso os nomes AWS sao `lab-metabase-alb`, `lab-metabase-ec2` e `lab-metabase-rds`, mantendo as tags `Name` exatamente como no PDF.

Observacao: o PDF usa `db.t4g.micro` e aceita `db.t3.micro` como alternativa. O default deste projeto usa `db.t3.micro` porque a criacao com `db.t4g.micro` falhou por falta de capacidade temporaria na AWS em `us-east-1`.

Tags padrao aplicadas pelo provider AWS:

```hcl
turma      = "turma3"
disciplina = "computacao em nuvem"
projeto    = "metabase-rds-alb"
ambiente   = "lab"
```

## Pre-requisitos

- Terraform instalado.
- AWS CLI/credenciais configuradas com permissao para S3, EC2, ELBv2 e RDS.
- Conta AWS em `us-east-1` com VPC default ativa.
- Seu IP publico em CIDR, exemplo `203.0.113.10/32`.

## Chave SSH

A chave dedicada do projeto foi criada em:

```sh
~/.ssh/lab-metabase-key
~/.ssh/lab-metabase-key.pub
```

Se precisar recriar:

```sh
ssh-keygen -t ed25519 -f ~/.ssh/lab-metabase-key -C lab-metabase
```

## State Remoto S3

O backend S3 precisa existir antes do Terraform principal. Primeiro suba o bootstrap:

```sh
cd bootstrap
terraform init
terraform apply
```

Copie o output `backend_config` para `../backend.hcl` ou use o exemplo:

```sh
cd ..
cp backend.hcl.example backend.hcl
```

Edite `backend.hcl` com o bucket criado. O arquivo e ignorado pelo git.

O backend usa `use_lockfile = true`, lock nativo do S3. DynamoDB nao e necessario.

## Variaveis

Crie o arquivo local:

```sh
cp terraform.tfvars.example terraform.tfvars
```

Preencha:

```hcl
my_ip_cidr       = "SEU_IP_PUBLICO/32"
ssh_public_key   = "CONTEUDO_DE_~/.ssh/lab-metabase-key.pub"
db_password      = "senha-forte-do-rds"
leitura_password = "senha-do-usuario-somente-leitura"
```

`terraform.tfvars` e ignorado pelo git.

Aviso: `db_password`, `leitura_password` e `user_data` ficam no Terraform state. Para lab isto e aceitavel; em producao use Secrets Manager/SSM e IAM.

## Subir Lab

```sh
terraform init -backend-config=backend.hcl
terraform fmt
terraform validate
terraform apply
```

Quando terminar, use os outputs:

```sh
terraform output metabase_url
terraform output ssh_command
terraform output rds_endpoint
```

O boot da EC2 instala Docker, instala Compose, grava os arquivos em `~/lab-metabase`, roda o seed uma vez e sobe o Metabase.

## Validacao

SSH:

```sh
ssh -i ~/.ssh/lab-metabase-key ec2-user@<ec2_public_ip>
```

Na EC2:

```sh
cd ~/lab-metabase
docker compose ps
curl -s localhost:3000/api/health
sudo journalctl -u metabase-lab.service -f
```

No navegador, acesse o output `metabase_url`.

Para conectar o Metabase ao banco de exemplo `loja`:

- Tipo: PostgreSQL.
- Host: output `rds_endpoint`.
- Porta: `5432`.
- Banco: `loja`.
- Usuario: `metabase_leitura`.
- Senha: valor de `leitura_password`.
- SSL: ligado, modo `require`.

## Limpeza

Destrua primeiro o lab principal:

```sh
terraform destroy
```

Depois, se nao precisar mais do state remoto:

```sh
cd bootstrap
terraform destroy
```

Nao apague a VPC default.
