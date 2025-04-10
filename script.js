 // Sistema Ficticio
    let isWalletConnected = false;
    let isKYCCompleted = false;
    
    function showAlert(message, type = 'warning') {
        const alert = document.createElement('div');
        alert.className = `centered-alert ${type}`;
        alert.innerHTML = `
            <div class="alert-content">
                ${message}
                <div class="alert-progress"></div>
            </div>
        `;
        
        document.body.appendChild(alert);
        
        setTimeout(() => {
            alert.classList.add('fade-out');
            setTimeout(() => alert.remove(), 300);
        }, 3000);
    }

    // Controladores de Botones
    document.querySelectorAll('.buy-button, .sell-button').forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            
            if(!isWalletConnected) {
                showAlert('⚠️ Primero debe conectar su wallet', 'warning');
                return;
            }
            
            if(!isKYCCompleted) {
                showAlert('🔐 Complete la verificación KYC', 'warning');
                return;
            }
            
            showAlert('✅ Transacción exitosa!', 'success');
        });
    });

    document.getElementById('approveTokens').addEventListener('click', () => {
        isWalletConnected = true;
        showAlert('🦊 Wallet conectada!', 'success');
    });

    document.getElementById('claimAll').addEventListener('click', () => {
        isKYCCompleted = true;
        showAlert('✅ KYC completado!', 'success');
    });
 // Función para mezclar array (Fisher-Yates)
    function shuffleArray(array) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        return array;
    }

    // Función para actualizar anuncios
    function actualizarAnuncios() {
        const contenedor = document.querySelector('.sad-list');
        const anuncios = Array.from(contenedor.children);
        
        // Mezclar anuncios
        const anunciosMezclados = shuffleArray(anuncios);
        
        // Limpiar contenedor
        while (contenedor.firstChild) {
            contenedor.removeChild(contenedor.firstChild);
        }
        
        // Volver a agregar anuncios mezclados
        anunciosMezclados.forEach(anuncio => {
            contenedor.appendChild(anuncio);
        });
    }

    // Actualizar cada 5 segundos (5000ms)
    setInterval(actualizarAnuncios, 5000);

    // También puedes agregar un botón para actualización manual
    const refreshButton = document.createElement('button');
    refreshButton.textContent = '🔄 Actualizar anuncios';
    refreshButton.style.position = 'fixed';
    refreshButton.style.bottom = '100px';
    refreshButton.style.right = '20px';
    refreshButton.style.zIndex = '1000';
    refreshButton.onclick = actualizarAnuncios;
    document.body.appendChild(refreshButton);

    // Habilitar botones
    window.onload = () => {
        document.getElementById('approveTokens').disabled = false;
        document.getElementById('claimAll').disabled = false;
    };
