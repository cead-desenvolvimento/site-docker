## O que tem neste repositório?

-   Configuração para três _containers_ que servirão o _site_ do CEAD
-   Clonar em `/srv` para compatibilidade dos _scripts_

## Configurações para _deploy_ do site do CEAD

-   Copiar para a pasta `database` o _dump_ do site, obrigatoriamente com o nome `site_cead.sql`
-   Fazer com que o arquivo `/srv/site-docker/database/backup.sh`seja executável
-   O _site_ (arquivos do Wordpress) precisam estar em `/srv/volumes/cead/wordpress`, com dono e grupo 33 (www-data)
-   Criar o usuário de _backup_ conforme o _script_

## Cópia dos `.env`

Coloque `.env` na pasta `/srv/site-docker`. Exemplo do arquivo:

```conf
MYSQL_DATABASE=site_cead
MYSQL_USER=site_cead
MYSQL_PASSWORD=w8J=secreto
MYSQL_ROOT_PASSWORD=secreto

WORDPRESS_DB_HOST=db:3306
WORDPRESS_DB_NAME=${MYSQL_DATABASE}
WORDPRESS_DB_USER=${MYSQL_USER}
WORDPRESS_DB_PASSWORD=${MYSQL_PASSWORD}
```

## Executar o _deploy_

```bash
cd /srv/site-docker
docker compose build
docker compose up -d
```
