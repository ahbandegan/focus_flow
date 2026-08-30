/**
 * Statistics Charts Initialization
 */

const Charts = {
    focusChart: null,
    projectChart: null,

    init() {
        this.renderFocusTimeChart();
        this.renderProjectChart();
    },

    renderFocusTimeChart() {
        const ctx = document.getElementById('chart-focus-time');
        if (!ctx) return;
        
        // Mock data for the week
        const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const data = [120, 150, 90, 200, 180, 60, Math.max(Store.data.stats.focusTime, 30)];

        const isDark = document.documentElement.classList.contains('dark');
        const textColor = isDark ? '#9ca3af' : '#6b7280';
        const gridColor = isDark ? 'rgba(75, 85, 99, 0.2)' : 'rgba(229, 231, 235, 0.5)';

        if (this.focusChart) this.focusChart.destroy();

        this.focusChart = new Chart(ctx, {
            type: 'bar',
            data: {
                labels: days,
                datasets: [{
                    label: 'Focus Time (min)',
                    data: data,
                    backgroundColor: '#3b82f6',
                    borderRadius: 6,
                    borderSkipped: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: gridColor },
                        ticks: { color: textColor }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: textColor }
                    }
                }
            }
        });
    },

    renderProjectChart() {
        const ctx = document.getElementById('chart-projects');
        if (!ctx) return;

        const tasks = Store.getTasks();
        const projects = Store.getProjects();
        
        // Count tasks per project
        const projectCounts = {};
        tasks.forEach(t => {
            if (t.projectId) {
                projectCounts[t.projectId] = (projectCounts[t.projectId] || 0) + 1;
            } else {
                projectCounts['unassigned'] = (projectCounts['unassigned'] || 0) + 1;
            }
        });

        const labels = [];
        const data = [];
        const bgColors = [];

        Object.keys(projectCounts).forEach(pid => {
            if (pid === 'unassigned') {
                labels.push('Unassigned');
                bgColors.push('#9ca3af');
            } else {
                const p = projects.find(pr => pr.id === pid);
                if (p) {
                    labels.push(p.name);
                    bgColors.push(p.color);
                }
            }
            data.push(projectCounts[pid]);
        });

        const isDark = document.documentElement.classList.contains('dark');
        
        if (this.projectChart) this.projectChart.destroy();

        this.projectChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: labels,
                datasets: [{
                    data: data.length ? data : [1], // fallback
                    backgroundColor: bgColors.length ? bgColors : ['#e5e7eb'],
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '75%',
                plugins: {
                    legend: {
                        position: 'right',
                        labels: {
                            color: isDark ? '#e5e7eb' : '#374151',
                            usePointStyle: true,
                            padding: 20
                        }
                    }
                }
            }
        });
    }
};
