#!/bin/bash

# Especificacion ruta de LOGS
LOGS="/var/log/$user/$domain.log"
LOGSERROR="/var/log/$user/$domain.error.log"

# Limpieza terminal
clear

# Instalacion de servidor nginx
echo -e "Instalando servidor nginx"
apt-get install nginx -y >/dev/null 2>/dev/null
echo -e "Instalacion completada"
clear

echo -e "Escribe un nombre de Usuario"
read -p " >" user

if id "$user" &>> "$LOGS"; then
    echo "El usuario $user ya existe. Por favor, elija otro nombre." >> "$LOGSERROR"
    exit 1
        if [ $? -eq 0 ]; then
        echo "Usuario '$user' creado con éxito."
    else
        echo "Error al crear el usuario '$user'."
    fi
fi

echo -e " Escribe una contraseña para el Usuario"
read -s -p " >" password

echo -e " Escribe nombre de empresa"
read -p " >" empresa
if grep -q "^$empresa:" /etc/group; then
    echo "La empresa '$empresa' ya existe. Por favor, eliga otro nombre de empresa."
    
    # Solicita al usuario que ingrese un nuevo nombre de grupo
    read -p "Nuevo nombre de empresa: " nueva_empresa

    # Repite el proceso hasta que se ingrese un nombre de grupo válido
    while grep -q "^$nueva_empresa:" /etc/group; do
        echo "El grupo '$nueva_empresa' ya existe. Por favor, elige otro nombre de empresa."
        read -p "Nuevo nombre de empresa: " nueva_empresa
    done

    # Establece el nuevo nombre de grupo
    empresa="$nueva_empresa"
fi
groupadd $empresa
#Comprueba usuario
if id "$user" &>/dev/null; then
    echo "El usuario '$user' ya existe. Por favor, elige otro nombre de usuario."
else
    # Crea el usuario con el grupo y el shell deseado
    useradd -G "$empresa" -s /sbin/nologin "$user"

    # Verifica si la creación del usuario fue exitosa
    if [ $? -eq 0 ]; then
        echo "Usuario '$user' creado con éxito."

        # Establece la contraseña para el usuario
        echo "$user:$password" | chpasswd

        # Verifica si la configuración de la contraseña fue exitosa
        if [ $? -eq 0 ]; then
            echo "Contraseña configurada con éxito para el usuario '$user'."
        else
            echo "Error al configurar la contraseña para el usuario '$user'."
        fi
    else
        echo "Error al crear el usuario '$user'."
    fi
fi
# Limpieza de chat
clear

echo -e "Procesando..."


mkdir -p /var/www/user/$empresa/html
#Preguntas para instalacion personalizada

echo -e " Escribe tu Pais (Iniciales 2)"
read -p " >" country >>$LOGS 2>$LOGSERROR
echo -e " Marca tu Provincia?"
read -p " >" provincia >>$LOGS 2>$LOGSERROR
echo -e " Marca tu ciudad?"
read -p " >" city >>$LOGS 2>$LOGSERROR
echo -e " Seleccione nombre de dominio"
read -p " >" domain >>$LOGS 2>$LOGSERROR
echo -e " Cual es tu correo electronico?"
read -p " >" correo >>$LOGS 2>$LOGSERROR

clear

echo -e "Es esta informacion correcta?"
echo -e " $country"
echo -e " $provincia"
echo -e " $city"
echo -e " $empresa"
echo -e " $domain"
echo -e " $correo"

read -e -p "Estas seguro? [y/N]" response
case $response in
    [Yy]|[Yy][Ee][Ss])
    ;;
    [Nn]|[Nn][Oo])
        echo -e "Exiting"
        exit
    ;;
esac


# Creacion del  usuario grupo y Jaula
chown root:$empresa /var/www/user/$empresa
chown :$empresa /var/www/user/$empresa/html
chmod 755 /var/www/user/$empresa/
chmod 775 /var/www/user/$empresa/html

echo -e "
Match Group $empresa
    ChrootDirectory /var/www/user/$empresa
    X11Forwarding no
    AllowTCPForwarding no
    ForceCommand internal-sftp
" >> /etc/ssh/sshd_config

# Genera Certificado SSL autofirmado
# Crear un archivo de configuración de solicitud (CSR) basado en las variables
cat <<EOF > solicitud.conf
[ req ]
default_bits       = 2048
prompt             = no
default_md         = sha256
distinguished_name = dn

[ dn ]
C = $country
ST = $provincia
L = $city
O = $empresa
OU = $empresa
CN = $domain
emailAddress = $correo
EOF

# Ejecutar el comando OpenSSL con el archivo de configuración
 openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "/etc/ssl/private/$empresa.key" -out "/etc/ssl/certs/$empresa.crt" -config solicitud.conf

# Verificar si la generación del certificado fue exitosa
if [ $? -eq 0 ]; then
    echo "Certificado generado con éxito."
else
    echo "Error al generar el certificado."
fi
#Creando archivo de configuracion de servidor web
echo -e "server {
        listen 80;
        listen [::]:80;
        root /var/www/user/$empresa/html;
        index index.html index.htm index.nginx-debian.html;
        server_name $domain;
        return 302 https://$server_name$request_uri;
        location / {
                try_files $uri $uri/ =404;
        }
}

server {
        listen 443 ssl;
        listen [::]:443 ssl;
        ssl_certificate /etc/ssl/certs/$empresa.crt;
        ssl_certificate_key /etc/ssl/private/$empresa.key;
        server_name $domain;
        root /var/www/user/$empresa/html;
        index index.html index.htm index.nginx-debian.html;
}
" >> /etc/nginx/sites-available/$empresa.conf

# Ruta simbolica a sites-enabled
ln -s /etc/nginx/sites-available/$empresa.conf /etc/nginx/sites-enabled

# Creacion contenido index.html en $domain/html
echo -e "<html>
    <head>
        <title>Bienvenido a $domain</title>
    </head>
    <body>
        <h1>Parece que todo anda correcto!</h1>
        <h1> Este dominio pertenece a $domain </h1>
    </body>
</html>

" >> /var/www/user/$empresa/html/index.html
chown :$empresa /var/www/user/$empresa/html/index.html
chmod -R 775 /var/www/user/$empresa/html/index.html
systemctl restart nginx.service
systemctl restart ssh
