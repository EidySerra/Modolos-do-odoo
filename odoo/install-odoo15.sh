#!/bin/bash
set -e

# ==== CONFIGURAÇÕES ====
ODOO_VERSION="15.0"
ODOO_USER="odoo"
ODOO_HOME="/opt/$ODOO_USER"
ODOO_VENV="$ODOO_HOME/venv"
ODOO_PORT="8069"
ADMIN_PASSWD=$(openssl rand -base64 24) # Senha aleatória segura
TIMESTAMP=$(date +%Y%m%d_%H%M%S)       # Timestamp para backups

# ==== ATUALIZAR SISTEMA ====
echo "📦 Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# ==== DEPENDÊNCIAS ====
echo "📦 Instalando pacotes necessários..."
sudo apt install -y software-properties-common git wget curl \
    build-essential python3-pip python3-dev libxml2-dev libxslt1-dev \
    zlib1g-dev libsasl2-dev libldap2-dev libffi-dev libpq-dev \
    libjpeg-dev libpng-dev node-less libjpeg8-dev liblcms2-dev \
    libblas-dev libatlas-base-dev

# ==== PYTHON 3.9 ====
echo "🐍 Instalando Python 3.9..."
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install -y python3.9 python3.9-dev python3.9-venv

# ==== POSTGRESQL ====
echo "🗄 Verificando PostgreSQL..."
if ! systemctl is-active --quiet postgresql; then
    echo "🔁 Iniciando PostgreSQL..."
    sudo apt install -y postgresql postgresql-contrib
    sudo systemctl enable --now postgresql
fi

echo "👤 Configurando usuário PostgreSQL..."
sudo -u postgres psql -c "DO \$\$ BEGIN CREATE USER $ODOO_USER WITH SUPERUSER CREATEDB ENCRYPTED PASSWORD '$ADMIN_PASSWD'; EXCEPTION WHEN duplicate_object THEN RAISE NOTICE 'Usuário $ODOO_USER já existe'; END \$\$;" 2>/dev/null

# ==== USUÁRIO DO ODOO ====
echo "👤 Verificando usuário do sistema..."
if ! id "$ODOO_USER" &>/dev/null; then
    sudo useradd -m -d "$ODOO_HOME" -U -r -s /bin/bash "$ODOO_USER"
    echo "✅ Usuário $ODOO_USER criado"
else
    echo "ℹ️ Usuário $ODOO_USER já existe"
fi

# ==== DOWNLOAD ODOO ====
echo "⬇️ Configurando repositório Odoo..."
if [ -d "$ODOO_HOME/odoo" ]; then
    echo "⚠️ Diretório Odoo já existe. Fazendo backup..."
    sudo mv "$ODOO_HOME/odoo" "$ODOO_HOME/odoo_backup_$TIMESTAMP"
fi

echo "⬇️ Baixando Odoo $ODOO_VERSION..."
sudo -u "$ODOO_USER" git clone --depth 1 --branch "$ODOO_VERSION" \
    https://github.com/odoo/odoo.git "$ODOO_HOME/odoo"

# ==== wkhtmltopdf ====
echo "📦 Verificando wkhtmltopdf..."
if ! command -v wkhtmltopdf &> /dev/null; then
    echo "⬇️ Instalando wkhtmltopdf..."
    sudo apt install -y xfonts-base xfonts-75dpi
    wget -q https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb
    sudo dpkg -i wkhtmltox_0.12.6.1-2.jammy_amd64.deb
    sudo rm -f wkhtmltox_0.12.6.1-2.jammy_amd64.deb
else
    echo "ℹ️ wkhtmltopdf já instalado"
fi

# ==== VIRTUALENV ====
echo "🐍 Configurando ambiente virtual..."
if [ -d "$ODOO_VENV" ]; then
    echo "⚠️ Ambiente virtual já existe. Recriando..."
    sudo rm -rf "$ODOO_VENV"
fi

sudo -u "$ODOO_USER" python3.9 -m venv "$ODOO_VENV"
source "$ODOO_VENV/bin/activate"

# ==== DEPENDÊNCIAS PYTHON ====
echo "📦 Instalando dependências do Odoo..."
pip install --upgrade pip wheel
pip install -r "$ODOO_HOME/odoo/requirements.txt"

echo "🔧 Instalando dependências adicionais..."
pip install PyPDF2==1.27.12 pillow==9.0.1

# ==== CONFIG ODOO ====
echo "⚙️ Criando arquivo de configuração..."
sudo mkdir -p /etc/odoo
sudo tee /etc/odoo/odoo.conf > /dev/null <<EOF
[options]
admin_passwd = $ADMIN_PASSWD
db_host = localhost
db_port = 5432
db_user = $ODOO_USER
db_password = $ADMIN_PASSWD
xmlrpc_port = $ODOO_PORT
addons_path = $ODOO_HOME/odoo/addons
logfile = /var/log/odoo/odoo.log
EOF

sudo mkdir -p /var/log/odoo
sudo chown "$ODOO_USER":"$ODOO_USER" /var/log/odoo

# ==== SYSTEMD ====
echo "⚙️ Configurando serviço systemd..."
if [ -f "/etc/systemd/system/odoo.service" ]; then
    echo "ℹ️ Parando serviço existente..."
    sudo systemctl stop odoo || true
fi

sudo tee /etc/systemd/system/odoo.service > /dev/null <<EOF
[Unit]
Description=Odoo
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
User=$ODOO_USER
Group=$ODOO_USER
WorkingDirectory=$ODOO_HOME
Environment="PATH=$ODOO_VENV/bin:/usr/bin"
ExecStart=$ODOO_VENV/bin/python3 $ODOO_HOME/odoo/odoo-bin -c /etc/odoo/odoo.conf
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# ==== INICIAR ODOO ====
echo "🚀 Iniciando Odoo..."
sudo systemctl daemon-reload
sudo systemctl enable odoo
sudo systemctl restart odoo

# ==== VALIDAÇÃO FINAL ====
echo "⏳ Aguardando inicialização do Odoo..."
sleep 15

if ! systemctl is-active --quiet odoo; then
    echo "❌ Erro: Serviço Odoo não iniciou!"
    echo "📝 Últimos logs do serviço:"
    journalctl -u odoo -n 30 --no-pager
    echo "🔍 Verificando dependências..."
    sudo -u $ODOO_USER $ODOO_VENV/bin/python3 -c "import sys, pkg_resources; [print(pkg) for pkg in ['PyPDF2', 'psycopg2', 'pillow'] if pkg not in {pkg.key for pkg in pkg_resources.working_set}]"
    exit 1
fi

echo "✅ Instalação concluída com sucesso!"
echo "========================================================"
echo "🌐 URL de acesso: http://$(curl -s ifconfig.me):$ODOO_PORT"
echo "🔑 Senha admin: $ADMIN_PASSWD"
echo "🔒 Credenciais PostgreSQL:"
echo "   Usuário: $ODOO_USER"
echo "   Senha: $ADMIN_PASSWD"
echo "📁 Backup do Odoo anterior: $ODOO_HOME/odoo_backup_$TIMESTAMP"
echo "========================================================"
