import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

from back_front.models import User, Incident, Comment
from datetime import datetime

def test_create_user():
    """Prueba unitaria: creación de usuario"""
    user = User(
        username="testuser",
        email="test@example.com",
        role="employee",
        active=True
    )
    user.set_password("Test123!")
    
    assert user.username == "testuser"
    assert user.email == "test@example.com"
    assert user.role == "employee"
    assert user.active == True
    assert user.check_password("Test123!") == True

def test_user_is_security():
    """Prueba unitaria: verificar rol de seguridad"""
    security_user = User(username="admin", email="admin@test.com", role="security")
    employee_user = User(username="emp", email="emp@test.com", role="employee")
    
    assert security_user.is_security() == True
    assert employee_user.is_security() == False

def test_incident_severity_color():
    """Prueba unitaria: colores de severidad"""
    incident = Incident(severity="critical")
    assert incident.get_severity_color() == "dark"
    
    incident.severity = "high"
    assert incident.get_severity_color() == "danger"
    
    incident.severity = "medium"
    assert incident.get_severity_color() == "warning"
    
    incident.severity = "low"
    assert incident.get_severity_color() == "success"

def test_incident_status_color():
    """Prueba unitaria: colores de estado"""
    incident = Incident(status="pending")
    assert incident.get_status_color() == "warning"
    
    incident.status = "investigating"
    assert incident.get_status_color() == "info"
    
    incident.status = "resolved"
    assert incident.get_status_color() == "success"
    
    incident.status = "false_positive"
    assert incident.get_status_color() == "secondary"