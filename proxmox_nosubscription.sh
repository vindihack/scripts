#!/bin/bash

set -e

echo "[+] Comprobando y desactivando repositorios enterprise..."

# Desactiva repo PVE enterprise
PVE_ENTERPRISE="/etc/apt/sources.list.d/pve-enterprise.list"
if [ -f "$PVE_ENTERPRISE" ]; then
    sed -i 's/^deb/#deb/' "$PVE_ENTERPRISE"
    echo "  - Repo enterprise de Proxmox desactivado."
fi

# Añade repo no-subscription si no existe
if ! grep -q "pve-no-subscription" /etc/apt/sources.list; then
    echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" >> /etc/apt/sources.list
    echo "  - Repo no-subscription añadido a sources.list."
fi

# Gestiona repo Ceph
CEPH_REPO="/etc/apt/sources.list.d/ceph.list"
if [ -f "$CEPH_REPO" ]; then
    echo "  - Se encontró un repositorio Ceph enterprise."

    # Elimina el repo si no se usa Ceph
    read -p "¿Estás usando Ceph en este nodo? (s/N): " ceph_used
    ceph_used=${ceph_used,,}  # minúsculas

    if [[ "$ceph_used" != "s" ]]; then
        rm "$CEPH_REPO"
        echo "  - Repo Ceph enterprise eliminado."
    else
        sed -i 's/^deb/#deb/' "$CEPH_REPO"
        echo "deb http://download.proxmox.com/debian/ceph-quincy bookworm main" > "$CEPH_REPO"
        echo "  - Repo Ceph no-subscription configurado."
    fi
fi

# Actualizar repositorios
echo "[+] Ejecutando apt update..."
apt update

echo "[✓] Repositorios de no-suscripción configurados correctamente."
