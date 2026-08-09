# Brain handoff — 2026-08-09

Use this block to update `Brain/projects/zodiac-daily.md` while the project
workspace does not have write access to Brain.

## Estado DIS-001

- Nombre interno: `ZodiacDailyNative`.
- Nombre publico de trabajo: **Zodiac Daily**.
- Promesa: “A beautifully written daily horoscope for your sign, presented
  like a collectible editorial card.”
- MVP definido: Welcome/Sign Selection, Today, Saved y Settings/About como hoja;
  iPhone, ingles, contenido diario remoto opcional con fallback local, guardados
  locales, sin cuentas ni datos personales.
- Compartir: candidato stretch; fuera del MVP base.
- Tareas auxiliares completadas: `product_mvp` y `technical_setup`.
- Tareas auxiliares completadas despues de la regla practica: `core_engine` y
  `architecture_audit`.
- Repo local: `C:\Users\dmkra\Documents\Codex Apps\ZodiacDailyNative`.
- Rama: `main`.
- Primer commit seguro: `5ff603a` (`chore: initialize Zodiac Daily repository`).
- Commit de nucleo y revision visual C2: `9e7b53a`
  (`feat: add deterministic horoscope core`).
- Commit de proyecto iOS, Today aprobado, persistencia y propuestas restantes:
  `4c6928c` (`feat: build approved Today iOS app`).
- Commit de las cuatro pantallas C2 aprobadas y propuesta Saved detail:
  `38a6ee3` (`feat: finalize approved C2 screens`).
- Commit del pipeline diario gratuito FreeAstroAPI/Cloudflare y cliente iOS:
  `7380fea` (`feat: add free daily horoscope pipeline`).
- Working tree: limpio tras el commit de actualizacion de esta ficha.
- GitHub: pendiente; no se creo repo ni remoto externo.
- UI: Today, Sign Selection, Saved vacio/poblado y Settings C2 implementadas
  tras sus aprobaciones. Solo Saved card detail sigue PROVISIONAL.
- Regla visual actualizada: la aprobacion bloquea solo la implementacion visual
  final; motor, datos, contenido local, persistencia, tests y documentacion
  pueden avanzar en paralelo.
- Historial de propuestas Today:
  - A `Design/Concepts/today-a-celestial-broadsheet.png` — recomendada.
  - B `Design/Concepts/today-b-modern-magazine.png`.
  - C `Design/Concepts/today-c-mystic-night.png`.
  - C2 `Design/Concepts/today-c2-collectible-card.png` — revision que presenta
    toda la lectura como una carta guardable; recomendacion actual.
- Feedback registrado: la lectura debe sentirse como una carta/tarjeta que el
  usuario guarda como objeto, no como un panel unido a la pantalla.
- C2 fue aprobada explicitamente por el propietario el 2026-08-09 para Today.
  Las aprobaciones posteriores de Welcome, Saved vacio/poblado y Settings
  autorizan tambien su implementacion visual final.
- Propuestas C2 adicionales:
  `Design/Concepts/sign-selection-c2.png`,
  `Design/Concepts/saved-populated-c2.png`,
  `Design/Concepts/saved-empty-c2.png` y
  `Design/Concepts/settings-c2.png`.
- El propietario aprobo explicitamente las cuatro propuestas anteriores el
  2026-08-09 y pidio continuar. Sign Selection, Saved vacio/poblado y Settings
  pueden implementarse como UI final. Saved card detail sigue provisional.
- Propuesta completa para la puerta visual restante:
  `Design/Concepts/saved-detail-c2.png`. Muestra la carta guardada completa,
  retorno nativo a Saved y `Remove from Saved` fuera de la carta. Sigue
  pendiente de aprobacion explicita y no autoriza su implementacion final.
- Implementacion actual: `ZodiacDaily.xcodeproj`, SwiftUI iOS 17, Today nativa,
  seleccion inicial de 12 signos, Saved vacio/poblado, Settings/About,
  navegacion Today/Saved, persistencia JSON atomica, preferencias locales y
  manifiesto de privacidad sin tracking ni datos recopilados. Bundle id
  provisional `com.zodiacdaily.app`, sin team ni icono.
- QA auxiliar de las pantallas C2: sin P0/P1 tras corregir el simbolo del signo
  en Saved vacio y el retorno tras eliminar desde el detalle provisional.
  XML, JSON, UTF-8, PBX y privacidad validados en Windows.
- Siguiente puerta visual: aprobar `Design/Concepts/saved-detail-c2.png` antes
  de fijar la jerarquia visual final del detalle de una carta guardada.
- Bloqueo tecnico futuro: compilacion, simulador, firma y archivo necesitan Mac
  con Xcode; el entorno Windows actual solo permite preparar repo y documentos.
- Nucleo implementado como Swift Package: 12 signos, dia local, catalogo ingles
  bundled, generacion FNV-1a determinista, snapshots guardados, stores en
  memoria y JSON file-backed y XCTest. Validacion estatica y JSON correctos;
  compilacion, XCTest y simulador pendientes de Mac/Xcode.

## Contenido diario gratuito

- El propietario eligio FreeAstroAPI free y autorizo implementacion local, no
  activacion externa.
- El iPhone pide a nuestro endpoint una edicion completa de 12 signos para la
  fecha local. No envia signo elegido, fecha de nacimiento, cuenta, guardados ni
  clave del proveedor.
- `RemoteHoroscopeRepository` valida HTTPS, fecha exacta, contrato y 12 signos;
  ante cualquier fallo usa contenido bundled.
- La primera carta resuelta por signo/dia se fija en una cache local derivable,
  de modo que no cambia al variar la red ni al relanzar. La cache se reconstruye
  si se corrompe y falla abierta si no puede escribir; `saved-cards.json` mantiene
  la politica estricta y nunca se descarta silenciosamente.
- `Backend/freeastro-worker` protege la clave, expone solo lecturas cacheadas y
  usa KV por fecha. El trafico publico nunca llama a FreeAstroAPI.
- Los Cron Triggers solo encolan fechas. Un Cloudflare Queue consumer gratuito
  procesa las 12 llamadas secuenciales; lote 1, concurrencia 1 y un solo retry.
  La precarga de manana es a las 09:45 UTC, antes de medianoche en UTC+14.
- Validacion: Worker 12/12 pruebas, sintaxis/JSON/XML/UTF-8/diff correctos, sin
  secretos y QA final sin P0/P1. Build y XCTest Swift siguen pendientes de Mac.
- No se creo cuenta, secreto, KV, Queue, Worker publico ni despliegue. Activar
  requiere autorizacion explicita y comprobar en vivo fecha de manana, CPU y
  consumo del plan gratuito.

## Lanzamiento y apoyo voluntario

- Aplicada la skill `ios-app-launch` a la planificacion. Ficha local:
  `docs/LAUNCH_READINESS.md`.
- URLs compartidas planificadas, aun no publicadas:
  `https://krazel.github.io/zodiac-daily/privacy/` y
  `https://krazel.github.io/zodiac-daily/support/`.
- Support the app queda como extension opcional de Settings, con uso principal
  siempre gratis. No hay StoreKit, productos ni UI implementados.
- La extension Support/review tiene puerta visual propia pendiente de imagen
  completa y aprobacion explicita. Crear productos, secretos, builds, subir o
  enviar a review sigue siendo accion roja.
