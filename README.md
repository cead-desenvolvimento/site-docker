## O que tem neste repositório?

- Configuração para três _containers_ que servirão o _site_ do CEAD
- Clonar em `/srv` para compatibilidade dos _scripts_

## Configurações para _deploy_ do site do CEAD

- Copiar para a pasta `database` o _dump_ do site, obrigatoriamente com o nome `site_cead.sql`
- Fazer com que o arquivo `/srv/site-docker/database/backup.sh`seja executável
- O _site_ (arquivos do Wordpress) precisam estar em `/srv/volumes/cead/wordpress`, com dono e grupo 33 (www-data)
- Criar o usuário de _backup_ conforme o _script_

## Cópia dos `.env`

Coloque `.env` na pasta `/srv/site-docker`. Veja exemplo em `.env.example`.

## Executar o _deploy_

```bash
cd /srv/site-docker
docker compose build
docker compose up -d
```

## Nome fixo da bridge Docker

A rede `site-cead-net` tem o nome de bridge fixado em `br-site-cead` via `driver_opts` no `docker-compose.yml`. Isso é necessário porque o _host_ Alpine usa nftables com regras de FORWARD explícitas referenciando esse nome — se o nome mudar (o que aconteceria se a rede fosse recriada sem essa opção), os _containers_ perdem acesso à internet.
