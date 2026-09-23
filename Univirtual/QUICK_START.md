# Quick Start - Guía Rápida

## ⚡ En 5 minutos

### 1. Verifica prerrequisitos
```bash
terraform --version
aws --version
aws configure
```

### 2. Copia los archivos
```bash
# En tu carpeta del proyecto
mkdir terraform-cloud-arch
cd terraform-cloud-arch
# Copia los 5 archivos aquí
```

### 3. Revisa y personaliza
```bash
# Edita terraform.tfvars
# Cambia db_master_password a una contraseña segura
# Cambia aws_region si lo necesitas
```

### 4. Valida la configuración
```bash
terraform init
terraform validate
```

### 5. Crea el plan
```bash
terraform plan -out=tfplan
```

### 6. Aplica los cambios
```bash
terraform apply tfplan
```

✅ **¡Listo!** Tu arquitectura está en AWS

---

## 📍 Conexión a instancias

### Crear par de claves (si no tienes)
```bash
aws ec2 create-key-pair --key-name mi-clave --region us-east-1 \
  --query 'KeyMaterial' --output text > mi-clave.pem
chmod 400 mi-clave.pem
```

### Conectarse a una instancia
```bash
# Obtén la IP pública del output
terraform output power_bi_server_public_ip

# Conéctate
ssh -i mi-clave.pem ubuntu@<IP-PUBLICA>
```

---

## 🔄 Operaciones comunes

### Ver todos los outputs
```bash
terraform output
```

### Ver recursos específicos
```bash
terraform state show aws_instance.power_bi_server
```

### Actualizar una instancia específica
```bash
terraform apply -target=aws_instance.email_server
```

### Destruir todo
```bash
terraform destroy
```

### Destruir recurso específico
```bash
terraform destroy -target=aws_s3_bucket.backups
```

---

## 🚨 Errores comunes

| Error | Solución |
|-------|----------|
| `Error: error reading S3 Bucket` | Espera 1 minuto, S3 se sincroniza lentamente |
| `Error: InvalidParameterValue in RDS` | Aumenta db_allocated_storage a 20 |
| `Error: AccessDenied` | Verifica credenciales AWS con `aws configure` |
| `Error: AuthFailure.ServiceUnavailable` | Intenta en otra región |

---

## 💡 Tips

### Guardar estado en S3 (para equipos)
1. Crea un bucket S3 para state
2. Crea una tabla DynamoDB llamada `terraform-locks`
3. Crea archivo `backend.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "mi-estado-terraform"
    key            = "arquitectura/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

4. Ejecuta `terraform init` nuevamente

### Usar variables de entorno
```bash
# En lugar de terraform.tfvars
export TF_VAR_db_master_password="MiContraseña123"
export TF_VAR_aws_region="eu-west-1"
terraform apply
```

### Actualizar solo la contraseña RDS
```bash
# Edita terraform.tfvars
terraform apply -target=aws_db_instance.moodle_db
```

---

## 📊 Monitoreo post-despliegue

### Ver logs de CloudWatch
```bash
aws logs describe-log-groups
aws logs tail /aws/rds/instance/moodle-db/error
```

### Revisar métricas RDS
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/RDS \
  --metric-name CPUUtilization \
  --dimensions Name=DBInstanceIdentifier,Value=moodle-db \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 300 \
  --statistics Average
```

### Listar instancias EC2
```bash
aws ec2 describe-instances --region us-east-1 \
  --query 'Reservations[].Instances[].[InstanceId,PublicIpAddress,State.Name]' \
  --output table
```

---

## 🔒 Seguridad - Importante

⚠️ **ANTES DE PRODUCCIÓN:**

1. Usa una contraseña fuerte en RDS (mínimo 12 caracteres con números y símbolos)
2. Restringe acceso SSH a tu IP solo:
   ```hcl
   # En main.tf, reemplaza:
   # cidr_blocks = ["0.0.0.0/0"]
   # Con:
   cidr_blocks = ["TU_IP/32"]
   ```

3. Usa AWS Secrets Manager:
   ```bash
   aws secretsmanager create-secret --name moodle-db-password \
     --secret-string 'MiContraseña123'
   ```

4. Habilita CloudTrail para auditoría:
   ```bash
   aws cloudtrail create-trail --name mi-trail --s3-bucket-name mi-bucket
   ```

---

## 📞 Contacto y Soporte

- Documentación oficial: https://registry.terraform.io/providers/hashicorp/aws
- Comunidad Terraform: https://discuss.hashicorp.com/c/terraform
- Foro AWS: https://forums.aws.amazon.com/

---

**¡Listo para desplegar!** 🚀
