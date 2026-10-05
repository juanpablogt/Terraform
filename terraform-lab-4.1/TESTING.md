# Guía de Pruebas - Laboratorio 4.1

Esta guía te ayudará a verificar que la infraestructura de Terraform está funcionando correctamente y que los grupos de seguridad están protegiendo los recursos como se espera.

## 1. Verificación Inicial de Recursos

### Ver todos los recursos creados
```bash
terraform state list
```

### Ver detalles de la VPC
```bash
terraform output vpc_id
terraform output vpc_cidr
```

### Ver IPs de las instancias
```bash
terraform output web_server_1_public_ip
terraform output web_server_1_private_ip
terraform output app_server_1_private_ip
terraform output db_server_1_private_ip
```

## 2. Pruebas de Conectividad Web

### 2.1 Conectar a Web Server por HTTP
```bash
# Obtener la IP pública
WEB_IP=$(terraform output -raw web_server_1_public_ip)

# Probar acceso HTTP
curl http://$WEB_IP

# Ver encabezados
curl -I http://$WEB_IP
```

**Resultado esperado**: Debes ver una página HTML simple con información del servidor.

### 2.2 Conectar a Web Server por HTTPS
```bash
# Nota: El servidor no tiene certificado SSL, así que usamos -k
WEB_IP=$(terraform output -raw web_server_1_public_ip)
curl -k https://$WEB_IP 2>/dev/null || echo "HTTPS no configurado (normal)"
```

## 3. Pruebas de Grupos de Seguridad

### 3.1 Verificar que los SGs están correctamente configurados
```bash
# Ver detalles del SG público
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw web_security_group_id) \
  --region us-east-1

# Ver detalles del SG de aplicación
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw app_security_group_id) \
  --region us-east-1

# Ver detalles del SG de base de datos
aws ec2 describe-security-groups \
  --group-ids $(terraform output -raw db_security_group_id) \
  --region us-east-1
```

### 3.2 Prueba: App Server NO es accesible desde internet
```bash
# Obtener IP privada del app server
APP_IP=$(terraform output -raw app_server_1_private_ip)

# Intentar conectar desde internet (DEBE FALLAR)
curl http://$APP_IP:8080 --connect-timeout 3

# Resultado esperado: timeout o "Connection refused"
```

## 4. Pruebas de Comunicación Entre Capas

Para estas pruebas necesitas conectarte a una instancia y hacer pruebas desde allí.

### 4.1 Preparar acceso SSH (si tienes clave)
```bash
# Crear una clave (si no tienes)
aws ec2 create-key-pair --key-name lab-key --region us-east-1 > lab-key.pem
chmod 400 lab-key.pem

# Conectar al web server
WEB_IP=$(terraform output -raw web_server_1_public_ip)
ssh -i lab-key.pem ec2-user@$WEB_IP
```

### 4.2 Desde Web Server → App Server (DEBE FUNCIONAR)
```bash
# Una vez conectado al web server
APP_IP=10.0.10.x  # Reemplazar con IP real

# Probar conectividad
curl http://$APP_IP:8080 --connect-timeout 5
```

**Resultado esperado**: Recibes respuesta HTML del servidor de aplicación.

### 4.3 Desde Web Server → DB Server (DEBE FUNCIONAR)
```bash
# Una vez conectado al web server
DB_IP=10.0.10.x  # Reemplazar con IP real

# Instalar cliente MySQL
sudo yum install -y mysql

# Intentar conectar a la BD
mysql -h $DB_IP -u appuser -pAppPassword123! lab_database -e "SELECT * FROM servers;"
```

**Resultado esperado**: Ves la tabla de servidores registrados en la BD.

## 5. Pruebas de Restricción (Lo que NO debería funcionar)

### 5.1 No puedes acceder a App Server desde internet
```bash
# Esto debería FALLAR
APP_IP=$(terraform output -raw app_server_1_private_ip)
curl http://$APP_IP:8080 --connect-timeout 3 -v

# Resultado esperado: timeout o rechazo de conexión
```

### 5.2 Base de datos NO tiene IP pública
```bash
# Las instancias privadas no tienen IP pública asignada
terraform output | grep -i db

# Resultado esperado: solo se ve IP privada (10.0.x.x)
```

### 5.3 No puedes acceder a BD desde internet
```bash
# Esto debería FALLAR
mysql -h <DB-IP-PÚBLICA> -u appuser -p --connect-timeout 3

# Resultado esperado: no hay IP pública, conexión rechazada
```

## 6. Pruebas de Comunicación Interna

### 6.1 App Servers se comunican entre sí (DEBE FUNCIONAR)
```bash
# Conectar a app-server-1
# Luego probar conectividad a app-server-2
APP2_IP=10.0.11.x  # IP del segundo app server
nc -zv $APP2_IP 8080

# Resultado esperado: conexión exitosa
```

## 7. Verificación de Logs

### Ver logs de inicialización en instancias
```bash
# Para ver logs de user_data, conectarse a una instancia:
ssh -i lab-key.pem ec2-user@$WEB_IP
tail -f /var/log/user-data.log
```

## 8. Métricas de CloudWatch (Opcional)

### Ver tráfico de red
```bash
aws cloudwatch list-metrics \
  --namespace AWS/EC2 \
  --region us-east-1 | grep -i network
```

## 9. Casos de Prueba Resumidos

| Prueba | Origen | Destino | Puerto | Esperado | Resultado |
|--------|--------|---------|--------|----------|-----------|
| Web público | Internet | Web SG | 80 | ✅ Permite | |
| SSH en Web | Internet | Web SG | 22 | ✅ Permite | |
| App desde Web | Web SG | App SG | 8080 | ✅ Permite | |
| App desde Internet | Internet | App SG | 8080 | ❌ Rechaza | |
| BD desde Web | Web SG | DB SG | 3306 | ✅ Permite | |
| BD desde App | App SG | DB SG | 3306 | ❌ Rechaza | |
| BD desde Internet | Internet | DB SG | 3306 | ❌ Rechaza | |

## 10. Limpiar Recursos

Cuando termines las pruebas:

```bash
# Eliminar todos los recursos
terraform destroy

# O de forma más agresiva
terraform destroy -auto-approve

# Eliminar la clave si la creaste
aws ec2 delete-key-pair --key-name lab-key --region us-east-1
rm lab-key.pem
```

## 11. Troubleshooting de Pruebas

### Las instancias no responden
```bash
# Esperar 2-3 minutos después de crear
# Verificar estado
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Web-Server-1" \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].State'
```

### No puedo conectar por SSH
```bash
# Crear y asignar clave
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=Web-Server-1" \
  --region us-east-1 \
  --query 'Reservations[0].Instances[0].SecurityGroups'

# Verificar que el SG permite puerto 22
```

### Ports no responden
```bash
# Verificar que los servicios están corriendo en la instancia
ssh -i lab-key.pem ec2-user@$WEB_IP "sudo systemctl status httpd"
ssh -i lab-key.pem ec2-user@$APP_IP "sudo systemctl status app-server"
```

---

**Consejos Finales:**
- Ejecuta las pruebas en orden
- Documenta resultados en una tabla
- Cada prueba fallida puede indicar un problema en la configuración
- Revisa CloudWatch Logs si hay problemas
- Usa `terraform refresh` si los outputs se ven desactualizados
