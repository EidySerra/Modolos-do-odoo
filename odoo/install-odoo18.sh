#!/bin/bash

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute como root!"
    exit 1
fi

# Verificar versão do Ubuntu
UBUNTU_VERSION=$(lsb_release -rs)
if [[ "$UBUNTU_VERSION" < "22.04" ]]; then
    echo "Este script requer Ubuntu 22.04 ou superior"
    exit 1
fi

# Configurações
ODOO_USER="odoo"
ODOO_HOME="/opt/odoo"
ODOO_CONF="/etc/odoo.conf"
LOG_FILE="/var/log/odoo/odoo-server.log"
ADMIN_PASS=$(openssl rand -base64 48 | tr -d '=+/' | cut -c1-32)
DB_PASSWORD=$(openssl rand -hex 24)

# Registrar senhas
echo "Senhas geradas:" > /root/odoo_credentials.txt
echo "Admin Password: $ADMIN_PASS" >> /root/odoo_credentials.txt
echo "Database Password: $DB_PASSWORD" >> /root/odoo_credentials.txt
chmod 600 /root/odoo_credentials.txt

# Atualizar sistema
echo "Atualizando sistema..."
apt update && apt upgrade -y

# Instalar dependências
echo "Instalando dependências..."
apt install -y python3-dev python3-venv python3-pip build-essential libssl-dev \
libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev libpq-dev \
libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev \
git curl nodejs npm postgresql libfreetype6-dev libffi-dev

# Configurar PostgreSQL
echo "Configurando PostgreSQL..."
sudo -u postgres psql -c "CREATE USER $ODOO_USER WITH PASSWORD '$DB_PASSWORD' SUPERUSER;"

# Criar usuário do sistema
echo "Criando usuário $ODOO_USER..."
adduser --system --quiet --shell /bin/bash --home $ODOO_HOME --group $ODOO_USER

# Baixar Odoo 18
echo "Baixando Odoo 18..."
cd /opt
git clone https://github.com/odoo/odoo.git --branch 18.0 --depth 1
chown -R $ODOO_USER:$ODOO_USER $ODOO_HOME

# Ambiente virtual
echo "Configurando ambiente virtual..."
sudo -u $ODOO_USER python3 -m venv $ODOO_HOME/odoo-env
source $ODOO_HOME/odoo-env/bin/activate

# Instalar dependências Python
echo "Instalando dependências Python..."
sudo -u $ODOO_USER pip install --upgrade pip setuptools wheel
sudo -u $ODOO_USER pip install wheel cython

# Instalação especial para gevent
sudo -u $ODOO_USER pip install gevent --only-binary :all:
sudo -u $ODOO_USER pip install --upgrade greenlet

# Instalar demais dependências
sudo -u $ODOO_USER pip install -r $ODOO_HOME/requirements.txt
deactivate

# Instalar wkhtmltopdf
echo "Instalando wkhtmltopdf..."
WKHTMLTOX_URL="https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb"
wget -q $WKHTMLTOX_URL -O /tmp/wkhtmltox.deb
apt install -y /tmp/wkhtmltox.deb
rm /tmp/wkhtmltox.deb

# Node.js e dependências
echo "Instalando Node.js dependencies..."
sudo -u $ODOO_USER npm install -g less less-plugin-clean-css

# Configurar diretórios
echo "Criando diretórios..."
mkdir -p $ODOO_HOME/custom/addons
mkdir -p /var/log/odoo
chown -R $ODOO_USER:$ODOO_USER /var/log/odoo
chown $ODOO_USER:$ODOO_USER $ODOO_HOME/custom/addons

# Criar arquivo de configuração
echo "Criando arquivo de configuração..."
cat > $ODOO_CONF << EOF
[options]
addons_path = $ODOO_HOME/addons,$ODOO_HOME/custom/addons
data_dir = $ODOO_HOME/.local/share/Odoo
admin_passwd = $ADMIN_PASS
db_host = localhost
db_port = 5432
db_user = $ODOO_USER
db_password = $DB_PASSWORD
logfile = $LOG_FILE
proxy_mode = True
without_demo = True
EOF

chown $ODOO_USER:$ODOO_USER $ODOO_CONF
chmod 640 $ODOO_CONF

# Configurar serviço systemd
echo "Criando serviço systemd..."
cat > /etc/systemd/system/odoo.service << EOF
[Unit]
Description=Odoo 18
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo
User=$ODOO_USER
Group=$ODOO_USER
ExecStart=$ODOO_HOME/odoo-env/bin/python3 $ODOO_HOME/odoo-bin -c $ODOO_CONF
WorkingDirectory=$ODOO_HOME
Restart=always
RestartSec=5
TimeoutStopSec=60
KillMode=process
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Configurar Fail2Ban
echo "Configurando Fail2Ban..."
apt install -y fail2ban

cat > /etc/fail2ban/jail.d/odoo.conf << EOF
[odoo]
enabled = true
port = 8069,8072
filter = odoo
logpath = $LOG_FILE
maxretry = 3
bantime = 3600
findtime = 600
ignoreip = 127.0.0.1
EOF

cat > /etc/fail2ban/filter.d/odoo.conf << EOF
[Definition]
failregex = ^ \d+ \d+ \S+ \S+ \d+ \d+ \S+ \S+ \S+ Login failed for db:\S+ login:\S+ from <HOST>
ignoreregex = 
EOF

systemctl restart fail2ban

# Iniciar serviço Odoo
echo "Iniciando Odoo..."
systemctl daemon-reload
systemctl enable odoo
systemctl start odoo

# Resumo da instalação
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo -e "\n\nInstalação completa!"
echo -e "Acesse o Odoo em: http://$IP_ADDRESS:8069"
echo -e "Senha de administrador: $ADMIN_PASS"
echo -e "Credenciais do banco de dados salvas em: /root/odoo_credentials.txt"
echo -e "\nFail2Ban configurado para proteger contra ataques de força bruta"
