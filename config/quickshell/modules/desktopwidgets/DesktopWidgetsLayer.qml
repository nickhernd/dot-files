pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

// The desktop widgets, each in its own draggable surface (WidgetWindow).
// Which are on and where they sit: services/DesktopWidgets. The visualizer
// lives in modules/cava/CavaWidget.qml.
Scope {
    WidgetWindow {
        widgetId: "clock"
        widget: Component { ClockWidget {} }
    }

    WidgetWindow {
        widgetId: "music"
        widget: Component { MusicWidget {} }
    }

    WidgetWindow {
        widgetId: "sysmon"
        widget: Component { SysmonWidget {} }
    }

    WidgetWindow {
        widgetId: "weather"
        widget: Component { WeatherWidget {} }
    }

    WidgetWindow {
        widgetId: "dev"
        widget: Component { DevWidget {} }
    }

    WidgetWindow {
        widgetId: "todo"
        widget: Component { TodoWidget {} }
    }

    WidgetWindow {
        widgetId: "quote"
        widget: Component { QuoteWidget {} }
    }

    WidgetWindow {
        widgetId: "formula"
        widget: Component { FormulaWidget {} }
    }

    WidgetWindow {
        widgetId: "deadlines"
        widget: Component { DeadlinesWidget {} }
    }

    WidgetWindow {
        widgetId: "coding"
        widget: Component { CodingTimeWidget {} }
    }

    WidgetWindow {
        widgetId: "pomodoro"
        widget: Component { PomodoroWidget {} }
    }

    WidgetWindow {
        widgetId: "battery"
        widget: Component { BatteryWidget {} }
    }

    WidgetWindow {
        widgetId: "network"
        widget: Component { NetworkWidget {} }
    }

    WidgetWindow {
        widgetId: "security"
        widget: Component { SecurityWidget {} }
    }

    WidgetWindow {
        widgetId: "news"
        widget: Component { NewsWidget {} }
    }

    WidgetWindow {
        widgetId: "notifications"
        widget: Component { NotificationsWidget {} }
    }


    WidgetWindow {
        widgetId: "processes"
        widget: Component { ProcessesWidget {} }
    }

    WidgetWindow {
        widgetId: "maintenance"
        widget: Component { MaintenanceWidget {} }
    }
}
