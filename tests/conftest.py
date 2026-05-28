import sys
import os
import pytest

# Añadir la ruta de back_front para poder importar app y models
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'back_front'))

from back_front.app import app, db
from back_front.models import User

@pytest.fixture
def app_context():
    """Fixture que proporciona el contexto de la aplicación"""
    with app.app_context():
        yield app

@pytest.fixture
def test_client():
    """Fixture que proporciona un cliente de prueba (sin autenticación real)"""
    app.config['TESTING'] = True
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///:memory:'
    app.config['WTF_CSRF_ENABLED'] = False
    app.config['LOGIN_DISABLED'] = True
    
    with app.test_client() as client:
        with app.app_context():
            db.create_all()
            yield client
            db.drop_all()