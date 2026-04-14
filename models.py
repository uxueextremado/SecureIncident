from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

db = SQLAlchemy()

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(200), nullable=False)
    role = db.Column(db.String(20), default='employee')
    active = db.Column(db.Boolean, default=True)  # Campo para deshabilitar usuarios
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    incidents = db.relationship('Incident', backref='reporter', lazy=True, foreign_keys='Incident.user_id')
    comments = db.relationship('Comment', backref='author', lazy=True)
    assigned_incidents = db.relationship('Incident', backref='assignee', lazy=True, foreign_keys='Incident.assigned_to')
    
    def set_password(self, password):
        self.password_hash = generate_password_hash(password)
    
    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
    
    def is_security(self):
        return self.role == 'security'
    
    def is_active(self):
        return self.active

class Incident(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    description = db.Column(db.Text, nullable=False)
    incident_type = db.Column(db.String(50))
    severity = db.Column(db.String(20), default='medium')
    status = db.Column(db.String(20), default='pending')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    assigned_to = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=True)
    
    comments = db.relationship('Comment', backref='incident', lazy=True, cascade='all, delete-orphan')
    
    def get_severity_color(self):
        colors = {
            'low': 'success',
            'medium': 'warning',
            'high': 'danger',
            'critical': 'dark'
        }
        return colors.get(self.severity, 'secondary')
    
    def get_status_color(self):
        colors = {
            'pending': 'warning',
            'investigating': 'info',
            'resolved': 'success',
            'false_positive': 'secondary'
        }
        return colors.get(self.status, 'secondary')

class Comment(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'))
    incident_id = db.Column(db.Integer, db.ForeignKey('incident.id'))