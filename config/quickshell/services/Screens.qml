pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// La pantalla del rice: la que lleva la barra, los widgets, el tracker, los paneles
// y las notificaciones. Las demás solo muestran el fondo (modules/wallpaper).
//
// Depende del perfil de la máquina (~/.config/dotfiles/perfil, lo escribe
// install.sh). Si cambias de monitor, cámbialo aquí y en hypr/perfiles/.
Singleton {
    id: root

    // Por perfil, el modelo o conector de esa pantalla (el primero que exista).
    // Sobremesa: el AOC de la izquierda; el Samsung de enfrente queda solo con el fondo.
    readonly property var principales: ({
        sobremesa: ["2343", "DP-4"],
        portatil: ["eDP-1", "eDP-2"]
    })

    property string perfil: ""

    readonly property ShellScreen primary: {
        const screens = Quickshell.screens;
        for (const want of principales[perfil] ?? [])
            for (const s of screens)
                if (s.name === want || s.model === want)
                    return s;
        return screens[0] ?? null;
    }

    FileView {
        path: Quickshell.env("HOME") + "/.config/dotfiles/perfil"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.perfil = text().trim()
    }
}
