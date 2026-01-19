// Default Settings
let settings = {
    position: 'left',
    colors: {
        primary: '#4ade80',
        health: '#4ade80',
        armor: '#4ade80',
        hunger: '#4ade80',
        thirst: '#4ade80',
        fuel: '#4ade80',
        voiceNormal: '#fbbf24',
        voiceRadio: '#22d3ee'
    },
    opacity: 0.95,
    scale: 1.0
};

let inVehicle = false;
let voiceRange = 1;

// Elements
const hudContainer = document.getElementById('hud-container');
const walkingHud = document.getElementById('walking-hud');
const vehicleHud = document.getElementById('vehicle-hud');
const settingsModal = document.getElementById('settings-modal');

// Update Circle
function updateCircle(id, value, max = 100) {
    const circle = document.getElementById(id);
    if (!circle) return;
    
    const circumference = 276;
    const offset = circumference - (value / max) * circumference;
    circle.style.strokeDashoffset = offset;
}

// Show/Hide Stamina - only when running and depleting
function updateStamina(value, showStamina) {
    const staminaWalk = document.getElementById('stamina-ring-walk');
    const staminaVehicle = document.getElementById('stamina-ring-vehicle');
    
    if (showStamina) {
        if (staminaWalk) staminaWalk.classList.remove('hidden');
        if (staminaVehicle) staminaVehicle.classList.remove('hidden');
        updateCircle('stamina-circle', value);
        updateCircle('stamina-circle-v', value);
    } else {
        if (staminaWalk) staminaWalk.classList.add('hidden');
        if (staminaVehicle) staminaVehicle.classList.add('hidden');
    }
}

// Show/Hide Oxygen
function updateOxygen(value, isUnderwater) {
    const oxygenWalk = document.getElementById('oxygen-ring-walk');
    const oxygenVehicle = document.getElementById('oxygen-ring-vehicle');
    
    if (isUnderwater) {
        if (oxygenWalk) oxygenWalk.classList.remove('hidden');
        if (oxygenVehicle) oxygenVehicle.classList.remove('hidden');
        updateCircle('oxygen-circle', value);
        updateCircle('oxygen-circle-v', value);
    } else {
        if (oxygenWalk) oxygenWalk.classList.add('hidden');
        if (oxygenVehicle) oxygenVehicle.classList.add('hidden');
    }
}

// Update Speedometer
function updateSpeedometer(speed, maxSpeed = 300) {
    const speedValue = document.getElementById('speed-value');
    const speedCircle = document.getElementById('speed-circle');
    
    if (speedValue) {
        speedValue.textContent = Math.floor(speed);
    }
    
    if (speedCircle) {
        const progress = Math.min(speed / maxSpeed, 1);
        const dashOffset = 400 - (267 * progress);
        speedCircle.style.strokeDashoffset = dashOffset;
    }
}

// Update RPM
function updateRPM(rpm) {
    const rpmCircle = document.getElementById('rpm-circle');
    const rpmValue = document.getElementById('rpm-value');
    
    if (rpmValue) {
        rpmValue.textContent = Math.floor(rpm * 10000);
    }
    
    if (rpmCircle) {
        const dashOffset = 471 - (314 * rpm);
        rpmCircle.style.strokeDashoffset = dashOffset;
    }
}

// Update Voice Range Display
function updateVoiceRange(range) {
    voiceRange = range;
    const voiceRangeEl = document.getElementById('voice-range');
    const voiceRangeV = document.getElementById('voice-range-v');
    
    if (voiceRangeEl) voiceRangeEl.textContent = range;
    if (voiceRangeV) voiceRangeV.textContent = range;
}

// Update Voice with Mute Icon
function updateVoice(talking, radioTalking) {
    // Walking mode elements
    const voiceCircle = document.getElementById('voice-circle');
    const voiceIcon = document.getElementById('voice-icon');
    const micMuted = document.getElementById('mic-muted');
    const micActive = document.getElementById('mic-active');
    
    // Vehicle mode elements
    const voiceCircleV = document.getElementById('voice-circle-v');
    const voiceIconV = document.getElementById('voice-icon-v');
    const micMutedV = document.getElementById('mic-muted-v');
    const micActiveV = document.getElementById('mic-active-v');
    
    // Update walking mode
    if (voiceCircle && voiceIcon) {
        voiceCircle.classList.remove('talking', 'radio');
        voiceIcon.classList.remove('talking', 'radio');
        
        if (radioTalking) {
            // Radio talking - CYAN color
            voiceCircle.classList.add('radio', 'talking');
            voiceIcon.classList.add('radio', 'talking');
            micMuted.classList.add('hidden');
            micActive.classList.remove('hidden');
            updateCircle('voice-circle', 100);
        } else if (talking) {
            // Normal talking - YELLOW color
            voiceCircle.classList.add('talking');
            voiceIcon.classList.add('talking');
            micMuted.classList.add('hidden');
            micActive.classList.remove('hidden');
            updateCircle('voice-circle', 100);
        } else {
            // Muted - no color
            micMuted.classList.remove('hidden');
            micActive.classList.add('hidden');
            updateCircle('voice-circle', 30);
        }
    }
    
    // Update vehicle mode
    if (voiceCircleV && voiceIconV) {
        voiceCircleV.classList.remove('talking', 'radio');
        voiceIconV.classList.remove('talking', 'radio');
        
        if (radioTalking) {
            // Radio talking - CYAN color
            voiceCircleV.classList.add('radio', 'talking');
            voiceIconV.classList.add('radio', 'talking');
            micMutedV.classList.add('hidden');
            micActiveV.classList.remove('hidden');
            updateCircle('voice-circle-v', 100);
        } else if (talking) {
            // Normal talking - YELLOW color
            voiceCircleV.classList.add('talking');
            voiceIconV.classList.add('talking');
            micMutedV.classList.add('hidden');
            micActiveV.classList.remove('hidden');
            updateCircle('voice-circle-v', 100);
        } else {
            // Muted - no color
            micMutedV.classList.remove('hidden');
            micActiveV.classList.add('hidden');
            updateCircle('voice-circle-v', 30);
        }
    }
}

// Receive messages from game
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'show':
            hudContainer.classList.remove('hidden');
            if (data.settings) {
                applySettings(data.settings);
            }
            break;
            
        case 'hide':
            hudContainer.classList.add('hidden');
            break;
            
        case 'update':
            if (inVehicle) {
                updateCircle('health-circle-v', data.health);
                updateCircle('armor-circle-v', data.armor);
                
                if (data.vehicle) {
                    updateSpeedometer(data.vehicle.speed);
                    updateRPM(data.vehicle.rpm || 0);
                    updateCircle('fuel-circle', data.vehicle.fuel);
                    
                    const gearValue = document.getElementById('gear-value');
                    if (gearValue) {
                        if (data.vehicle.gear === 0) {
                            gearValue.textContent = 'R';
                        } else if (data.vehicle.gear === -1) {
                            gearValue.textContent = 'N';
                        } else {
                            gearValue.textContent = data.vehicle.gear;
                        }
                    }
                }
            } else {
                updateCircle('health-circle', data.health);
                updateCircle('armor-circle', data.armor);
            }
            
            updateVoice(data.talking, data.radioTalking);
            
            // Update Stamina and Oxygen
            updateStamina(data.stamina, data.showStamina);
            updateOxygen(data.oxygen, data.isUnderwater);
            break;
            
        case 'enterVehicle':
            inVehicle = true;
            walkingHud.classList.add('hidden');
            vehicleHud.classList.remove('hidden');
            break;
            
        case 'exitVehicle':
            inVehicle = false;
            vehicleHud.classList.add('hidden');
            walkingHud.classList.remove('hidden');
            updateSpeedometer(0);
            updateRPM(0);
            break;
            
        case 'updateVoiceRange':
            updateVoiceRange(data.range);
            break;
            
        case 'openSettings':
            if (data.settings) {
                settings = data.settings;
                loadSettingsUI();
            }
            settingsModal.classList.remove('hidden');
            break;
            
        case 'closeSettings':
            settingsModal.classList.add('hidden');
            break;
            
        case 'applySettings':
            if (data.settings) {
                applySettings(data.settings);
            }
            break;
    }
});

// Apply Settings
function applySettings(newSettings) {
    settings = newSettings;
    
    hudContainer.classList.remove('hud-left', 'hud-center', 'hud-right');
    hudContainer.classList.add('hud-' + settings.position);
    
    const root = document.documentElement;
    root.style.setProperty('--primary', settings.colors.primary);
    root.style.setProperty('--health', settings.colors.health);
    root.style.setProperty('--armor', settings.colors.armor);
    root.style.setProperty('--hunger', settings.colors.hunger);
    root.style.setProperty('--thirst', settings.colors.thirst);
    root.style.setProperty('--fuel', settings.colors.fuel);
    root.style.setProperty('--voice-normal', settings.colors.voiceNormal);
    root.style.setProperty('--voice-radio', settings.colors.voiceRadio);
    
    root.style.setProperty('--hud-opacity', settings.opacity);
    root.style.setProperty('--hud-scale', settings.scale);
}

// Load Settings UI
function loadSettingsUI() {
    document.querySelectorAll('.pos-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.pos === settings.position) {
            btn.classList.add('active');
        }
    });
    
    document.getElementById('color-primary').value = settings.colors.primary;
    document.getElementById('color-health').value = settings.colors.health;
    document.getElementById('color-armor').value = settings.colors.armor;
    document.getElementById('color-hunger').value = settings.colors.hunger;
    document.getElementById('color-thirst').value = settings.colors.thirst;
    document.getElementById('color-fuel').value = settings.colors.fuel;
    document.getElementById('color-voiceNormal').value = settings.colors.voiceNormal;
    document.getElementById('color-voiceRadio').value = settings.colors.voiceRadio;
    
    document.getElementById('opacity-slider').value = settings.opacity * 100;
    document.getElementById('opacity-value').textContent = Math.round(settings.opacity * 100) + '%';
    document.getElementById('scale-slider').value = settings.scale * 100;
    document.getElementById('scale-value').textContent = Math.round(settings.scale * 100) + '%';
}

function setPosition(pos) {
    settings.position = pos;
    document.querySelectorAll('.pos-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.dataset.pos === pos) btn.classList.add('active');
    });
    applySettings(settings);
}

function updateColor(type, value) {
    settings.colors[type] = value;
    applySettings(settings);
}

function updateOpacity(value) {
    settings.opacity = value / 100;
    document.getElementById('opacity-value').textContent = value + '%';
    applySettings(settings);
}

function updateScale(value) {
    settings.scale = value / 100;
    document.getElementById('scale-value').textContent = value + '%';
    applySettings(settings);
}

function saveSettings() {
    fetch('https://Vx-hud/saveSettings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ settings: settings })
    });
    closeSettings();
}

function resetSettings() {
    settings = {
        position: 'left',
        colors: {
            primary: '#4ade80',
            health: '#4ade80',
            armor: '#4ade80',
            hunger: '#4ade80',
            thirst: '#4ade80',
            fuel: '#4ade80',
            voiceNormal: '#fbbf24',
            voiceRadio: '#22d3ee'
        },
        opacity: 0.95,
        scale: 1.0
    };
    loadSettingsUI();
    applySettings(settings);
}

function closeSettings() {
    settingsModal.classList.add('hidden');
    fetch('https://Vx-hud/closeSettings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

settingsModal.addEventListener('click', function(e) {
    if (e.target === settingsModal) closeSettings();
});

// Initialize
document.addEventListener('DOMContentLoaded', function() {
    updateCircle('health-circle', 100);
    updateCircle('armor-circle', 50);
    updateCircle('voice-circle', 30);
});
