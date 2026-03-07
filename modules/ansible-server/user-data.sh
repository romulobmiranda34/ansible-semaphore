#!/bin/bash

# Atualizar sistema
apt-get update
apt-get upgrade -y

# Instalar dependências
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    python3-pip \
    mysql-client \
    postgresql-client

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker azureuser

# Instalar Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Instalar Ansible
pip3 install ansible

# Criar diretório para Semaphore
mkdir -p /opt/semaphore
cd /opt/semaphore

# Criar docker-compose.yml para Semaphore
cat > docker-compose.yml <<EOF
version: '3'
services:
  mysql:
    image: mysql:8.0
    hostname: mysql
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
      MYSQL_DATABASE: semaphore
      MYSQL_USER: semaphore
      MYSQL_PASSWORD: semaphore
    volumes:
      - semaphore-mysql:/var/lib/mysql
    restart: unless-stopped

  semaphore:
    image: semaphoreui/semaphore:latest
    ports:
      - 3000:3000
    environment:
      SEMAPHORE_DB_USER: semaphore
      SEMAPHORE_DB_PASS: semaphore
      SEMAPHORE_DB_HOST: mysql
      SEMAPHORE_DB_PORT: 3306
      SEMAPHORE_DB: semaphore
      SEMAPHORE_PLAYBOOK_PATH: /tmp/semaphore/
      SEMAPHORE_ADMIN_PASSWORD: ${semaphore_admin_pass}
      SEMAPHORE_ADMIN_NAME: ${semaphore_admin_user}
      SEMAPHORE_ADMIN_EMAIL: ${semaphore_admin_email}
      SEMAPHORE_ADMIN: ${semaphore_admin_user}
      SEMAPHORE_ACCESS_KEY_ENCRYPTION: $(head -c32 /dev/urandom | base64)
    volumes:
      - semaphore-data:/var/lib/semaphore
      - /tmp/semaphore:/tmp/semaphore
    restart: unless-stopped
    depends_on:
      - mysql

volumes:
  semaphore-mysql:
  semaphore-data:
EOF

# Iniciar Semaphore
docker-compose up -d

# Criar diretório para playbooks
mkdir -p /tmp/semaphore

# Instalar Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Criar script de healthcheck
cat > /usr/local/bin/check-semaphore.sh <<'SCRIPT'
#!/bin/bash
if ! docker ps | grep -q semaphore; then
    cd /opt/semaphore && docker-compose up -d
fi
SCRIPT

chmod +x /usr/local/bin/check-semaphore.sh

# Adicionar ao cron para verificar a cada 5 minutos
(crontab -l 2>/dev/null; echo "*/5 * * * * /usr/local/bin/check-semaphore.sh") | crontab -

echo "Instalação concluída!"
