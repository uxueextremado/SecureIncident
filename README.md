# SecureIncident
Web de Reporte de Incidentes de Seguridad en Microsoft Azure

Seguridad en la nube - Uxue Extremado

## Descripción
SecureIncident es una plataforma web en la nube diseñada para gestionar y rastrear incidentes de seguridad dentro de una organización. Los empleados pueden reportar incidentes como correos sospechosos (phishing), pérdida de dispositivos, accesos no autorizados, malware o fugas de información. El equipo de seguridad puede gestionar los incidentes, cambiar su estado, añadir comentarios y clasificarlos por severidad.

El sistema se despliega en Microsoft Azure utilizando una arquitectura segura y segmentada, con control de acceso basado en roles y funciones de monitorización.

## Workflows
Se han creado tres workflows independientes para gestionar el despliegue de SecureIncident, siguiendo el principio de separación de responsabilidades y reutilización de workflows de GitHub Actions.

### Infrastructure Deploy (infrastructure.yml)
Gestiona toda la infraestructura de Azure mediante Terraform.

- Acciones:

apply: Crea o actualiza la infraestructura (VNet, subredes, Key Vault, PostgreSQL, App Service)

destroy: Elimina toda la infraestructura

- Uso manual:

Actions → Infrastructure Deploy → Run workflow

Seleccionar rama (main o uxue)

Elegir acción (apply o destroy)

### App Deploy (app.yml)
Despliega el código de la aplicación en el App Service.

- Acción:

deploy: Empaqueta y sube el código de la aplicación

- Requisito: La infraestructura debe existir previamente.

- Uso manual:

Actions → App Deploy → Run workflow

Seleccionar rama (main o uxue)

Elegir acción (deploy)

### Solution Deploy (solution.yml)
Workflow orquestador que automatiza el despliegue completo utilizando reusable workflows (workflows reutilizables). Llama a infrastructure.yml y espera a que termine (gracias a needs) antes de ejecutar app.yml.

- Acciones:

deploy: Despliega infraestructura + aplicación (todo completo)

destroy: Destruye toda la infraestructura

- Uso:

Actions → Solution Deploy → Run workflow

Seleccionar rama (main o uxue)

Elegir acción (deploy o destroy)

- Flujo de ejecución de Solution Deploy

Solution Deploy (deploy)

    │

    ├── 1. Llama a Infrastructure Deploy (apply)

    │        │

    │        └── Espera automáticamente a que termine (needs)

    │

    └── 2. Llama a App Deploy (deploy)

             │

             └── Se ejecuta SOLO si Infrastructure Deploy terminó con éxito

- Configuración de secrets

Los workflows reutilizables necesitan heredar los secrets del workflow llamante. En solution.yml se utiliza secrets: inherit para pasar todos los secrets necesarios a los workflows llamados.

## Verificación del despliegue
Una vez completado el despliegue, se puede comprobar que la aplicación funciona correctamente accediendo a la URL `https://webapp-secureincident.azurewebsites.net`. En los logs de la aplicación (disponibles en el Log Stream del App Service) deben aparecer los mensajes:

- Usuario de seguridad creado: security@secureincident.com

- Usuario empleado creado: employee@secureincident.com

Estos, confirman que la base de datos está accesible y que la aplicación se ha inicializado correctamente.

## Logs y Monitorización
La aplicación genera logs en 4 niveles distintos donde muestra todas las acciones que se realizan la aplicación como; inicio de sesión exitoso o fallido, registro de nuevo usuario existoso o fallido, reporte o actualización de incidente, errores al reportar o actualizar... Estos pueden visualizarse en Log Stream, Application Insights y Log Analytics workspaces.

Además, para demostrar su correcto funcionamiento cada vez que se despliega SecureIncident, la aplicación se inicia y genera automáticamente 4 logs de diferentes niveles: 

| Nivel | Mensaje | Consulta en Application Insights |
|------|-------------|-----------|
| **INFO** | Aplicación SecureIncident iniciada correctamente | traces | where severityLevel == 1 | take 10 |
| **WARNING** | Modo de desarrollo activado - Asegúrate de usar HTTPS en producción | traces | where severityLevel == 2 | take 10 |
| **ERROR** | Esto es un log de error de prueba - No hay problema real | traces | where severityLevel == 3 | take 10 |
| **DEBUG** | Log de depuración: Variables de entorno cargadas correctamente | traces | where severityLevel == 0 | take 10 |

## Tests Automatizados
Se han implementado tres niveles de pruebas para garantizar la calidad y el correcto funcionamiento de la aplicación.

### Estructura de los tests
tests/

├── test_unitarios.py # Pruebas unitarias de modelos

├── test_integracion.py # Pruebas de integración de rutas

├── test_funcionales_local.py # Pruebas funcionales (entorno local), tiene que estar la aplicación desplegada para que funcionen

└── test_funcionales_azure.py # Pruebas funcionales (entorno Azure), tiene que estar la aplicación desplegada para que funcionen

### Tipos de pruebas

| Tipo | Descripción | Cobertura |
|------|-------------|-----------|
| **Unitarias** | Validan modelos individuales (User, Incident, Comment) | 4 tests |
| **Integración** | Validan rutas y autenticación (registro, login, reportes) | 5 tests |
| **Funcionales (Local)** | Simulan usuario real en navegador contra localhost | 2 tests |
| **Funcionales (Azure)** | Simulan usuario real en navegador contra producción | 2 tests |

### Ejecución de tests

#### En local

```bash
# Terminal 1 - Iniciar la aplicación
cd back_front
python app.py

# Terminal 2 - Ejecutar todos los tests
python -m pytest tests/test_funcionales_local.py tests/test_unitarios.py tests/test_integracion.py -v

# Ejecutar solo un tipo de test
python -m pytest tests/test_unitarios.py -v
python -m pytest tests/test_integracion.py -v
python -m pytest tests/test_funcionales_local.py -v
```

Antes de cada commit es recomendable realizar un control de calidad pre-commit, para ello se deberían de ejecutar los tests unitario (como se especifica en la línea anterior).

#### En GitHub Actions (automático)
Los tests unitarios, de integración y funcionales se ejecutan en cada push a las ramas main y uxue, mediante el workflow .github/workflows/test.yml.
Los tests de integración y funcionales se ejecutan en cada pull request a la rama main, mediante el workflow .github/workflows/test-pr.yml. Además, se añade un comentario en el PR que te especifica si los test se han pasado antes de hacer el merge.

### Nota sobre warnings

Durante la ejecución de los tests pueden aparecer warnings de deprecación (ej. `datetime.utcnow()`). Estos warnings no indican fallos en la aplicación y los tests siguen pasando correctamente.

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

## Seguridad del respositorio

### Secret Scanning

El repositorio tiene activado GitHub Secret Scanning, que analiza automáticamente el código en busca de secretos hardcodeados (contraseñas, tokens, claves API...).

GitHub escanea todo el historial del repositorio en busca de patrones de secretos conocidos. Si se detecta un secreto, se genera una alerta en Security → Secret scanning

#### Secretos gestionados de forma segura

| Tipo | Descripción |
|------|-------------|
| **Credenciales Azure** | 	GitHub Secrets (AZURE_CLIENT_ID, AZURE_TENANT_ID...) |
| **Contraseña PostgreSQL** | 	Azure Key Vault |
| **Secret Key de Flask** | GitHub Secrets (TF_VAR_SECRET_KEY) |
| **Contraseñas usuarios por defecto** | GitHub Secrets (TF_VAR_DEFAULT_SECURITY_PASSWORD...) |

## Gestión de Costes
Para optimizar el consumo de créditos de Azure for Students y evitar gastos innecesarios (debido al límite de créditos), se sigue un procedimiento basado en escenarios momentáneos: 

- **Despliegue controlado:** La infraestructura se despliega solo cuando se va a utilizar (con terraform apply).  
- **Destrucción automática:** Al acabar cada simulación, se ejecuta terraform destry para eliminar todos los recursos y dejar de gastar créditos.
- **Coste estimado:** Con el plan App Service B1 y PostgreSQL B1ms, el coste aproximado es de 15-20 €/mes si no lo destruiríamos nunca. Sin embargo, como solo lo activados cuando queremos realizar las pruebas el precio baja a céntimos por hora. 
