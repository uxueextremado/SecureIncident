# SecureIncident
Web de Reporte de Incidentes de Seguridad en Microsoft Azure

Seguridad en la nube - Uxue Extremado

## Descripción
SecureIncident es una plataforma web en la nube diseñada para gestionar y rastrear incidentes de seguridad dentro de una organización. Los empleados pueden reportar incidentes como correos sospechosos (phishing), pérdida de dispositivos, accesos no autorizados, malware o fugas de información. El equipo de seguridad puede gestionar los incidentes, cambiar su estado, añadir comentarios y clasificarlos por severidad.

El sistema se despliega en Microsoft Azure utilizando una arquitectura segura y segmentada, con control de acceso basado en roles y funciones de monitorización.

## Arquitectura
La plataforma se despliega en Azure con los siguientes componentes:

- **Red Virtual (VNet):** Una única VNet con espacio de direcciones `10.0.0.0/16` que contiene:
  - Subred privada para PostgreSQL (10.0.1.0/24): aloja el servidor de base de datos sin acceso público.
  - Subred para VNet Integration (10.0.2.0/24): permite la comunicación segura desde App Service hacia la VNet.
- **Azure App Service (Plan B1):** Ejecuta la aplicación web (Python/Flask) con escalado automático, SSL integrado y VNet Integration para conectarse de forma privada a la base de datos.
- **PostgreSQL Flexible Server:** Base de datos relacional que almacena usuarios, incidentes y comentarios. Se despliega sin acceso público y solo es accesible desde la VNet a través de la subred privada.
- **VNet Integration:** Conexión directa desde App Service a la VNet, permitiendo que la web acceda a PostgreSQL de forma privada y segura sin exponer la base de datos a Internet.
- **Azure Key Vault:** Almacena de forma segura las credenciales de la base de datos (PostgreSQL) y otros secretos. App Service accede mediante Managed Identity.
- **Azure Monitor:** Recopila métricas y logs. Genera alertas por CPU alta, intentos de login fallidos, reinicios de la aplicación y rendimiento de la base de datos.

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
