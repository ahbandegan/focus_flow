/**
 * Local Data Store
 * Handles localStorage reading/writing and provides mock data for first run.
 */

const Store = {
    data: {
        tasks: [],
        projects: [
            { id: 'p1', name: 'Android App', color: '#3b82f6', icon: 'fa-mobile-screen' },
            { id: 'p2', name: 'Design System', color: '#8b5cf6', icon: 'fa-pen-nib' },
            { id: 'p3', name: 'Personal', color: '#10b981', icon: 'fa-house' }
        ],
        habits: [],
        history: [],
        settings: {
            theme: 'system',
            focusDuration: 25,
            shortBreak: 5,
            longBreak: 15,
            autoBreak: false,
            soundEnabled: true,
            onboardingDone: false
        },
        stats: {
            focusTime: 0,
            pomodorosCompleted: 0
        }
    },

    init() {
        const stored = localStorage.getItem('focusflow_data');
        if (stored) {
            try {
                this.data = JSON.parse(stored);
                this.migrateData();
            } catch (e) {
                console.error("Failed to parse local data", e);
            }
        } else {
            this.seedMockData();
            this.save();
        }
    },

    migrateData() {
        if (!this.data.settings) this.data.settings = { theme: 'system', focusDuration: 25, shortBreak: 5, longBreak: 15, autoBreak: false, soundEnabled: true, onboardingDone: false };
        if (this.data.settings.onboardingDone === undefined) this.data.settings.onboardingDone = true; // if they had data, they are not a new user
        if (!this.data.stats) this.data.stats = { focusTime: 0, pomodorosCompleted: 0 };
        if (!this.data.habits) this.data.habits = [];
        if (!this.data.history) this.data.history = [];
        
        if (this.data.habits.length === 0 && !this.data.settings.onboardingDone) {
            this.data.habits = [
                { id: 'h1', title: 'Drink 2L Water', color: '#3b82f6', streak: 0, bestStreak: 0, completedDates: [] }
            ];
            this.save();
        }
    },

    seedMockData() {
        const today = new Date().toISOString().split('T')[0];
        
        this.data.tasks = [
            { id: this.generateId(), title: 'Review wireframes for dashboard', description: 'Check spacing and typography on mobile views.', completed: false, priority: 3, dueDate: today, projectId: 'p2', estimatedPomodoros: 2, completedPomodoros: 0, createdAt: new Date().toISOString() },
            { id: this.generateId(), title: 'Implement LocalStorage wrapper', description: 'Write the store.js file for the prototype.', completed: true, priority: 2, dueDate: today, projectId: 'p1', estimatedPomodoros: 3, completedPomodoros: 3, createdAt: new Date().toISOString() },
            { id: this.generateId(), title: 'Read 20 pages of clean code', description: '', completed: false, priority: 0, dueDate: today, projectId: 'p3', estimatedPomodoros: 1, completedPomodoros: 0, createdAt: new Date().toISOString() }
        ];
        
        this.data.habits = [
            { id: 'h1', title: 'Drink 2L Water', color: '#3b82f6', streak: 4, bestStreak: 12, completedDates: [] },
            { id: 'h2', title: 'Read 20 mins', color: '#8b5cf6', streak: 2, bestStreak: 5, completedDates: [] }
        ];
        
        this.data.history = [
            { id: this.generateId(), type: 'pomodoro', title: 'Focus Session Completed', duration: 25, date: today, time: '10:30 AM' },
            { id: this.generateId(), type: 'task', title: 'Completed: Implement LocalStorage wrapper', duration: null, date: today, time: '11:15 AM' }
        ];
    },

    save() {
        localStorage.setItem('focusflow_data', JSON.stringify(this.data));
    },

    generateId() {
        return Math.random().toString(36).substr(2, 9);
    },

    // Tasks API
    getTasks() { return this.data.tasks; },
    addTask(taskData) {
        const newTask = {
            id: this.generateId(),
            title: taskData.title,
            description: taskData.description || '',
            completed: false,
            priority: parseInt(taskData.priority) || 0,
            dueDate: taskData.dueDate || null,
            projectId: taskData.projectId || null,
            estimatedPomodoros: parseInt(taskData.estimatedPomodoros) || 1,
            completedPomodoros: 0,
            createdAt: new Date().toISOString()
        };
        this.data.tasks.push(newTask);
        this.save();
        return newTask;
    },
    updateTask(id, updates) {
        const index = this.data.tasks.findIndex(t => t.id === id);
        if (index > -1) {
            this.data.tasks[index] = { ...this.data.tasks[index], ...updates };
            this.save();
            return this.data.tasks[index];
        }
        return null;
    },
    toggleTaskCompletion(id) {
        const task = this.data.tasks.find(t => t.id === id);
        if (task) {
            task.completed = !task.completed;
            if (task.completed) this.addHistoryEvent('task', `Completed: ${task.title}`, null);
            this.save();
            return task;
        }
        return null;
    },
    deleteTask(id) {
        this.data.tasks = this.data.tasks.filter(t => t.id !== id);
        this.save();
    },

    // Projects API
    getProjects() { return this.data.projects; },
    getProject(id) { return this.data.projects.find(p => p.id === id); },
    addProject(name, color) {
        const p = { id: 'p' + this.generateId(), name, color, icon: 'fa-folder' };
        this.data.projects.push(p);
        this.save();
        return p;
    },
    deleteProject(id) {
        this.data.projects = this.data.projects.filter(p => p.id !== id);
        this.save();
    },
    
    // Habits API
    getHabits() { return this.data.habits; },
    addHabit(title) {
        const h = { id: 'h' + this.generateId(), title, color: '#10b981', streak: 0, bestStreak: 0, completedDates: [] };
        this.data.habits.push(h);
        this.save();
        return h;
    },
    toggleHabit(id, dateStr) {
        const habit = this.data.habits.find(h => h.id === id);
        if (habit) {
            const idx = habit.completedDates.indexOf(dateStr);
            if (idx > -1) {
                habit.completedDates.splice(idx, 1);
                habit.streak = Math.max(0, habit.streak - 1);
            } else {
                habit.completedDates.push(dateStr);
                habit.streak += 1;
                if (habit.streak > habit.bestStreak) habit.bestStreak = habit.streak;
                this.addHistoryEvent('habit', `Habit done: ${habit.title}`, null);
            }
            this.save();
        }
    },
    deleteHabit(id) {
        this.data.habits = this.data.habits.filter(h => h.id !== id);
        this.save();
    },

    // History API
    getHistory() { return this.data.history || []; },
    addHistoryEvent(type, title, duration = null) {
        const now = new Date();
        const dateStr = now.toISOString().split('T')[0];
        let hours = now.getHours();
        let minutes = now.getMinutes();
        const ampm = hours >= 12 ? 'PM' : 'AM';
        hours = hours % 12; hours = hours ? hours : 12; 
        minutes = minutes < 10 ? '0' + minutes : minutes;
        
        this.data.history.unshift({ id: this.generateId(), type, title, duration, date: dateStr, time: `${hours}:${minutes} ${ampm}` });
        if (this.data.history.length > 100) this.data.history = this.data.history.slice(0, 100);
        this.save();
    },

    // Settings API
    getSettings() { return this.data.settings; },
    updateSettings(updates) {
        this.data.settings = { ...this.data.settings, ...updates };
        this.save();
    },
    completeOnboarding() {
        this.data.settings.onboardingDone = true;
        this.save();
    },

    // Stats
    addFocusTime(minutes) { this.data.stats.focusTime += minutes; this.save(); },
    incrementPomodoro(taskId = null) {
        this.data.stats.pomodorosCompleted += 1;
        let title = 'Focus Session Completed';
        if (taskId) {
            const t = this.data.tasks.find(x => x.id === taskId);
            if (t) { t.completedPomodoros += 1; title = `Focused on: ${t.title}`; }
        }
        this.addHistoryEvent('pomodoro', title, this.data.settings.focusDuration);
        this.save();
    },

    // Import / Export
    exportData() {
        return JSON.stringify(this.data);
    },
    importData(jsonString) {
        try {
            const parsed = JSON.parse(jsonString);
            if (parsed && parsed.tasks && parsed.settings) {
                this.data = parsed;
                this.save();
                return true;
            }
        } catch (e) { console.error("Import failed", e); }
        return false;
    },

    clearAll() {
        localStorage.removeItem('focusflow_data');
        this.data = { tasks: [], projects: [], habits: [], history: [], settings: {}, stats: {} };
        this.init();
    }
};

Store.init();
