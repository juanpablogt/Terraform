# Arquitectura Cloud en AWS con Terraform

Este proyecto de Terraform crea una arquitectura completa en AWS similar a tu arquitectura on-premise actual, pero escalable y completamente manejada en la nube.

## 📋 Qué incluye

### Compute
- **4 EC2 Instances** (Ubuntu 22.04, t3.micro):
  - `power-bi-server` - Para análisis de datos
  - `email-server` - Para envío de correos
  - `llama-container` - Para contenedores LLM
  - `web-moodle` - Para aplicación web Moodle

### Database
- **RDS PostgreSQL** (db.t3.micro, 20GB):
  - Base de datos `moodle` para Moodle
  - Backup automático (7 días)
  - Multi-AZ listo para producción

### Storage
- **S3 Bucket** para backups:
  - Versionado habilitado
  - Encriptación por defecto
  - Acceso público bloqueado

### Networking
- **VPC** (10.0.0.0/16):
  - 3 subnets públicas
  - 3 subnets privadas
  - Internet Gateway
  - Route Tables configuradas

### Seguridad
- **Security Groups**:
  - EC2: SSH (22), HTTP (80), HTTPS (443)
  - RDS: PostgreSQL (5432) solo desde EC2

## 🚀 Instrucciones de uso

### Prerrequisitos

1. **Terraform instalado** (versión ≥ 1.0)
   ```bash
   terraform --version
   ```
   Descarga desde: https://www.terraform.io/downloads

2. **AWS CLI configurado**
   ```bash
   aws configure
   ```
   Necesitas:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Región por defecto (ej: us-east-1)

3. **Credenciales de AWS**
   - IAM user con permisos de EC2, RDS, S3, VPC

### Pasos para desplegar

#### 1. Descarga los archivos
Copia estos 5 archivos a una carpeta en tu VS Code:
- `main.tf`
- `variables.tf`
- `outputs.tf`
- `terraform.tfvars`
- `README.md`

#### 2. Abre VS Code
```bash
code .
```

#### 3. Inicializa Terraform
```bash
terraform init
```
Esto descargará el provider de AWS y preparará el directorio.

#### 4. Revisa el plan
```bash
terraform plan
```
Esto mostrará qué recursos se crearán. Verás algo como:
```
Plan: 18 to add, 0 to change, 0 to destroy.
```

#### 5. Personaliza las variables (IMPORTANTE)
Edita `terraform.tfvars` y cambia:
- `db_master_password`: Usa una contraseña segura
- `aws_region`: Tu región preferida (default: us-east-1)
- `project_name`: Nombre de tu proyecto

#### 6. Aplica los cambios
```bash
terraform apply
```
Escribe `yes` cuando te lo pida para confirmar.

Espera 5-10 minutos mientras se crean todos los recursos.

#### 7. Obtén los outputs
Después de que termine, verás algo como:
```
Apply complete! Resources: 18 added, 0 changed, 0 destroyed.

Outputs:

architecture_summary = {
  "availability_zones" = ["us-east-1a", "us-east-1b", "us-east-1c"]
  "ec2_instance_type" = "t3.micro"
  "ec2_instances_count" = 4
  "project_name" = "cloud-arch"
  "rds_instance_class" = "db.t3.micro"
  "region" = "us-east-1"
  "s3_bucket_name" = "cloud-arch-backups-123456789"
}

power_bi_server_public_ip = "54.123.45.67"
email_server_public_ip = "54.123.45.68"
llama_container_public_ip = "54.123.45.69"
web_moodle_public_ip = "54.123.45.70"

rds_endpoint = "moodle-db.xxxxxxxxx.us-east-1.rds.amazonaws.com:5432"
s3_bucket_name = "cloud-arch-backups-123456789"
```

## 📊 Estructura de archivos

```
terraform/
├── main.tf              # Definición de recursos principales
├── variables.tf         # Declaración de variables
├── outputs.tf           # Outputs/salidas
├── terraform.tfvars     # Valores de variables
└── README.md            # Este archivo
```

## 🔧 Comandos útiles

### Ver estado actual
```bash
terraform show
```

### Actualizar recursos específicos
```bash
terraform apply -target=aws_instance.power_bi_server
```

### Destruir todo (CUIDADO)
```bash
terraform destroy
```

### Ver el estado del Terraform
```bash
terraform state list
```

### Refrescar el estado actual
```bash
terraform refresh
```

## 🔐 Consideraciones de seguridad

1. **Cambiar contraseña de RDS**
   - En `terraform.tfvars`, usa una contraseña segura
   - NO uses la contraseña de ejemplo en producción

2. **Restringir acceso SSH**
   - En `main.tf`, reemplaza `"0.0.0.0/0"` con tu IP
   - Busca `cidr_blocks = ["0.0.0.0/0"]`

3. **Usar AWS Secrets Manager**
   - Para variables sensibles, usa AWS Secrets Manager en lugar de archivos

4. **State file en remoto**
   - Para equipos, guarda el state en S3 (ver ejemplos abajo)

## 📝 Ejemplo: State file remoto (Teams)

Crea un archivo `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "mi-terraform-state"
    key            = "cloud-arch/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## 💰 Estimación de costos

Con t3.micro (free tier eligible):
- 4x EC2 t3.micro: ~$0.01 USD/hour
- RDS db.t3.micro: ~$0.02 USD/hour
- S3 storage: ~$0.023 USD/GB/mes
- **Total**: ~$2-3 USD/día sin free tier

## 🐛 Troubleshooting

### Error: "Access Denied"
```
Solución: Verifica que tus credenciales de AWS sean correctas
aws configure
```

### Error: "InvalidParameterValue" en RDS
```
Solución: Cambia db_allocated_storage a un valor válido (mínimo 20)
```

### Instancias no se crean
```
Solución: Verifica que tu región tenga suficientes límites de recursos
Contacta a AWS support para aumentar límites
```

## 📚 Recursos adicionales

- [Documentación Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Mejores prácticas de Terraform](https://www.terraform.io/language/syntax/style)
- [AWS Free Tier](https://aws.amazon.com/free)

## ✅ Próximos pasos

Después de desplegar:

1. **Conectarse a EC2**
   ```bash
   ssh -i ~/.ssh/tu-key.pem ubuntu@<public-ip>
   ```

2. **Instalar aplicaciones**
   ```bash
   sudo apt update
   sudo apt install apache2 postgresql-client docker.io
   ```

3. **Configurar Moodle**
   - Instala PHP, Apache, PostgreSQL
   - Descarga Moodle: https://download.moodle.org

4. **Configurar backups automáticos**
   - Usa AWS Backup o scripts cron
   - Guarda backups en S3

5. **Monitoreo**
   ```bash
   # Agregar CloudWatch para monitoreo
   # Edita main.tf para agregar dashboards
   ```

## 📞 Soporte

Para problemas:
1. Revisa los logs de Terraform: `terraform logs`
2. Revisa los logs de AWS: AWS Console → CloudFormation
3. Verifica la sintaxis: `terraform validate`

---

**Autor**: Terraform Cloud Architecture  
**Última actualización**: 2026-09-23
