#!/usr/bin/env bash

set -euo pipefail

if ! command -v apt-get >/dev/null 2>&1; then
  echo "Este script foi feito para distribuicoes Debian/Ubuntu com apt." >&2
  exit 1
fi

if [ "$(id -u)" -eq 0 ]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "Instalando dependencias..."
$SUDO apt-get update
$SUDO apt-get install -y gnupg software-properties-common wget lsb-release

echo "Adicionando a chave GPG oficial da HashiCorp..."
wget -O - https://apt.releases.hashicorp.com/gpg \
  | $SUDO gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

ARCH="$(dpkg --print-architecture)"
CODENAME="$(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || true)"

if [ -z "$CODENAME" ]; then
  CODENAME="$(lsb_release -cs)"
fi

echo "Adicionando o repositorio oficial da HashiCorp..."
echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com ${CODENAME} main" \
  | $SUDO tee /etc/apt/sources.list.d/hashicorp.list >/dev/null

echo "Instalando Terraform..."
$SUDO apt-get update
$SUDO apt-get install -y terraform

echo
echo "Terraform instalado com sucesso:"
terraform version
