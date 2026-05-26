# Aplicación web - SecureIncident

La interfaz web está desarrollada con HTML5, CSS3, Bootstrap 5 y Jinja2, e incluye:

- **Autenticación** con registro/login y roles diferenciados (empleado / seguridad).
- **Dashboard para empleados:** estadísticas personales, tabla de incidentes propios y formulario de reporte con tipos predefinidos más la opción "Otro tipo".
- **Dashboard para seguridad:** estadísticas globales, tabla completa de incidentes con edición en línea (estado/severidad), eliminación y acceso a la gestión de usuarios.
- **Gestión de usuarios:** listado de todos los usuarios, visualización de estado (activo/deshabilitado) y acciones para habilitar o deshabilitar (solo seguridad).
- **Vista de detalle:** información completa del incidente, comentarios y panel de gestión para el equipo de seguridad.

## Despliegue en local
Para ejecutar la aplicación en un entorno de desarrollo local, sigue estos pasos:

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

Existen dos archivos distintos de requirements dependiendo de si el despliegue es en local o en Azure. En este caso, se instala requirements_local.txt que excluye psycopg2-binary y opencensus-ext-azure, los cuales no son neceasrios para el despliegue local.

5. Configuración de las variables de entorno

Creamos un archivo .env siguiendo el modelo de .env.example y reemplazando el valor de las variables SECRET_KEY, DEFAULT_SECURITY_PASSWORD y DEFAULT_EMPLOYEE_PASSWORD por los secretos y contraseñas correspondientes.

6. Ejecución de la aplicación:

*cd back_front*
*python app.py*

7. Acceso a la web:

Abrimos en el navegador la dirección http://127.0.0.1:5000
