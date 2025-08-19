#!/bin/bash
set -e

# Criar diretório
mkdir -p ~/n8n && cd ~/n8n

# Criar os arquivos .env e docker-compose.yml para n8n
cat << EOF > .env
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n_secure_password_123
POSTGRES_DB=n8n
DB_TYPE=postgresdb
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=n8n_secure_password_123
DB_POSTGRESDB_SCHEMA=public
GENERIC_TIMEZONE=America/Sao_Paulo
TZ=America/Sao_Paulo
N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
N8N_RUNNERS_ENABLED=true
N8N_SECURE_COOKIE=false
N8N_HOST=0.0.0.0
EOF

cat << EOF > docker-compose.yml
version: '3.8'
volumes:
  db_storage:
  n8n_storage:
services:
  postgres:
    image: postgres:17
    restart: always
    environment:
      - POSTGRES_USER
      - POSTGRES_PASSWORD
      - POSTGRES_DB
    volumes:
      - db_storage:/var/lib/postgresql/data
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -h localhost -U ${POSTGRES_USER} -d ${POSTGRES_DB}']
      interval: 5s
      timeout: 5s
      retries: 10
  n8n:
    image: docker.n8n.io/n8nio/n8n
    restart: always
    environment:
      - DB_TYPE
      - DB_POSTGRESDB_DATABASE
      - DB_POSTGRESDB_HOST
      - DB_POSTGRESDB_PORT
      - DB_POSTGRESDB_USER
      - DB_POSTGRESDB_PASSWORD
      - GENERIC_TIMEZONE
      - N8N_SECURE_COOKIE
      - N8N_HOST
    ports:
      - 5678:5678
    links:
      - postgres
    volumes:
      - n8n_storage:/home/node/.n8n
    depends_on:
      postgres:
        condition: service_healthy
EOF

# Iniciar
docker-compose up -d

# Verificar status
docker-compose ps


