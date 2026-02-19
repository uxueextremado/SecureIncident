# SecureIncident
Web de Reporte de Incidentes de Seguridad en Microsoft Azure

Seguridad en la nube - Uxue Extremado

## Descripción
SecureIncident es una plataforma web en la nube diseñada para gestionar y rastrear incidentes de seguridad dentro de una organización. Los empleados pueden reportar incidentes como correos sospechosos (phishing), pérdida de dispositivos, accesos no autorizados, malware o fugas de información. El equipo de seguridad puede gestionar los incidentes, cambiar su estado, añadir comentarios y clasificarlos por severidad.

El sistema se despliega en Microsoft Azure utilizando una arquitectura segura y segmentada, con control de acceso basado en roles y funciones de monitorización.

## Arquitectura
La plataforma se despliega en Azure con los siguientes componentes:

- **Red Virtual (VNet):** Segmentada en subred pública y privada
  - Subred pública: VM Linux con la aplicación web
  - Subred privada: Base de datos PostgreSQL
- **VM Linux:** Ejecuta la aplicación web
- **PostgreSQL Flexible Server:** Almacena usuarios e incidentes
- **Key Vault:** Guarda de manera segura los secretos de la base de datos
- **Azure Monitor:** Monitorea métricas y genera alertas por CPU, intentos de login fallidos y reinicios de VM

