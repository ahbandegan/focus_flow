/**
 * Main Application Logic
 */

const app = {
    currentView: 'dashboard',
    contextMenuTarget: null,
    
    init() {
        this.checkOnboarding();
        this.setupNavigation();
        this.setupTheme();
        this.setupModals();
        this.setupContextMenu();
        this.setupQuickAdd();
        
        Timer.init();
        Charts.init();
        
        this.renderTasks();
        this.renderProjects();
        this.renderHabits();
        this.renderHistory();
        this.updateDashboardStats();
        
        const options = { weekday: 'long', month: 'long', day: 'numeric' };
        document.getElementById('dash-date').textContent = new Date().toLocaleDateString('en-US', options);
        
        this.loadSettingsToUI();
    },

    checkOnboarding() {
        const s = Store.getSettings();
        if (!s.onboardingDone) {
            const overlay = document.getElementById('onboarding-overlay');
            overlay.classList.remove('hidden');
            overlay.classList.add('flex');
        }
    },

    completeOnboarding() {
        Store.completeOnboarding();
        const overlay = document.getElementById('onboarding-overlay');
        overlay.classList.add('hidden');
        overlay.classList.remove('flex');
    },

    // --- NAVIGATION ---
    setupNavigation() {
        const navItems = document.querySelectorAll('.nav-item[data-view]');
        navItems.forEach(item => {
            item.addEventListener('click', (e) => {
                e.preventDefault();
                const view = item.getAttribute('data-view');
                this.switchView(view);
                document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
                document.querySelectorAll(`.nav-item[data-view="${view}"]`).forEach(n => n.classList.add('active'));
            });
        });

        const toggleBtn = document.getElementById('toggle-sidebar');
        const sidebar = document.getElementById('desktop-sidebar');
        if (toggleBtn && sidebar) {
            toggleBtn.addEventListener('click', () => {
                if (sidebar.classList.contains('w-64') || sidebar.classList.contains('lg:w-72')) {
                    sidebar.classList.remove('w-64', 'lg:w-72');
                    sidebar.classList.add('w-20');
                    document.querySelectorAll('.nav-label').forEach(el => el.classList.add('hidden'));
                } else {
                    sidebar.classList.add('w-64', 'lg:w-72');
                    sidebar.classList.remove('w-20');
                    setTimeout(() => {
                        document.querySelectorAll('.nav-label').forEach(el => el.classList.remove('hidden'));
                    }, 200);
                }
            });
        }
    },

    switchView(viewId) {
        document.querySelectorAll('.app-view').forEach(view => {
            view.classList.add('hidden');
            view.classList.remove('block', 'fade-in');
        });
        
        const target = document.getElementById(`view-${viewId}`);
        if (target) {
            target.classList.remove('hidden');
            target.classList.add('block', 'fade-in');
            this.currentView = viewId;
            
            const titles = { 'dashboard': 'Today', 'tasks': 'All Tasks', 'focus': 'Focus Timer', 'projects': 'Projects', 'habits': 'Habits', 'history': 'History', 'statistics': 'Statistics', 'settings': 'Settings' };
            document.getElementById('topbar-title').textContent = titles[viewId] || 'FocusFlow';
            
            if (viewId === 'statistics') Charts.init();
            else if (viewId === 'dashboard' || viewId === 'tasks') this.renderTasks();
            else if (viewId === 'projects') this.renderProjects();
            else if (viewId === 'habits') this.renderHabits();
            else if (viewId === 'history') this.renderHistory();
        }
    },

    // --- THEME & SETTINGS ---
    setupTheme() {
        const toggle = document.getElementById('theme-toggle');
        const isDark = localStorage.getItem('theme') === 'dark' || (!localStorage.getItem('theme') && window.matchMedia('(prefers-color-scheme: dark)').matches);
            
        if (isDark) { document.documentElement.classList.add('dark'); toggle.innerHTML = '<i class="fa-solid fa-sun text-gray-400"></i>'; } 
        else { document.documentElement.classList.remove('dark'); toggle.innerHTML = '<i class="fa-solid fa-moon text-gray-600"></i>'; }

        toggle.addEventListener('click', () => {
            document.documentElement.classList.toggle('dark');
            const isNowDark = document.documentElement.classList.contains('dark');
            localStorage.setItem('theme', isNowDark ? 'dark' : 'light');
            toggle.innerHTML = isNowDark ? '<i class="fa-solid fa-sun text-gray-400"></i>' : '<i class="fa-solid fa-moon text-gray-600"></i>';
            if (this.currentView === 'statistics') Charts.init();
        });
        
        const bindRange = (id, valId, storeKey) => {
            const el = document.getElementById(id);
            if (!el) return;
            el.addEventListener('input', (e) => {
                document.getElementById(valId).textContent = e.target.value + ' min';
                Store.updateSettings({ [storeKey]: parseInt(e.target.value) });
                Timer.setMode(Timer.mode);
            });
        };
        
        bindRange('set-focus-dur', 'val-focus-dur', 'focusDuration');
        bindRange('set-short-dur', 'val-short-dur', 'shortBreak');
        bindRange('set-long-dur', 'val-long-dur', 'longBreak');
        
        document.getElementById('set-auto-break')?.addEventListener('change', (e) => Store.updateSettings({ autoBreak: e.target.checked }));
        document.getElementById('set-sound')?.addEventListener('change', (e) => Store.updateSettings({ soundEnabled: e.target.checked }));
    },
    
    loadSettingsToUI() {
        const s = Store.getSettings();
        if (document.getElementById('set-focus-dur')) {
            document.getElementById('set-focus-dur').value = s.focusDuration; document.getElementById('val-focus-dur').textContent = s.focusDuration + ' min';
            document.getElementById('set-short-dur').value = s.shortBreak; document.getElementById('val-short-dur').textContent = s.shortBreak + ' min';
            document.getElementById('set-long-dur').value = s.longBreak; document.getElementById('val-long-dur').textContent = s.longBreak + ' min';
            document.getElementById('set-auto-break').checked = s.autoBreak; document.getElementById('set-sound').checked = s.soundEnabled;
        }
    },

    // --- UI RENDERING ---
    renderTasks() {
        const tasks = Store.getTasks();
        const projects = Store.getProjects();
        const today = new Date().toISOString().split('T')[0];
        
        const dashContainer = document.getElementById('dashboard-task-list');
        const allContainer = document.getElementById('all-task-list');
        
        if (dashContainer) dashContainer.innerHTML = '';
        if (allContainer) allContainer.innerHTML = '';
        
        const filterVal = document.getElementById('task-filter')?.value || 'all';
        const projectFilterVal = document.getElementById('task-filter-project')?.value || 'all';

        tasks.sort((a, b) => {
            if (a.completed !== b.completed) return a.completed ? 1 : -1;
            return b.priority - a.priority;
        }).forEach(task => {
            const project = projects.find(p => p.id === task.projectId) || { name: 'Inbox', color: '#9ca3af', icon: 'fa-inbox' };
            const isToday = task.dueDate === today;
            const taskHTML = this.createTaskHTML(task, project);
            
            if (isToday && dashContainer) dashContainer.insertAdjacentHTML('beforeend', taskHTML);
            
            if (allContainer) {
                const passStatus = filterVal === 'all' || (filterVal === 'pending' && !task.completed) || (filterVal === 'completed' && task.completed);
                const passProject = projectFilterVal === 'all' || task.projectId === projectFilterVal;
                if (passStatus && passProject) {
                    allContainer.insertAdjacentHTML('beforeend', taskHTML);
                }
            }
        });
        
        if (dashContainer && dashContainer.children.length === 0) dashContainer.innerHTML = '<div class="text-center p-8 text-gray-500 border border-dashed rounded-xl">No tasks for today!</div>';
        if (allContainer && allContainer.children.length === 0) allContainer.innerHTML = '<div class="text-center p-8 text-gray-500 border border-dashed rounded-xl">No tasks found.</div>';
        
        this.bindTaskEvents();
    },

    createTaskHTML(task, project) {
        const priorityColors = ['', 'text-blue-500', 'text-orange-500', 'text-red-500'];
        const pColor = priorityColors[task.priority] || 'text-gray-400';
        const pIcon = task.priority > 0 ? `<i class="fa-solid fa-flag ${pColor} text-xs"></i>` : '';
        const pomodorosHTML = task.estimatedPomodoros > 0 ? 
            `<div class="flex gap-0.5 ml-2">${Array(task.estimatedPomodoros).fill().map((_, i) => `<div class="w-1.5 h-3 rounded-sm ${i < task.completedPomodoros ? 'bg-focus' : 'bg-gray-200 dark:bg-gray-700'}"></div>`).join('')}</div>` : '';

        return `
            <div class="task-row group bg-white dark:bg-gray-900 border border-gray-100 dark:border-gray-800 hover:border-primary-300 rounded-xl p-3 md:p-4 flex gap-3 shadow-sm hover:shadow-md transition cursor-pointer" data-task-id="${task.id}">
                <div class="pt-0.5 flex-shrink-0"><input type="checkbox" class="task-checkbox text-primary-500" data-id="${task.id}" ${task.completed ? 'checked' : ''}></div>
                <div class="flex-1 min-w-0" onclick="app.openTaskDetails('${task.id}')">
                    <h4 class="font-medium text-gray-900 dark:text-gray-100 truncate ${task.completed ? 'line-through text-gray-400 dark:text-gray-500' : ''}">${task.title}</h4>
                    <div class="flex items-center gap-3 mt-1.5 text-xs text-gray-500">
                        <span class="flex items-center gap-1" style="color: ${project.color}"><i class="fa-solid ${project.icon}"></i> <span>${project.name}</span></span>
                        ${pIcon}
                        ${task.dueDate ? `<span class="flex items-center gap-1"><i class="fa-regular fa-calendar"></i> ${task.dueDate}</span>` : ''}
                        ${pomodorosHTML}
                    </div>
                </div>
                <div class="opacity-0 group-hover:opacity-100 transition-opacity flex items-center">
                    <button class="w-8 h-8 rounded-full hover:bg-gray-100 text-gray-400 hover:text-focus" onclick="app.selectTaskForTimer('${task.id}'); event.stopPropagation();"><i class="fa-solid fa-play text-xs"></i></button>
                </div>
            </div>`;
    },

    bindTaskEvents() {
        document.querySelectorAll('.task-checkbox').forEach(cb => {
            cb.addEventListener('change', (e) => {
                Store.toggleTaskCompletion(e.target.getAttribute('data-id'));
                this.renderTasks(); this.updateDashboardStats();
                if (this.currentView === 'history') this.renderHistory();
            });
        });
        
        ['task-filter', 'task-filter-project'].forEach(id => {
            const filter = document.getElementById(id);
            if (filter) {
                const newFilter = filter.cloneNode(true);
                filter.parentNode.replaceChild(newFilter, filter);
                newFilter.addEventListener('change', () => this.renderTasks());
            }
        });
    },
    
    renderProjects() {
        const container = document.getElementById('project-list-grid');
        const projSelectFilter = document.getElementById('task-filter-project');
        const projSelectModal = document.getElementById('task-project');
        
        const projects = Store.getProjects();
        const tasks = Store.getTasks();
        
        // Update selects
        if (projSelectFilter) projSelectFilter.innerHTML = `<option value="all">All Projects</option>` + projects.map(p => `<option value="${p.id}">${p.name}</option>`).join('');
        if (projSelectModal) projSelectModal.innerHTML = projects.map(p => `<option value="${p.id}">${p.name}</option>`).join('');
        
        if (!container) return;
        
        container.innerHTML = projects.map(p => {
            const pTasks = tasks.filter(t => t.projectId === p.id);
            const done = pTasks.filter(t => t.completed).length;
            const progress = pTasks.length === 0 ? 0 : Math.round((done / pTasks.length) * 100);
            
            return `
                <div class="bg-white dark:bg-gray-900 rounded-xl p-5 border border-gray-100 dark:border-gray-800 shadow-sm hover:shadow-md transition">
                    <div class="flex justify-between items-start mb-4">
                        <div class="w-10 h-10 rounded-lg flex items-center justify-center text-white text-lg shadow-sm" style="background-color: ${p.color}"><i class="fa-solid ${p.icon}"></i></div>
                        <button onclick="app.deleteProject('${p.id}')" class="text-gray-300 hover:text-red-500"><i class="fa-solid fa-trash"></i></button>
                    </div>
                    <h3 class="font-bold text-lg mb-1">${p.name}</h3>
                    <p class="text-sm text-gray-500 mb-4">${pTasks.length} Tasks</p>
                    <div class="w-full bg-gray-100 dark:bg-gray-800 rounded-full h-1.5 mb-1"><div class="h-1.5 rounded-full" style="width: ${progress}%; background-color: ${p.color}"></div></div>
                    <div class="text-right text-xs text-gray-400 font-medium">${progress}%</div>
                </div>`;
        }).join('');
    },
    
    renderHabits() {
        const container = document.getElementById('habit-list-grid');
        if (!container) return;
        const habits = Store.getHabits();
        const today = new Date().toISOString().split('T')[0];
        
        container.innerHTML = habits.map(h => {
            const isDoneToday = h.completedDates.includes(today);
            return `
                <div class="bg-white dark:bg-gray-900 rounded-xl p-4 md:p-5 border border-gray-100 dark:border-gray-800 shadow-sm transition flex items-center justify-between">
                    <div class="flex items-center gap-4">
                        <div class="w-12 h-12 rounded-full flex items-center justify-center text-white text-xl shadow-sm transition-transform ${isDoneToday ? 'scale-110' : ''}" style="background-color: ${isDoneToday ? '#10b981' : '#9ca3af'}">
                            <i class="fa-solid ${isDoneToday ? 'fa-check' : 'fa-seedling'}"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-base md:text-lg text-gray-900 dark:text-white ${isDoneToday ? 'line-through opacity-70' : ''}">${h.title}</h3>
                            <div class="flex items-center gap-3 text-xs text-gray-500 mt-1">
                                <span class="flex items-center gap-1"><i class="fa-solid fa-fire text-orange-500"></i> ${h.streak} Streak</span>
                                <span>Best: ${h.bestStreak}</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex gap-2">
                        <button onclick="app.toggleHabit('${h.id}')" class="px-4 py-2 rounded-lg text-sm font-medium transition border ${isDoneToday ? 'bg-gray-100 text-gray-500 border-transparent' : 'bg-white text-gray-700 hover:bg-gray-50'}">${isDoneToday ? 'Done' : 'Complete'}</button>
                        <button onclick="app.deleteHabit('${h.id}')" class="px-3 py-2 rounded-lg text-sm text-gray-400 hover:text-red-500"><i class="fa-solid fa-trash"></i></button>
                    </div>
                </div>`;
        }).join('');
    },

    renderHistory() {
        const calContainer = document.getElementById('history-calendar');
        const feedContainer = document.getElementById('history-feed');
        if (!calContainer || !feedContainer) return;
        
        const now = new Date();
        const year = now.getFullYear(); const month = now.getMonth();
        document.getElementById('history-month-label').textContent = `${["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"][month]} ${year}`;
        
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const firstDay = new Date(year, month, 1).getDay();
        
        let calHTML = '';
        for (let i = 0; i < firstDay; i++) calHTML += `<div></div>`;
        
        const history = Store.getHistory();
        
        for (let i = 1; i <= daysInMonth; i++) {
            const dateStr = `${year}-${(month+1).toString().padStart(2,'0')}-${i.toString().padStart(2,'0')}`;
            const isToday = i === now.getDate();
            const hasActivity = history.some(h => h.date === dateStr);
            
            calHTML += `
                <div class="aspect-square flex flex-col items-center justify-center rounded-lg ${isToday ? 'bg-primary-100 text-primary-600 font-bold' : 'text-gray-700 dark:text-gray-300'}">
                    <span>${i}</span>
                    <div class="flex gap-0.5 mt-0.5">${hasActivity ? `<div class="w-1 h-1 rounded-full bg-focus"></div>` : ''}</div>
                </div>`;
        }
        calContainer.innerHTML = calHTML;
        
        const todayStr = now.toISOString().split('T')[0];
        const todayHistory = history.filter(h => h.date === todayStr);
        if (todayHistory.length === 0) { feedContainer.innerHTML = '<div class="text-center p-6 text-gray-500">No activity yet for today.</div>'; return; }
        
        feedContainer.innerHTML = todayHistory.map(item => {
            const icon = item.type === 'pomodoro' ? 'fa-stopwatch' : (item.type === 'habit' ? 'fa-seedling' : 'fa-check-double');
            const color = item.type === 'pomodoro' ? 'text-focus' : (item.type === 'habit' ? 'text-green-500' : 'text-blue-500');
            const bgClass = item.type === 'pomodoro' ? 'bg-red-50' : (item.type === 'habit' ? 'bg-green-50' : 'bg-blue-50');
            return `
                <div class="relative flex items-center gap-4 mb-4">
                    <div class="absolute left-0 md:left-1/2 -translate-x-1/2 w-4 h-4 rounded-full bg-white border-2 border-gray-300 z-10"></div>
                    <div class="pl-8 md:pl-0 w-full md:grid md:grid-cols-2 md:gap-8 items-center">
                        <div class="text-sm text-gray-500 font-medium md:text-right hidden md:block">${item.time}</div>
                        <div class="bg-white dark:bg-gray-900 border ${bgClass} border-opacity-50 p-3 rounded-lg shadow-sm w-full relative">
                            <span class="md:hidden text-xs text-gray-500 font-medium absolute top-3 right-3">${item.time}</span>
                            <div class="flex items-center gap-2 mb-1"><i class="fa-solid ${icon} ${color} text-sm"></i><span class="text-xs font-semibold uppercase tracking-wider text-gray-500">${item.type}</span></div>
                            <p class="text-sm font-medium pr-12 md:pr-0">${item.title}</p>
                            ${item.duration ? `<p class="text-xs text-gray-500 mt-1"><i class="fa-regular fa-clock"></i> ${item.duration} minutes</p>` : ''}
                        </div>
                    </div>
                </div>`;
        }).join('');
    },

    updateDashboardStats() {
        const tasks = Store.getTasks(); const habits = Store.getHabits(); const stats = Store.data.stats;
        const today = new Date().toISOString().split('T')[0];
        let dashCount = 0, dashDone = 0;
        
        tasks.forEach(t => { if (t.dueDate === today) { dashCount++; if (t.completed) dashDone++; } });
        
        if (document.getElementById('dash-tasks-done')) document.getElementById('dash-tasks-done').textContent = `${dashDone}/${dashCount}`;
        if (document.getElementById('dash-pomos-done')) document.getElementById('dash-pomos-done').textContent = stats.pomodorosCompleted;
        if (document.getElementById('dash-focus-time')) { const h = Math.floor(stats.focusTime / 60); const m = stats.focusTime % 60; document.getElementById('dash-focus-time').textContent = h > 0 ? `${h}h ${m}m` : `${m}m`; }
        if (document.getElementById('dash-streak')) document.getElementById('dash-streak').textContent = habits.reduce((max, h) => Math.max(max, h.streak), 0);
    },

    // --- MODALS & FORMS ---
    setupModals() {
        document.getElementById('task-date').value = new Date().toISOString().split('T')[0];
        
        // Project color picker
        const colors = document.querySelectorAll('#project-colors button');
        colors.forEach(btn => {
            btn.addEventListener('click', (e) => {
                colors.forEach(c => c.classList.remove('ring-2', 'ring-offset-2', 'ring-blue-500', 'ring-purple-500', 'ring-green-500', 'ring-red-500', 'ring-yellow-500'));
                const colorVal = e.target.getAttribute('data-color');
                let ringClass = 'ring-blue-500';
                if(colorVal === '#8b5cf6') ringClass = 'ring-purple-500';
                if(colorVal === '#10b981') ringClass = 'ring-green-500';
                if(colorVal === '#ef4444') ringClass = 'ring-red-500';
                if(colorVal === '#eab308') ringClass = 'ring-yellow-500';
                e.target.classList.add('ring-2', 'ring-offset-2', ringClass);
                document.getElementById('project-color-val').value = colorVal;
            });
        });
    },

    openTaskModal(taskId = null) {
        const modal = document.getElementById('modal-task');
        document.getElementById('form-task').reset();
        document.getElementById('task-date').value = new Date().toISOString().split('T')[0];
        document.getElementById('task-id').value = '';
        document.getElementById('modal-task-title').textContent = 'New Task';
        
        if (taskId) {
            const task = Store.getTasks().find(t => t.id === taskId);
            if (task) {
                document.getElementById('task-id').value = task.id; document.getElementById('task-title').value = task.title;
                document.getElementById('task-desc').value = task.description || ''; document.getElementById('task-date').value = task.dueDate || '';
                document.getElementById('task-priority').value = task.priority; document.getElementById('task-pomos').value = task.estimatedPomodoros;
                if(task.projectId) document.getElementById('task-project').value = task.projectId;
                document.getElementById('modal-task-title').textContent = 'Edit Task';
            }
        }
        modal.classList.remove('hidden'); modal.classList.add('flex');
        setTimeout(() => { modal.classList.remove('opacity-0'); document.getElementById('task-title').focus(); }, 10);
    },
    closeTaskModal() {
        const modal = document.getElementById('modal-task');
        modal.classList.add('opacity-0'); setTimeout(() => { modal.classList.add('hidden'); modal.classList.remove('flex'); }, 200);
    },
    saveTask(e) {
        e.preventDefault();
        const id = document.getElementById('task-id').value;
        const taskData = {
            title: document.getElementById('task-title').value, description: document.getElementById('task-desc').value,
            dueDate: document.getElementById('task-date').value, priority: document.getElementById('task-priority').value,
            estimatedPomodoros: document.getElementById('task-pomos').value, projectId: document.getElementById('task-project').value
        };
        if (id) Store.updateTask(id, taskData); else Store.addTask(taskData);
        this.closeTaskModal(); this.renderTasks(); this.updateDashboardStats(); this.renderProjects();
    },

    openProjectModal() {
        const modal = document.getElementById('modal-project');
        document.getElementById('project-name').value = '';
        modal.classList.remove('hidden'); modal.classList.add('flex');
        setTimeout(() => { modal.classList.remove('opacity-0'); document.getElementById('project-name').focus(); }, 10);
    },
    closeProjectModal() {
        const modal = document.getElementById('modal-project');
        modal.classList.add('opacity-0'); setTimeout(() => { modal.classList.add('hidden'); modal.classList.remove('flex'); }, 200);
    },
    saveProject() {
        const name = document.getElementById('project-name').value;
        const color = document.getElementById('project-color-val').value;
        if (name) { Store.addProject(name, color); this.closeProjectModal(); this.renderProjects(); }
    },
    deleteProject(id) {
        if(confirm('Delete project? All associated tasks will lose their project assignment.')) { Store.deleteProject(id); this.renderProjects(); this.renderTasks(); }
    },

    openHabitModal() {
        const modal = document.getElementById('modal-habit');
        document.getElementById('habit-name').value = '';
        modal.classList.remove('hidden'); modal.classList.add('flex');
        setTimeout(() => { modal.classList.remove('opacity-0'); document.getElementById('habit-name').focus(); }, 10);
    },
    closeHabitModal() {
        const modal = document.getElementById('modal-habit');
        modal.classList.add('opacity-0'); setTimeout(() => { modal.classList.add('hidden'); modal.classList.remove('flex'); }, 200);
    },
    saveHabit() {
        const name = document.getElementById('habit-name').value;
        if (name) { Store.addHabit(name); this.closeHabitModal(); this.renderHabits(); }
    },
    deleteHabit(id) {
        if(confirm('Delete this habit?')) { Store.deleteHabit(id); this.renderHabits(); }
    },
    toggleHabit(id) {
        const today = new Date().toISOString().split('T')[0];
        Store.toggleHabit(id, today); this.renderHabits(); this.updateDashboardStats();
        if (this.currentView === 'history') this.renderHistory();
    },

    // --- DETAILS PANEL ---
    openTaskDetails(taskId) {
        const task = Store.getTasks().find(t => t.id === taskId);
        if (!task) return;
        const project = Store.getProjects().find(p => p.id === task.projectId) || { name: 'Inbox', color: '#9ca3af', icon: 'fa-inbox' };
        const content = document.getElementById('details-content');
        const panel = document.getElementById('details-panel');
        const priorityLabels = ['None', 'Low', 'Medium', 'High'];
        const priorityColors = ['bg-gray-100 text-gray-600', 'bg-blue-100 text-blue-700', 'bg-orange-100 text-orange-700', 'bg-red-100 text-red-700'];
        const pClass = priorityColors[task.priority] || priorityColors[0];
        
        content.innerHTML = `
            <div class="mb-6 flex justify-between items-start gap-4">
                <h2 class="text-xl font-bold leading-tight ${task.completed ? 'line-through text-gray-500' : ''}">${task.title}</h2>
                <div class="flex gap-2 shrink-0">
                    <button onclick="app.openTaskModal('${task.id}')" class="w-8 h-8 bg-gray-100 rounded-md hover:bg-gray-200"><i class="fa-solid fa-pen text-xs"></i></button>
                    <button onclick="app.deleteTask('${task.id}')" class="w-8 h-8 bg-red-50 rounded-md hover:bg-red-100 text-red-500"><i class="fa-solid fa-trash text-xs"></i></button>
                </div>
            </div>
            <div class="space-y-5">
                <div class="flex items-center gap-4"><div class="w-24 text-sm text-gray-500 font-medium">Project</div><div class="flex items-center gap-2 px-2.5 py-1 rounded-md text-sm font-medium" style="background-color: ${project.color}15; color: ${project.color}"><i class="fa-solid ${project.icon}"></i> ${project.name}</div></div>
                <div class="flex items-center gap-4"><div class="w-24 text-sm text-gray-500 font-medium">Due Date</div><div class="text-sm font-medium">${task.dueDate || 'No Date'}</div></div>
                <div class="flex items-center gap-4"><div class="w-24 text-sm text-gray-500 font-medium">Priority</div><div class="px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wide ${pClass}">${priorityLabels[task.priority] || 'None'}</div></div>
                <div class="flex items-center gap-4"><div class="w-24 text-sm text-gray-500 font-medium">Pomodoros</div><div class="text-sm font-medium flex items-center gap-2"><span class="text-focus font-bold">${task.completedPomodoros}</span> / ${task.estimatedPomodoros} <button onclick="app.selectTaskForTimer('${task.id}')" class="ml-2 w-7 h-7 bg-focus text-white rounded-full flex items-center justify-center hover:bg-red-600"><i class="fa-solid fa-play text-[10px] ml-0.5"></i></button></div></div>
                ${task.description ? `<div class="pt-4 border-t border-gray-100"><div class="text-sm text-gray-500 font-medium mb-2">Description</div><p class="text-sm whitespace-pre-line">${task.description}</p></div>` : ''}
            </div>
            <div class="mt-8 pt-6 border-t border-gray-100">
                <button onclick="app.toggleTaskFromDetails('${task.id}')" class="w-full py-2.5 rounded-lg font-medium flex items-center justify-center gap-2 ${task.completed ? 'bg-gray-100 text-gray-600' : 'bg-primary-50 text-primary-600 border border-primary-200'}"><i class="fa-solid ${task.completed ? 'fa-rotate-left' : 'fa-check'}"></i> ${task.completed ? 'Mark as Incomplete' : 'Complete Task'}</button>
            </div>`;
        panel.classList.remove('translate-x-full'); panel.classList.add('translate-x-0');
        if (window.innerWidth < 1280) { panel.classList.remove('hidden'); panel.classList.add('flex', 'absolute', 'right-0', 'top-0', 'h-full', 'z-40', 'shadow-2xl'); }
    },
    
    closeDetailsPanel() {
        const panel = document.getElementById('details-panel');
        panel.classList.add('translate-x-full'); panel.classList.remove('translate-x-0');
        if (window.innerWidth < 1280) setTimeout(() => panel.classList.add('hidden'), 300);
    },

    deleteTask(id) { if (confirm('Delete this task?')) { Store.deleteTask(id); this.closeDetailsPanel(); this.renderTasks(); this.updateDashboardStats(); this.renderProjects(); } },
    
    toggleTaskFromDetails(id) { Store.toggleTaskCompletion(id); this.renderTasks(); this.updateDashboardStats(); if(this.currentView === 'history') this.renderHistory(); this.openTaskDetails(id); },

    // --- CONTEXT MENU ---
    setupContextMenu() {
        const menu = document.getElementById('context-menu');
        
        document.addEventListener('contextmenu', (e) => {
            const taskRow = e.target.closest('.task-row');
            if (taskRow) {
                e.preventDefault();
                this.contextMenuTarget = taskRow.getAttribute('data-task-id');
                menu.classList.remove('hidden');
                
                // Position logic
                let x = e.clientX, y = e.clientY;
                if (x + 192 > window.innerWidth) x -= 192; // 192 is menu width approx
                if (y + 120 > window.innerHeight) y -= 120;
                
                menu.style.left = `${x}px`;
                menu.style.top = `${y}px`;
                
                // Animation frame trick to trigger CSS transition
                requestAnimationFrame(() => { menu.classList.remove('scale-95', 'opacity-0'); });
            } else {
                this.closeContextMenu();
            }
        });
        
        document.addEventListener('click', () => this.closeContextMenu());
        
        // Menu actions
        document.getElementById('cm-edit').addEventListener('click', () => { if(this.contextMenuTarget) app.openTaskModal(this.contextMenuTarget); });
        document.getElementById('cm-focus').addEventListener('click', () => { if(this.contextMenuTarget) app.selectTaskForTimer(this.contextMenuTarget); });
        document.getElementById('cm-delete').addEventListener('click', () => { if(this.contextMenuTarget) app.deleteTask(this.contextMenuTarget); });
    },
    
    closeContextMenu() {
        const menu = document.getElementById('context-menu');
        menu.classList.add('scale-95', 'opacity-0');
        setTimeout(() => menu.classList.add('hidden'), 100);
        this.contextMenuTarget = null;
    },

    // --- SEARCH & QUICK ADD ---
    toggleSearch() {
        const overlay = document.getElementById('search-overlay');
        const input = document.getElementById('search-input');
        
        if (overlay.classList.contains('hidden')) {
            overlay.classList.remove('hidden'); overlay.classList.add('flex');
            setTimeout(() => { overlay.classList.remove('opacity-0'); input.focus(); }, 10);
            input.addEventListener('input', (e) => this.handleSearch(e.target.value));
        } else {
            overlay.classList.add('opacity-0');
            setTimeout(() => { overlay.classList.add('hidden'); overlay.classList.remove('flex'); input.value = ''; }, 200);
        }
    },
    
    handleSearch(query) {
        const hint = document.getElementById('quick-add-hint');
        const qaText = document.getElementById('qa-text');
        const resultsContainer = document.getElementById('search-list');
        
        if (!query.trim()) {
            hint.classList.add('hidden'); resultsContainer.innerHTML = ''; return;
        }
        
        // Show Quick Add hint
        hint.classList.remove('hidden');
        qaText.textContent = query;
        
        const q = query.toLowerCase();
        const tasks = Store.getTasks().filter(t => t.title.toLowerCase().includes(q));
        const projects = Store.getProjects();
        
        if (tasks.length === 0) { resultsContainer.innerHTML = ''; return; }
        
        resultsContainer.innerHTML = `<div class="mt-6 mb-2 text-xs font-bold text-gray-400 uppercase tracking-wider">Search Results</div><div class="space-y-2">` + tasks.map(task => {
            const project = projects.find(p => p.id === task.projectId) || { name: 'Inbox', color: '#9ca3af', icon: 'fa-inbox' };
            return this.createTaskHTML(task, project);
        }).join('') + `</div>`;
    },
    
    setupQuickAdd() {
        const input = document.getElementById('search-input');
        const hint = document.getElementById('quick-add-hint');
        
        input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && input.value.trim() !== '') {
                // Parse priority e.g., "Buy milk p:high"
                let title = input.value;
                let priority = 0;
                
                if (title.toLowerCase().includes('p:high')) { priority = 3; title = title.replace(/p:high/i, '').trim(); }
                else if (title.toLowerCase().includes('p:med')) { priority = 2; title = title.replace(/p:med/i, '').trim(); }
                else if (title.toLowerCase().includes('p:low')) { priority = 1; title = title.replace(/p:low/i, '').trim(); }
                
                Store.addTask({ title, priority, dueDate: new Date().toISOString().split('T')[0], projectId: Store.getProjects()[0]?.id, estimatedPomodoros: 1 });
                
                input.value = '';
                this.toggleSearch();
                this.renderTasks(); this.updateDashboardStats(); this.renderProjects();
            }
        });
        
        hint.addEventListener('click', () => {
            input.dispatchEvent(new KeyboardEvent('keydown', {'key': 'Enter'}));
        });
    },

    // --- UTILS ---
    selectTaskForTimer(taskId) {
        if (taskId) Timer.setActiveTask(taskId);
        this.switchView('focus');
        if (window.innerWidth < 1280) this.closeDetailsPanel();
        if (!document.getElementById('search-overlay').classList.contains('hidden')) this.toggleSearch();
    },
    
    exportData() {
        const dataStr = Store.exportData();
        const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
        const exportFileDefaultName = 'focusflow_backup.json';
        const linkElement = document.createElement('a');
        linkElement.setAttribute('href', dataUri);
        linkElement.setAttribute('download', exportFileDefaultName);
        linkElement.click();
    },
    
    importData(e) {
        const file = e.target.files[0];
        if (!file) return;
        const reader = new FileReader();
        reader.onload = (e) => {
            const contents = e.target.result;
            if (Store.importData(contents)) {
                alert('Data imported successfully!');
                window.location.reload();
            } else {
                alert('Invalid backup file.');
            }
        };
        reader.readAsText(file);
    },
    
    clearAllData() {
        if (confirm('WARNING: This will delete all local data. Are you absolutely sure?')) {
            Store.clearAll();
            window.location.reload();
        }
    }
};

document.addEventListener('DOMContentLoaded', () => {
    app.init();
    document.addEventListener('keydown', (e) => {
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') { e.preventDefault(); app.toggleSearch(); }
        if (e.key === 'Escape') {
            if (!document.getElementById('search-overlay').classList.contains('hidden')) app.toggleSearch();
            else if (!document.getElementById('modal-task').classList.contains('hidden')) app.closeTaskModal();
            else if (!document.getElementById('modal-project').classList.contains('hidden')) app.closeProjectModal();
            else if (!document.getElementById('modal-habit').classList.contains('hidden')) app.closeHabitModal();
            else app.closeDetailsPanel();
        }
    });
});
