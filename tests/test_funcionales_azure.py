import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import pytest
import time
import random
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Detectar si estamos en GitHub Actions
IN_GITHUB_ACTIONS = os.getenv('GITHUB_ACTIONS') == 'true'

URL_AZURE = "https://webapp-secureincident.azurewebsites.net"

@pytest.fixture
def driver():
    """Configura el WebDriver para pruebas funcionales"""
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920,1080')
    
    if IN_GITHUB_ACTIONS:
        options.binary_location = '/usr/bin/chromium-browser'
        driver = webdriver.Chrome(options=options)
    else:
        driver = webdriver.Chrome(options=options)
    
    yield driver
    driver.quit()

def test_pagina_inicio_azure(driver):
    """Test funcional AZURE: la página de inicio carga correctamente"""
    driver.get(f'{URL_AZURE}')
    assert "SecureIncident" in driver.title or "Incident" in driver.page_source

def test_registro_y_login_azure(driver):
    """Test funcional AZURE: flujo de registro y login"""
    # Generar email ÚNICO con timestamp + random
    unique_id = f"{int(time.time())}_{random.randint(10000, 99999)}"
    unique_email = f"testazure{unique_id}@test.com"
    
    driver.get(f'{URL_AZURE}/registro')
    
    # Esperar a que la página cargue completamente
    WebDriverWait(driver, 10).until(
        EC.presence_of_element_located((By.NAME, "username"))
    )
    
    # Registrar usuario
    driver.find_element(By.NAME, "username").send_keys(f"testazure{unique_id}")
    driver.find_element(By.NAME, "email").send_keys(unique_email)
    driver.find_element(By.NAME, "password").send_keys("Test123!")
    
    # Esperar a que el botón sea clickeable
    submit_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.CSS_SELECTOR, "button[type='submit']"))
    )
    submit_button.click()
    
    # Verificar redirección a login
    WebDriverWait(driver, 10).until(
        EC.url_contains("login")
    )
    assert "login" in driver.current_url
    
    # Iniciar sesión
    driver.find_element(By.NAME, "email").send_keys(unique_email)
    driver.find_element(By.NAME, "password").send_keys("Test123!")
    
    submit_button = WebDriverWait(driver, 10).until(
        EC.element_to_be_clickable((By.CSS_SELECTOR, "button[type='submit']"))
    )
    submit_button.click()
    
    # Verificar dashboard
    WebDriverWait(driver, 10).until(
        EC.url_contains("dashboard")
    )
    assert "dashboard" in driver.current_url