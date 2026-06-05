# Aplicación web - SecureIncident

La aplicación web está desarrollada con Flask (Python), HTML5, CSS3, Bootstrap 5 y Jinja2. Incluye los siguientes dashboards:

- **Dashboard de autenticación:** Registro (se pide nombre de usuario, email y contraseña), login (se pide email y contraseña) y roles diferenciados (empleado / seguridad). Cada usuario nuevo que se crea pertenecerá al rol empleado, para evitar los accesos excesivos.
- **Dashboard para empleados:** Tabla de incidentes propios (total reportados, pendientes, en investigación y resueltos), historial de incidentes reportados con los datos principales y formulario para reportar un nuevo incidente, donde se pide título, tipo (phising, malware, dispositivo perdido/borrado,acceso no autorizado, fuga de información o otro tipo), severidad (baja, media, alta o crítica) y descripción detallada del incidente.
- **Dashboard para seguridad:** Tabla de incidentes globales (total reportados, pendientes, en investigación y resueltos), historial de incidentes reportados con los datos principales y panel de gestión de usuarios, donde tenemos un listado de todos los usuarios con su información (ID, nombre de usuario, email, rol, estado y fecha de registro) y acciones para habilitar o deshabilitar (para evitar que usuarios que no se utilizan sigan teniendo acceso). Además, desde el historial de incidentes podemos acceder a cada uno para realizar diferentes acciones como; añadir un comentarios o cambiar el nivel de estado y severidad.


## Despliegue en local
Para ejecutar la aplicación en un entorno de desarrollo local, se siguen los siguientes pasos:

1. Requisitos previos instalados: Python 3.12 (o superior) y Git.

2. Clonación del repositorio:

*git clone https://github.com/uxueextremado/SecureIncident.git*
*cd SecureIncident*

3. Creación y activación del entorno virtual:

*Windows*
*python -m venv venv*
*venv\Scripts\activate*

*Linux/Mac*
*python -m venv venv*
*source venv/bin/activate*

4. Instalación de dependencias de desarrollo:

*pip install -r back_front/requirements_local.txt*

Existen dos archivos distintos de requirements según el entorno. En local, se instala requirements_local.txt y excluye psycopg2-binary y opencensus-ext-azure. En la nube (Azure), se utiliza requirements.txt e incluye todas las dependencias.

5. Configuración de las variables de entorno

Creamos un archivo .env siguiendo el modelo de .env.example y reemplazando los valores de las siguientes variables: SECRET_KEY, DEFAULT_SECURITY_PASSWORD y DEFAULT_EMPLOYEE_PASSWORD.

6. Ejecución de la aplicación:

*cd back_front*
*python app.py*

7. Acceso a la web:

Abrimos en el navegador la dirección http://127.0.0.1:5000

## Logs y monitorización

La aplicación genera logs en diferentes niveles (INFO, WARNING, ERROR, DEBUG) que se envían a:

- **Application Insights**: Para consultar logs almacenados y métricas de rendimiento
- **Log Analytics Workspace**: Para análisis histórico y consultas KQL
- **Log stream**: Para ver logs en tiempo real desde Azure Portal

### Niveles de log implementados

| Nivel | Uso |
|-------|-----|
| INFO | Acciones normales |
| WARNING | Situaciones anómalas |
| ERROR | Errores críticos |
| DEBUG | Información detallada |

### Verificación de logs en Azure

```kusto
// Consulta en Application Insights
traces
| order by timestamp desc
| take 20

// Consulta por nivel de severidad (0: DEBUG , 1:INFO, 2: WARNING, 3: ERROR)
traces
| where severityLevel == 1  // INFO
| take 10

