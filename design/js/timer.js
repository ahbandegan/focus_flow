/**
 * Pomodoro Timer Logic
 */

const Timer = {
    state: 'idle', // 'idle', 'running', 'paused'
    mode: 'focus', // 'focus', 'shortBreak', 'longBreak'
    timeLeft: 0,
    totalTime: 0,
    intervalId: null,
    activeTaskId: null,
    pomodorosInSession: 0,
    
    ui: {
        display: null,
        progress: null,
        modeLabel: null,
        btnToggle: null,
        sessions: null
    },

    init() {
        this.ui.display = document.getElementById('timer-display');
        this.ui.progress = document.getElementById('timer-progress');
        this.ui.modeLabel = document.getElementById('timer-mode-label');
        this.ui.btnToggle = document.getElementById('btn-timer-toggle');
        this.ui.sessions = document.getElementById('timer-sessions');
        
        // Listeners
        document.getElementById('btn-timer-toggle').addEventListener('click', () => this.toggle());
        document.getElementById('btn-timer-reset').addEventListener('click', () => this.reset());
        document.getElementById('btn-timer-skip').addEventListener('click', () => this.skip());
        
        this.setMode('focus');
    },

    setMode(newMode) {
        this.mode = newMode;
        const settings = Store.getSettings();
        
        if (newMode === 'focus') {
            this.totalTime = settings.focusDuration * 60;
            this.ui.modeLabel.textContent = 'Focus Session';
            this.ui.modeLabel.className = 'text-sm font-medium uppercase tracking-widest mb-2 text-focus';
            this.ui.progress.classList.remove('text-break', 'text-longbreak');
            this.ui.progress.classList.add('text-focus');
        } else if (newMode === 'shortBreak') {
            this.totalTime = settings.shortBreak * 60;
            this.ui.modeLabel.textContent = 'Short Break';
            this.ui.modeLabel.className = 'text-sm font-medium uppercase tracking-widest mb-2 text-break';
            this.ui.progress.classList.remove('text-focus', 'text-longbreak');
            this.ui.progress.classList.add('text-break');
        } else if (newMode === 'longBreak') {
            this.totalTime = settings.longBreak * 60;
            this.ui.modeLabel.textContent = 'Long Break';
            this.ui.modeLabel.className = 'text-sm font-medium uppercase tracking-widest mb-2 text-longbreak';
            this.ui.progress.classList.remove('text-focus', 'text-break');
            this.ui.progress.classList.add('text-longbreak');
        }
        
        this.reset();
        this.updateSessionDots();
    },

    toggle() {
        if (this.state === 'running') {
            this.pause();
        } else {
            this.start();
        }
    },

    start() {
        if (this.timeLeft <= 0) return;
        this.state = 'running';
        this.ui.btnToggle.innerHTML = '<i class="fa-solid fa-pause text-2xl"></i>';
        
        // Play tick sound optionally
        const settings = Store.getSettings();
        
        this.intervalId = setInterval(() => {
            this.timeLeft--;
            this.updateUI();
            
            if (this.timeLeft <= 0) {
                this.complete();
            }
        }, 1000);
    },

    pause() {
        this.state = 'paused';
        this.ui.btnToggle.innerHTML = '<i class="fa-solid fa-play text-2xl ml-1"></i>';
        clearInterval(this.intervalId);
    },

    reset() {
        this.pause();
        this.state = 'idle';
        this.timeLeft = this.totalTime;
        this.updateUI();
    },

    skip() {
        if (this.state !== 'idle' || confirm('Skip current session?')) {
            this.complete();
        }
    },

    complete() {
        this.pause();
        this.timeLeft = 0;
        this.updateUI();
        
        const settings = Store.getSettings();
        
        // Play sound
        if (settings.soundEnabled) {
            const audio = document.getElementById('audio-complete');
            if (audio) {
                audio.currentTime = 0;
                audio.play().catch(e => console.log("Audio play blocked", e));
            }
        }
        
        if (this.mode === 'focus') {
            // Log stats
            Store.addFocusTime(settings.focusDuration);
            Store.incrementPomodoro(this.activeTaskId);
            app.renderTasks(); // Refresh task list to show updated pomodoro count
            
            this.pomodorosInSession++;
            
            // Switch to break
            if (this.pomodorosInSession % 4 === 0) {
                this.setMode('longBreak');
            } else {
                this.setMode('shortBreak');
            }
        } else {
            // Break is over, back to focus
            this.setMode('focus');
        }
        
        // Check auto-start
        if (settings.autoBreak && this.mode !== 'focus') {
            setTimeout(() => this.start(), 1500);
        } else if (settings.autoBreak && this.mode === 'focus') {
            setTimeout(() => this.start(), 1500);
        }
        
        // Update dashboard stats
        app.updateDashboardStats();
    },

    updateUI() {
        // Time text
        const m = Math.floor(this.timeLeft / 60).toString().padStart(2, '0');
        const s = (this.timeLeft % 60).toString().padStart(2, '0');
        this.ui.display.textContent = `${m}:${s}`;
        document.title = `${m}:${s} - FocusFlow`;
        
        // Circle progress
        // 753.98 is the circumference of r=120
        const dashoffset = 753.98 - (this.timeLeft / this.totalTime) * 753.98;
        this.ui.progress.style.strokeDashoffset = dashoffset;
    },

    updateSessionDots() {
        const dots = this.ui.sessions.children;
        const count = this.pomodorosInSession % 4;
        
        for (let i = 0; i < 4; i++) {
            if (i < count) {
                dots[i].className = 'w-2 h-2 rounded-full bg-focus';
            } else if (i === count && this.mode === 'focus') {
                dots[i].className = 'w-2 h-2 rounded-full bg-focus animate-pulse';
            } else {
                dots[i].className = 'w-2 h-2 rounded-full bg-gray-300 dark:bg-gray-700';
            }
        }
    },
    
    setActiveTask(taskId) {
        this.activeTaskId = taskId;
        const task = Store.getTasks().find(t => t.id === taskId);
        const taskLabel = document.getElementById('timer-active-task');
        if (task) {
            taskLabel.textContent = task.title;
        } else {
            taskLabel.textContent = "Select a task to focus on";
        }
    }
};
