# Propuesta de Mejoras Estéticas y Módulo Nativo — Robert's Book

Este documento técnico está diseñado para su procesamiento e implementación mediante **Antigravity CLI**. Contiene la especificación de mejoras visuales para el frontend sin romper la arquitectura existente, la implementación nativa modernizada en **Kotlin + Material Design 3 (`activity_main.xml`)** con descripción detallada de interfaz, y los requerimientos modulares para el backend de Firebase.

---

## 1. Lineamientos de Diseño y Paleta de Colores

Para mantener la base existente sin alterar la estructura funcional ni requerir cambios tipográficos o animaciones complejas, se aplica una elevación de saturación y contraste mediante una paleta más viva:

*   **Primario (Deep Indigo / Electric Violet):** `#4F46E5` (Acentos principales, botones de acción y barras superiores).
*   **Secundario / Acento (Vibrant Emerald):** `#10B981` (Insignias de estado, lecturas de batería óptimas y disponibilidad).
*   **Fondo Base (Clean Off-White):** `#F8FAFC` (Superficie limpia con mejor contraste para tarjetas).
*   **Superficie de Tarjeta (Pure White):** `#FFFFFF` (Bordes definidos con sutil elevación).
*   **Texto Principal:** `#0F172A` (Mayor legibilidad y peso visual sin cambiar la fuente del sistema).
*   **Texto Secundario / Descriptivo:** `#64748B` (Gris neutro de alto contraste).

---

## 2. Lado Nativo Android: Kotlin + Material Design 3

Se actualiza la vista nativa de diagnóstico del dispositivo (`main.xml` evoluciona a `activity_main.xml`) adoptando componentes de **Material Design 3**: `MaterialCardView`, `ShapeableImageView` y `MaterialButton`, conservando la interoperabilidad con el `MethodChannel`.

### 2.1. Maquetación Visual: `android/app/src/main/res/layout/activity_main.xml`

A continuación se describe la estructura visual y cómo se percibe cada elemento en pantalla:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- 
  DESCRIPCIÓN VISUAL DE LA PANTALLA:
  - Fondo general: Gris ultra claro (#F8FAFC) que da un aspecto limpio y moderno.
  - Distribución: Contenedor vertical centrado con espaciado equilibrado de 24dp.
-->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:padding="24dp"
    android:gravity="center_horizontal"
    android:background="#F8FAFC">

    <!-- 
      1. CABECERA E ÍCONO PRINCIPAL
      - Cómo se ve: Un contenedor circular sombreado con borde sutil que aloja 
        el ícono de información en color azul eléctrico (#4F46E5).
    -->
    <com.google.android.material.card.MaterialCardView
        android:layout_width="88dp"
        android:layout_height="88dp"
        app:cardCornerRadius="44dp"
        app:cardElevation="2dp"
        app:strokeWidth="1dp"
        app:strokeColor="#E2E8F0"
        app:cardBackgroundColor="#EEF2FF"
        android:layout_marginTop="16dp"
        android:layout_marginBottom="20dp">

        <ImageView
            android:layout_width="44dp"
            android:layout_height="44dp"
            android:layout_gravity="center"
            android:src="@android:drawable/ic_dialog_info"
            app:tint="#4F46E5"
            android:contentDescription="Ícono de información técnica" />
    </com.google.android.material.card.MaterialCardView>

    <!-- 
      2. TÍTULOS Y DESCRIPCIÓN
      - Cómo se ve: Título audaz en negro pizarra (#0F172A), seguido de un 
        párrafo explicativo centrado en gris pizarra (#64748B).
    -->
    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Información del Dispositivo"
        android:textSize="22sp"
        android:textStyle="bold"
        android:textColor="#0F172A"
        android:layout_marginBottom="6dp" />

    <TextView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        android:text="Vista nativa desarrollada en Kotlin y maquetada con Material Design 3 sin componentes de Flutter."
        android:textSize="14sp"
        android:textAlignment="center"
        android:textColor="#64748B"
        android:lineSpacingExtra="3sp"
        android:layout_marginBottom="28dp" />

    <!-- 
      3. TARJETA MATERIAL 3 - ESTADO DEL HARDWARE
      - Cómo se ve: Una tarjeta blanca rectangular con esquinas redondeadas (16dp),
        borde suave (#E2E8F0) y dos filas internas separadas: Batería y Modelo.
    -->
    <com.google.android.material.card.MaterialCardView
        android:layout_width="match_parent"
        android:layout_height="wrap_content"
        app:cardCornerRadius="16dp"
        app:cardElevation="3dp"
        app:strokeWidth="1dp"
        app:strokeColor="#E2E8F0"
        app:cardBackgroundColor="#FFFFFF"
        android:layout_marginBottom="24dp">

        <LinearLayout
            android:layout_width="match_parent"
            android:layout_height="wrap_content"
            android:orientation="vertical"
            android:padding="20dp">

            <!-- Fila: Batería -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical"
                android:layout_marginBottom="14dp">

                <TextView
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="Nivel de Batería"
                    android:textSize="15sp"
                    android:textStyle="bold"
                    android:textColor="#334155" />

                <!-- Badge dinámico de batería en color esmeralda vivo (#10B981) -->
                <TextView
                    android:id="@+id/batteryLevelText"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Leyendo..."
                    android:textSize="15sp"
                    android:textColor="#10B981"
                    android:textStyle="bold" />
            </LinearLayout>

            <!-- Divisor sutil -->
            <View
                android:layout_width="match_parent"
                android:layout_height="1dp"
                android:background="#F1F5F9"
                android:layout_marginBottom="14dp" />

            <!-- Fila: Modelo del Dispositivo -->
            <LinearLayout
                android:layout_width="match_parent"
                android:layout_height="wrap_content"
                android:orientation="horizontal"
                android:gravity="center_vertical">

                <TextView
                    android:layout_width="0dp"
                    android:layout_weight="1"
                    android:layout_height="wrap_content"
                    android:text="Modelo Físico"
                    android:textSize="15sp"
                    android:textStyle="bold"
                    android:textColor="#334155" />

                <TextView
                    android:id="@+id/deviceModelText"
                    android:layout_width="wrap_content"
                    android:layout_height="wrap_content"
                    android:text="Detectando..."
                    android:textSize="14sp"
                    android:textColor="#64748B" />
            </LinearLayout>

        </LinearLayout>
    </com.google.android.material.card.MaterialCardView>

    <!-- Espaciador flexible para empujar la acción hacia la parte inferior -->
    <View
        android:layout_width="match_parent"
        android:layout_height="0dp"
        android:layout_weight="1" />

    <!-- 
      4. BOTÓN MATERIAL DESIGN 3 - RETORNO A FLUTTER
      - Cómo se ve: Botón ancho, sólido, de color índigo vibrante (#4F46E5) con
        esquinas redondeadas de 14dp y altura táctil confortable de 54dp.
    -->
    <com.google.android.material.button.MaterialButton
        android:id="@+id/btnBackToFlutter"
        android:layout_width="match_parent"
        android:layout_height="54dp"
        android:text="Volver a Robert's Book"
        android:textSize="15sp"
        android:textStyle="bold"
        android:textColor="#FFFFFF"
        app:backgroundTint="#4F46E5"
        app:cornerRadius="14dp"
        android:layout_marginBottom="12dp" />

</LinearLayout>
```

---

### 2.2. Controlador en Kotlin: `NativeInfoActivity.kt`

Adaptado para inflar `R.layout.activity_main` y desacoplar la carga del modelo y nivel de batería en etiquetas independientes:

```kotlin
package com.example.bookshop_flutter

import android.app.Activity
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Bundle
import android.widget.Button
import android.widget.TextView

class NativeInfoActivity : Activity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Se conecta con el layout Material Design 3
        setContentView(R.layout.activity_main)

        val batteryLevelText: TextView = findViewById(R.id.batteryLevelText)
        val deviceModelText: TextView = findViewById(R.id.deviceModelText)
        val btnBackToFlutter: Button = findViewById(R.id.btnBackToFlutter)

        // Lectura de Hardware
        val batteryLevel = getBatteryLevel()
        val manufacturer = Build.MANUFACTURER.replaceFirstChar { it.uppercase() }
        val model = Build.MODEL

        batteryLevelText.text = if (batteryLevel >= 0) "$batteryLevel%" else "N/A"
        deviceModelText.text = "$manufacturer $model"

        // Retorno al stack previo de Flutter
        btnBackToFlutter.setOnClickListener {
            finish()
        }
    }

    private fun getBatteryLevel(): Int {
        val batteryIntent = registerReceiver(
            null,
            IntentFilter(Intent.ACTION_BATTERY_CHANGED)
        )
        val level = batteryIntent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale = batteryIntent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1

        return if (level >= 0 && scale > 0) {
            (level * 100) / scale
        } else {
            -1
        }
    }
}
```

---

## 3. Lado Flutter: Tarjetas de Libros con Imágenes PNG y Paleta Viva

Sin modificar la arquitectura de pantallas ni el árbol de navegación existente, las tarjetas del catálogo en `home_screen.dart` adoptan portadas `.png` locales o remotas mediante un contenedor estético con bordes curvos y acentos vivos.

### 3.1. Estructura de Assets para Portadas PNG
Para utilizar archivos locales sin depender de URLs externas:

1. Registrar la carpeta en `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/books/
   ```
2. Ubicación recomendada:
   * `assets/books/book_1.png`
   * `assets/books/book_2.png`
   * `assets/books/placeholder.png`

### 3.2. Widget Modular para la Tarjeta de Libro (`BookCardItem`)

Representación visual mejorada que mantiene el código modular y no invasivo:

```dart
import 'package:flutter/material.dart';

class BookCardItem extends StatelessWidget {
  final String title;
  final String author;
  final String price;
  final String imagePath; // Ruta local a asset .png o URL

  const BookCardItem({
    Key? key,
    required this.title,
    required this.author,
    required this.price,
    required this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isNetwork = imagePath.startsWith('http');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contenedor de la Portada PNG
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                color: const Color(0xFFF8FAFC),
                width: double.infinity,
                child: isNetwork
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallback(),
                      ),
              ),
            ),
          ),
          // Información del Libro
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F46E5), // Índigo vivo
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallback() {
    return const Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 40,
        color: Color(0xFF94A3B8),
      ),
    );
  }
}
```

---

## 4. Instrucciones de Verificación para Antigravity CLI

1. Asegurar que `activity_main.xml` resida en `android/app/src/main/res/layout/activity_main.xml`.
2. Verificar que `AndroidManifest.xml` mantenga la referencia hacia `.NativeInfoActivity`.
3. Validar la compilación mediante:
   ```bash
   flutter build apk --debug
   ```