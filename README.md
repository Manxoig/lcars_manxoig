# LCARS Interactive Desktop Overlay 🖖

Este proyecto tiene como objetivo crear un **escritorio interactivo inspirado en LCARS** (Star Trek) que funciona como una capa informativa sobre el wallpaper, sin reemplazar la barra de tareas o el flujo de trabajo actual del usuario.

Desarrollado bajo **Licencia GNU GPL v3**, este proyecto está diseñado para ser altamente personalizable y ligero.

## ✨ Características
- **Capa No Intrusiva:** Se sitúa detrás de las ventanas activas pero encima del fondo de pantalla.
- **Interactividad Directa:** Control de volumen, monitor de sistema y acceso rápido a herramientas.
- **Estética Fiel:** Basado en el diseño Library Computer Access and Retrieval System.
- **Portabilidad:** Diseñado inicialmente para Arch Linux con planes de expansión a Ubuntu y otras distros.

## 🛠️ Requisitos previos (Arch Linux)
Para la versión inicial necesistas:
- `eww-wayland` o `eww-x11` (ElKowar's Wacky Widgets)
- `playerctl` (para control de medios)
- `pamixer` o `pactl` (para control de audio)
- Fuentes: *Hansen* o *Swiss 911 Ultra Compressed* (se incluirán en /assets)



## 🗺️ Roadmap
- [ ] **Fase 1:** Implementación funcional en Arch Linux (Widgets básicos de Audio y RAM).
- [ ] **Fase 2:** Empaquetado para Ubuntu/Debian.
- [ ] **Fase 3:** Sistema de configuración vía archivo YAML/JSON.
- [ ] **Fase 4:** Soporte multi-monitor.



---
Desarrollado por manxoig- Basado en la experiencia del proyecto [Raspkali](https://github.com/Manxoig/raspkali)
