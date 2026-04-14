# SecureIncident
Web de Reporte de Incidentes de Seguridad en Microsoft Azure

Seguridad en la nube - Uxue Extremado

## Descripción
SecureIncident es una plataforma web en la nube diseñada para gestionar y rastrear incidentes de seguridad dentro de una organización. Los empleados pueden reportar incidentes como correos sospechosos (phishing), pérdida de dispositivos, accesos no autorizados, malware o fugas de información. El equipo de seguridad puede gestionar los incidentes, cambiar su estado, añadir comentarios y clasificarlos por severidad.

El sistema se despliega en Microsoft Azure utilizando una arquitectura segura y segmentada, con control de acceso basado en roles y funciones de monitorización.

## Arquitectura
La plataforma se despliega en Azure con los siguientes componentes:

- **Red Virtual (VNet):** Una única VNet con espacio de direcciones `10.0.0.0/16` que contiene:
  - Subred para Private Endpoint (conecta de forma privada con PostgreSQL).
  - Subred para VNet Integration (permite la comunicación segura desde App Service).
- **Azure App Service:** Ejecuta la aplicación web (Python/Flask) sin necesidad de administrar servidores. Escalado automático y SSL integrado.
- **PostgreSQL Flexible Server:** Base de datos relacional que almacena usuarios, incidentes y comentarios. Se despliega sin acceso público y solo es accesible a través de un Private Endpoint dentro de la VNet.
- **Private Endpoint:** Asigna una IP privada a PostgreSQL dentro de la VNet, garantizando que el tráfico entre App Service y la base de datos no salga a Internet.
- **Azure Key Vault:** Almacena de forma segura las credenciales de la base de datos, cadenas de conexión y otros secretos. App Service accede mediante Managed Identity.
- **Azure Monitor:** Recopila métricas y logs. Genera alertas por CPU alta, intentos de login fallidos, reinicios de la aplicación y rendimiento de la base de datos.

## Frontend
La interfaz web está desarrollada con HTML5, CSS3, Bootstrap 5 y Jinja2, e incluye:

- **Autenticación** con registro/login y roles diferenciados (empleado / seguridad).
- **Dashboard para empleados:** estadísticas personales, tabla de incidentes propios y formulario de reporte con tipos predefinidos más la opción "Otro tipo".
- **Dashboard para seguridad:** estadísticas globales, tabla completa de incidentes con edición en línea (estado/severidad), eliminación y acceso a la gestión de usuarios.
- **Gestión de usuarios:** listado de todos los usuarios, visualización de estado (activo/deshabilitado) y acciones para habilitar o deshabilitar (solo seguridad).
- **Vista de detalle:** información completa del incidente, comentarios y panel de gestión para el equipo de seguridad.
