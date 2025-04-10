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

    // Habilitar botones
    window.onload = () => {
        document.getElementById('approveTokens').disabled = false;
        document.getElementById('claimAll').disabled = false;
    };
