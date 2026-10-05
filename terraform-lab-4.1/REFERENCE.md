# Referencia Rápida - Lab 4.1 Terraform

## 📁 Estructura del Proyecto

```
lab-4.1-terraform/
├── main.tf                    # Infraestructura principal
├── variables.tf               # Definición de variables
├── outputs.tf                 # Salidas (IPs, IDs)
├── terraform.tfvars           # Valores de variables
├── user_data_web.sh           # Script de Web Servers
├── user_data_app.sh           # Script de App Servers
├── user_data_db.sh            # Script de DB Servers
├── .gitignore                 # Archivos a ignorar en Git
├── README.md                  # Documentación completa
├── QUICKSTART.md              # Guía rápida (5 min)
├── TESTING.md                 # Casos de prueba
├── SECURITY_GROUPS.md         # Explicación detallada de SGs
└── REFERENCE.md               # Este archivo
```

---

## 🎯 Comandos Más Usados

### Inicialización
```bash
terraform init              # Descargar plugins
terraform validate          # Verificar sintaxis
terraform fmt               # Formatear código
```

### Planificación y Aplicación
```bash
terraform plan              # Ver cambios
terraform apply             # Aplicar (pide confirmación)
terraform apply -auto-approve  # Aplicar sin confirmar
```

### Información
```bash
terraform output            # Ver outputs
terraform state list        # Ver recursos
terraform state show <res>  # Ver detalles
terraform refresh           # Actualizar estado
```

### Limpieza
```bash
terraform destroy           # Eliminar (pide confirmación)
terraform destroy -auto-approve  # Eliminar sin confirmar
```

---

## 🌍 Recursos Creados

| Recurso | Cantidad | ID en Terraform |
|---------|----------|-----------------|
| VPC | 1 | aws_vpc.lab_vpc |
| Subnets | 4 | public/private_subnet_1/2 |
| Internet Gateway | 1 | aws_internet_gateway.lab_igw |
| NAT Gateway | 1 | aws_nat_gateway.nat_gateway |
| Elastic IP | 1 | aws_eip.nat_eip |
| Route Tables | 2 | public_rt / private_rt |
| Security Groups | 3 | public_web_sg / private_app_sg / private_db_sg |
| EC2 Instances | 5 | web_server_1/2, app_server_1/2, db_server_1 |

**Total Aproximado: 19 recursos**

---

## 💰 Costo Estimado

### Por hora:
- 5 instancias t2.micro: ~$0.01 USD/hora
- NAT Gateway: ~$0.045 USD/hora
- Transferencia de datos: Primeros 100GB/mes gratis

### Total aproximado:
- **Laboratorio activo: ~$0.055 USD/hora** (~$1.32/día)
- **Laboratorio pausado: ~$0 USD** (solo almacenamiento mínimo)

💡 **Consejo**: Ejecutar `terraform destroy` cuando no uses para evitar cargos.

---

## 🔑 Variables Configurables

### Cambiar región:
```bash
# En terraform.tfvars
aws_region = "eu-west-1"  # En lugar de us-east-1
```

### Cambiar tipo de instancia:
```bash
# En terraform.tfvars
instance_type = "t3.small"  # En lugar de t2.micro
# Más potentes: t3.medium, t3.large
# Más baratos: t2.micro, t2.small
```

### Cambiar CIDR de VPC:
```hcl
# En main.tf, busca:
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"  # Cambiar aquí
}
```

---

## 🔗 IPs y Conectividad

### Rangos de IPs
- **VPC**: 10.0.0.0/16
- **Public Subnet 1**: 10.0.1.0/24
- **Public Subnet 2**: 10.0.2.0/24
- **Private Subnet 1**: 10.0.10.0/24
- **Private Subnet 2**: 10.0.11.0/24

### Obtener IPs después de crear:
```bash
terraform output web_server_1_public_ip
terraform output app_server_1_private_ip
terraform output db_server_1_private_ip
```

---

## 🔐 Puertos y Protocolos

### Públicos (Web Servers)
- **SSH (22)**: Administración
- **HTTP (80)**: Tráfico web
- **HTTPS (443)**: Tráfico web seguro

### Privados (App Servers)
- **8080**: Puerto de aplicación
- **0-65535**: Comunicación interna

### Privados (DB Servers)
- **3306**: MySQL/MariaDB
- **5432**: PostgreSQL

---

## 🐛 Problemas Comunes

### "No hay suficientes IPs públicas"
```bash
# Aumentar EIP limit en AWS Console
# O usar menos instancias
```

### "Las instancias no responden"
```bash
# Esperar 2-3 minutos para que inicie
# Ver estado: aws ec2 describe-instances
```

### "Error: VPC está en uso"
```bash
# Alguien/algo está usando recursos
# terraform destroy -auto-approve
# terraform apply -auto-approve
```

### "SSH rechaza conexión"
```bash
# Verificar key pair existe
# Verificar permisos: chmod 400 key.pem
# Verificar SG permite puerto 22
```

---

## 📊 Monitoreo

### Ver estado en tiempo real
```bash
watch 'terraform output -json | jq'  # Actualiza cada 2s
```

### Ver logs en instancia
```bash
# Primero conectar
ssh -i key.pem ec2-user@<public-ip>

# Ver logs de inicio
tail -f /var/log/user-data.log

# Ver estado de servicios
sudo systemctl status httpd    # Web server
sudo systemctl status app-server  # App server
```

### Ver métricas en CloudWatch
```bash
aws cloudwatch list-metrics --namespace AWS/EC2
```

---

## 🔄 Ciclo de Vida Típico

### Semana 1: Setup
```bash
terraform init
terraform plan
terraform apply
terraform output > outputs.txt
```

### Semana 2-3: Testing
```bash
# Revisar outputs
cat outputs.txt

# Conectar y probar
ssh -i key.pem ec2-user@<web-ip>
curl http://<web-ip>

# Ver documentación
cat TESTING.md
```

### Semana 4: Cambios
```bash
# Editar main.tf o variables
terraform plan
terraform apply
```

### Final: Cleanup
```bash
terraform destroy
```

---

## 📝 Anotaciones Importantes

1. **AMI**: Usa Amazon Linux 2 (gratuito en tier)
2. **Tipo de instancia**: t2.micro (gratuito en tier primer año)
3. **Region**: us-east-1 (más barato, mejor disponibilidad)
4. **Firewall**: SGs son nivel de instancia (no de subnet)
5. **Redundancia**: 2 AZs para alta disponibilidad

---

## 🔐 Seguridad Recordar

✅ **Buenas prácticas aplicadas:**
- Subnets públicas y privadas separadas
- NAT Gateway para instancias privadas
- SGs restrictivos (menor privilegio)
- Múltiples AZs para redundancia

⚠️ **Por mejorar en producción:**
- Usar VPN para SSH en lugar de exponer puerto 22
- Implementar WAF (Web Application Firewall)
- Habilitar VPC Flow Logs
- Usar AWS Secrets Manager para credenciales
- Implementar auto-scaling

---

## 🎓 Aprender Más

### Oficial AWS
- [VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Security Groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html)

### Terraform
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [Terraform Docs](https://www.terraform.io/docs/)

### Seguridad
- [AWS Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

---

## 💻 Atajos Útiles

### Crear alias
```bash
alias tf='terraform'
alias tfa='terraform apply -auto-approve'
alias tfd='terraform destroy -auto-approve'
alias tfo='terraform output'
```

### Script de inicio rápido
```bash
#!/bin/bash
terraform init && \
terraform plan && \
echo "Review plan above, then press Enter" && \
read && \
terraform apply -auto-approve && \
terraform output
```

---

## ✅ Checklist Pre-Deploy

- [ ] Revisar main.tf para cambios no intencionados
- [ ] Verificar región correcta en terraform.tfvars
- [ ] Confirmar tipo de instancia apropiado
- [ ] Revisar limites de cuenta AWS
- [ ] Tener AWS CLI configurado
- [ ] Tener credenciales válidas
- [ ] Backup de archivos importante

---

## ⚡ Optimizaciones

### Más rápido
```bash
terraform apply -auto-approve -input=false
```

### Menos salida
```bash
terraform plan -compact-warnings -no-color
```

### Paralelo (experimental)
```bash
terraform apply -parallelism=20
```

---

**Referencia Final - Laboratorio 4.1 con Terraform**

*Última actualización: 2026-09-24*
