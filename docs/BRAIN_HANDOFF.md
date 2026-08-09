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
- Commit de nucleo y revision visual C2: `9e7b53a`
  (`feat: add deterministic horoscope core`).
- Working tree: limpio.
- GitHub: pendiente; no se creo repo ni remoto externo.
- UI: Today C2 implementada tras aprobacion; Sign Selection, Saved y Settings
  son andamios funcionales PROVISIONALES que no fijan su diseno final.
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
- C2 fue aprobada explicitamente por el propietario el 2026-08-09; Today puede
  implementarse con fidelidad. Welcome, Saved y Settings siguen necesitando su
  propia aprobacion visual; cualquier prototipo previo es provisional.
- Nuevas propuestas C2 pendientes de aprobacion:
  `Design/Concepts/sign-selection-c2.png`,
  `Design/Concepts/saved-populated-c2.png`,
  `Design/Concepts/saved-empty-c2.png` y
  `Design/Concepts/settings-c2.png`.
- Implementacion actual: `ZodiacDaily.xcodeproj`, SwiftUI iOS 17, Today nativa,
  selector de 12 signos, navegacion Today/Saved, persistencia JSON atomica,
  preferencias locales y manifiesto de privacidad sin tracking ni datos
  recopilados. Bundle id provisional `com.zodiacdaily.app`, sin team ni icono.
- Siguiente puerta visual: aprobar las propuestas C2 de Welcome, Saved y
  Settings antes de convertir sus andamios de sistema en experiencia visual
  final.
- Bloqueo tecnico futuro: compilacion, simulador, firma y archivo necesitan Mac
  con Xcode; el entorno Windows actual solo permite preparar repo y documentos.
- Nucleo implementado como Swift Package: 12 signos, dia local, catalogo ingles
  bundled, generacion FNV-1a determinista, snapshots guardados, stores en
  memoria y JSON file-backed y XCTest. Validacion estatica y JSON correctos;
  compilacion, XCTest y simulador pendientes de Mac/Xcode.
