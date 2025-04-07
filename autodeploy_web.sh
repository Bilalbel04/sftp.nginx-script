#!/bin/bash

# Definir colores ANSI
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
MAGENTA='\e[35m'
CYAN='\e[36m'
BOLD='\e[1m'
RESET='\e[0m'

# Limpiar pantalla
clear

# Título llamativo
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${BOLD}${CYAN}🚀 SCRIPT DE CONFIGURACIÓN AUTOMÁTICA 🚀${RESET}"
echo -e "${BOLD}${CYAN}     🚀 AutoDeploy - By: Bily 🚀  ${RESET}"
echo -e "${MAGENTA}======================================${RESET}"
sleep 1

# Instalación de Nginx con animación
echo -e "\n${YELLOW}[⏳] Instalando Nginx...${RESET}"
sleep 1
if apt-get install nginx -y >/dev/null 2>/dev/null; then
    echo -e "${GREEN}[✅] Nginx instalado correctamente.${RESET}"
else
    echo -e "${RED}[❌] Error al instalar Nginx.${RESET}" >&2
    exit 1
fi
sleep 1
clear

# Solicitud de usuario con resaltado
echo -e "${MAGENTA}--------------------------------------${RESET}"
echo -e "${BOLD}${CYAN}🔹 Escribe un nombre de usuario:${RESET}"
read -p " > " user
echo -e "${MAGENTA}--------------------------------------${RESET}"

LOGS="/var/log/$user/install.log"
LOGSERROR="/var/log/$user/install.error.log"
mkdir -p "$(dirname "$LOGS")"

# Verificación de usuario
if id "$user" &>/dev/null; then
    echo -e "${RED}[❌] El usuario '$user' ya existe. Elige otro nombre.${RESET}"
    exit 1
fi

# Solicitar contraseña
echo -e "${BOLD}${CYAN}🔹 Escribe una contraseña para el usuario:${RESET}"
read -s -p " > " password
echo
echo -e "${MAGENTA}--------------------------------------${RESET}"

# Solicitar nombre de empresa
echo -e "${BOLD}${CYAN}🔹 Escribe el nombre de la empresa:${RESET}"
read -p " > " empresa

# Verificar si el grupo ya existe
while grep -q "^$empresa:" /etc/group; do
    echo -e "${RED}[❌] La empresa '$empresa' ya existe.${RESET}"
    read -p "Nuevo nombre de empresa: " empresa
done

groupadd "$empresa"

# Creación del usuario con efecto de espera
echo -e "${YELLOW}[⏳] Creando usuario...${RESET}"
sleep 1
useradd -G "$empresa" -s /sbin/nologin "$user" && \
echo "$user:$password" | chpasswd && \
echo -e "${GREEN}[✅] Usuario '$user' creado con éxito.${RESET}" || \
echo -e "${RED}[❌] Error al crear el usuario.${RESET}" >&2
sleep 1

# Preguntas adicionales
clear
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${BOLD}${CYAN}📋 CONFIGURACIÓN ADICIONAL 📋${RESET}"
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${BOLD}${CYAN}🔹 Escribe tu País (Iniciales 2):${RESET}"
read -p " > " country
echo -e "${BOLD}${CYAN}🔹 Marca tu Provincia:${RESET}"
read -p " > " provincia
echo -e "${BOLD}${CYAN}🔹 Marca tu Ciudad:${RESET}"
read -p " > " city
echo -e "${BOLD}${CYAN}🔹 Selecciona nombre de Dominio:${RESET}"
read -p " > " domain
echo -e "${BOLD}${CYAN}🔹 ¿Cuál es tu Correo Electrónico?:${RESET}"
read -p " > " correo

# Confirmación visual de los datos
clear
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${BOLD}${CYAN}⚡ INFORMACIÓN INGRESADA ⚡${RESET}"
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${GREEN}🌍 País:${RESET} $country"
echo -e "${GREEN}🏙  Provincia:${RESET} $provincia"
echo -e "${GREEN}🏘  Ciudad:${RESET} $city"
echo -e "${GREEN}🏢 Empresa:${RESET} $empresa"
echo -e "${GREEN}🌐 Dominio:${RESET} $domain"
echo -e "${GREEN}📧 Correo:${RESET} $correo"
echo -e "${MAGENTA}======================================${RESET}"

read -e -p "${CYAN}¿Es correcta esta información? [y/N]${RESET} " response
[[ "$response" =~ ^[Yy]$ ]] || exit

# Creación de directorios
mkdir -p /var/www/$empresa/html
chown root:$empresa /var/www/$empresa
chown :$empresa /var/www/$empresa/html
chmod 755 /var/www/$empresa/
chmod 775 /var/www/$empresa/html

# Generación de certificado SSL con efecto de espera
echo -e "${YELLOW}[⏳] Generando certificado SSL...${RESET}"
mkdir -p /etc/ssl/private /etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "/etc/ssl/private/$empresa.key" \
    -out "/etc/ssl/certs/$empresa.crt" \
    -subj "/C=$country/ST=$provincia/L=$city/O=$empresa/OU=$empresa/CN=$domain/emailAddress=$correo"

echo -e "${GREEN}[✅] Certificado SSL generado con éxito.${RESET}"
sleep 1

# Reinicio de servicios con efecto visual
echo -e "${YELLOW}[⏳] Reiniciando servicios...${RESET}"
systemctl restart nginx.service
systemctl restart ssh
echo -e "${GREEN}[✅] Servicios reiniciados correctamente.${RESET}"

# Mensaje final con efecto visual
clear
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${BOLD}${CYAN}🎉 INSTALACIÓN COMPLETA 🎉${RESET}"
echo -e "${MAGENTA}======================================${RESET}"
echo -e "${GREEN}🚀 Tu servidor está listo y funcionando.${RESET}"
echo -e "${CYAN}🔗 Accede a: https://$domain${RESET}"
echo -e "${YELLOW}⚠ Recuerda configurar tu DNS correctamente.${RESET}"
echo -e "${GREEN}🎉 ¡Disfruta de tu nuevo servidor! 🎉${RESET}"
echo -e "${MAGENTA}======================================${RESET}"
