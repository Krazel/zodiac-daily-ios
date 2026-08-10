# Brain handoff — 2026-08-10

Use this block to update `Brain/projects/zodiac-daily.md` while the project
workspace does not have write access to Brain.

## Estado DIS-001

- Nombre interno: `ZodiacDailyNative`.
- Nombre publico en App Store: **The Daily Zodiac**. La marca dentro de la app
  sigue siendo **Zodiac Daily**; Apple rechazo ese texto exacto como nombre de
  ficha porque ya estaba en uso.
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
- Commits de cierre y build: `040ea32` (experiencia aprobada), `b5813ba`
  (workflow IPA), `abcec2b` (compatibilidad iOS) y `0cf1d5f` (validacion de
  contenido empaquetado).
- Working tree: limpio tras el cierre del build y la descarga verificada.
- GitHub: repo privado `Krazel/zodiac-daily-ios`, remoto `origin` configurado y
  rama `main` subida. Actions esta habilitado. El conector GitHub de Codex no
  tiene acceso a este repo concreto, pero no bloquea el flujo actual.
- UI: Today, Sign Selection, Saved vacio/poblado y Settings C2 implementadas
  tras sus aprobaciones. `saved-detail-c2`, `settings-support-c3` y el icono C1
  estan aprobados por autorizacion visual anticipada; pueden implementarse y
  verificarse sin otra ronda visual.
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
  se implementaron como UI final. La autorizacion anticipada posterior aprobo
  tambien Saved card detail, Settings Support C3 y el icono C1.
- Referencias aprobadas por autorizacion anticipada:
  `Design/Concepts/saved-detail-c2.png`,
  `Design/Concepts/settings-support-c3.png` y
  `Design/Concepts/app-icon-c1.png`.
- Saved detail muestra la carta completa, retorno nativo a Saved y
  `Remove from Saved` fuera de la carta. Settings C3 incorpora Support, restore,
  manage, review, privacidad y terminos sin bloquear el uso gratuito.
- El icono runtime esta en `ZodiacDaily/Assets.xcassets/AppIcon.appiconset`;
  publicar el icono o preparar capturas de tienda sigue fuera de alcance.
- Implementacion actual: `ZodiacDaily.xcodeproj`, SwiftUI iOS 16, Today nativa,
  seleccion inicial de 12 signos, Saved vacio/poblado/detalle, Settings/About y
  Support StoreKit 2 local, navegacion Today/Saved, persistencia JSON atomica,
  preferencias locales y manifiesto de privacidad sin tracking ni datos
  recopilados. Bundle previsto `com.krazel.zodiacdaily`, sin team ni activacion
  externa de StoreKit.
- QA auxiliar de las pantallas C2: sin P0/P1 tras corregir el simbolo del signo
  en Saved vacio y el retorno tras eliminar desde el antiguo wrapper de detalle.
  XML, JSON, UTF-8, PBX y privacidad validados en Windows.
- Las referencias visuales restantes anteriores ya estan aprobadas. Capturas de
  tienda y cualquier arte promocional nuevo conservan su propia puerta visual.
- Bloqueos tecnicos/externos: Mac/Xcode o un dispositivo para simulador,
  StoreKitTest, firma y archivo de distribucion; App Store Connect para
  productos/grupo; URLs publicas de privacidad/terminos/soporte; y equipo de
  firma.
- Nucleo implementado como Swift Package: 12 signos, dia local, catalogo ingles
  bundled, generacion FNV-1a determinista, snapshots guardados, stores en
  memoria y JSON file-backed y XCTest. Validacion estatica y JSON correctos;
  compilacion, XCTest y simulador pendientes de Mac/Xcode.

## Contenido diario gratuito

- El propietario eligio FreeAstroAPI free y autorizo la activacion externa el
  2026-08-11.
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
- El contrato Worker/app subio a schema 2 para conservar datos V2 que antes se
  descartaban: focus, keywords, cuatro scores, suerte y Luna. Schema 1 se acepta
  durante la transicion, pero su reverso se identifica como Offline Edition y
  no inventa campos diarios ausentes. Sign essence es copy estatico del signo.
- Referencia aprobada actual del reverso:
  `Design/Concepts/today-card-back-provider-c2.png`; C1 queda supersedida.
- Validacion local del nuevo Worker: 13/13 pruebas y sintaxis correctas, sin
  secretos. Build/XCTest/visual QA del schema 2 deben cerrarse en GitHub/macOS.
- Produccion activa: Worker
  `https://zodiac-daily-content.krazel-zodiac-daily.workers.dev`, KV
  `DAILY_CACHE`, Queue `zodiac-daily-warmup`, crons `00:15 UTC` y `09:45 UTC`,
  y `FREEASTRO_API_KEY` cifrada. La edicion `2026-08-11` se valido en vivo con
  schema 2, 12 signos y datos completos. El secreto temporal de precarga fue
  eliminado y no existe ningun secreto en Git/GitHub.

## Lanzamiento y apoyo voluntario

- Aplicada la skill `ios-app-launch` a la planificacion. Ficha local:
  `docs/LAUNCH_READINESS.md`.
- App Store Connect creada el 2026-08-11: **The Daily Zodiac**, app ID
  `6800136195`, bundle ID `com.krazel.zodiacdaily`, ingles (EE. UU.), SKU
  `zodiac-daily-ios`, version `0.1.1` / build `1`, sin login y con publicacion
  manual. No se subio build ni se crearon productos.
- URLs compartidas planificadas, aun no publicadas:
  `https://krazel.github.io/zodiac-daily/privacy/` y
  `https://krazel.github.io/zodiac-daily/support/`.
- Support the app esta implementado localmente como extension opcional de
  Settings con StoreKit 2. Today, Saved y el resto del core siguen siempre
  gratis.
- Tres niveles mensuales equivalentes:
  `com.krazel.zodiacdaily.support.monthly`,
  `com.krazel.zodiacdaily.support.kind` y
  `com.krazel.zodiacdaily.support.generous`.
- La UI debe mostrar precios localizados de StoreKit, estados sin productos,
  Restore Purchases y Manage Subscription. No debe usar como precio real los
  importes dibujados en la referencia.
- Rate Zodiac Daily usa el App Store ID real `6800136195` para la URL
  `action=write-review`.
- La referencia `settings-support-c3.png` esta aprobada por autorizacion
  anticipada. Crear productos/grupo en App Store Connect, firmar, subir o enviar
  a review sigue requiriendo autorizacion externa explicita.
- Riesgo material de lanzamiento: la regla 3.1.2 exige valor continuo para una
  suscripcion auto-renovable. Antes de crear productos hay que confirmar que el
  estado supporter/mantenimiento es suficiente o convertir el mismo concepto a
  apoyo de pago unico; esto no bloquea el commit local.
- Flujo Local QA IPA operativo en
  `.github/workflows/build-ios-local-qa.yml`: manual, owner-only, sin secretos y
  sin upload a Apple. Compila en `macos-latest`, valida bundle/version/iOS 16,
  privacidad, assets y contenido, y publica solo un artifact unsigned para
  firmar/instalar con Sideloadly. Tras adaptar las APIs recientes, la ejecucion
  5 (`31347517648`) termino con exito y produjo la IPA Local QA v0.1.0 build 5,
  compatible con el dispositivo del propietario en iOS 16.7.16.
