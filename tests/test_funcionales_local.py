import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))

import pytest
import time
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

# Detectar si estamos en GitHub Actions
IN_GITHUB_ACTIONS = os.getenv('GITHUB_ACTIONS') == 'true'

@pytest.fixture
def driver():
    """Configura el WebDriver para pruebas funcionales"""
    options = Options()
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-dev-shm-usage')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1920,1080')
    # Desactivar logs de Chrome
    options.add_experimental_option('excludeSwitches', ['enable-logging'])
    
    if IN_GITHUB_ACTIONS:
        options.binary_location = '/usr/bin/chromium-browser'
        driver = webdriver.Chrome(options=options)
    else:
        driver = webdriver.Chrome(options=options)
    
    yield driver
    driver.quit()

def test_pagina_inicio_local(driver):
    """Test funcional LOCAL: la página de inicio carga correctamente"""
    driver.get('http://localhost:5000')
    time.sleep(2)
    assert "SecureIncident" in driver.page_source or "Incident" in driver.page_source

def test_registro_y_login_local(driver):
    """Test funcional LOCAL: flujo de registro y login"""
    import random
    unique_id = random.randint(1000, 9999)
    unique_email = f"testlocal{unique_id}@test.com"
    
    driver.get('http://localhost:5000/registro')
    time.sleep(2)
    
    # Registrar usuario
    driver.find_element(By.NAME, "username").send_keys(f"testlocal{unique_id}")
    driver.find_element(By.NAME, "email").send_keys(unique_email)
    driver.find_element(By.NAME, "password").send_keys("Test123!")
    
    # Hacer clic en el botón de registro
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    time.sleep(3)
    
    # Verificar redirección a login (debe contener "login" en la URL)
    current_url = driver.current_url
    print(f"URL después de registro: {current_url}")
    assert "login" in current_url, f"Se esperaba 'login' en la URL, pero se obtuvo: {current_url}"
    
    # Iniciar sesión
    driver.find_element(By.NAME, "email").send_keys(unique_email)
    driver.find_element(By.NAME, "password").send_keys("Test123!")
    driver.find_element(By.CSS_SELECTOR, "button[type='submit']").click()
    time.sleep(3)
    
    # Verificar dashboard
    current_url = driver.current_url
    print(f"URL después de login: {current_url}")
    assert "dashboard" in current_url, f"Se esperaba 'dashboard' en la URL, pero se obtuvo: {current_url}"