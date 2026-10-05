# Laboratorio 4.1: Protección de los Recursos de la VPC mediante Grupos de Seguridad - Terraform

Este proyecto implementa la arquitectura del Laboratorio 4.1 de AWS Academy usando Terraform, demostrando cómo usar grupos de seguridad para proteger recursos en una VPC.

## 📋 Descripción de la Infraestructura

La solución crea una VPC de 3 niveles con:

### Capas de Red

1. **Capa Pública (10.0.1.0/24 y 10.0.2.0/24)**
   - 2 Subnets públicas en diferentes AZs
   - Internet Gateway para acceso desde internet
   - NAT Gateway para que instancias privadas accedan a internet

2. **Capa de Aplicación (10.0.10.0/24 y 10.0.11.0/24)**
   - 2 Subnets privadas en diferentes AZs
   - 2 Servidores de aplicación

3. **Capa de Datos (10.0.10.0/24 y 10.0.11.0/24)**
   - 1 Servidor de base de datos privado

### Instancias EC2

| Nombre | Subnet | Tipo | IP Privada | Acceso Público |
|--------|--------|------|-----------|----------------|
| Web-Server-1 | Public-1 | t2.micro | 10.0.1.x | Sí |
| Web-Server-2 | Public-2 | t2.micro | 10.0.2.x | Sí |
| App-Server-1 | Private-1 | t2.micro | 10.0.10.x | No |
| App-Server-2 | Private-2 | t2.micro | 10.0.11.x | No |
| DB-Server-1 | Private-1 | t2.micro | 10.0.10.x | No |

### Grupos de Seguridad

#### 1. Public-Web-SG (Servidores Web Públicos)
**Reglas de Entrada (Ingress):**
- SSH (22): Desde 0.0.0.0/0 (cualquier lugar)
- HTTP (80): Desde 0.0.0.0/0 (cualquier lugar)
- HTTPS (443): Desde 0.0.0.0/0 (cualquier lugar)

**Reglas de Salida (Egress):**
- Todo el tráfico (0.0.0.0/0)

#### 2. Private-App-SG (Servidores de Aplicación Privados)
**Reglas de Entrada (Ingress):**
- Puerto 8080: Solo desde Public-Web-SG
- Comunicación interna (0-65535): Entre instancias con el mismo SG

**Reglas de Salida (Egress):**
- Todo el tráfico (0.0.0.0/0)

#### 3. Private-DB-SG (Servidores de Base de Datos Privados)
**Reglas de Entrada (Ingress):**
- MySQL (3306): Solo desde Public-Web-SG
- PostgreSQL (5432): Solo desde Public-Web-SG

**Reglas de Salida (Egress):**
- Todo el tráfico (0.0.0.0/0)

## 🚀 Cómo Usar

### Requisitos Previos

- Terraform >= 1.0
- AWS CLI configurado con credenciales válidas
- Cuenta de AWS con permisos suficientes

### Pasos de Instalación

1. **Clonar o descargar el proyecto**
```bash
cd /path/to/terraform-lab
```

2. **Inicializar Terraform**
```bash
terraform init
```

3. **Revisar el plan de ejecución**
```bash
terraform plan
```

Esto mostrará todos los recursos que serán creados.

4. **Aplicar la configuración**
```bash
terraform apply
```

Escribe `yes` cuando se te pida confirmación.

5. **Obtener los outputs**
```bash
terraform output
```

Esto mostrará IPs, IDs de seguridad, etc.

### Monitoreo de Recursos

Después de aplicar:

1. **Ver instancias en ejecución**
```bash
terraform state list
```

2. **Ver detalles específicos**
```bash
terraform state show 'aws_instance.web_server_1'
```

## 🧪 Pruebas de Conectividad

### 1. Acceso a Servidores Web (Públicos)

```bash
# Obtener IP pública del web server
WEB_IP=$(terraform output -raw web_server_1_public_ip)

# Probar conectividad HTTP
curl http://$WEB_IP

# Probar conectividad SSH
ssh -i /path/to/key.pem ec2-user@$WEB_IP
```

### 2. Comunicación Web → App

**Desde Web Server a App Server:**
```bash
# Una vez conectado al web server
curl http://10.0.10.x:8080  # Debe funcionar
```

### 3. Comunicación App → Base de Datos

**Desde App Server a DB Server:**
```bash
# Una vez conectado al app server
mysql -h 10.0.10.x -u appuser -p  # Debe funcionar
```

### 4. Pruebas de Restricción

**Intenta cosas que NO deberían funcionar:**

```bash
# Desde tu máquina local (NO debe conectar)
curl http://10.0.10.x:8080  # Falla - no es pública

# Acceso directo a BD desde internet (NO debe funcionar)
mysql -h <DB-PUBLIC-IP> -u appuser -p  # Falla - sin IP pública
```

## 📊 Diagrama de Seguridad

```
┌─────────────────────────────────────────────────────────────────┐
│ VPC: 10.0.0.0/16                                               │
│                                                                 │
│  ┌────────────────────────┬────────────────────────┐           │
│  │ Public Subnet 1        │ Public Subnet 2        │           │
│  │ 10.0.1.0/24           │ 10.0.2.0/24            │           │
│  │                        │                        │           │
│  │ ┌──────────────────┐   │ ┌──────────────────┐   │           │
│  │ │  Web Server 1    │   │ │  Web Server 2    │   │           │
│  │ │  (t2.micro)      │   │ │  (t2.micro)      │   │           │
│  │ │  10.0.1.x        │   │ │  10.0.2.x        │   │           │
│  │ │  [Public SG]     │   │ │  [Public SG]     │   │           │
│  │ └──────────────────┘   │ └──────────────────┘   │           │
│  └────────────────────────┴────────────────────────┘           │
│                     ↓↓ (Puerto 8080)                            │
│  ┌────────────────────────┬────────────────────────┐           │
│  │ Private Subnet 1       │ Private Subnet 2       │           │
│  │ 10.0.10.0/24          │ 10.0.11.0/24           │           │
│  │                        │                        │           │
│  │ ┌──────────────────┐   │ ┌──────────────────┐   │           │
│  │ │ App Server 1     │   │ │ App Server 2     │   │           │
│  │ │ (t2.micro)       │   │ │ (t2.micro)       │   │           │
│  │ │ 10.0.10.x        │   │ │ 10.0.11.x        │   │           │
│  │ │ [App SG]         │   │ │ [App SG]         │   │           │
│  │ └──────────────────┘   │ └──────────────────┘   │           │
│  │         ↓↓ (3306/5432)                          │           │
│  │ ┌──────────────────┐                            │           │
│  │ │ DB Server 1      │                            │           │
│  │ │ (t2.micro)       │                            │           │
│  │ │ 10.0.10.x        │                            │           │
│  │ │ [DB SG]          │                            │           │
│  │ └──────────────────┘                            │           │
│  └────────────────────────┬────────────────────────┘           │
│                                                                 │
│  [IGW] ← Internet Gateway                                       │
│  [NAT] ← NAT Gateway                                            │
└─────────────────────────────────────────────────────────────────┘
```

## 🧹 Limpieza

Para eliminar toda la infraestructura y detener los cargos:

```bash
terraform destroy
```

Escribe `yes` cuando se te pida confirmación.

## 📝 Archivos del Proyecto

```
├── main.tf                 # Configuración principal (VPC, SGs, Instancias)
├── variables.tf            # Definición de variables
├── outputs.tf              # Outputs (IPs, IDs)
├── terraform.tfvars        # Valores de variables
├── user_data_web.sh        # Script de configuración para web servers
├── user_data_app.sh        # Script de configuración para app servers
├── user_data_db.sh         # Script de configuración para db servers
└── README.md               # Este archivo
```

## 🔒 Conceptos de Seguridad Implementados

1. **Principio de Menor Privilegio**: Cada SG tiene permisos mínimos necesarios
2. **Segmentación de Red**: Subnets públicas y privadas separadas
3. **Acceso Restringido**: 
   - Servidores privados NO son accesibles desde internet
   - Comunicación entre capas está controlada
   - Base de datos solo recibe conexiones de servidores web/app
4. **NAT Gateway**: Permite que instancias privadas accedan a internet sin exponerse
5. **Múltiples AZs**: Alta disponibilidad con subnets en diferentes zonas

## 🐛 Troubleshooting

### Las instancias tardan en estar listas
- Las instancias tardan 2-3 minutos en ejecutar los scripts de inicialización
- Usa `aws ec2 describe-instances` para verificar el estado

### No puedo conectar al web server
- Verifica que tienes acceso SSH configurado
- Asegúrate de tener una clave privada válida
- Confirma el grupo de seguridad permite SSH (puerto 22)

### La base de datos no es accesible
- Verifica que la instancia está en la subnet privada
- Comprueba que está dentro del CIDR de la VPC
- Asegúrate que el SG permite conexiones MySQL (3306)

## 📚 Recursos Adicionales

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [AWS Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 📄 Licencia

Este proyecto es de ejemplo educativo para el Laboratorio 4.1 de AWS Academy.

---

**Creado con Terraform**
**Compatible con AWS Academy - Laboratorio 4.1**
