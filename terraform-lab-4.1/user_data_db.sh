#!/bin/bash
# Database Server Configuration Script

echo "=== Configurando Database Server ==="

# Actualizar sistema
yum update -y
yum install -y curl wget nc nmap telnet

# Instalar MariaDB (compatible con MySQL)
yum install -y mariadb-server

# Iniciar MariaDB
systemctl start mariadb
systemctl enable mariadb

# Configuración básica de base de datos
mysql -e "CREATE DATABASE IF NOT EXISTS lab_database;"
mysql -e "CREATE TABLE IF NOT EXISTS lab_database.servers (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), ip_address VARCHAR(15), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
mysql -e "INSERT INTO lab_database.servers (name, ip_address) VALUES ('Web-Server-1', '10.0.1.0');"
mysql -e "INSERT INTO lab_database.servers (name, ip_address) VALUES ('Web-Server-2', '10.0.2.0');"
mysql -e "INSERT INTO lab_database.servers (name, ip_address) VALUES ('App-Server-1', '10.0.10.0');"
mysql -e "INSERT INTO lab_database.servers (name, ip_address) VALUES ('App-Server-2', '10.0.11.0');"

# Crear usuario para la aplicación (solo acceso local)
mysql -e "CREATE USER IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'AppPassword123!';"
mysql -e "GRANT SELECT, INSERT, UPDATE, DELETE ON lab_database.* TO 'appuser'@'%';"
mysql -e "FLUSH PRIVILEGES;"

# Configuración de bind address para aceptar conexiones remotas
sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/my.cnf

# Reiniciar MariaDB para aplicar cambios
systemctl restart mariadb

# Crear un script de monitoreo
cat > /opt/db-monitor.sh << 'EOF'
#!/bin/bash
while true; do
    echo "=== Database Status ===" >> /var/log/db-monitor.log
    date >> /var/log/db-monitor.log
    mysql -e "SELECT COUNT(*) as 'Total Servers' FROM lab_database.servers;" >> /var/log/db-monitor.log
    sleep 300
done
EOF

chmod +x /opt/db-monitor.sh

# Log
echo "Database Server configurado correctamente" >> /var/log/user-data.log
echo "Base de datos 'lab_database' creada" >> /var/log/user-data.log
echo "Usuario 'appuser' creado con permisos de lectura/escritura" >> /var/log/user-data.log
