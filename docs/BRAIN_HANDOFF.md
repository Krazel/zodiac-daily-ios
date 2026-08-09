# Brain handoff — 2026-08-09

Use this block to update `Brain/projects/zodiac-daily.md` while the project
workspace does not have write access to Brain.

## Estado DIS-001

- Nombre interno: `ZodiacDailyNative`.
- Nombre publico de trabajo: **Zodiac Daily**.
- Promesa: “A beautifully written daily horoscope for your sign, presented
  like a collectible editorial card.”
- MVP definido: Welcome/Sign Selection, Today, Saved y Settings/About como hoja;
  iPhone, ingles, contenido y guardados locales, sin cuentas ni datos personales.
- Compartir: candidato stretch; fuera del MVP base.
- Tareas auxiliares completadas: `product_mvp` y `technical_setup`.
- Tareas auxiliares completadas despues de la regla practica: `core_engine` y
  `architecture_audit`.
- Repo local: `C:\Users\dmkra\Documents\Codex Apps\ZodiacDailyNative`.
- Rama: `main`.
- Primer commit seguro: `5ff603a` (`chore: initialize Zodiac Daily repository`).
- Working tree: limpio.
- GitHub: pendiente; no se creo repo ni remoto externo.
- UI: no implementada, conforme a visual-first.
- Regla visual actualizada: la aprobacion bloquea solo la implementacion visual
  final; motor, datos, contenido local, persistencia, tests y documentacion
  pueden avanzar en paralelo.
- Propuestas Today pendientes de aprobacion:
  - A `Design/Concepts/today-a-celestial-broadsheet.png` — recomendada.
  - B `Design/Concepts/today-b-modern-magazine.png`.
  - C `Design/Concepts/today-c-mystic-night.png`.
  - C2 `Design/Concepts/today-c2-collectible-card.png` — revision que presenta
    toda la lectura como una carta guardable; recomendacion actual.
- Feedback registrado: la lectura debe sentirse como una carta/tarjeta que el
  usuario guarda como objeto, no como un panel unido a la pantalla.
- Primera decision del propietario: aprobar C2 o pedir otro ajuste concreto.
- Tras aprobacion: registrar imagen/fecha/cambios y generar Welcome, Saved y
  Settings en esa direccion; no implementar todavia esas pantallas sin su propia
  aprobacion.
- Bloqueo tecnico futuro: compilacion, simulador, firma y archivo necesitan Mac
  con Xcode; el entorno Windows actual solo permite preparar repo y documentos.
- Nucleo no visual implementado como Swift Package: 12 signos, dia local,
  catalogo ingles bundled, generacion FNV-1a determinista, snapshots guardados,
  store en memoria y XCTest. Validacion estatica y JSON correctos; ejecucion de
  XCTest pendiente de Mac/Swift.
