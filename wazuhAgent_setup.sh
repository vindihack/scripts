#!/bin/bash

# Función para obtener la dirección IP del servidor Wazuh
function obtener_ip_wazuh() {
  # Color verde claro para el texto
  echo -e "\e[92mIntroduzca la dirección IP del servidor Wazuh:\e[0m"
  read -r ip_wazuh

  # Validación básica de la IP
  if [[ ! $ip_wazuh =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo -e "\e[31mError: La dirección IP no es válida.\e[0m"
    exit 1
  fi

  # Color verde claro para el texto
  echo -e "\e[92mLa dirección IP del servidor Wazuh es: $ip_wazuh\e[0m"
}

# Comprobación de privilegios
if [[ $EUID -ne 0 ]]; then
  echo -e "\e[91mEste script debe ejecutarse con privilegios de root.\e[0m"
  echo -e "\e[91mEjecute el comando con 'sudo' o 'su'.\e[0m"
  exit 1
fi

# Obtención de la IP del servidor Wazuh
obtener_ip_wazuh

# Importación de la clave GPG de Wazuh
echo -e "\e[33mImportando la clave GPG de Wazuh...\e[0m"
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring /usr/share/keyrings/wazuh.gpg > /dev/null 2>&1
chmod 644 /usr/share/keyrings/wazuh.gpg

# Adición del repositorio de Wazuh
echo -e "\e[33mAgregando el repositorio de Wazuh...\e[0m"
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list
apt-get update

# Animación mientras se instala el agente
echo -e "\e[33mInstalando el agente Wazuh...\e[0m"
for i in {1..10}; do
  echo -n "."
  sleep 0.5
done

# Instalación del agente Wazuh
WAZUH_MANAGER="$ip_wazuh" apt-get install -y wazuh-agent

# Habilitación e inicio del servicio Wazuh
echo -e "\e[33mHabilitando e iniciando el servicio Wazuh...\e[0m"
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent

# Eliminación del repositorio de Wazuh
echo -e "\e[33mEliminando el repositorio de Wazuh...\e[0m"
sed -i "s/^deb/#deb/" /etc/apt/sources.list.d/wazuh.list
apt-get update

# Desactivación de actualizaciones del agente (opcional)
echo -e "\e[33mDesactivando actualizaciones del agente (opcional)...\e[0m"
echo "wazuh-agent hold" | dpkg --set-selections

# Mensaje de éxito
echo -e "\e[92m**Agente de Wazuh instalado y apuntando a $ip_wazuh**\e[0m"

