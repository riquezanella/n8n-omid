#!/bin/bash
set -e

# Criar diretório
mkdir -p ~/evolution && cd ~/evolution

# Criar os arquivos .env e docker-compose.yml para evolution
cat << EOF > .env
AUTHENTICATION_API_KEY=MINHA_CHAVE_SUPER_SECRETA_123
TZ=America/Sao_Paulo
DATABASE_ENABLED=true
DATABASE_PROVIDER=postgresql
DATABASE_CONNECTION_URI=postgresql://n8n:n8n_secure_password_123@postgres:5432/evolution_db
CACHE_REDIS_ENABLED=true
CACHE_REDIS_URI=redis://redis:6379/1
CACHE_REDIS_PREFIX_KEY=evolution
AUTHENTICATION_API_KEY=MINHA_CHAVE_SUPER_SECRETA_123
EOF

cat << EOF > docker-compose.yml
version: '3.9'
services:
  evolution-api:
    container_name: evolution_api
    image: atendai/evolution-api:v2.1.1
    restart: always
    ports:
      - "8080:8080"
    env_file:
      - .env
    volumes:
      - evolution_instances:/evolution/instances
    depends_on:
      - postgres
      - redis

  postgres:
    image: postgres:17
    restart: always
    environment:
      POSTGRES_USER: n8n
      POSTGRES_PASSWORD: n8n_secure_password_123
      POSTGRES_DB: evolution_db
    volumes:
      - evolution_db_storage:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h localhost -U n8n -d evolution_db"]
      interval: 5s
      timeout: 5s
      retries: 10

  redis:
    image: redis:7
    restart: always
    volumes:
      - redis_data:/data

volumes:
  evolution_instances:
  evolution_db_storage:
  redis_data:
EOF

# Iniciar
docker-compose up -d

# Verificar status
docker-compose ps


