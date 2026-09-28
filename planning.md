# Plan y Documentación de Implementación Nativa (Kotlin + XML) en Robert's Book

## 1. Objetivo del Proyecto
Integrar una característica nativa desarrollada en **Kotlin** con diseño en **XML puro**, comunicada mediante **Platform Channels (MethodChannel)** con el framework de Flutter. 

Esta implementación está diseñada específicamente para justificar técnicamente el uso de desarrollo nativo en una aplicación híbrida/multiplataforma frente a una evaluación docente.

---

## 2. Caso de Uso: Módulo Nativo de Diagnóstico y Hardware
En aplicaciones del mundo real, no todas las interfaces y funcionalidades se construyen en Flutter:
- Ciertos SDKs bancarios, lectores biométricos o módulos de periféricos exigen interfaces nativas (`Activity` tradicional con layouts XML).
- La lectura de métricas críticas de hardware (sensores, estado de batería detallado, niveles de carga, arquitecturas de CPU) es gestionada de manera directa por las APIs nativas del Android Framework.

En **Robert's Book**, creamos una **Pantalla Nativa de Información del Dispositivo**:
1. Desde la pantalla de inicio en Flutter (`HomeScreen`), el usuario presiona el botón **"Ver Info del Dispositivo"**.
2. Flutter despacha un mensaje asíncrono a través de un canal binario (`MethodChannel`).
3. La clase `MainActivity.kt` intercepta el mensaje e inicia una nueva `Activity` nativa (`NativeInfoActivity.kt`).
4. Esta actividad infla el layout `main.xml`, consulta el hardware a través de `BatteryManager` y `android.os.Build`, y muestra los datos en pantalla.
5. El usuario puede presionar **"Volver a Flutter"** para cerrar la actividad nativa y regresar fluidamente al flujo de Flutter.

---

## 3. Estructura y Separación de Archivos

Cada tecnología tiene su propia carpeta aislada, respetando la arquitectura estándar de Android y Flutter:

```
bookshop_flutter/
├── android/app/src/main/
│   ├── AndroidManifest.xml                    <- Registro de la nueva Activity nativa y etiqueta Robert's Book
│   ├── kotlin/com/example/bookshop_flutter/
│   │   ├── MainActivity.kt                    <- Configuración del MethodChannel ("com.robertsbook/native")
│   │   └── NativeInfoActivity.kt              <- Lógica nativa en Kotlin (Lectura de hardware y ciclo de vida)
│   └── res/layout/
│       └── main.xml                           <- Interfaz gráfica nativa diseñada en XML (LinearLayout, TextView, Button)
└── lib/
    ├── main.dart                              <- Configuración principal renombrada a "Robert's Book"
    └── ui/screens/home/
        └── home_screen.dart                   <- Interfaz moderna de Robert's Book + invocación del MethodChannel
```

---

## 4. Guía de Sustentación para el Docente (Preguntas Frecuentes)

### P1: *"¿Por qué utilizaron Kotlin y XML si Flutter ya se encarga de la interfaz?"*
> **Respuesta:** *"Utilizamos Kotlin y XML para demostrar la interoperabilidad de Flutter con el sistema operativo anfitrión. En entornos empresariales es muy común tener módulos heredados (Legacy) o librerías de fabricantes que únicamente proveen interfaces nativas en XML. Implementamos este flujo para evidenciar el dominio de Method Channels y el ciclo de vida de un `Activity` de Android dentro de una app Flutter."*

### P2: *"¿Cómo se comunican Flutter y Kotlin internamente?"*
> **Respuesta:** *"Se comunican mediante **Platform Channels**, específicamente un `MethodChannel` con el identificador `'com.robertsbook/native'`. Este mecanismo serializa las llamadas en mensajes binarios que viajan entre la máquina virtual de Dart y el proceso nativo de Android gestionado por `FlutterEngine`."*

### P3: *"¿Qué hace el código Kotlin exactamente?"*
> **Respuesta:** *"El archivo `NativeInfoActivity.kt` extiende de `Activity`. En su método `onCreate`:
> 1. Realiza el enlace con la vista usando `setContentView(R.layout.main)`.
> 2. Consulta el estado del hardware suscribiéndose a las transmisiones del sistema mediante un `IntentFilter(Intent.ACTION_BATTERY_CHANGED)`.
> 3. Extrae la información de batería (`BatteryManager.EXTRA_LEVEL` y `EXTRA_SCALE`) y las constantes del fabricante en `android.os.Build`.
> 4. Vincula un `OnClickListener` al botón para invocar `finish()`, devolviendo el control al stack de navegación de Flutter."*

---

## 5. Estado de la Implementación
- [x] Documento de planificación y sustentación (`planning.md`).
- [x] Maquetación nativa en XML (`android/app/src/main/res/layout/main.xml`).
- [x] Controlador nativo en Kotlin (`NativeInfoActivity.kt`).
- [x] Integración del puente en `MainActivity.kt`.
- [x] Registro en `AndroidManifest.xml` con nombre "Robert's Book".
- [x] Rediseño profesional de `home_screen.dart` con bienvenida, catálogo decorativo y botón al módulo nativo.
