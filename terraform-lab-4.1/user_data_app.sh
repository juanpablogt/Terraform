#!/bin/bash
# Application Server Configuration Script

echo "=== Configurando Application Server ==="

# Actualizar sistema
yum update -y
yum install -y java-17-amazon-corretto-headless curl wget nc nmap telnet

# Crear un script de servidor simple en puerto 8080
cat > /opt/simple-app.py << 'EOF'
#!/usr/bin/env python3
import socket
import sys
import os

PORT = 8080

def get_instance_name():
    try:
        with open('/var/lib/instance-name', 'r') as f:
            return f.read().strip()
    except:
        return "unknown"

instance_name = os.environ.get('INSTANCE_NAME', get_instance_name())

def start_server():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_socket.bind(('0.0.0.0', PORT))
    server_socket.listen(5)
    print(f"Servidor de aplicación {instance_name} escuchando en puerto {PORT}")

    while True:
        try:
            client_socket, address = server_socket.accept()
            response = f"""HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<!DOCTYPE html>
<html>
<head>
    <title>Application Server</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 40px; }}
        .container {{ background-color: #f0f0f0; padding: 20px; border-radius: 5px; }}
        h1 {{ color: #333; }}
        .info {{ background-color: #fff; padding: 15px; margin: 10px 0; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Servidor de Aplicación - Instancia Privada</h1>
        <div class="info">
            <p><strong>Instance Name:</strong> {instance_name}</p>
            <p><strong>Port:</strong> {PORT}</p>
            <p><strong>Type:</strong> Servidor de aplicación privado</p>
            <p><strong>Client IP:</strong> {address[0]}</p>
        </div>
        <div class="info">
            <h3>Acceso:</h3>
            <ul>
                <li>Accesible solo desde servidores web</li>
                <li>No accesible desde internet directamente</li>
                <li>Puede comunicarse con servidores de BD</li>
            </ul>
        </div>
    </div>
</body>
</html>"""
            client_socket.sendall(response.encode())
            client_socket.close()
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"Error: {e}")

if __name__ == "__main__":
    start_server()
EOF

chmod +x /opt/simple-app.py

# Instalar Python 3
yum install -y python3

# Crear systemd service para la aplicación
cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=Simple Application Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /opt/simple-app.py
Restart=always
RestartSec=10
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Habilitar el servicio
systemctl daemon-reload
systemctl enable app-server.service
systemctl start app-server.service

# Log
echo "App Server configurado correctamente" >> /var/log/user-data.log
