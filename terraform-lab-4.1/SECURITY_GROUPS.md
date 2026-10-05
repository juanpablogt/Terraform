# Explicación Detallada de Grupos de Seguridad

Este documento explica en profundidad los grupos de seguridad utilizados en el Laboratorio 4.1.

## 📌 Conceptos Básicos de Grupos de Seguridad

Un **Security Group** es un firewall virtual que controla el tráfico de entrada y salida para instancias EC2.

### Características Principales

- **Por defecto**: Rechaza TODO tráfico de entrada, permite TODO tráfico de salida
- **Basados en reglas**: Solo permiten lo que explícitamente especifiques
- **Asociados a instancias**: Una instancia puede tener múltiples SGs
- **Cubren IP src/dest y puertos**: Puedes especificar protocolos exactos

---

## 🌐 Grupo 1: Public-Web-SG (Servidores Web Públicos)

### Propósito
Proteger servidores web que DEBEN ser accesibles desde internet, pero solo en puertos específicos.

### Configuración

#### Reglas de ENTRADA (Ingress)

| Protocolo | Puerto | Origen | Descripción | Razón |
|-----------|--------|--------|-------------|-------|
| TCP | 22 | 0.0.0.0/0 | SSH desde cualquier lugar | Administración remota |
| TCP | 80 | 0.0.0.0/0 | HTTP desde cualquier lugar | Tráfico web normal |
| TCP | 443 | 0.0.0.0/0 | HTTPS desde cualquier lugar | Tráfico web seguro |

#### Código Terraform
```hcl
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Cualquier IP
  description = "SSH from anywhere"
}

ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Cualquier IP
  description = "HTTP from anywhere"
}

ingress {
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]  # Cualquier IP
  description = "HTTPS from anywhere"
}
```

#### Reglas de SALIDA (Egress)

| Protocolo | Puerto | Destino | Descripción |
|-----------|--------|---------|-------------|
| Todos (-1) | Todos | 0.0.0.0/0 | Tráfico saliente sin restricciones |

#### Código Terraform
```hcl
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"  # Todos los protocolos
  cidr_blocks = ["0.0.0.0/0"]
  description = "All outbound traffic"
}
```

### ¿Qué SÍ puede hacer?
✅ Recibir solicitudes HTTP desde internet  
✅ Recibir solicitudes HTTPS desde internet  
✅ Acceso SSH para administración  
✅ Conectarse a otros servidores en la VPC  

### ¿Qué NO puede hacer?
❌ Escuchar en otros puertos (ej: 8080, 3306)  
❌ Recibir tráfico que no sea TCP/80/443/22  

---

## 🛡️ Grupo 2: Private-App-SG (Servidores de Aplicación Privados)

### Propósito
Proteger servidores de aplicación en la red privada. Solo deben recibir conexiones de servidores web y de otros servidores de aplicación.

### Configuración

#### Reglas de ENTRADA (Ingress)

| Protocolo | Puerto | Origen | Descripción | Razón |
|-----------|--------|--------|-------------|-------|
| TCP | 8080 | Public-Web-SG | Puerto de aplicación desde web | Solo web servers |
| TCP | 0-65535 | Self | Comunicación interna | Entre app servers |

#### Código Terraform - Regla desde Web SG
```hcl
ingress {
  from_port       = 8080
  to_port         = 8080
  protocol        = "tcp"
  security_groups = [aws_security_group.public_web_sg.id]  # Referencia a otro SG
  description     = "App port from web servers"
}
```

#### Código Terraform - Comunicación Interna
```hcl
ingress {
  from_port = 0
  to_port   = 65535
  protocol  = "tcp"
  self      = true  # Desde el mismo SG
  description = "Internal app communication"
}
```

#### Reglas de SALIDA (Egress)

| Protocolo | Puerto | Destino | Descripción |
|-----------|--------|---------|-------------|
| Todos | Todos | 0.0.0.0/0 | Tráfico saliente sin restricciones |

### Características Especiales

**1. Origen = otro Security Group**
```hcl
security_groups = [aws_security_group.public_web_sg.id]
```
- Permite tráfico DESDE cualquier instancia con el SG especificado
- Más seguro que especificar IPs (que pueden cambiar)
- La IP de origen no importa, solo que tenga ese SG

**2. Self = true**
```hcl
self = true
```
- Permite comunicación entre instancias del mismo SG
- Útil para clustering, replicación, coordinación

### ¿Qué SÍ puede hacer?
✅ Recibir conexiones en puerto 8080 desde Web Servers  
✅ Comunicarse con otros App Servers (puerto 8080)  
✅ Iniciar conexiones salientes a cualquier lado  

### ¿Qué NO puede hacer?
❌ Escuchar en otros puertos  
❌ Recibir conexiones desde internet directamente  
❌ Recibir SSH (puerto 22) de internet  

---

## 🔐 Grupo 3: Private-DB-SG (Servidores de Base de Datos Privados)

### Propósito
Proteger la base de datos. Solo deben recibir conexiones de servidores web/app, nunca de internet.

### Configuración

#### Reglas de ENTRADA (Ingress)

| Protocolo | Puerto | Origen | Descripción | Razón |
|-----------|--------|--------|-------------|-------|
| TCP | 3306 | Public-Web-SG | MySQL desde web | App en web |
| TCP | 5432 | Public-Web-SG | PostgreSQL desde web | App en web |

#### Código Terraform - MySQL
```hcl
ingress {
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.public_web_sg.id]
  description     = "MySQL from web servers"
}
```

#### Código Terraform - PostgreSQL
```hcl
ingress {
  from_port       = 5432
  to_port         = 5432
  protocol        = "tcp"
  security_groups = [aws_security_group.public_web_sg.id]
  description     = "PostgreSQL from web servers"
}
```

#### Reglas de SALIDA (Egress)

| Protocolo | Puerto | Destino | Descripción |
|-----------|--------|---------|-------------|
| Todos | Todos | 0.0.0.0/0 | Tráfico saliente sin restricciones |

### Particularidades

**Puerto 3306 = MySQL/MariaDB/Aurora**
- Puerto estándar para bases de datos compatibles con MySQL
- Transporta comandos SQL y datos

**Puerto 5432 = PostgreSQL**
- Puerto estándar para PostgreSQL
- Alternativa a MySQL con características avanzadas

**Origen = Web SG**
- Solo Web Servers pueden conectarse
- App Servers NO pueden conectarse (excepto si tienen el mismo SG)

### ¿Qué SÍ puede hacer?
✅ Recibir conexiones MySQL desde Web Servers  
✅ Recibir conexiones PostgreSQL desde Web Servers  
✅ Enviar datos y respuestas de vuelta a Web Servers  

### ¿Qué NO puede hacer?
❌ Escuchar en otros puertos  
❌ Recibir conexiones desde internet  
❌ Recibir conexiones de App Servers (ni SSH)  
❌ Ser accesible desde afuera de la VPC  

---

## 🔄 Flujo de Comunicación Permitido

```
┌──────────────────────────────────────────────────────────┐
│ COMUNICACIÓN PERMITIDA (✅)                              │
├──────────────────────────────────────────────────────────┤
│ 1. Internet → Web Server:80   (HTTP)                    │
│ 2. Internet → Web Server:443  (HTTPS)                   │
│ 3. Internet → Web Server:22   (SSH)                     │
│ 4. Web Server → App Server:8080 (Aplicación)           │
│ 5. App Server → App Server:8080 (Replicación)          │
│ 6. Web Server → DB Server:3306 (MySQL)                 │
│ 7. Web Server → DB Server:5432 (PostgreSQL)            │
│ 8. (Todos) → Internet (salidas)                        │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│ COMUNICACIÓN BLOQUEADA (❌)                              │
├──────────────────────────────────────────────────────────┤
│ 1. Internet → App Server:8080 (Bloqueado por SG)       │
│ 2. Internet → DB Server:3306  (Sin IP pública)         │
│ 3. App Server → DB Server (Sin regla explícita)        │
│ 4. Internet → Web Server:8080 (Puerto no permitido)    │
│ 5. Cualquier → Cualquier en puertos no especificados   │
└──────────────────────────────────────────────────────────┘
```

---

## 🧪 Pruebas de Seguridad

### Prueba 1: Verificar que HTTP funciona
```bash
curl http://<web-server-public-ip>
# ✅ Debe responder
```

### Prueba 2: App Server no es accesible
```bash
curl http://<app-server-private-ip>:8080
# ❌ Debe fallar (timeout)
```

### Prueba 3: Desde Web Server, acceso a App
```bash
# SSH en Web Server
ssh ec2-user@<web-server-public-ip>

# Desde allá, conectar a App Server
curl http://<app-server-private-ip>:8080
# ✅ Debe funcionar
```

### Prueba 4: DB solo desde Web
```bash
# Desde Web Server
mysql -h <db-server-ip> -u appuser -p
# ✅ Debe funcionar

# Desde App Server
mysql -h <db-server-ip> -u appuser -p
# ❌ Debe fallar (si no está explícitamente permitido)
```

---

## 🔧 Modificaciones Comunes

### Si quieres permitir App → DB
```hcl
# Agregar a DB-SG
ingress {
  from_port       = 3306
  to_port         = 3306
  protocol        = "tcp"
  security_groups = [aws_security_group.private_app_sg.id]
  description     = "MySQL from app servers"
}
```

### Si quieres limitar SSH solo a una IP
```hcl
# En Web-SG, cambiar:
ingress {
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["203.0.113.0/32"]  # Tu IP
  description = "SSH from my IP"
}
```

### Si quieres HTTPS con certificado
```hcl
# Ya está permitido el 443 en Web-SG
# Solo configura certificado en el servidor
# Usa AWS Certificate Manager o Let's Encrypt
```

---

## 📊 Matriz de Conectividad

|  | Web Server | App Server | DB Server | Internet |
|---|------------|-----------|-----------|----------|
| **Web Server** | ✅ SSH(22) | ✅ 8080 | ✅ 3306/5432 | ✅ Outbound |
| **App Server** | ❌ - | ✅ 8080 | ❌ 3306 | ✅ Outbound |
| **DB Server** | ✅ inbound | ❌ - | ❌ - | ✅ Outbound |
| **Internet** | ✅ 80,443 | ❌ - | ❌ - | - |

---

## 💡 Mejores Prácticas Implementadas

1. **Principio de Menor Privilegio**: Solo los puertos necesarios están abiertos
2. **Separación de Capas**: Web/App/DB están aisladas
3. **Referencia de SG**: Se usan SGs en lugar de IPs para mayor flexibilidad
4. **Restricción de Salida**: Aunque permitimos todo outbound (típico), podría restringirse
5. **Documentación**: Cada regla tiene descripción clara

---

## 🚀 Pasos Siguientes

Para mejorar la seguridad aún más, considera:

1. **Network ACLs**: Firewall a nivel de subnet (más granular)
2. **WAF**: Web Application Firewall en frente de web servers
3. **VPN**: Acceso SSH seguro desde fuera
4. **Logging**: Registrar intentos de conexión en CloudWatch
5. **Auto-scaling**: Agregar/quitar instancias automáticamente

---

**Documento: Security Groups - Laboratorio 4.1 con Terraform**
