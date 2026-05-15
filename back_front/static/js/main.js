// Cerrar alertas automáticamente después de 5 segundos
document.addEventListener('DOMContentLoaded', function() {
    setTimeout(function() {
        const alerts = document.querySelectorAll('.alert');
        alerts.forEach(function(alert) {
            const closeButton = alert.querySelector('.btn-close');
            if (closeButton) {
                closeButton.click();
            }
        });
    }, 5000);
});

// Confirmar antes de acciones importantes
function confirmAction(message) {
    return confirm(message || '¿Estás seguro de realizar esta acción?');
}

// Formatear fechas
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('es-ES');
}