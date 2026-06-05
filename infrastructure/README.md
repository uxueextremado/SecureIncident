# Infraestructura - SecureIncident

La plataforma se despliega en Azure con los siguientes componentes:

### Red Virtual (VNet):
Una única VNet con espacio de direcciones 10.0.0.0/16 que está dividida en dos subredes con distintos objetivos: 
  - **Subred privada para PostgreSQL (10.0.1.0/24)**: Aloja el servidor de base de datos (PostgreSQL). No tiene acceso público, es decir, ningún recurso externo a la VNET va a poder conectarse directamente a la base de datos. Sin embargo, los recursos que están dentro como App Service sí podrá acceder. 
  - **Subred para VNet Integration (10.0.2.0/24)**: Actúa como enlace entre Azure App Service y la VNet. Permite que la aplicación web se conecte con la base de datos de forma privada, sin exponer PostgreSQL a Internet. Se delega su uso a App Service. 

### Azure App Service: 
La aplicación web se ejecuta en Azure App Service, un servicio PaaS (Platform as a Service). Se ha elegido el plan B1 (Basic), ya que es el más económico que soporta las necesidades del proyecto (VNet Integration, para conectar la aplicación con la base de datos de forma privada). 

El despliegue de la aplicación sobre este servicio se ha automatizado con GitHub Actions utilizando OpenID Connect (OIDC), lo que permite que el código se actualice en Azure automáticamente cada vez que se realiza un git push a la rama main, sin necesidad de intervención manual y sin almacenar credenciales estáticas en el repositorio.

Las características más destacables de este recurso son:
- **Escalado automático:** Ajusta los recursos dependiendo de la demanda, para quu la plataforma esté preparada para crecer sin cambios en el código.
- **SSL integrado:** Proporciona automáticamente un certificado SSL/TLS para el dominio *.azurewebsites.net, garantizando que toda la comunicación con la web esté cifrada mediante HTTPS.
- **Despliegue continuo:** Con GitHub Actions, cualquier cambio en el código que se suba a la rama main activa un pipeline que empaqueta la aplicación y la despliega en App Service de forma automática.
- **VNet Integration:** La aplicación se conecta a la subred subnet-app-integration dentro de la VNet, lo que permite que se comunique con la base de datos PostgreSQL a través de la red privada de Azure, sin exponer la base de datos a Internet y garantizando la seguridad de los datos.
- **Acceso a secretos mediante Managed Identity:**  Utiliza una identidad gestionada (SystemAssigned) para autenticarse en Azure Key Vault y obtener la contraseña de PostgreSQL de forma segura. Así, las credenciales no se almacenan en el código ni en variables de entorno del pipeline.

### PostgreSQL Flexible Server: 
Como base de datos relacional se utiliza PostgreSQL Flexible Server (servicio PaaS de Azure) y almacena toda la información: usuarios, incidentes, comentarios y estados. Además, se ha configurado con estas medidas:
- **Sin acceso público:** No tiene una IP pública asignada. 
- **Acceso exclusivo desde VNet:** Solo los recursos que están dentro de la VNet pueden conectarse. 
- **Cifrado de conexiones:** Se utiliza SSL/TLS en la cadena de conexión. 

### VNet Integration: 
Mecanismo que permite la conexión directa desde App Service a la VNet sin exponer la base de datos a Internet. Consiste en conectar el App Service a la subred dedicada (10.0.2.0/24) dentro de la VNet. Tras esta conexión: 
- Todo el tráfico entre la aplicación web y la base de datos viaja por la red privada de Azure.
- No hay que configurar reglas de firewall para permitir IPs públicas ni abrir puertos a Internet. 
- La comunicación es segura y aislada, cumpliendo con buenas prácticas de seguridad en la nube. 

### Azure Key Vault:
Servicio creado para almacenar y administrar de forma segura los secretos. En este caso guarda la contraseña del administrador de PostgreSQL. De esta forma, en vez de añadir la contraseña en el código o archivos de configuración, App Service accede al secreto a través de una Managed Identity, una identidad que se gestiona desde Azure. Tiene varias ventajas: 
- **Sin acceso indebidos:** Solo los recursos autorizados (App Service) pueden leer los secretos.
- **Sin secretos en el código:** Los no se almacenan en los archivos de configuración ni en el código. 
- **Auditabilidad:** Key Vault registra quién accede a cada secreto y cuándo. 

### Azure Monitor, Application Insights y Log Analytics: 
**Azure Monitor:** Servicio de supervisión de Azure. Recopila métricas y logs de todos los recursos que desplegamos y permite la visualización del estado de la plataforma en tiempo real. Proporciona: 

- Métricas de rendimiento: CPU, memoria y peticiones de App Service y PostgreSQL. 

- Alertas: Se notifica cuando se superan los límites establecidos. 

- Monitorización: Detecta intentos de login fallidos y reinicios inesperados de la aplicación. 

- Logs centralizados: Almacenae logs para diagnóstico y análisis histórico. 

**Application Insights:** Monitorización específica de la aplicación web:
- Tiempos de respuesta y rendimiento.
- Peticiones HTTP y excepciones.
- Logs personalizados de la aplicación.

**Log Analytics Workspace (`law-secureincident`):** Almacenamiento centralizado de logs.

## Integración Continua con GitHub Actions y OIDC
El despliegue de la infraestructura se automatiza mediante pipelines de GitHub Actions que utilizan OpenID Connect (OIDC) para autenticarse en Azure.

### Flujo de trabajo del pipeline
El pipeline se define en el archivo .github/workflows/terraform.yml y se divide en dos fases principales:

### Workflows disponibles

| Workflow | Archivo | Función |
|----------|---------|---------|
| **Infrastructure Deploy** | `infrastructure.yml` | Despliega/destruye infraestructura |
| **App Deploy** | `app.yml` | Despliega solo el código |
| **Solution Deploy** | `solution.yml` | Orquesta el despliegue completo |
| **Run Tests** | `test.yml` | Ejecuta tests automáticos al hacer commit |
| **PR Tests** | `test-pr.yml` | Ejecuta tests automáticos al hacer pull requests |

### Componentes utilizados

- **Managed Identity en Azure:** Se creó una identidad gestionada (tf-oidc-secureincident) con permisos limitados sobre los recursos del proyecto (rg-secureincident). Esta se utiliza para ejecutar Terraform y desplegar el código.
- **Federación de credenciales:** Se configuró una credencial federada en Azure que vincula la Managed Identity con el repositorio de GitHub.
- **Backend remoto de Terraform:** El estado de Terraform se almacena en un Azure Storage Account (stterraformsecure), dentro del contenedor tfstate. Esto permite la ejecución del pipeline desde cualquier entorno.
- **Repository secrets y variables:** Los valores sensibles (contraseñas, claves...) se almacenan como secrets, mientras que la URL del repositorio se define como variable de entorno. Esto asegura que las credenciales no queden expuestas en el código ni en los logs del pipeline.

### Configuración de secrets y variables en GitHub
Para que el pipeline funcione correctamente, se añadieron los siguientes elementos en el repositorio (Settings → Secrets and variables → Actions):

- **Secrets (valores sensibles)**
  
| Nombre del secret                     | Propósito                                                   |
|--------------------------------------|-------------------------------------------------------------|
| AZURE_CLIENT_ID                      | ID de la Managed Identity para autenticación OIDC          |
| AZURE_TENANT_ID                      | ID del inquilino de Azure AD                               |
| AZURE_SUBSCRIPTION_ID                | ID de la suscripción de Azure                              |
| TF_VAR_DB_PASSWORD                   | Contraseña del administrador de PostgreSQL                 |
| TF_VAR_SECRET_KEY                    | Clave secreta de Flask para sesiones                       |
| TF_VAR_DEFAULT_SECURITY_PASSWORD     | Contraseña del usuario por defecto del equipo de seguridad |
| TF_VAR_DEFAULT_EMPLOYEE_PASSWORD     | Contraseña del usuario por defecto de empleado             |

- **Variables (no sensibles)**
  
| Nombre de la variable | Valor                                              | Propósito                                      |
|----------------------|----------------------------------------------------|-----------------------------------------------|
| REPO_URL             | https://github.com/uxueextremado/SecureIncident    | URL del repositorio para el despliegue continuo |

### Seguridad del sistema
- **Sin secretos estáticos:** No se almacenan credenciales permanentes en GitHub. Los tokens de OIDC son temporales y se generan en cada ejecución.
- **Permisos limitados:** La Managed Identity tiene asignado el rol Contributor solo sobre el grupo de recursos del proyecto, para limitar el alcance.
- **Auditabilidad:** Todas las ejecuciones del pipeline quedan registradas en GitHub Actions, y las acciones sobre los recursos de Azure se registran en el Activity Log de Azure.