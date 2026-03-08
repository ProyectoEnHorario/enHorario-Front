⏱️ EnHorario

Aplicación móvil orientada a optimizar el tiempo de las personas, permitiendo conocer tiempos estimados de espera y niveles de afluencia en diferentes establecimientos como bancos, restaurantes, comercios o entidades de servicio.

El sistema utiliza datos históricos, reportes colaborativos de usuarios y análisis predictivo para estimar cuánto tiempo podría tardar una fila antes de que el usuario llegue al lugar. 


📱 Descripción del Proyecto

En muchas ciudades, las personas pierden tiempo esperando en filas sin saber cuánto tardará la atención. Esto afecta la planificación diaria y genera estrés innecesario.

EnHorario propone una solución tecnológica que permite:

Consultar tiempos estimados de espera.

Identificar horarios con menor afluencia.

Recibir notificaciones cuando un lugar tenga poca fila.

Visualizar la concurrencia mediante mapas.

De esta forma, los usuarios pueden tomar decisiones más inteligentes sobre cuándo y dónde realizar sus actividades. 

## Reglas de Colaboración

Este documento describe el flujo de trabajo y las convenciones que seguirá el equipo de desarrollo del proyecto **EnHorario**.

### Estrategia de Ramificación: GitFlow Adaptado

Adoptamos un esquema **GitFlow adaptado** como flujo de trabajo principal. A continuación se describen las ramas del proyecto y su propósito:

| Rama | Propósito |
|------|-----------|
| `main` | Código estable y listo para producción. Protegida contra cambios directos. |
| `develop` | Rama de integración continua. Base para crear todas las feature branches. |
| `feature/nombre-funcionalidad` | Una rama por historia de usuario o tarea del backlog. |
| `fix/nombre-bug` | Corrección de bugs encontrados en `develop`. |
| `hotfix/nombre-critico` | Correcciones urgentes en producción. Se integra en `main` y `develop`. |

---

### Flujo de Trabajo Paso a Paso

1. Crear la rama desde `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/nombre-funcionalidad
   ```

2. Desarrollar y hacer commits siguiendo las convenciones (ver abajo).

3. Subir la rama al repositorio remoto:
   ```bash
   git push origin feature/nombre-funcionalidad
   ```

4. Abrir un **Pull Request** hacia `develop` en GitHub.

5. El PR debe recibir **al menos 1 aprobación** de otro miembro del equipo antes del merge.

6. Una vez aprobado, hacer merge y eliminar la rama remota.

---

### Convenciones de Mensajes de Commit

Seguimos la especificación **Conventional Commits**:

```
tipo(alcance): descripción breve
```

**Tipos válidos:**

| Tipo | Cuándo usarlo |
|------|---------------|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `docs` | Cambios en documentación |
| `refactor` | Refactorización sin cambio de funcionalidad |
| `test` | Agregar o modificar pruebas |
| `chore` | Tareas de mantenimiento (dependencias, configs) |

**Ejemplos:**
```
feat(mapas): implementar mapa de calor con datos simulados
fix(auth): corregir redirección tras login exitoso
docs(readme): actualizar sección de instalación
test(reportes): agregar unit tests para validación de campos
```
## PR de prueba
Este cambio se realizó solo para probar la plantilla de Pull Request.
