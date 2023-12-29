Este es un script echo en bash para un proyecto llamado DarkHosting. Automatiza los siguientes procesos:

-   ( Update* ) Instalacion o/y actualizacion servicio nginx
-   ( Update* ) Instalacion o/y actualizacion servicio OpenSSH Server
-   Automatizacion creacion de vhosts ( Dominios personalizados )
-   Automatizacion SSL autofirmado por cada dominio
-   Automatizacion jaula dentro la ruta html de tu sitio web
-   Automatizacion creacion de usuarios y contraseñas para cada cliente
-   Denegacion conectividad por SSH
-   Permite acceso SFTP.

Como usarlo paso por paso

Paso 1:
-   Primero deberemos instalar el paquete git, en varias distribuciones de linux no viene incluido.

        apt-get install get
Paso 2:
 -   Ahora deberemos instalar el script

        git clone https://github.com/Bilalbel04/sftp.nginx-script.git
