document.addEventListener('DOMContentLoaded', function() {
    // DOM Elements
    const networkElement = document.querySelector('.status-item:nth-child(1) .status-value');
    const cpuElement = document.querySelector('.status-item:nth-child(2) .status-value');
    const ramElement = document.querySelector('.status-item:nth-child(3) .status-value');
    const hddElement = document.querySelector('.status-item:nth-child(4) .status-value');
    
    const downloadValue = document.querySelector('.traffic-item:nth-child(1) .traffic-value');
    const uploadValue = document.querySelector('.traffic-item:nth-child(2) .traffic-value');
    const totalValue = document.querySelector('.traffic-item:nth-child(3) .traffic-value');
    
    const downloadBar = document.querySelector('.traffic-bar.download');
    const uploadBar = document.querySelector('.traffic-bar.upload');
    const totalBar = document.querySelector('.traffic-bar.total');
    
    const connectionValues = document.querySelectorAll('.connection-value');
    const progressFills = document.querySelectorAll('.progress-fill');
    const resourceValues = document.querySelectorAll('.resource-value');
    const thermalBadge = document.querySelector('.thermal-badge');
    
    // Initial values
    let networkSpeed = 7.99;
    let cpuUsage = 9.8;
    let ramUsage = 64.7;
    let hddUsage = 83.8;
    let downloadMB = 1.44;
    let uploadMB = 4.52;
    let totalMB = 5.95;
    let batteryLevel = 74;
    
    // Connection initial values
    let linkRate = 7;
    let signalStrength = -80;
    let noiseLevel = -94;
    
    // Color utilities
    function getColorForValue(value, type) {
        if (type === 'cpu' || type === 'ram' || type === 'hdd') {
            if (value < 50) return '#66be69'; // Green
            if (value < 75) return '#FF9800'; // Orange
            return '#FF5252'; // Red
        }
        if (type === 'network') {
            if (value > 50) return '#66be69'; // Green
            if (value > 10) return '#FF9800'; // Orange
            return '#FF5252'; // Red
        }
        if (type === 'signal') {
            if (value > -60) return '#66be69'; // Green
            if (value > -80) return '#FF9800'; // Orange
            return '#FF5252'; // Red
        }
        return '#58a6ff';
    }
    
    function updateStatusBar() {
        // Network speed fluctuation
        networkSpeed = Math.max(0.5, Math.min(50, networkSpeed + (Math.random() * 2 - 1)));
        networkElement.textContent = networkSpeed.toFixed(2) + ' Kbps';
        networkElement.style.background = `linear-gradient(90deg, ${getColorForValue(networkSpeed, 'network')}, #a78bfa)`;
        networkElement.style.webkitBackgroundClip = 'text';
        networkElement.style.webkitTextFillColor = 'transparent';
        
        // CPU fluctuation
        cpuUsage = Math.max(0, Math.min(100, cpuUsage + (Math.random() * 6 - 3)));
        cpuElement.textContent = Math.round(cpuUsage) + '%';
        cpuElement.style.background = `linear-gradient(90deg, ${getColorForValue(cpuUsage, 'cpu')}, #a78bfa)`;
        cpuElement.style.webkitBackgroundClip = 'text';
        cpuElement.style.webkitTextFillColor = 'transparent';
        
        // RAM fluctuation
        ramUsage = Math.max(0, Math.min(100, ramUsage + (Math.random() * 4 - 2)));
        ramElement.textContent = Math.round(ramUsage) + '%';
        ramElement.style.background = `linear-gradient(90deg, ${getColorForValue(ramUsage, 'ram')}, #a78bfa)`;
        ramElement.style.webkitBackgroundClip = 'text';
        ramElement.style.webkitTextFillColor = 'transparent';
        
        // HDD fluctuation (slow change)
        hddUsage = Math.max(0, Math.min(100, hddUsage + (Math.random() * 0.5 - 0.25)));
        hddElement.textContent = Math.round(hddUsage) + '%';
        hddElement.style.background = `linear-gradient(90deg, ${getColorForValue(hddUsage, 'hdd')}, #a78bfa)`;
        hddElement.style.webkitBackgroundClip = 'text';
        hddElement.style.webkitTextFillColor = 'transparent';
    }
    
    function updateTraffic() {
        // Simulate network traffic
        const downloadChange = Math.random() * 0.2;
        const uploadChange = Math.random() * 0.1;
        
        downloadMB = Math.max(0, downloadMB + downloadChange);
        uploadMB = Math.max(0, uploadMB + uploadChange);
        totalMB = downloadMB + uploadMB;
        
        // Update values
        downloadValue.textContent = downloadMB.toFixed(2) + ' MB';
        uploadValue.textContent = uploadMB.toFixed(2) + ' MB';
        totalValue.textContent = totalMB.toFixed(2) + ' MB';
        
        // Update bar widths
        const downloadPercent = Math.min(100, (downloadMB / (totalMB || 1)) * 100);
        const uploadPercent = Math.min(100, (uploadMB / (totalMB || 1)) * 100);
        
        downloadBar.style.width = downloadPercent + '%';
        uploadBar.style.width = uploadPercent + '%';
        totalBar.style.width = '100%';
        
        // Animate the bars
        downloadBar.style.transition = 'width 0.5s ease';
        uploadBar.style.transition = 'width 0.5s ease';
    }
    
    function updateConnection() {
        // Simulate connection changes
        linkRate = Math.max(1, Math.min(150, linkRate + (Math.random() * 10 - 5)));
        signalStrength = Math.max(-120, Math.min(-30, signalStrength + (Math.random() * 4 - 2)));
        noiseLevel = Math.max(-120, Math.min(-60, noiseLevel + (Math.random() * 2 - 1)));
        
        // Update values
        connectionValues[0].textContent = Math.round(linkRate) + ' Mbps';
        connectionValues[1].textContent = Math.round(signalStrength) + ' dBm';
        connectionValues[2].textContent = Math.round(noiseLevel) + ' dBm';
        
        // Update signal color
        connectionValues[1].style.color = getColorForValue(signalStrength, 'signal');
    }
    
    function updateSystemResources() {
        // Update progress bars and values
        progressFills[0].style.width = cpuUsage + '%';
        progressFills[0].style.backgroundColor = getColorForValue(cpuUsage, 'cpu');
        
        progressFills[1].style.width = ramUsage + '%';
        progressFills[1].style.backgroundColor = getColorForValue(ramUsage, 'ram');
        
        progressFills[2].style.width = hddUsage + '%';
        progressFills[2].style.backgroundColor = getColorForValue(hddUsage, 'hdd');
        
        // Battery fluctuation
        batteryLevel = Math.max(0, Math.min(100, batteryLevel - (Math.random() * 0.1)));
        progressFills[3].style.width = batteryLevel + '%';
        progressFills[3].style.backgroundColor = batteryLevel > 20 ? '#c26fd0' : '#FF5252';
        
        // Update resource values
        resourceValues[0].textContent = `Usage ${cpuUsage.toFixed(1)}%`;
        resourceValues[1].textContent = `Usage ${ramUsage.toFixed(1)}%`;
        resourceValues[2].textContent = `Usage ${hddUsage.toFixed(1)}%`;
        resourceValues[3].textContent = `Level ${Math.round(batteryLevel)}%`;
        
        // Update thermal state based on CPU usage
        if (cpuUsage > 80) {
            thermalBadge.textContent = 'State Critical';
            thermalBadge.style.backgroundColor = '#FF5252';
        } else if (cpuUsage > 60) {
            thermalBadge.textContent = 'State High';
            thermalBadge.style.backgroundColor = '#FF9800';
        } else {
            thermalBadge.textContent = 'State Normal';
            thermalBadge.style.backgroundColor = '#4CAF50';
        }
    }
    
    // Add hover effects to connection boxes
    document.querySelectorAll('.connection-box').forEach(box => {
        box.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-5px)';
            this.style.boxShadow = '0 10px 25px rgba(0, 0, 0, 0.3)';
        });
        
        box.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0)';
            this.style.boxShadow = 'none';
        });
    });
    
    // Add click effects to resource items
    document.querySelectorAll('.resource-item').forEach(item => {
        item.addEventListener('click', function() {
            this.style.backgroundColor = 'rgba(30, 41, 59, 0.95)';
            this.style.transform = 'scale(1.02)';
            
            setTimeout(() => {
                this.style.backgroundColor = 'rgba(30, 41, 59, 0.8)';
                this.style.transform = 'scale(1)';
            }, 300);
        });
    });
    
    // Add refresh functionality
    function refreshDashboard() {
        updateStatusBar();
        updateTraffic();
        updateConnection();
        updateSystemResources();
    }
    
    // Initial update
    refreshDashboard();
    
    // Update dashboard every 3 seconds
    setInterval(refreshDashboard, 3000);
    
    // Add a manual refresh button (optional - you can add this to your HTML)
    const refreshBtn = document.createElement('button');
    refreshBtn.innerHTML = '<i class="fas fa-sync-alt"></i> Refresh';
    refreshBtn.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        background: linear-gradient(90deg, #3b82f6, #8b5cf6);
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 20px;
        cursor: pointer;
        font-family: 'Inter', sans-serif;
        font-weight: 600;
        z-index: 1000;
        box-shadow: 0 4px 15px rgba(59, 130, 246, 0.3);
        transition: all 0.3s ease;
    `;
    
    refreshBtn.addEventListener('mouseenter', () => {
        refreshBtn.style.transform = 'scale(1.05)';
        refreshBtn.style.boxShadow = '0 6px 20px rgba(59, 130, 246, 0.4)';
    });
    
    refreshBtn.addEventListener('mouseleave', () => {
        refreshBtn.style.transform = 'scale(1)';
        refreshBtn.style.boxShadow = '0 4px 15px rgba(59, 130, 246, 0.3)';
    });
    
    refreshBtn.addEventListener('click', () => {
        refreshBtn.style.transform = 'scale(0.95)';
        setTimeout(() => {
            refreshBtn.style.transform = 'scale(1)';
        }, 150);
        refreshDashboard();
    });
    
    document.body.appendChild(refreshBtn);
    
    // Add network status indicator
    const networkStatus = document.createElement('div');
    networkStatus.innerHTML = '<i class="fas fa-circle"></i> Live';
    networkStatus.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: rgba(30, 41, 59, 0.9);
        color: #10b981;
        padding: 5px 15px;
        border-radius: 15px;
        font-size: 12px;
        font-weight: 600;
        border: 1px solid #334155;
        display: flex;
        align-items: center;
        gap: 8px;
        z-index: 1000;
    `;
    
    // Animate the dot
    setInterval(() => {
        const dot = networkStatus.querySelector('i');
        dot.style.opacity = dot.style.opacity === '0.5' ? '1' : '0.5';
    }, 1000);
    
    document.body.appendChild(networkStatus);
    
    // Add data usage animation
    function animateDataUsage() {
        const trafficIcons = document.querySelectorAll('.traffic-icon');
        trafficIcons.forEach(icon => {
            icon.style.transform = 'scale(1.1)';
            setTimeout(() => {
                icon.style.transform = 'scale(1)';
            }, 300);
        });
    }
    
    setInterval(animateDataUsage, 5000);
});
