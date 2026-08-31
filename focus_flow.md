---
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 4px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  margin-mobile: 16px
  gutter-mobile: 12px
---

## Brand & Style

The design system is anchored in a **Modern Corporate** aesthetic with a strong emphasis on **Minimalism** to facilitate deep work and cognitive clarity. The brand personality is focused, reliable, and functional, catering to high-performance individuals who require a tool that recedes into the background until needed.

The visual language utilizes heavy whitespace and precise alignment to reduce mental noise. It avoids decorative flourishes in favor of utility, using color only to denote state changes, urgency, or task completion. The interface should feel like a high-end physical stationery set—purposeful, tactile, and durable.

## Colors

This design system uses a logic-driven palette designed for long-term focus.

*   **Primary (Deep Productivity Blue):** Used for primary actions, active navigation states, and brand identifiers. It evokes stability and professional trust.
*   **Secondary (Slate):** Used for supporting elements, inactive icons, and metadata. It provides a grounded, neutral balance.
*   **Accent (Tomato Red):** Reserved exclusively for high-priority states: the active Pomodoro timer, overdue tasks, and critical alerts.
*   **Surface Strategy:** 
    *   **Light Mode:** Employs a "Paper" strategy using `#FFFFFF` for cards and `#F7FAFC` for the base background to create subtle depth without shadows.
    *   **Dark Mode:** Employs a "Charcoal" strategy using `#1A202C` as the base and `#2D3748` for elevated containers to maintain contrast and readability in low-light environments.

## Typography

The typography system relies on **Inter** for its exceptional legibility and neutral, systematic tone. **JetBrains Mono** is introduced for labels and metadata to provide a technical, "data-driven" feel that reinforces the productivity narrative.

*   **Hierarchy:** Use bold weights (700) sparingly for page titles. Medium weights (500/600) are the primary drivers for list item titles and interactive elements.
*   **Scale:** On mobile devices, `display-lg` is capped at 32px to ensure titles do not wrap aggressively.
*   **Spacing:** Tighten letter spacing on larger headings (`-0.02em`) to maintain a compact, professional appearance.

## Layout & Spacing

The design system utilizes a **4px baseline grid** to ensure mathematical harmony. 

*   **Content Density:** Prioritize high density for task lists. Use `12px` (sm+xs) vertical padding for list items to maximize the number of visible tasks per screen.
*   **Margins:** A standard `16px` margin is applied to the left and right of the screen.
*   **Safe Areas:** Ensure interactive elements (buttons, checkboxes) maintain a minimum hit target of `44x44px`, even if their visual representation is smaller.

## Elevation & Depth

Hierarchy is established through **Tonal Layering** supplemented by **Low-Contrast Outlines**.

*   **Base Layer:** The background uses the neutral surface color.
*   **Level 1 (Cards):** Use a pure white (light) or soft charcoal (dark) background with a `1px` border colored at 10% opacity of the secondary color.
*   **Shadows:** Shadows are highly diffused and faint. Use a `Y: 4, Blur: 12, Opacity: 0.05` shadow for cards to suggest they are slightly raised from the surface.
*   **Active State:** When an item is dragged or focused, the shadow intensity increases to `Opacity: 0.12` and the border color shifts to the Primary color.

## Shapes

The shape language is defined by **16px (rounded-lg)** corners for primary containers and cards. This softens the professional tone, making the app feel approachable rather than rigid.

*   **Buttons:** Use the `rounded-lg` (1rem) setting for a modern, chunky feel.
*   **Input Fields:** Match the card radius (16px) to maintain visual consistency.
*   **Small Elements:** Chips and tags should use "Pill-shaped" (3) roundedness to differentiate them from actionable cards.

## Components

*   **Cards:** The core of the UI. Must have a 16px corner radius, a 1px subtle border, and 16px internal padding.
*   **Buttons:**
    *   *Primary:* Solid Deep Blue background with white text.
    *   *Secondary:* Ghost style with a Slate 1px border.
    *   *Accent:* Solid Tomato Red for Pomodoro "Start" or "Stop" actions.
*   **Checkboxes:** Large, custom-styled circles (24px). When checked, they should fill with the Primary color and trigger a strikethrough on the associated text.
*   **Input Fields:** Use a subtle light gray fill (`#EDF2F7`) in light mode to define the field area clearly without needing a heavy border.
*   **Chips/Tags:** Used for categorizing tasks (e.g., "Work", "Personal"). Use light tint versions of the category color with dark text for high legibility.
*   **Progress Bars:** Use a thick 8px height with fully rounded ends. The track should be a 10% opacity version of the fill color.
*   **Timer Display:** Centered, large-scale typography using `timer-display` tokens, utilizing the Accent color when the timer is counting down.


TaskBloc
├── LoadTasks
├── AddTask
├── UpdateTask
├── DeleteTask
├── CompleteTask
├── RestoreTask
└── FilterTasks

ProjectBloc
├── LoadProjects
├── AddProject
├── UpdateProject
└── DeleteProject

PomodoroBloc
├── StartTimer
├── PauseTimer
├── ResumeTimer
├── StopTimer
├── SkipTimer
└── TimerTick

StatisticsBloc
├── LoadDailyStats
├── LoadWeeklyStats
├── LoadMonthlyStats
└── ChangeDateRange

HabitBloc
├── LoadHabits
├── AddHabit
├── CompleteHabit
└── DeleteHabit

SettingsCubit
├── Theme
├── TimerSettings
├── NotificationSettings
└── AppSettings