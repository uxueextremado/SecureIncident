from flask import Flask, render_template, request, redirect, url_for, flash
from flask_login import LoginManager, login_user, logout_user, login_required, current_user
from models import db, User, Incident, Comment
from datetime import datetime
import os
from dotenv import load_dotenv

load_dotenv()

app = Flask(__name__,
            template_folder='templates',
            static_folder='static')
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv('DATABASE_URL', 'sqlite:///app.db')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db.init_app(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login'

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

# Crear tablas y usuarios por defecto (solo si no existen)
with app.app_context():
    db.create_all()
    
    # Crear usuario de seguridad por defecto (si no existe ninguno con rol 'security')
    if User.query.filter_by(role='security').count() == 0:
        admin_email = os.getenv('DEFAULT_SECURITY_EMAIL', 'security@secureincident.com')
        admin_user = os.getenv('DEFAULT_SECURITY_USERNAME', 'security_team')
        admin_pass = os.getenv('DEFAULT_SECURITY_PASSWORD')
        if admin_pass:
            admin = User(username=admin_user, email=admin_email, role='security', active=True)
            admin.set_password(admin_pass)
            db.session.add(admin)
            db.session.commit()
            print(f"✅ Usuario de seguridad creado: {admin_email}")
        else:
            print("⚠️ ADVERTENCIA: No se creó usuario de seguridad porque falta DEFAULT_SECURITY_PASSWORD")
    
    # Crear usuario empleado por defecto (solo si no existe ningún empleado)
    if User.query.filter_by(role='employee').count() == 0:
        emp_email = os.getenv('DEFAULT_EMPLOYEE_EMAIL', 'employee@secureincident.com')
        emp_user = os.getenv('DEFAULT_EMPLOYEE_USERNAME', 'employee1')
        emp_pass = os.getenv('DEFAULT_EMPLOYEE_PASSWORD')
        if emp_pass:
            employee = User(username=emp_user, email=emp_email, role='employee', active=True)
            employee.set_password(emp_pass)
            db.session.add(employee)
            db.session.commit()
            print(f"✅ Usuario empleado creado: {emp_email}")
        else:
            print("⚠️ ADVERTENCIA: No se creó usuario empleado porque falta DEFAULT_EMPLOYEE_PASSWORD")

# ==================== RUTAS PÚBLICAS ====================

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = User.query.filter_by(email=email).first()
        # Verificar credenciales y que el usuario esté activo
        if user and user.check_password(password) and user.active:
            login_user(user)
            flash(f'¡Bienvenido {user.username}!', 'success')
            return redirect(url_for('dashboard'))
        else:
            flash('Email o contraseña incorrectos, o usuario deshabilitado', 'danger')
    
    return render_template('login.html')

@app.route('/registro', methods=['GET', 'POST'])
def registro():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    
    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')
        
        if User.query.filter_by(email=email).first():
            flash('El email ya está registrado', 'danger')
        elif User.query.filter_by(username=username).first():
            flash('El nombre de usuario ya existe', 'danger')
        else:
            user = User(username=username, email=email, role='employee', active=True)
            user.set_password(password)
            db.session.add(user)
            db.session.commit()
            flash('Registro exitoso. Ahora puedes iniciar sesión', 'success')
            return redirect(url_for('login'))
    
    return render_template('registro.html')

@app.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Sesión cerrada correctamente', 'info')
    return redirect(url_for('index'))

# ==================== RUTAS DE EMPLEADO ====================

@app.route('/dashboard')
@login_required
def dashboard():
    if current_user.is_security():
        return redirect(url_for('security_dashboard'))
    
    incidents = Incident.query.filter_by(user_id=current_user.id).order_by(Incident.created_at.desc()).all()
    stats = {
        'total': len(incidents),
        'pending': len([i for i in incidents if i.status == 'pending']),
        'investigating': len([i for i in incidents if i.status == 'investigating']),
        'resolved': len([i for i in incidents if i.status == 'resolved'])
    }
    return render_template('dashboard_employee.html', incidents=incidents, stats=stats)

@app.route('/reportar', methods=['GET', 'POST'])
@login_required
def report_incident():
    if request.method == 'POST':
        incident = Incident(
            title=request.form.get('title'),
            description=request.form.get('description'),
            incident_type=request.form.get('incident_type'),
            severity=request.form.get('severity'),
            user_id=current_user.id
        )
        db.session.add(incident)
        db.session.commit()
        flash('Incidente reportado correctamente', 'success')
        return redirect(url_for('dashboard'))
    
    return render_template('report_incident.html')

@app.route('/incidente/<int:id>')
@login_required
def incident_detail(id):
    incident = Incident.query.get_or_404(id)
    
    # Verificar permisos
    if not current_user.is_security() and incident.user_id != current_user.id:
        flash('No tienes permiso para ver este incidente', 'danger')
        return redirect(url_for('dashboard'))
    
    return render_template('incident_detail.html', incident=incident)

# ==================== RUTAS DE EQUIPO DE SEGURIDAD ====================

@app.route('/security/dashboard')
@login_required
def security_dashboard():
    if not current_user.is_security():
        return redirect(url_for('dashboard'))
    
    incidents = Incident.query.order_by(Incident.created_at.desc()).all()
    security_users = User.query.filter_by(role='security').all()
    
    stats = {
        'total': Incident.query.count(),
        'pending': Incident.query.filter_by(status='pending').count(),
        'investigating': Incident.query.filter_by(status='investigating').count(),
        'resolved': Incident.query.filter_by(status='resolved').count(),
        'critical': Incident.query.filter_by(severity='critical').count()
    }
    
    return render_template('dashboard_security.html', incidents=incidents, stats=stats, security_users=security_users)

@app.route('/security/incidente/<int:id>/actualizar', methods=['POST'])
@login_required
def update_incident(id):
    if not current_user.is_security():
        flash('No autorizado', 'danger')
        return redirect(url_for('dashboard'))
    
    incident = Incident.query.get_or_404(id)
    incident.status = request.form.get('status')
    incident.severity = request.form.get('severity')
    
    if request.form.get('assigned_to'):
        incident.assigned_to = int(request.form.get('assigned_to'))
    
    incident.updated_at = datetime.utcnow()
    
    if request.form.get('comment'):
        comment = Comment(
            content=request.form.get('comment'),
            user_id=current_user.id,
            incident_id=id
        )
        db.session.add(comment)
    
    db.session.commit()
    flash('Incidente actualizado correctamente', 'success')
    return redirect(url_for('security_dashboard'))

@app.route('/security/incidente/<int:id>/comentar', methods=['POST'])
@login_required
def add_comment(id):
    if not current_user.is_security():
        flash('No autorizado', 'danger')
        return redirect(url_for('dashboard'))
    
    comment = Comment(
        content=request.form.get('comment'),
        user_id=current_user.id,
        incident_id=id
    )
    db.session.add(comment)
    db.session.commit()
    flash('Comentario añadido', 'success')
    return redirect(url_for('incident_detail', id=id))

@app.route('/security/incidente/<int:id>/eliminar', methods=['POST'])
@login_required
def delete_incident(id):
    if not current_user.is_security():
        flash('No autorizado', 'danger')
        return redirect(url_for('dashboard'))
    
    incident = Incident.query.get_or_404(id)
    db.session.delete(incident)
    db.session.commit()
    
    flash(f'Incidente #{id} eliminado correctamente', 'success')
    return redirect(url_for('security_dashboard'))

# ==================== GESTIÓN DE USUARIOS (SOLO SEGURIDAD) ====================

@app.route('/security/usuarios')
@login_required
def security_users():
    if not current_user.is_security():
        flash('No autorizado', 'danger')
        return redirect(url_for('dashboard'))
    users = User.query.order_by(User.created_at.desc()).all()
    return render_template('security_users.html', users=users)

@app.route('/security/usuario/<int:id>/toggle', methods=['POST'])
@login_required
def toggle_user_active(id):
    if not current_user.is_security():
        flash('No autorizado', 'danger')
        return redirect(url_for('dashboard'))
    
    user = User.query.get_or_404(id)
    
    # No permitir deshabilitar a uno mismo
    if user.id == current_user.id:
        flash('No puedes deshabilitar tu propio usuario', 'danger')
        return redirect(url_for('security_users'))
    
    # Cambiar estado
    user.active = not user.active
    db.session.commit()
    
    estado = "habilitado" if user.active else "deshabilitado"
    flash(f'Usuario {user.email} ha sido {estado}', 'success')
    return redirect(url_for('security_users'))

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)