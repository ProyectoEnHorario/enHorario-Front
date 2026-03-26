# EnHorario - Documentacion Tecnica Oficial

Aplicacion movil para gestion de tiempos de espera, turnos y afluencia en establecimientos (bancos, restaurantes y comercios).

Este documento centraliza la informacion tecnica del proyecto frontend Flutter, su integracion con backend, flujo de ramas y practicas operativas del equipo.

## 1. Alcance del Proyecto

EnHorario permite:

- Consultar establecimientos y tiempos de espera estimados.
- Gestionar turnos (solicitud, seguimiento, cambio de estado, cancelacion).
- Registrar usuarios y autenticar acceso.
- Marcar favoritos y consumir datos de apoyo para pruebas funcionales.

Estado actual de navegacion principal:

- App real: inicia en flujo de registro de usuario.
- Modo test: panel manual para pruebas de endpoints sobre Railway.
- Modo administrador: placeholder (vacio por definicion actual).

## 2. Arquitectura General

Arquitectura por capas (frontend):

- app: arranque y configuracion global de MaterialApp.
- core: configuracion compartida, utilidades, errores, componentes base.
- features: modulos funcionales por dominio (auth, home, establishments, turns, etc.).

Stack frontend:

- Flutter (SDK Dart 3.11.x).
- flutter_bloc para estado/presentacion.
- dio para cliente HTTP.
- pretty_dio_logger para trazabilidad de requests.

Backend asociado (repositorio separado):

- Spring Boot + PostgreSQL en Railway.
- Base URL por defecto consumida desde frontend:
   - https://enhorarioback-production.up.railway.app/api/v1

## 3. Estructura del Repositorio Frontend

```text
enHorario/
|- lib/
|  |- app/
|  |- core/
|  `- features/
|- android/
|- ios/
|- test/
|- pubspec.yaml
`- ReadMe.md
```

Archivos tecnicos clave:

- lib/main.dart: punto de entrada.
- lib/app/app.dart: configuracion de la app.
- lib/core/config/app_config.dart: configuracion de backend y timeouts.
- lib/features/home/presentation/pages/home_screen.dart: selector de modos.
- lib/features/auth/presentation/pages/register_user_screen.dart: registro (UI principal de App real).

## 4. Integracion con Backend

La app usa una API REST externa y no requiere backend local para el flujo operativo actual del equipo.

Configuracion de red:

- Variable compilacion opcional: BACKEND_URL.
- Si no se define, usa la URL productiva de Railway.

Regla operativa vigente:

- Pruebas funcionales y de integracion se realizan contra Railway.
- No se considera obligatorio ejecutar entorno local para validar historias de negocio.

## 5. Funcionalidades Actuales por Modo

### 5.1 App real

- Entrada al formulario de registro nuevo.
- Validaciones en cliente:
   - campos obligatorios,
   - formato de correo,
   - contrasena minima,
   - confirmacion de contrasena.
- Estado de carga y mensajes de error por campo/general.
- Servicio de registro desacoplado para conectar backend real sin rehacer UI.

### 5.2 Modo test

Panel manual para pruebas directas de endpoints:

- health,
- register/login,
- listar establecimientos,
- crear turno,
- consultar mis turnos,
- actualizar estado,
- cancelar turno.

### 5.3 Modo administrador

- Pantalla placeholder vacia (en espera de historia funcional).

## 6. Entorno de Datos de Pruebas (Railway)

El proyecto backend dispone de scripts SQL para sembrar datos de prueba integrales (usuarios, establecimientos, turnos, favoritos y demas entidades).

Referencia de script completo:

- enHorarioBack/scripts/railway_seed_full_env.sql

Este seed habilita pruebas end-to-end sobre entidades relacionadas sin depender de datos manuales en el dashboard.

## 7. Requisitos y Ejecucion Frontend

Prerequisitos:

- Flutter SDK compatible con Dart 3.11.x.
- Dispositivo/emulador Android o iOS.

Instalacion:

```bash
flutter pub get
```

Ejecucion:

```bash
flutter run
```

Ejecucion con backend alterno:

```bash
flutter run --dart-define=BACKEND_URL=https://tu-backend/api/v1
```

Calidad basica:

```bash
flutter analyze
flutter test
```

## 8. Estrategia de Ramas (GitFlow Adaptado)

Ramas base:

- main: estable para produccion.
- develop: integracion continua.

Ramas de trabajo:

- feature/<nombre-funcionalidad>
- fix/<descripcion-bug>
- hotfix/<descripcion-critica>
- ENH-<numero>-<titulo-corto>

Regla recomendada para nuevas historias:

1. Crear rama desde develop.
2. Implementar con commits pequenos y trazables.
3. Abrir PR hacia develop.
4. Hacer merge tras revision.

Ejemplo:

```bash
git checkout develop
git pull origin develop
git checkout -b ENH-2-Registro-de-Usuarios
```

## 9. Convencion de Commits

Formato:

```text
tipo(alcance): descripcion
```

Tipos permitidos:

- feat
- fix
- docs
- refactor
- test
- chore

Ejemplos:

```text
feat(auth): rehacer vista de registro para app real
fix(turns): corregir parseo de estado en modo test
docs(readme): ampliar documentacion tecnica oficial
```

## 10. Definicion de Calidad para PR

Checklist minimo sugerido:

- Compila sin errores en flutter analyze.
- No rompe navegacion base (home con 3 modos).
- Mantiene separacion por capas/modulos.
- Incluye manejo de errores y estados de carga.
- Incluye evidencia de prueba manual cuando aplique.

## 11. Seguridad y Buenas Practicas

- No exponer secretos en codigo o commits.
- Variables sensibles por entorno (CI/CD o gestor de secretos).
- Evitar logs con credenciales/tokens completos.
- Mantener validaciones de entrada en UI y backend.

## 12. Documentacion Complementaria

Frontend (este repositorio):

- ReadMe.md
- README modulares dentro de lib/

Backend (repositorio enHorarioBack):

- README.md
- README_API_ENDPOINTS.md
- API_ENDPOINTS_Y_REGLAS.md

## 13. Hoja de Ruta Tecnica

Prioridades inmediatas:

- Conectar el nuevo registro de App real al backend Railway.
- Completar login real y persistencia de sesion.
- Implementar vista funcional de administrador.
- Incrementar cobertura de pruebas automatizadas por feature.

---

Documento mantenido por el equipo de EnHorario.
Actualizar este README en cada cambio arquitectonico relevante o ajuste de flujo de ramas.
