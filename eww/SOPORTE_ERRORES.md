# 🖖 LCARS Desktop Overlay - Guía de Soporte y Solución de Errores

Esta guía recopila los problemas comunes detectados en este widget de escritorio LCARS y proporciona los pasos específicos para diagnosticarlos y resolverlos.

---

## 🛠️ Índice de Problemas Comunes

1. [El widget se muestra pero las métricas no se actualizan (Stardate o Volumen en blanco/0%)](#1-las-métricas-no-se-actualizan)
2. [Error: `eww` no está instalado o no se encuentra en el sistema](#2-eww-no-instalado)
3. [Error de colisión: El widget no se abre o no responde (Conflicto de demonio)](#3-conflicto-de-demonio)
4. [Los botones de acción no hacen nada (SYS MONITOR, RUN APPS, etc.)](#4-botones-de-acción-inactivos)
5. [La tipografía no se parece a Star Trek (Fuentes por defecto)](#5-fuentes-y-estilo-incorrecto)
6. [El widget se dibuja encima de otras ventanas (Problemas de capa/stacking)](#6-problema-de-capas)

---

### 1. Las métricas no se actualizan

* **Síntoma:** El indicador `STARDATE` muestra un valor fijo o vacío, o la barra de `VOLUME` se queda en `0%` y los botones `DEC` e `INC` no funcionan.
* **Causa Común:** Los scripts auxiliares en `eww/scripts/` no tienen permisos de ejecución o faltan dependencias del sistema.
* **Diagnóstico:**
  Ejecuta los scripts manualmente desde la terminal para ver el error:
  ```bash
  ./eww/scripts/stardate.py
  ./eww/scripts/volume_control.sh get
  ```
  Si obtienes un error tipo `Permission denied`, es un problema de permisos. Si obtienes `command not found`, falta una dependencia.
* **Solución:**
  1. **Otorgar permisos:**
     ```bash
     chmod +x eww/scripts/stardate.py eww/scripts/volume_control.sh
     ```
  2. **Instalar Python 3** (necesario para Stardate):
     Asegúrate de tener Python instalado: `python3 --version`.
  3. **Instalar controladores de volumen:**
     El script de volumen soporta `pamixer` (recomendado) y `pactl` (PulseAudio/PipeWire). Instálalos según tu distribución:
     * *Arch Linux:* `sudo pacman -S pamixer pulseaudio` (o `pipewire-pulse`)
     * *Ubuntu/Debian:* `sudo apt install pamixer pulseaudio-utils`

---

### 2. Eww no instalado

* **Síntoma:** Al ejecutar `run_test.sh` o `install.sh` se muestra el error `Error: 'eww' no está instalado en el sistema`.
* **Causa Común:** No se ha instalado el paquete de Eww (Elkowars Wacky Widgets).
* **Solución:**
  Instala `eww` en tu sistema. Se recomienda la versión adaptada a tu servidor gráfico (X11 o Wayland).
  * **Arch Linux (AUR):**
    * Para Wayland: `yay -S eww-wayland`
    * Para X11: `yay -S eww-x11`
  * **Otras distribuciones:** Sigue las instrucciones oficiales de compilación e instalación en [elkowar.github.io/eww](https://elkowar.github.io/eww/).

---

### 3. Conflicto de demonio

* **Síntoma:** Intentas iniciar el widget pero la terminal se queda colgada, o los cambios que haces en la configuración no se ven reflejados.
* **Causa Común:** Hay otra instancia del demonio `eww` ejecutándose con una configuración diferente (por ejemplo, en `~/.config/eww`), lo que impide que la nueva instancia tome el control.
* **Solución:**
  1. Detén todas las instancias de eww activas:
     ```bash
     eww kill
     ```
  2. Si estás probando de forma aislada, utiliza siempre el script provisto en la raíz del proyecto:
     ```bash
     ./run_test.sh
     ```
     Este script utiliza directorios temporales independientes en `/tmp/` para evitar colisiones con tu configuración de producción.

---

### 4. Botones de acción inactivos

* **Síntoma:** Haces clic en `SYS MONITOR`, `RUN APPS`, `SYS CONFIG` o `REBOOT SYSTEM` y no sucede nada.
* **Causa Común:** Estos botones están configurados por defecto para entornos de escritorio basados en **KDE Plasma** (`plasma-systemmonitor`, `krunner`, `systemsettings`, `qdbus org.kde.Shutdown`). Si usas GNOME, XFCE, i3, Hyprland u otro entorno, estas herramientas no están instaladas.
* **Solución:**
  Edita el archivo [eww.yuck](file:///home/manxoig/Plantillas/lcars-eww/eww/eww.yuck) para cambiar los comandos de los botones por los de tu entorno de escritorio.
  * **Ejemplo para GNOME:**
    * Cambiar `plasma-systemmonitor &` por `gnome-system-monitor &`
    * Cambiar `krunner &` por `gnome-extensions app-grid` o el lanzador que uses.
    * Cambiar `systemsettings &` por `gnome-control-center &`

---

### 5. Fuentes y estilo incorrecto

* **Síntoma:** El widget tiene un aspecto simple, los textos son demasiado anchos y desalineados, y no se parecen al estilo de Star Trek LCARS.
* **Causa Común:** No tienes instalada la fuente tipográfica recomendada en tu sistema.
* **Solución:**
  El archivo CSS del widget busca las siguientes fuentes en orden de prioridad: `"Swiss 911 Ultra Compressed"`, `"Hansen"`, `"Arial Narrow"`.
  1. Descarga e instala una fuente estilo LCARS como **Swiss 911 Ultra Compressed** o **Antonio Bold**.
  2. Cópiala a tu directorio de fuentes de usuario (usualmente `~/.local/share/fonts/` o `~/.fonts/`).
  3. Regenera la caché de fuentes de tu sistema:
     ```bash
     fc-cache -fv
     ```

---

### 6. Problema de capas

* **Síntoma:** El widget se superpone a las ventanas del navegador o la terminal, tapando el flujo de trabajo en lugar de actuar como un fondo de pantalla.
* **Causa Común:** La configuración del comportamiento de ventana de Eww depende del compositor de ventanas (X11 vs Wayland).
* **Solución:**
  En [eww.yuck](file:///home/manxoig/Plantillas/lcars-eww/eww/eww.yuck), localiza la sección `(defwindow lcars-bg ...)` y ajusta las opciones:
  * `:stacking "bottom"` (indica a Eww que debe ir al fondo).
  * `:exclusive false` (evita que reserve espacio en los bordes de la pantalla e interfiera con las ventanas maximizadas).
  * Si usas un gestor de ventanas tipo i3/Sway, añade una regla de ventana flotante y desactiva los bordes para la clase `eww-lcars-bg`.
