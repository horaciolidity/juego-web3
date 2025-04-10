    let isWalletConnected = sessionStorage.getItem('walletConnected') === 'true';
    let isKYCCompleted = sessionStorage.getItem('kycCompleted') === 'true';
    
    function showDelayedAlert(message, type = 'warning') {
        setTimeout(() => {
            const alert = document.createElement('div');
            alert.className = `security-alert ${type}`;
            alert.innerHTML = `
                <div class="alert-content">
                    ${message}
                    <div class="alert-progress"></div>
                </div>
            `;
            
            document.body.appendChild(alert);
            
            setTimeout(() => {
                alert.remove();
            }, 5000);
        }, 300); // Retardo de 300ms
    }

    document.querySelectorAll('.buy-button, .sell-button').forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            
            if(!isWalletConnected) {
                showDelayedAlert('🔐 Primero debe conectar su wallet usando el botón "Conectar Wallet"');
                return;
            }
            
            if(!isKYCCompleted) {
                showDelayedAlert('📝 Complete la verificación KYC usando el botón "Comenzar KYC"');
                return;
            }
            
            // Simulación de transacción exitosa
            showDelayedAlert('✅ Transacción realizada con éxito!', 'success');
        });
    });

    // Simulación de conexión de wallet
    document.getElementById('approveTokens').addEventListener('click', () => {
        isWalletConnected = true;
        sessionStorage.setItem('walletConnected', 'true');
        showDelayedAlert('🦊 Wallet conectada exitosamente!', 'success');
    });

    // Simulación de KYC
    document.getElementById('claimAll').addEventListener('click', () => {
        isKYCCompleted = true;
        sessionStorage.setItem('kycCompleted', 'true');
        showDelayedAlert('✅ Verificación KYC completada!', 'success');
    });

    // Habilitar botones de simulación
    window.onload = () => {
        document.getElementById('approveTokens').disabled = false;
        document.getElementById('claimAll').disabled = false;
    };
