# Brain handoff — updated 2026-08-26

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
- Working tree: limpio tras el commit de la correccion de compilacion y la
  subida verificada de TestFlight 0.2/1.
- GitHub: repo publico `Krazel/zodiac-daily-ios`, remoto `origin` configurado y
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
  recopilados. Bundle registrado `com.krazel.zodiacdaily`, team de firma
  configurado y sin activacion externa de StoreKit.
- QA auxiliar de las pantallas C2: sin P0/P1 tras corregir el simbolo del signo
  en Saved vacio y el retorno tras eliminar desde el antiguo wrapper de detalle.
  XML, JSON, UTF-8, PBX y privacidad validados en Windows.
- Las referencias visuales restantes anteriores ya estan aprobadas. Capturas de
  tienda y cualquier arte promocional nuevo conservan su propia puerta visual.
- Bloqueos tecnicos/externos restantes: Mac/Xcode o un dispositivo para
  simulador, comparacion visual, Dynamic Type, VoiceOver y StoreKitTest; DSA de
  la UE; productos StoreKit; capturas y puertas de publicacion.
- Nucleo implementado como Swift Package: 12 signos, dia local, catalogo ingles
  bundled, generacion FNV-1a determinista, snapshots guardados, stores en
  memoria y JSON file-backed y XCTest. Compilacion Release, XCTest, analisis,
  archivo firmado y exportacion pasan en macOS/Xcode; simulador y QA visual
  fisica siguen pendientes.

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
  eliminado y no existe ningun secreto en texto plano en Git. Las credenciales
  de produccion necesarias viven cifradas en Cloudflare o en el environment
  protegido de GitHub.

## Lanzamiento y apoyo voluntario

- Aplicada la skill `ios-app-launch` a la planificacion. Ficha local:
  `docs/LAUNCH_READINESS.md`.
- App Store Connect creada el 2026-08-11: **The Daily Zodiac**, app ID
  `6800136195`, bundle ID `com.krazel.zodiacdaily`, ingles (EE. UU.), SKU
  `zodiac-daily-ios`, version `0.1.1` / build `1`, sin login y con publicacion
  manual. Se subio unicamente la build interna TestFlight `0.1.1` (`1`); no se
  crearon productos ni se envio App Review.
- Ficha completada y guardada: subtitulo `Daily Horoscope & Zodiac`, categoria
  primaria Lifestyle, secundaria Magazines & Newspapers, precio gratis en los
  175 territorios, distribucion publica y disponibilidad Mac/Vision Pro
  desactivada. Estan guardados descripcion, keywords, copyright y notas de
  revision exactas; promotional text, marketing URL, privacy choices y adjunto
  opcional estan vacios.
- Derechos de contenido declarados. Clasificacion completada como 9+ global
  (12+ Vietnam/Brasil), declarando unicamente temas de bienestar. App Privacy
  esta guardado como `No data collected` y la URL publica ya esta cargada, pero
  la respuesta no se publico por falta de autorizacion expresa de publicacion.
- El proyecto declara `ITSAppUsesNonExemptEncryption = NO`: usa HTTPS estandar
  de Apple y no implementa cifrado propietario/no exento.
- URLs compartidas publicadas y verificadas con HTTP 200:
  `https://krazel.github.io/zodiac-daily/privacy/` y
  `https://krazel.github.io/zodiac-daily/support/`.
- Publicacion GitHub Pages minimizada en el commit `450aadf`. Las URLs de
  privacidad y soporte estan cargadas en App Store Connect; marketing URL y
  privacy choices quedan vacias. Falta autorizacion expresa para publicar la
  respuesta de privacidad.
- El contacto obligatorio de App Review esta completo solo en la seccion
  privada de Apple; sus valores no se replican en paginas ni repositorio.
  Tampoco se ha subido build, enviado review, creado IAP, aceptado acuerdos ni
  publicado la app.
- Auditoria de minimizacion `docs/DATA_MINIMIZATION_AUDIT.md`: build 0.1.1/1
  sin permisos, cuenta, anuncios, analytics ni SDKs terceros; signo/cartas/
  ajustes locales; unica peticion de contenido con fecha; StoreKit presente sin
  productos activos. App Store Privacy `No data collected` sigue siendo exacto.
- Cumplimiento DSA de la UE esta enviado a Apple y figura `En revision`. No se
  cambia la condicion para eludir divulgacion; si Apple exige datos de trader,
  quedan limitados a su superficie legal y no se duplican publicamente.
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
- Registro visual durable creado en `Design/APPROVALS.md`. Las ocho maestras
  vigentes completas viven en `Design/Approved/` con pantalla/estado,
  dispositivo/lienzo, orientacion, idioma, fecha y SHA-256. Propuestas e
  historico permanecen en `Design/Concepts/`; `today-card-back-c1.png` y
  `settings-c2.png` estan marcadas como reemplazadas sin borrarse. Las capturas
  de tienda deberan salir de una build real y enlazarse al manifiesto.
- Flujo Local QA IPA operativo en
  `.github/workflows/build-ios-local-qa.yml`: manual, owner-only, sin secretos y
  sin upload a Apple. Compila en `macos-latest`, valida bundle/version/iOS 16,
  privacidad, assets y contenido, y publica solo un artifact unsigned para
  firmar/instalar con Sideloadly. Tras adaptar las APIs recientes, la ejecucion
  5 (`31347517648`) termino con exito y produjo la IPA Local QA v0.1.0 build 5,
  compatible con el dispositivo del propietario en iOS 16.7.16.

## TestFlight interno

- El propietario autorizo expresamente firma, secretos y subida a TestFlight
  interno. No autorizo App Review ni publicacion.
- The Daily Zodiac `0.1.1` build `1` se compilo, probo, analizo, firmo y subio
  en el run `31488398661` desde el commit `0d648d3`.
- Apple marca la build `VALID`, iOS 16.0 minimo,
  `usesNonExemptEncryption=false` y audiencia `INTERNAL_ONLY`.
- El grupo interno `Testers` tiene acceso automatico a todas las builds y un
  tester. No se registran aqui identidad ni correo del tester.
- No se creo grupo externo, enlace publico, Beta App Review, App Review,
  producto StoreKit ni publicacion.
- Evidencia completa no secreta: `docs/TESTFLIGHT_STATUS.md`.

## Reanudacion 2026-08-11 — Settings e interfaz EN/ES

- Settings deja de estar oculto tras una accion secundaria: Today incorpora un
  boton de engranaje visible y mantiene el toque directo del selector de signo.
- Se implemento `AppLanguage` EN/ES persistido, deteccion inicial de dispositivos
  espanoles, cambio inmediato de locale, nombres de signos y fechas localizados,
  y un catalogo con 153 claves completas en ambos idiomas.
- Settings incorpora Language, Your Sign, Support the app, Restore/Manage,
  Rate, Help & Support, Privacy, Terms y About. Los mensajes StoreKit son estados
  semanticos y se vuelven a renderizar en el idioma activo.
- FreeAstroAPI Daily Sign no ofrece espanol a 2026-08-11. La interfaz puede ser
  espanola, pero la edicion diaria del proveedor sigue en ingles y Settings lo
  indica expresamente; no se inventa ni se etiqueta falsamente contenido.
- Propuestas completas guardadas en `Design/Concepts/settings-language-support-c4.png`
  y `Design/Concepts/today-settings-entry-c4.png`; siguen como propuestas hasta
  obtener captura real y comparacion de la build.
- No se crearon productos StoreKit, no se subio una build nueva y no se envio
  TestFlight/App Review durante este hito.

## Reanudacion 2026-08-11 — Edicion diaria real EN/ES

- Estado activo: contrato schema 3 con `language`,
  endpoint `?lang=en|es`, cache KV separada por idioma y cabecera
  `Content-Language`.
- El Queue consumer obtiene una sola edicion inglesa de 12 signos y crea una
  edicion castellana una vez con Workers AI `m2m100`. El trafico de usuarios
  solo lee cache y nunca llama al proveedor ni al traductor.
- Fallo ES: remoto ES → remoto EN de la misma fecha → bundled EN. Nunca se
  etiqueta ingles como castellano. Un fallo de traduccion conserva EN y el
  retry no repite las 12 llamadas FreeAstro.
- `DailyHoroscope`, pin diario y guardados incluyen idioma; archivos legacy
  migran a EN. EN/ES del mismo signo/dia no colisionan, se ordenan de forma
  estable y la UI muestra el codigo real de idioma.
- Worker: 23/23 pruebas offline. Estimacion normal 93–155 neuronas por nueva
  edicion, con maximo contractual conservador de 815 frente a 10.000 gratis;
  12 llamadas proveedor por nueva fecha frente a 80/dia.
- La app envia solo fecha + `en`/`es`; no envia signo seleccionado, cuenta,
  nacimiento, guardados ni identificadores. Workers AI recibe solo texto del
  proveedor.
- Preview real no productiva superada: respuesta castellana con acentos, HTTP
  200, 15 tokens de entrada + 17 de salida y 0,9936 neuronas. El preview se
  detuvo y no cambio recursos productivos.
- El propietario autorizo el despliegue. Produccion usa schema 3 bilingue; no
  se publico la app ni se crearon productos StoreKit.
- La version visible `0.2`, build `1`, se compilo, probo, analizo, firmo y
  subio a TestFlight interno.
- App Store Connect muestra la build `En pruebas`, asignada al grupo interno
  `Testers` y con caducidad de 90 dias. No se creo testing externo, enlace
  publico, Beta App Review, App Review, IAP ni publicacion.

## Correccion 2026-08-26 — IPA desconectada

- El propietario informo que Scorpio mostraba solo la esencia inglesa
  `Intense · Perceptive · Transformative` y el reverso de emergencia.
- La inspeccion del IPA exacto 0.2.2/1 confirmo la causa:
  el `Info.plist` generado por Xcode omitio `ZodiacDailyAPIBaseURL` y
  `ZodiacDailyAppStoreID`. La app nunca contacto al Worker y uso el catalogo
  ingles incorporado sin datos de proveedor. El Worker schema 3 EN/ES estaba
  sano y devolvia Scorpio completo.
- La correccion 0.2.3/1 usa un `Info.plist` explicito, compila la URL publica y
  el App Store ID como valores seguros, usa solo el repositorio remoto para
  Today, exige coincidencia exacta de idioma y muestra Retry en vez de presentar
  una carta de emergencia como lectura real.
- Los workflows Local QA y TestFlight ahora inspeccionan ambas claves dentro
  del app bundle y la URL de respaldo dentro del ejecutable. Una IPA
  desconectada debe fallar antes del empaquetado o subida.
- La build TestFlight 0.2.2/1 queda marcada como defectuosa y no valida el
  producto. 0.2.3/1 paso Local QA: 65 pruebas Core, build Release, inspeccion
  de valores empaquetados y creacion de IPA sin firma de distribucion. El
  propietario autorizo el upload interno; pruebas, analisis Release, firma,
  inspeccion, export, verificacion y subida Apple fueron correctas.
- La inspeccion App Store Connect confirma 0.2.3/1
  `VALID`, iOS 16.0, `INTERNAL_ONLY`, no caducada, sin cifrado no exento y con
  acceso automatico para el grupo interno. No se creo
  testing externo, enlace publico, App Review ni publicacion.

## Ajustes posteriores solicitados — rendimiento, signo y legibilidad

- El lag de primera apertura de Settings se rastreo a mas de 50 resoluciones de
  localizacion que buscaban y reconstruian el bundle de idioma durante la
  animacion. Commit `9bd4d33` cachea los bundles EN/ES y cambia solo el
  contenedor exterior de Settings a carga diferida; StoreKit no se recarga al
  abrir la pantalla y no se modifico.
- Desde Today o Settings, tocar un signo ahora lo aplica y cierra el selector
  en el mismo gesto. El primer inicio conserva seleccion pendiente + Continue
  porque esa es la maestra aprobada.
- Run visual QA `32917443740`: 65 pruebas, compilacion iOS, capturas de todos
  los estados y validacion estacionaria de iPhone SE correctas. No genero IPA
  ni hizo upload a Apple.
- El texto live llegaba a 9,25–10,5 pt por la heuristica de copy largo dentro de
  la carta fija. Se prepararon dos propuestas completas sin aprobar:
  `Design/Concepts/today-readable-frame-c5a.png` (doble linea limpia, recomendada)
  y `Design/Concepts/today-readable-frame-c5b.png` (esquinas luna grabadas).
  Ambas aumentan el cuerpo a un objetivo visual de 17–18 pt y recuperan espacio
  eliminando el aro gris pesado. La UI final de carta queda bloqueada hasta que
  el propietario elija A o B; C4 sigue siendo la maestra vigente.

## Cierre visual C5B — marco, lectura larga y detalle guardado

- El propietario eligio B para el borde. La implementacion compartida aplica
  una linea exterior dorada fina, filete interior, geometria mas cuadrada y
  motivos grabados de luna/estrella en las cuatro esquinas. Frente, reverso y
  detalle guardado usan el mismo componente fisico; no se modificaron las
  miniaturas independientes de la coleccion Saved.
- La lectura normal deja de caer a los 9,25–10,5 pt historicos y prueba primero
  candidatos medidos de 18/17 pt, reduciendo arte antes que tipografia. El
  fallback extremo conserva el texto completo para payloads excepcionalmente
  largos.
- Run `32961689190` paso pruebas/build y descubrio visualmente un defecto que el
  chequeo tecnico no detectaba: la lectura larga en iPhone SE desplazaba la
  cabecera. Se corrigio el anclaje superior del layout estacionario en el
  commit `95d28aa` y se repitio la validacion completa en la rama temporal
  `visual-qa/c5b-se-fix`.
- Run final `32963500029`: 65 pruebas Core, build iOS, frente, reverso, texto
  largo, Saved detail y todos los estados aprobados capturados; iPhone 15 Pro e
  iPhone SE correctos. En el SE se ven a la vez cabecera, selector, carta larga
  completa, Guardar y tabs sin scroll regular. La evidencia visual canonica se
  conserva en `Design/Comparisons/`.
- Las nuevas maestras runtime y sus SHA-256 estan registradas en
  `Design/APPROVALS.md`; la hoja normalizada propuesta/build/overlay y las
  capturas compactas quedan en `Design/Comparisons/`. La propuesta C5B y las
  maestras anteriores se conservan como historial reemplazado.
- No se genero IPA, no se subio TestFlight y no se realizo ninguna accion en
  App Store Connect durante este cierre visual.

## TestFlight interno 0.3/1 — entrega C5B

- El propietario autorizo expresamente GitHub, firma y subida a TestFlight
  interno el 2026-08-27. No autorizo testing externo, App Review ni publicacion.
- Se aplico la regla de versionado: el nuevo marco completo, la lectura mayor y
  el flujo de signo inmediato constituyen una entrega funcional/visual y pasan
  de `0.2.3` a `0.3`; build `1` por ser el primer binario de esa version.
- La build paso 65 pruebas, analisis Release, firma, inspeccion de
  plist/endpoint/privacidad/assets, export, verificacion Apple y upload.
- App Store Connect confirma `0.3 (1)`
  `VALID`, iOS 16.0, `INTERNAL_ONLY`, no caducada, sin cifrado no exento y con
  acceso automatico para el grupo interno.
- La auditoria 0.3 sigue exacta: sin permisos, cuenta, anuncios, analytics ni
  SDKs terceros; signo/cartas/idioma locales; unica peticion de contenido con
  fecha e idioma; StoreKit presente sin productos activos. No se creo IAP, no
  se envio App Review y no se publico la app.

## Correccion editorial castellana desplegada

- El 2026-08-27 el propietario rechazo la calidad de la traduccion literal.
  La causa confirmada era `m2m100`: traducía titular, lectura y metadatos por
  separado, sin contexto editorial.
- La plantilla editorial actual de FreeAstro se renderiza directamente en
  castellano natural. Signo, planeta, casa, elemento, prioridad, consejo,
  ambito, fase, color, titular y palabras clave tienen conversion determinista:
  el camino diario normal no usa IA y no puede inventar ni omitir esos datos.
  Si el proveedor cambia a una plantilla desconocida, `@cf/openai/gpt-oss-20b`
  queda como respaldo y `@cf/meta/llama-3.1-8b-instruct-fast` revisa fidelidad.
- La revision de cache `es-r8` evita reutilizar las traducciones defectuosas sin
  gastar nuevas llamadas a FreeAstroAPI. La suite del Worker pasa 29/29 y el
  2026-08-31 se valido en preview remoto un Scorpio completo con ambos modelos.
- Se pulio tambien la copia fija española para eliminar literalismos y jerga de
  proveedor. La edicion real `2026-08-31` quedo validada 12/12, cero ingles residual, cero patrones
  de concordancia defectuosa y todos los datos diarios presentes.

## TestFlight interno 0.4/1 — entrega C6

- Autorizacion expresa del propietario para build, firma, GitHub y subida
  interna. No se autorizo testing externo, App Review ni publicacion.
- El build/upload paso pruebas Core, analisis Release, firma, inspeccion,
  export, verificacion Apple y subida interna.
- El primer inspector seguia fijado por error a 0.3 y fue corregido antes del
  cierre. La inspeccion final confirma exactamente `0.4 (1)`, `VALID`,
  iOS 16.0, `INTERNAL_ONLY`, no caducada y acceso automatico para `Testers`
  sin publicar informacion sobre las personas del grupo.

## TestFlight interno 0.4.1/1 — tipografia legible C7

- El propietario autorizo expresamente la build, firma y subida interna. No se
  autorizo testing externo, App Review ni publicacion.
- La implementacion elimina Didot de la interfaz y de los datos cambiantes. La
  serif nativa robusta queda reservada para grandes titulares editoriales;
  reverso, puntuaciones, suerte, Settings, selector, Saved, controles y
  navegacion usan sans-serif nativa legible, con digitos tabulares semibold.
- Run visual `33348593592` paso pruebas, compilacion, todos los estados EN/ES y
  layouts estacionarios en iPhone 15 Pro e iPhone SE. Las maestras, capturas y
  hashes quedan registrados en `Design/APPROVALS.md`.
- Run de build/upload `33399388605` paso pruebas, analisis Release, firma,
  inspeccion, export, verificacion Apple y subida. Commit exacto `a84cab4`.
- Run inspector `33399906575` confirma `0.4.1 (1)`, `VALID`, iOS 16.0,
  `INTERNAL_ONLY`, no caducada, sin cifrado no exento y con acceso automatico
  para el grupo interno.
- IPA `ZodiacDaily-v0.4.1-build-1-a84cab4-TestFlight.ipa`, SHA-256
  `0d7b9acb53b8499b4c0560c75ee374e5c97bd6cc9cc9819799d40b01fe72acaf`.

## Candidato publico 1.0/1 — preparado, no enviado a revision

- El propietario autorizo build, firma, subida a App Store Connect y preparacion
  completa de la ficha, pero indico expresamente no enviar a App Review.
- Commit exacto `fa03ff09e4f383fe454c782e7eb0ec373511d4cb`. Run
  `33440183125`: 65 pruebas, analisis Release, firma, inspeccion, export,
  validacion Apple y upload correctos.
- App Store Connect confirma `1.0 (1)`, `VALID`, iOS 16.0,
  `APP_STORE_ELIGIBLE`, no caducada y sin cifrado no exento. Inspector run
  `33441385942`.
- IPA `ZodiacDaily-v1.0-build-1-fa03ff0-AppStore.ipa`, SHA-256
  `2316febd7191b1a75557c6ace5ae6d704bf6e0157794374a51d93ff6d02e5525`.
- Run de capturas `33440182881`: seis EN y seis ES reales, iPhone 14 Plus,
  1284 x 2778. Los archivos, hashes y procedencia quedan en
  `AppStore/StoreReady/` y `Design/APPROVALS.md`.
- La 1.0 oculta por completo el apoyo StoreKit no configurado. No hay IAP,
  suscripcion, anuncios, analytics, cuenta, permisos ni tracking. La ficha
  canonica bilingue esta en `AppStore/METADATA.md`.
- Ficha ensamblada: localizacion EN/ES, subtitulo ES, version 1.0, build 1,
  notas exactas, seis capturas por idioma y privacidad `No data collected`
  publicada. Run `33443511143` confirma las 12 capturas `COMPLETE` y la UI de
  Apple muestra `6 de 10` en ambos idiomas.
- La app queda lista para `Añadir a revisión`, pero ese boton no se toco por la
  instruccion expresa del propietario. Publicacion manual sigue seleccionada y
  la pagina `Revisión de apps` permanece vacia.
