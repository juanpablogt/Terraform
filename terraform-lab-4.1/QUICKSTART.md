# Quick Start - Laboratorio 4.1 con Terraform

## ⚡ 5 Minutos para Empezar

### Paso 1: Inicializar Terraform
```bash
cd ~/path/to/lab
terraform init
```

### Paso 2: Ver qué se va a crear
```bash
terraform plan
```

### Paso 3: Crear la infraestructura
```bash
terraform apply
```
Escribe `yes` cuando se te pida confirmación.

### Paso 4: Obtener información
```bash
# Todas las IPs y recursos
terraform output

# Solo una IP específica
terraform output web_server_1_public_ip

# Guardar outputs en archivo
terraform output -json > outputs.json
```

### Paso 5: Probar acceso
```bash
# Reemplaza XX.XX.XX.XX con la IP que obtuviste
curl http://XX.XX.XX.XX
```

---

## 🔄 Flujo de Trabajo Típico

```bash
# Día 1: Crear
terraform init
terraform plan
terraform apply -auto-approve

# Día 2: Revisar/Modificar
terraform state list
terraform state show aws_vpc.lab_vpc

# Día 3: Cambiar algo (ej: más instancias)
# Editar main.tf...
terraform plan
terraform apply -auto-approve

# Día 4: Eliminar
terraform destroy -auto-approve
```

---

## 🎯 Casos de Uso Comunes

### Solo revisar sin crear nada
```bash
terraform init
terraform plan
# (revisar, no hacer apply)
```

### Crear y guardar los outputs
```bash
terraform apply -auto-approve
terraform output -json > lab-outputs.json
```

### Destruir solo una instancia
```bash
terraform destroy -target=aws_instance.web_server_1 -auto-approve
```

### Recrear toda la infraestructura
```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

### Ver el costo estimado
```bash
terraform plan
# El plan muestra recursos a crear/modificar/destruir
```

---

## 📋 Comandos Esenciales

| Comando | Función |
|---------|---------|
| `terraform init` | Descargar providers |
| `terraform plan` | Ver cambios antes de aplicar |
| `terraform apply` | Crear/modificar recursos |
| `terraform destroy` | Eliminar todos los recursos |
| `terraform output` | Ver resultados |
| `terraform state list` | Ver recursos creados |
| `terraform refresh` | Actualizar estado |
| `terraform fmt` | Formatear archivos |
| `terraform validate` | Validar sintaxis |

---

## 🚀 Ir Más Rápido

### Aplicar sin confirmación
```bash
terraform apply -auto-approve
```

### Destruir sin confirmación
```bash
terraform destroy -auto-approve
```

### Ver solo cambios importantes
```bash
terraform plan -compact-warnings
```

### Ver outputs en tabla bonita
```bash
terraform output
# o
terraform output -json | jq
```

---

## ⚙️ Personalización Rápida

### Cambiar región
```bash
# Editar terraform.tfvars
aws_region = "eu-west-1"  # en lugar de us-east-1
terraform apply -auto-approve
```

### Cambiar tipo de instancia
```bash
# Editar terraform.tfvars
instance_type = "t3.small"  # en lugar de t2.micro
terraform apply -auto-approve
```

### Agregar más instancias
```bash
# Editar main.tf y agregar más bloques de aws_instance
# Luego:
terraform apply -auto-approve
```

---

## 🔍 Debugging

### Ver qué hace terraform
```bash
terraform apply -var-file="terraform.tfvars" -auto-approve -input=false
```

### Ver detalles del state
```bash
terraform state show aws_instance.web_server_1
```

### Ver cambios que se harían
```bash
terraform plan -detailed-exitcode
# 0 = no cambios, 1 = error, 2 = cambios pendientes
```

### Listar todos los recursos con IPs
```bash
terraform output -json | jq '.[] | select(.value | type == "string")'
```

---

## 💾 Guardar Configuración

### Exportar outputs a un archivo
```bash
# JSON
terraform output -json > outputs.json

# CSV personalizado
terraform output -json | jq -r '.[] | [.value] | @csv' > ips.csv
```

### Exportar plan para revisión
```bash
terraform plan -out=tfplan
# Luego compartir tfplan con otros
```

---

## ❌ Si algo falla

### Rollback completo
```bash
terraform destroy -auto-approve
terraform apply -auto-approve
```

### Limpiar estado corrupto
```bash
rm -rf .terraform
rm -f .terraform.lock.hcl
terraform init
```

### Ver logs detallados
```bash
TF_LOG=DEBUG terraform plan 2>&1 | head -100
```

---

## 🎓 Siguiente Paso

Cuando domines estos comandos, aprende:

1. **Módulos**: Reutilizar código
```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}
```

2. **Workspaces**: Múltiples ambientes
```bash
terraform workspace new produccion
terraform workspace new staging
```

3. **Remote State**: Compartir estado en equipo
```hcl
terraform {
  backend "s3" {
    bucket = "mi-bucket"
    key    = "lab/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## 📞 Ayuda Rápida

```bash
# Ayuda general
terraform -h

# Ayuda de un comando específico
terraform apply -h

# Ver versión
terraform -v

# Validar sintaxis
terraform validate

# Formatear automático
terraform fmt -recursive
```

---

**¡Listo! Ahora ejecuta `terraform apply -auto-approve` y comienza tu laboratorio.**
