# Zodiac Daily -- instrucciones del proyecto

## Rol del cerebro del proyecto

- Este proyecto tiene un cerebro permanente que coordina, decide, integra resultados, mantiene estado y delega trabajo pesado o separable en tareas auxiliares.
- El cerebro no debe convertirse por defecto en el unico ejecutor.
- Las tareas auxiliares deben tener limites, rutas, entregables y verificacion claros. Informan al cerebro del proyecto, no al propietario.

## Alcance permanente

- Zodiac Daily es una app separada de Tarot.
- Trabajar iOS primero y primera version en ingles.
- No iniciar Android ni idiomas adicionales hasta peticion expresa del propietario.
- No publicar, subir a TestFlight/App Store, enviar a revision, crear productos de pago, usar secretos nuevos, aceptar acuerdos, crear cuentas, asumir costes o eliminar trabajo sin autorizacion expresa del propietario en ese momento.

## Visual-first y fidelidad 1:1

- Para nuevas pantallas, redisenos, iconos, capturas y arte final, leer y aplicar `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\visual-first-app-development\SKILL.md`.
- Una imagen aprobada por el propietario es especificacion visual, no inspiracion.
- La implementacion final debe reproducir fondo, assets, layout, composicion, jerarquia, color, tipografia, espaciado, materiales, decoracion, estados y atmosfera.
- Antes de llamar final a una pantalla, se deben inventariar y crear/preparar todos los assets necesarios. No sustituir fondos, ilustraciones, iconos, tarjetas, texturas o marcos por versiones genericas o simplificadas por comodidad.
- Toda pantalla implementada desde una referencia aprobada debe compararse visualmente contra la imagen al mismo tamano/dispositivo. Las diferencias visibles se corrigen o se elevan al propietario si cambian la promesa visual.
- Una version simplificada solo puede llamarse prototipo funcional o implementacion parcial. No puede presentarse como pantalla final ni candidata visual.
- Visual-first bloquea la implementacion visual final, pero no bloquea trabajo estructural: motor, reglas, datos, contenido, arquitectura, navegacion interna, persistencia, pruebas, build/CI, privacidad, tienda, documentacion y prototipos internos no definitivos pueden avanzar.
- `Design/APPROVALS.md` es la fuente de verdad visual durable. Debe existir una
  sola maestra vigente por pantalla/estado, con ruta, dispositivo/lienzo,
  orientacion, idioma, fecha y SHA-256. Las maestras vigentes viven en
  `Design/Approved/`; las propuestas e historico se conservan separadas.
- Una sustitucion aprobada se anade como nuevo archivo y nueva maestra antes de
  marcar la anterior como reemplazada; nunca se sobrescribe ni se borra el
  historico aprobado.
- Las capturas de App Store usan las maestras solo como direccion de arte. La
  captura base final debe proceder de la build real y quedar enlazada en el
  manifiesto con version, build, commit, dispositivo, idioma, fecha y SHA-256.

## Launch iOS y builds

- Para lanzamiento iOS, IPA, TestFlight, App Store Connect, App Review, AdMob, StoreKit/IAP, supporter subscriptions, privacidad, soporte, firma, workflows, capturas, icono o checklist de publicacion, leer y aplicar `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\SKILL.md` y sus referencias relevantes.
- Para crear IPA sin Mac local, leer especialmente `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\references\github-actions-ipa.md`.
- Para problemas de GitHub, no pedir "autenticar GitHub" genericamente. Leer `C:\Users\dmkra\Documents\ChatGPT\Brain\.agents\skills\ios-app-launch\references\github-project-access.md` y diagnosticar si falla CLI auth, origin, repo, conector, Actions, secrets o workflow.
- Antes de cada build publicable, actualizar
  `docs/DATA_MINIMIZATION_AUDIT.md` contra el binario real: datos, SDKs,
  permisos, almacenamiento, transmisiones, retencion, control y destinatarios.
- No solicitar campos o permisos especulativos ni publicar nombre completo,
  domicilio, telefono, cuentas personales o repositorio. Usar el alias de
  soporte y mantener el contacto obligatorio de App Review solo en el area
  privada de Apple.
- Privacidad, soporte, App Store Privacy, metadatos y terminos deben describir
  exactamente la build, sin clausulas hipoteticas. Mantener vacios los campos
  opcionales que no cumplan una funcion real.
- No falsear la condicion DSA para reducir divulgacion. Cualquier dato de trader
  exigido para la UE se limita a la superficie de cumplimiento de Apple y su
  estado pendiente bloquea la distribucion territorial afectada.

## Sistema de apoyo voluntario

- El sistema estandar de monetizacion opcional va en Settings como `Support the app`, `Support development` o `Monthly Supporter`, no como pantalla principal obligatoria.
- Usar StoreKit/In-App Purchase de Apple para pagos dentro de iOS.
- Evitar `donation` salvo nonprofit aprobada.
- La app debe seguir siendo usable gratis; el beneficio minimo es estado activo de supporter en Settings y mensaje de agradecimiento.
- Crear productos, configurar suscripciones o enviar IAP a revision requiere autorizacion expresa del propietario.
