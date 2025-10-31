FROM mariadb:10.6

# Define o timezone
RUN cp /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && echo "America/Sao_Paulo" > /etc/timezone

# Copia o dump inicial do banco
COPY site_cead.sql /docker-entrypoint-initdb.d/
