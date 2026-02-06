function openTab(tabId) {
            const tabContents = document.querySelectorAll('.tab-content');
            tabContents.forEach(content => {
                content.classList.remove('active');
            });
            
            
            const tabs = document.querySelectorAll('.tab');
            tabs.forEach(tab => {
                tab.classList.remove('active');
            });
            
        
            document.getElementById(tabId).classList.add('active');
            event.currentTarget.classList.add('active');
        }
        
    
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', function(e) {
                e.preventDefault();
                
                const targetId = this.getAttribute('href');
                if(targetId === '#') return;
                
                const targetElement = document.querySelector(targetId);
                if(targetElement) {
                    window.scrollTo({
                        top: targetElement.offsetTop - 80,
                        behavior: 'smooth'
                    });
                }
            });
        });
        
    
        document.querySelector('.btn-dmg').addEventListener('click', function(e) {
            e.preventDefault();
            alert('In a real implementation, this would download the NetBar_Installer.dmg file.\n\nFor now, you can visit the GitHub releases page:\nhttps://github.com/iad1tya/Net-Bar/releases');
        });
        
    
        document.addEventListener('DOMContentLoaded', function() {
            const yearElement = document.querySelector('.copyright p');
            if(yearElement) {
                yearElement.innerHTML = yearElement.innerHTML.replace('2026', new Date().getFullYear());
            }
        });

        
        
