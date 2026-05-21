# SecureIncident
Web de Reporte de Incidentes de Seguridad en Microsoft Azure

Seguridad en la nube - Uxue Extremado

## Descripción
SecureIncident es una plataforma web en la nube diseñada para gestionar y rastrear incidentes de seguridad dentro de una organización. Los empleados pueden reportar incidentes como correos sospechosos (phishing), pérdida de dispositivos, accesos no autorizados, malware o fugas de información. El equipo de seguridad puede gestionar los incidentes, cambiar su estado, añadir comentarios y clasificarlos por severidad.

El sistema se despliega en Microsoft Azure utilizando una arquitectura segura y segmentada, con control de acceso basado en roles y funciones de monitorización.

## Gestión de Costes
Para optimizar el consumo de créditos de Azure for Students y evitar gastos innecesarios (debido al límite de créditos), se sigue un procedimiento basado en escenarios momentáneos: 

- **Despliegue controlado:** La infraestructura se despliega solo cuando se va a utilizar (con terraform apply).  
- **Destrucción automática:** Al acabar cada simulación, se ejecuta terraform destry para eliminar todos los recursos y dejar de gastar créditos.
- **Coste estimado:** Con el plan App Service B1 y PostgreSQL B1ms, el coste aproximado es de 15-20 €/mes si no lo destruiríamos nunca. Sin embargo, como solo lo activados cuando queremos realizar las pruebas el precio baja a céntimos por hora. 

## Verificación del despliegue
Una vez completado el despliegue, se puede comprobar que la aplicación funciona correctamente accediendo a la URL `https://webapp-secureincident.azurewebsites.net`. En los logs de la aplicación (disponibles en el Log Stream del App Service) deben aparecer los mensajes:

- Usuario de seguridad creado: security@secureincident.com

- Usuario empleado creado: employee@secureincident.com

Estos, confirman que la base de datos está accesible y que la aplicación se ha inicializado correctamente.

## Destroy desde local
Para destruir los recursos creados debemos seguir los siguientes pasos:

1. Elimina el secreto y las políticas del estado antes de destruir:

*terraform state rm azurerm_key_vault_secret.db_password*

*terraform state rm azurerm_key_vault_access_policy.current_user*

*terraform state rm azurerm_key_vault_access_policy.managed_identity*

*terraform state rm azurerm_key_vault.secureincident_vault*

*az monitor action-group delete --name "Application Insights Smart Detection" --resource-group rg-secureincident*

2. Purgar Key Vault (para evitar conflictos de nombre) desde local o con el comando:

*az keyvault purge --name kv-secureincident2 --location spaincentral*

3. Ejucuta destroy:

*terraform destroy -auto-approve*
