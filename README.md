# SecureIncident
Web de Reporte de Incidentes de Seguridad en Microsoft Azure

Seguridad en la nube - Uxue Extremado

## Descripción
SecureIncident es una plataforma web en la nube diseñada para gestionar y rastrear incidentes de seguridad dentro de una organización. Los empleados pueden reportar incidentes como correos sospechosos (phishing), pérdida de dispositivos, accesos no autorizados, malware o fugas de información. El equipo de seguridad puede gestionar los incidentes, cambiar su estado, añadir comentarios y clasificarlos por severidad.

El sistema se despliega en Microsoft Azure utilizando una arquitectura segura y segmentada, con control de acceso basado en roles y funciones de monitorización.

## Arquitectura
La plataforma se despliega en Azure con los siguientes componentes:

### Red Virtual (VNet):
Una única VNet con espacio de direcciones 10.0.0.0/16 que está dividida en dos subredes con distintos objetivos: 
  - **Subred privada para PostgreSQL (10.0.1.0/24)**: Aloja el servidor de base de datos (PostgreSQL). No tiene acceso público, es decir, ningún recurso externo a la VNET va a poder conectarse directamente a la base de datos. Sin embargo, los recursos que están dentro como App Service sí podrá acceder. 
  - **Subred para VNet Integration (10.0.2.0/24)**: Actúa como enlace entre Azure App Service y la VNet. Permite que la aplicación web se conecte con la base de datos de forma privada, sin exponer PostgreSQL a Internet. Se delega su uso a App Service. 

### Azure App Service: 
La aplicación web se ejecuta en Azure App Service, un servicio PaaS (Platform as a Service). Se ha elegido el plan B1 (Basic), ya que es el más económico que soporta las necesidades del proyecto (VNet Integration). Las características más destacables de este recurso son:
- **Escalado automático:** Ajusta los recursos dependiendo de la demanda.
- **SSL integrado:** Proporciona conexiones seguras HTTPS.
- **Despliegue continuo:** Se une a GitHub para actualizar la aplicación automáticamente.  

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

### Azure Monitor: 
Servicio de supervisión de Azure. Recopila métricas y logs de todos los recursos que desplegamos y permite la visualización del estado de la plataforma en tiempo real. Proporciona: 
- **Métricas de rendimiento:** CPU, memoria y peticiones de App Service y PostgreSQL. 
- **Alertas:** Se notifica cuando se superan los límites establecidos. 
- **Monitorización:** Detecta intentos de login fallidos y reinicios inesperados de la aplicación. 
- **Logs centralizados:** Almacenae logs para diagnóstico y análisis histórico. 

## Frontend
La interfaz web está desarrollada con HTML5, CSS3, Bootstrap 5 y Jinja2, e incluye:

- **Autenticación** con registro/login y roles diferenciados (empleado / seguridad).
- **Dashboard para empleados:** estadísticas personales, tabla de incidentes propios y formulario de reporte con tipos predefinidos más la opción "Otro tipo".
- **Dashboard para seguridad:** estadísticas globales, tabla completa de incidentes con edición en línea (estado/severidad), eliminación y acceso a la gestión de usuarios.
- **Gestión de usuarios:** listado de todos los usuarios, visualización de estado (activo/deshabilitado) y acciones para habilitar o deshabilitar (solo seguridad).
- **Vista de detalle:** información completa del incidente, comentarios y panel de gestión para el equipo de seguridad.

## Integración Continua con GitHub Actions y OIDC
El despliegue de la infraestructura se automatiza mediante un pipeline de GitHub Actions que utiliza OpenID Connect (OIDC) para autenticarse en Azure.

### Componentes utilizados

- **Managed Identity en Azure:** Se creó una identidad gestionada (tf-oidc-secureincident) con permisos limitados sobre los recursos del proyecto.
- **Federación de credenciales:** Se configuró una credencial federada que permite a GitHub Actions autenticarse como la Managed Identity mediante OIDC.
- **Backend remoto de Terraform:** El estado de Terraform se almacena en un Azure Storage Account (stterraformsecure), permitiendo la ejecución del pipeline desde cualquier entorno.
- **Repository secrets y variables:** Los valores sensibles se almacenan como secrets, mientras que la URL del repositorio se define como variable de entorno.

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

## Gestión de Costes
Para optimizar el consumo de créditos de Azure for Students y evitar gastos innecesarios (debido al límite de créditos), se sigue un procedimiento basado en escenarios momentáneos: 

- **Despliegue controlado:** La infraestructura se despliega solo cuando se va a utilizar (con terraform apply).  
- **Destrucción automática:** Al acabar cada simulación, se ejecuta terraform destry para eliminar todos los recursos y dejar de gastar créditos.
- **Coste estimado:** Con el plan App Service B1 y PostgreSQL B1ms, el coste aproximado es de 15-20 €/mes si no lo destruiríamos nunca. Sin embargo, como solo lo activados cuando queremos realizar las pruebas el precio baja a céntimos por hora. 