# 🚀 Script de Configuración Automática

Este script en **Bash** automatiza la instalación de **Nginx**, la creación de un usuario y un grupo, la generación de un certificado SSL autofirmado y la configuración de un servidor web seguro.

## 📌 Características
- Instalación automática de **Nginx** 🖥️
- Creación de usuario y grupo con restricciones 🔒
- Configuración de **Chroot SFTP** para seguridad extra 🛡️
- Generación de certificado **SSL autofirmado** 🔑
- Creación de configuración para **Nginx** con HTTPS 🌍
- Mensajes coloridos en la terminal para una mejor experiencia 🖌️

## 📦 Requisitos
- **Sistema operativo:** Ubuntu/Debian
- **Permisos:** Debe ejecutarse como `root`

## 📜 Uso
```bash
### 1️⃣ Actualizacion del sistema
sudo apt update -y && sudo apt upgrade -y
```

### 2️⃣ Clonar el Repositorio
```bash
git clone git@github.com:Bilalbel04/sftp.nginx-script.git
cd sftp.nginx-script
```

### 3️⃣ Dar Permisos de Ejecución
```bash
chmod +x autodeploy_web.sh
```

### 4️⃣ Ejecutar el Script
```bash
./autodeploy_web.sh
```

---

## 🛠️ Configuración
Durante la ejecución, se te pedirá que ingreses:
- **Usuario** 👤
- **Contraseña** 🔑
- **Nombre de la empresa** 🏢
- **Ubicación geográfica** 🌍
- **Nombre de dominio** 🌐
- **Correo electrónico** 📧

## 🎨 Vista previa en Terminal
<img src="https://imgur.com/MR2RvT5" alt="Imagen Salida Terminal">

## 🔗 Conectarse al servidor
Una vez completada la instalación, puedes acceder a tu servidor con HTTPS:
```bash
https://tu-dominio.com
```

## 🔥 Autor

Creado por Bily ⚡

Si te gusta este proyecto, ¡dale una ⭐ en GitHub y sígueme para más herramientas útiles!

## 📄 Licencia
Este proyecto está bajo la licencia MIT. ¡Siéntete libre de usarlo y modificarlo a tu gusto! 😃

