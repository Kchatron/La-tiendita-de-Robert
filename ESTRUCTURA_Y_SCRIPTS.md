# Documentación Técnica de Estructura y Scripts — Robert's Book

Este documento detalla exhaustivamente todos los archivos, scripts y componentes técnicos implementados y modernizados en el proyecto **Robert's Book**, aplicando las especificaciones de **Material Design 3**, la paleta de colores de alto contraste y la arquitectura desacoplada entre **Flutter (Dart)** y el módulo nativo de **Android (Kotlin + XML)**.

---

## 1. Diagrama de Arquitectura y Comunicación

```
+-------------------------------------------------------------+
|                     CAPA FLUTTER (Dart)                    |
|                                                             |
|  HomeScreen (home_screen.dart)                              |
|  - UI moderna con Paleta Vibrante (#4F46E5, #F8FAFC).       |
|  - Catálogo de libros con portadas mediante BookCardItem.   |
|  - Botón técnico: "Diagnóstico del Sistema (Nativo)".       |
|  - Dispara: platform.invokeMethod('openNativeInfo')         |
+------------------------------+------------------------------+
                               |
                               |  MethodChannel ("com.robertsbook/native")
                               v
+-------------------------------------------------------------+
|                  CAPA NATIVA ANDROID (Kotlin)               |
|                                                             |
|  MainActivity.kt                                            |
|  - Intercepta la llamada asíncrona del MethodChannel.       |
|  - Dispara un Intent explícito hacia la Activity nativa.    |
|                              |                              |
|                              v                              |
|  NativeInfoActivity.kt                                      |
|  - Hereda de Activity nativa con NativeTheme (MD3).         |
|  - Infla la vista moderna: activity_main.xml                |
|  - Lee el hardware: Build.MODEL, Build.VERSION y batería.   |
|  - Botón "Volver a Robert's Book": invoca finish().         |
+-------------------------------------------------------------+
```

---

## 2. Árbol de Estructura del Proyecto

```
bookshop_flutter/
├── planning.md                                  # Plan original y justificación académica
├── mejoras_esteticas_y_modulo_nativo.md         # Especificación técnica de diseño y módulo nativo MD3
├── ESTRUCTURA_Y_SCRIPTS.md                      # [Este documento] Detalle completo de scripts y arquitectura
├── android/
│   ├── gradle/wrapper/
│   │   └── gradle-wrapper.properties            # Configuración estable de Gradle Wrapper
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml              # Declaración de NativeInfoActivity con tema NativeTheme
│           ├── kotlin/com/example/bookshop_flutter/
│           │   ├── MainActivity.kt              # Registro y despacho del MethodChannel
│           │   └── NativeInfoActivity.kt        # Controlador nativo Kotlin (Hardware & Material Design 3)
│           └── res/
│               ├── layout/
│               │   └── activity_main.xml        # Interfaz gráfica nativa con componentes Material Design 3
│               └── values/
│                   └── styles.xml               # Configuración de temas (LaunchTheme, NormalTheme, NativeTheme)
└── lib/
    ├── main.dart                                # Punto de entrada Flutter (renombrado a "Robert's Book")
    └── ui/screens/
        ├── auth/
        │   └── login_screen.dart                # Actualización de identidad de marca ("Robert's Book")
        └── home/
            └── home_screen.dart                 # Dashboard moderno + BookCardItem + Invocación del canal nativo
```

---

## 3. Desglose Detallado de Scripts y Archivos

### 3.1. Lado Nativo Android (Kotlin & Material Design 3)

#### A. Interfaz Gráfica Nativa: `android/app/src/main/res/layout/activity_main.xml`
* **Ruta:** `android/app/src/main/res/layout/activity_main.xml` (reemplaza al legacy `main.xml`).
* **Propósito:** Vista de diagnóstico del dispositivo y hardware utilizando componentes de **Material Design 3**:
  * `com.google.android.material.card.MaterialCardView`: Tarjetas con elevación sutil, bordes suaves (`#E2E8F0`) y radio de curva de 16dp.
  * `TextView`: Despliega de manera separada:
    1. **Modelo Físico:** (`deviceModelText`), ej. `Xiaomi M2007J20CG`.
    2. **Sistema Operativo:** (`osVersionText`), ej. `Android 10 (API 29)`.
    3. **Nivel de Batería:** (`batteryLevelText`), badge en color verde esmeralda (`#10B981`).
  * `com.google.android.material.button.MaterialButton`: Botón estilizado en color índigo (`#4F46E5`) con curvatura táctil confortable.

---

#### B. Controlador Nativo: `NativeInfoActivity.kt`
* **Ruta:** `android/app/src/main/kotlin/com/example/bookshop_flutter/NativeInfoActivity.kt`
* **Propósito:** Conecta con `activity_main.xml`, extrae la telemetría del sistema operativo y gestiona el ciclo de vida:
  * Lee el modelo con `Build.MANUFACTURER` y `Build.MODEL`.
  * Lee la versión y nivel de API con `Build.VERSION.RELEASE` y `Build.VERSION.SDK_INT`.
  * Monitorea la batería con `IntentFilter(Intent.ACTION_BATTERY_CHANGED)`.
  * Finaliza la actividad y regresa fluidamente a Flutter con `finish()`.

---

#### C. Estilos y Manifiesto: `styles.xml` y `AndroidManifest.xml`
* **`styles.xml`:** Define `NativeTheme` heredando de `Theme.MaterialComponents.DayNight.NoActionBar` para dar soporte nativo a los componentes de Material 3 sin generar conflictos con el tema de splash de Flutter.
* **`AndroidManifest.xml`:** Registra la actividad con:
  ```xml
  <activity
      android:name=".NativeInfoActivity"
      android:exported="false"
      android:label="Robert's Book - Diagnóstico"
      android:theme="@style/NativeTheme" />
  ```

---

### 3.2. Lado Flutter (Dart)

#### A. Dashboard Principal: `lib/ui/screens/home/home_screen.dart`
* **Paleta de Colores de Alto Contraste:**
  * Fondo: `#F8FAFC` (Clean Off-White).
  * Primario: `#4F46E5` (Electric Indigo).
  * Acentos: `#10B981` (Emerald).
  * Texto Principal: `#0F172A` (Slate Dark).
  * Texto Secundario: `#64748B`.
* **Componentes Principales:**
  * **Hero Banner:** Mensaje de bienvenida a "Robert's Book", degradado estilizado y botón **"Diagnóstico del Sistema (Nativo)"**.
  * **AppBar Action:** Ícono técnico directo (`Icons.memory_rounded`) para acceso inmediato a la pantalla nativa.
  * **Widget `BookCardItem`:** Tarjetas de catálogo con portadas redondeadas, sombra sutil, título, autor y precio destacado, con soporte para imágenes remotas, locales y fallback decorativo.
