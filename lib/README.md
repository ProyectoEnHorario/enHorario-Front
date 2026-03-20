# Estructura base de lib

Este directorio contiene todo el codigo Dart de la app.

## Convenciones generales
- Tipo de archivo principal: `.dart`.
- Nombres de archivo: `snake_case.dart`.
- Nombres de clases: `PascalCase`.
- Nombres de variables y funciones: `camelCase`.
- Un widget publico por archivo cuando sea posible.

## Carpetas
- `app/`: configuracion global (tema, app root, rutas).
- `core/`: piezas compartidas entre features.
- `features/`: modulos funcionales por caso de uso.
