#!/bin/bash
# Web Server Configuration Script

echo "=== Configurando Web Server ==="

# Actualizar sistema
yum update -y
yum install -y httpd curl wget

# Crear página HTML simple
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Server - Public Instance</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
        h1 { color: #333; }
        .info { background-color: #fff; padding: 15px; margin: 10px 0; }
        code { background-color: #ddd; padding: 5px; border-radius: 3px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Servidor Web - Instancia Pública</h1>
        <div class="info">
            <p><strong>Instance Name:</strong> ${instance_name}</p>
            <p><strong>Type:</strong> Servidor web público</p>
            <p><strong>Role:</strong> Recibe solicitudes HTTP/HTTPS desde internet</p>
        </div>
        <div class="info">
            <h3>Pruebas de Conectividad:</h3>
            <ul>
                <li>Este servidor puede comunicarse con servidores de aplicación</li>
                <li>Este servidor puede comunicarse con servidores de base de datos</li>
                <li>Este servidor NO puede recibir conexiones SSH desde internet (si está configurado)</li>
            </ul>
        </div>
    </div>
</body>
</html>
EOF

# Iniciar Apache
systemctl start httpd
systemctl enable httpd

# Instalar herramientas de diagnóstico
yum install -y nc nmap telnet

# Log
echo "Web Server ${instance_name} configurado correctamente" >> /var/log/user-data.log
