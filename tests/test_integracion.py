import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from back_front.app import app, db
from back_front.models import User
import pytest

@pytest.fixture
def client():
    """Configura un cliente de prueba con base de datos en memoria"""
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    app.config['WTF_CSRF_ENABLED'] = False
    app.config['LOGIN_DISABLED'] = True
    
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
            yield client
            db.drop_all()

def test_index_page(client):
    """Test de integración: página de inicio"""
    response = client.get('/')
    assert response.status_code == 200
    assert b'SecureIncident' in response.data

def test_registro_usuario(client):
    """Test de integración: registro de nuevo usuario"""
    response = client.post('/registro', data={
        'username': 'testuser',
        'email': 'test@example.com',
        'password': 'Test123!'
    }, follow_redirects=True)
    
    assert response.status_code == 200
    assert b'Registro exitoso' in response.data

def test_login_exitoso(client):
    """Test de integración: inicio de sesión correcto"""
    # Primero crear usuario
    with app.app_context():
        user = User(username='testuser', email='test@example.com', role='employee')
        user.set_password('Test123!')
        db.session.add(user)
        db.session.commit()
    
    response = client.post('/login', data={
        'email': 'test@example.com',
        'password': 'Test123!'
    }, follow_redirects=True)
    
    assert response.status_code == 200
    assert b'Bienvenido' in response.data

def test_login_fallido(client):
    """Test de integración: inicio de sesión con credenciales incorrectas"""
    response = client.post('/login', data={
        'email': 'noexiste@test.com',
        'password': 'wrongpassword'
    }, follow_redirects=True)
    
    assert response.status_code == 200
    assert b'Email o contrase' in response.data

def test_reporte_incidente_sin_login(client):
    """Test de integración: reportar incidente sin estar logueado"""
    response = client.post('/reportar', data={
        'title': 'Incidente de prueba',
        'description': 'Descripción del incidente',
        'incident_type': 'phishing',
        'severity': 'high'
    }, follow_redirects=True)
    
    assert response.status_code == 200
    assert b'Iniciar sesi' in response.data or b'login' in response.data