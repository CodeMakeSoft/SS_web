# SmartSync Web

Este es el panel administrativo de **SmartSync**, desarrollado exclusivamente para la web. Está separado del proyecto móvil de SmartSync para mantener una arquitectura de código limpio, rápida y enfocada únicamente en la experiencia de escritorio para los administradores.

## 🚀 Tecnologías Principales

- **Framework**: Flutter (Web)
- **Lenguaje**: Dart
- **Backend/Base de Datos**: Firebase (Authentication & Cloud Firestore)
- **Diseño**: Tema "Dark Tech" personalizado (Material 3)

## 📁 Estructura del Proyecto

El proyecto está diseñado bajo una arquitectura modular por funcionalidades (Feature-first):

```text
lib/
 ┣ features/
 ┃ ┣ auth/          # Pantallas y lógica de inicio de sesión del administrador
 ┃ ┣ dashboard/     # Métricas y estadísticas principales (Home web)
 ┃ ┣ layout/        # Estructura principal, Sidebars y barras de navegación
 ┃ ┗ users/         # Módulo para visualizar la lista y control de usuarios
 ┣ main.dart        # Punto de entrada de la aplicación
 ┗ firebase_options.dart # (Archivo auto-generado, no se sube al repositorio por seguridad)
```

## ⚙️ Configuración y Ejecución

1. **Requisitos Previos**

   - Tener Flutter SDK instalado y configurado en tu entorno.
   - Acceso al proyecto de nube de Firebase: `smartsync-a3167`.
2. **Instalar Dependencias**

   ```bash
   flutter pub get
   ```
3. **Configurar Firebase Localmente**
   Como este es un proyecto nuevo, necesitas enlazar tu frontend al backend usando Flutterfire CLI. *(Los archivos resultantes como `firebase_options.dart` están ignorados en Git).*

   ```bash
   flutterfire configure
   ```
4. **Correr el Proyecto**
   Para probarlo o desarrollar, ejecuta el proyecto forzando el modo navegador:

   ```bash
   flutter run -d chrome
   ```

## 🔒 Consideraciones de Seguridad

- **No expongas credenciales:** El archivo `firebase_options.dart`, configuraciones locales o de Firebase CLI han sido ignoradas en el `.gitignore`. Cada entorno o desarrollador deberá correr `flutterfire configure`.
- **Reglas de Acceso:** La UI permite navegar bajo un rol de Administrador. En caso de implementar seguridad backend, deberás validarlo contra los claims de tu Firebase Firestore (verificando `user.role == 'admin'`).
