// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'un quiz bíblico';

  @override
  String inviteJoin(String title, String brand) {
    return '¿Te unes a $title en $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'O introduce el código: $code';
  }

  @override
  String get errGenericTitle => 'Algo salió mal';

  @override
  String get errGenericMessage =>
      'No pudimos completarlo. Inténtalo de nuevo en un momento.';

  @override
  String get errNetworkTitle => 'Sin conexión';

  @override
  String get errNetworkMessage =>
      'Comprueba tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errSignedOutTitle => 'Vuelve a iniciar sesión';

  @override
  String get errSignedOutMessage =>
      'Tu sesión ha caducado. Inicia sesión de nuevo para seguir jugando.';

  @override
  String get errRoomNotFoundTitle => 'Sala no encontrada';

  @override
  String get errRoomNotFoundMessage =>
      'Esta sala ya no existe o está cerrada. Revisa el código o crea una sala nueva.';

  @override
  String get errRoomFullTitle => 'La sala está llena';

  @override
  String get errRoomFullMessage =>
      'No caben más jugadores en esta sala. Pide al anfitrión que abra una sala nueva.';

  @override
  String get errRoomStartedTitle => 'La partida ya empezó';

  @override
  String get errRoomStartedMessage =>
      'Este quiz ya está en marcha. Espera a que termine la ronda o crea una sala nueva.';

  @override
  String get errRoomFinishedTitle => 'La partida terminó';

  @override
  String get errRoomFinishedMessage =>
      'Esta sala está cerrada. Crea una sala nueva para seguir jugando.';

  @override
  String get errRoomCodeTitle => 'Código de sala no válido';

  @override
  String get errRoomCodeMessage =>
      'Este código no es correcto. Un código de sala tiene 6 caracteres.';

  @override
  String get errAlreadyInRoomTitle => 'Ya estás en esta sala';

  @override
  String get errAlreadyInRoomMessage => 'Vuelve a la sala para seguir jugando.';

  @override
  String get errPremiumTitle => 'Se requiere Premium';

  @override
  String get errPremiumMessage =>
      'Crear tu propia sala es parte de Bible Quizzes Premium. Unirte siempre es gratis.';

  @override
  String get errForbiddenTitle => 'Sin acceso';

  @override
  String get errForbiddenMessage => 'Solo el anfitrión puede hacer esto.';

  @override
  String get errRateLimitedTitle => 'Un momento';

  @override
  String get errRateLimitedMessage =>
      'Lo intentaste demasiadas veces seguidas. Espera un momento e inténtalo de nuevo.';

  @override
  String get errNotFoundTitle => 'No encontrado';

  @override
  String get errNotFoundMessage =>
      'No pudimos encontrarlo. Vuelve atrás e inténtalo de nuevo.';

  @override
  String get errConflictTitle => 'Ahora no es posible';

  @override
  String get errConflictMessage =>
      'Esta acción no encaja con el estado actual de la partida. Actualiza e inténtalo de nuevo.';

  @override
  String get errServerTitle => 'El servidor no responde';

  @override
  String get errServerMessage =>
      'Algo salió mal por nuestra parte. Inténtalo de nuevo en unos segundos.';

  @override
  String get errLiveLostTitle => 'Se perdió la conexión en vivo';

  @override
  String get errLiveLostMessage =>
      'Se cayó la conexión en vivo. Estamos recuperando el estado automáticamente.';

  @override
  String get errLoginTitle => 'Error al iniciar sesión';

  @override
  String get errLoginBadCredentials =>
      'Este correo o contraseña no es correcto.';

  @override
  String get errAccountExistsTitle => 'La cuenta ya existe';

  @override
  String get errAccountExistsMessage =>
      'Ya existe una cuenta con este correo. Inicia sesión.';

  @override
  String get errRegisterTitle => 'Error al registrarse';

  @override
  String get errRegisterMessage =>
      'No pudimos crear tu cuenta. Inténtalo de nuevo.';

  @override
  String get errLoginMessage =>
      'No pudimos iniciar tu sesión. Inténtalo de nuevo.';

  @override
  String get errLeaderboardTitle => 'No se cargó la clasificación';

  @override
  String get errLeaderboardMessage =>
      'No pudimos cargar la clasificación. Inténtalo de nuevo.';

  @override
  String get errQuizzesTitle => 'No se cargaron los quizzes';

  @override
  String get errQuizzesMessage =>
      'No pudimos cargar los quizzes. Inténtalo de nuevo.';

  @override
  String get errProfileTitle => 'No se cargó el perfil';

  @override
  String get errProfileMessage =>
      'No pudimos cargar tu perfil. Inténtalo de nuevo.';

  @override
  String get errPurchaseTitle => 'Error en la compra';

  @override
  String get errPurchaseMessage =>
      'La compra no se completó. No se te ha cobrado nada.';

  @override
  String get streakReminderTitle => 'Tu racha está en juego';

  @override
  String get streakReminderChannel => 'Recordatorio de racha';

  @override
  String get streakReminderChannelDescription =>
      'Un recordatorio la noche en que tu racha está por acabarse.';

  @override
  String streakReminderBody(Object streak) {
    return 'Tu racha de $streak días termina esta noche. Un quiz basta para mantenerla.';
  }

  @override
  String get navQuizzes => 'Quizzes';

  @override
  String get navTogether => 'Juntos';

  @override
  String get navLeaderboard => 'Clasificación';

  @override
  String get navProfile => 'Perfil';

  @override
  String get savedQuizFallback => 'tu quiz';

  @override
  String savedScoreOne(Object title, Object xpEarned) {
    return 'Tu puntuación de \"$title\" se ha guardado (+$xpEarned XP).';
  }

  @override
  String savedScoreMany(Object saved, Object xpEarned) {
    return '$saved quizzes guardados (+$xpEarned XP).';
  }

  @override
  String get progressSaved => 'Progreso guardado';

  @override
  String get navHome => 'Inicio';

  @override
  String get avatarLamb => 'Cordero';

  @override
  String get avatarLion => 'León';

  @override
  String get avatarDove => 'Paloma';

  @override
  String get avatarOwl => 'Búho';

  @override
  String get avatarDeer => 'Ciervo';

  @override
  String get avatarOx => 'Buey';

  @override
  String get avatarSand => 'Arena';

  @override
  String get avatarLapis => 'Lapislázuli';

  @override
  String get avatarClay => 'Arcilla';

  @override
  String get avatarOlive => 'Oliva';

  @override
  String get avatarRose => 'Rosa';

  @override
  String get avatarSlate => 'Pizarra';

  @override
  String get avatarParchment => 'Pergamino';

  @override
  String get avatarSky => 'Cielo';

  @override
  String get avatarSage => 'Salvia';

  @override
  String get avatarSunrise => 'Amanecer';

  @override
  String get avatarNight => 'Noche';

  @override
  String get avatarBlush => 'Rubor';

  @override
  String get avatarNone => 'Ninguno';

  @override
  String get avatarGlasses => 'Gafas';

  @override
  String get avatarCap => 'Gorra';

  @override
  String get avatarScarf => 'Bufanda';

  @override
  String get avatarCrown => 'Corona';

  @override
  String avatarWith(Object character, Object accessory) {
    return '$character con $accessory';
  }

  @override
  String get wordmarkFirst => 'Bible';

  @override
  String get wordmarkSecond => 'Quizzes';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionBack => 'Atrás';

  @override
  String questionsCount(Object questionCount) {
    return '$questionCount preguntas';
  }

  @override
  String get actionStart => 'Empezar';

  @override
  String get authGoogleAndroidInterrupted =>
      'El inicio de sesión con Google se interrumpió en Android. Revisa el SHA-1/SHA-256 de la clave de publicación en el cliente OAuth de Google Cloud.';

  @override
  String get authGoogleNoToken =>
      'Google no devolvió un token de inicio de sesión. Inténtalo de nuevo o elige otra cuenta.';

  @override
  String get authAppleUnavailable =>
      'Iniciar sesión con Apple no está disponible en este dispositivo.';

  @override
  String get authAppleError1000 =>
      'No se pudo iniciar sesión con Apple (error 1000). Asegúrate de tener un Apple ID en este dispositivo e inténtalo de nuevo.';

  @override
  String get authAppleWebNotConfigured =>
      'Iniciar sesión con Apple aún no está configurado en esta plataforma.';

  @override
  String get authWelcomeBack => 'Bienvenido de nuevo';

  @override
  String get authLoginSubtitle =>
      'Inicia sesión para guardar tu progreso y aparecer en la clasificación.';

  @override
  String get authEmailHint => 'nombre@ejemplo.com';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authPasswordHint => 'Tu contraseña';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authNoAccount => '¿Aún no tienes cuenta?';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authCreateAccount => 'Crear cuenta';

  @override
  String get authCreateSubtitle => 'Gratis, y tu progreso queda guardado.';

  @override
  String get authName => 'Nombre';

  @override
  String get authNameHelp =>
      'Así te verán los demás en la clasificación y cuando juguéis juntos.';

  @override
  String get authTermsPrefixRegister => 'Al crear una cuenta aceptas los ';

  @override
  String get authHaveAccount => '¿Ya tienes cuenta?';

  @override
  String get splashTagline => '¿Cuánto conoces la Biblia?';

  @override
  String get authOrEmail => 'o con correo';

  @override
  String get authTermsPrefix => 'Al continuar aceptas los ';

  @override
  String get errLinkTitle => 'No se abrió el enlace';

  @override
  String get errLinkMessage =>
      'No pudimos abrir esta página. Inténtalo de nuevo.';

  @override
  String get authTermsAnd => ' y la ';

  @override
  String get authShowPassword => 'Mostrar contraseña';

  @override
  String get authHidePassword => 'Ocultar contraseña';

  @override
  String get authContinueGoogle => 'Continuar con Google';

  @override
  String get authContinueApple => 'Continuar con Apple';

  @override
  String get dataInfoTitle => 'Cómo tratamos tus datos';

  @override
  String get dataInfoBody =>
      'Al iniciar sesión o registrarte solo usamos los datos necesarios para que tu cuenta funcione, como tu nombre, correo y datos de acceso.\n\nTus datos se envían por conexiones seguras y no los compartimos con fines publicitarios sin tu permiso.\n\nSiempre puedes pedir que se elimine tu cuenta. Escríbenos a info@biblequizzes.app o usa los canales de soporte de la app. Tras la eliminación, los datos de tu cuenta se borran según nuestra política de privacidad.';

  @override
  String get dataInfoMore => 'Más sobre el uso de datos';

  @override
  String get homeContinue => 'Seguir jugando';

  @override
  String get homeAll => 'Todo';

  @override
  String get homePickTopic => 'Elige un tema';

  @override
  String get homePopular => 'Quizzes populares';

  @override
  String get streakOneDay => 'Racha de 1 día';

  @override
  String streakDays(Object streak) {
    return 'Racha de $streak días';
  }

  @override
  String questionsCountShort(Object count) {
    return '$count preguntas';
  }

  @override
  String quizOfTheDayLabel(Object title) {
    return 'Quiz del día: $title';
  }

  @override
  String get quizOfTheDayKicker => 'QUIZ DEL DÍA';

  @override
  String get actionUnlock => 'Desbloquear';

  @override
  String get actionPlayNow => 'Jugar ahora';

  @override
  String get homeChallengeLoading =>
      'Aparecerá un nuevo reto cuando se carguen los quizzes.';

  @override
  String get homeLoadFailed => 'No se pudo cargar el inicio';

  @override
  String get checkConnectionRetry =>
      'Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get actionRetry => 'Reintentar';

  @override
  String get homeGuestTitle => 'Juega gratis, sin cuenta';

  @override
  String get homeGuestBody =>
      'Crea una para guardar tu puntuación, puntos y racha.';

  @override
  String get homeGuestAction => 'Guardar progreso';

  @override
  String chapterN(Object chapter) {
    return 'Capítulo $chapter';
  }

  @override
  String scoreCorrect(Object scoreText) {
    return '$scoreText correctas';
  }

  @override
  String get played => 'Jugado';

  @override
  String scoreA11y(Object title, Object score, Object total) {
    return '$title, $score de $total correctas';
  }

  @override
  String get books39 => '39 libros';

  @override
  String get books27 => '27 libros';

  @override
  String get catGeneral => 'General';

  @override
  String get catWholeBible => 'Toda la Biblia';

  @override
  String get catByTheme => 'Por tema';

  @override
  String questionsCountQuiz(Object questionCount) {
    return '$questionCount preguntas';
  }

  @override
  String get groupsLoadFailed => 'No se pudieron cargar tus grupos.';

  @override
  String get groupSaveFailed => 'No se pudo guardar el grupo.';

  @override
  String get groupSaveFailedTitle => 'Error al guardar el grupo';

  @override
  String get groupSaveNoGroup =>
      'El servidor no devolvió ningún grupo. Inténtalo de nuevo.';

  @override
  String get groupRenameFailed => 'No se pudo cambiar el nombre.';

  @override
  String get deleteFailed => 'No se pudo eliminar.';

  @override
  String get groupStandingsFailed =>
      'No se pudo cargar la clasificación de este grupo.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupSingular => 'Grupo';

  @override
  String get leaderboardLoadFailed => 'No se pudo cargar la clasificación';

  @override
  String get leaderboardMonthHint => 'XP de los últimos 30 días';

  @override
  String get leaderboardAllTimeHint => 'Cuenta toda la XP desde el inicio';

  @override
  String get periodMonth => 'Este mes';

  @override
  String get periodAllTime => 'Siempre';

  @override
  String get periodLabel => 'Periodo';

  @override
  String get everyone => 'Todos';

  @override
  String leaderboardGap(Object gap, Object rank) {
    return '$gap XP para el puesto $rank';
  }

  @override
  String get showLess => 'Mostrar menos';

  @override
  String showAllPlayers(Object total) {
    return 'Mostrar los $total jugadores';
  }

  @override
  String get leaderboardGuestHint => 'Con una cuenta gratis tu XP cuenta.';

  @override
  String get leaderboardNotOnIt => 'Aún no estás en esta clasificación';

  @override
  String get leaderboardPlayToJoin => 'Juega un quiz para participar.';

  @override
  String get leaderboardNoData => 'Aún no hay datos de clasificación.';

  @override
  String get leaderboardEmpty => 'Aún no hay nadie en la clasificación';

  @override
  String get onboardingTagline =>
      'Quizzes cortos sobre los libros de la Biblia, solo o con otros.';

  @override
  String get onboardingGuest => 'Jugar primero sin cuenta';

  @override
  String get onboardingPreviewA11y =>
      'Ejemplo: una pregunta con la respuesta correcta, un duelo contra Sara, XP y una racha';

  @override
  String get onboardingSampleQuestion => '¿Cuántos panes tenía el muchacho?';

  @override
  String get onboardingSampleStreak => '6 días seguidos';

  @override
  String get seasonEndsToday => 'Termina hoy';

  @override
  String get seasonOneDayLeft => 'Queda 1 día';

  @override
  String seasonDaysLeft(Object daysRemaining) {
    return 'Quedan $daysRemaining días';
  }

  @override
  String get season => 'Temporada';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get viaWebsite => 'Desde el sitio web';

  @override
  String get lifetime => 'De por vida';

  @override
  String get active => 'Activo';

  @override
  String get deleteSignInFirst =>
      'Primero inicia sesión con la cuenta que quieres eliminar.';

  @override
  String get deleteAccountQuestion => '¿Eliminar cuenta?';

  @override
  String get deleteAccountBody =>
      'Tu cuenta, tu progreso, tu XP y tus duelos se eliminarán para siempre. No se puede deshacer.\n\nUna suscripción de App Store o Google Play no se cancela por esto: cancélala primero en las suscripciones de tu teléfono.';

  @override
  String get deletePermanently => 'Eliminar definitivamente';

  @override
  String deleteAccountFailed(Object accountEmail) {
    return 'No se pudo eliminar. Inténtalo de nuevo o escribe a $accountEmail.';
  }

  @override
  String get accountNotDeleted => 'Cuenta no eliminada';

  @override
  String get accountDeleted => 'Tu cuenta se ha eliminado.';

  @override
  String get notificationsOff =>
      'Las notificaciones están desactivadas para Bible Quizzes. Actívalas en los ajustes de tu teléfono.';

  @override
  String get purchasesRestored => 'Compras restauradas';

  @override
  String get settingsReminder => 'Recordatorio';

  @override
  String get settingsTime => 'Hora';

  @override
  String get settingsPlaying => 'Juego';

  @override
  String get settingsReadChapterFirst => 'Leer primero el capítulo';

  @override
  String get settingsShowReference => 'Referencia bíblica en la explicación';

  @override
  String get settingsLargeText => 'Texto de pregunta grande';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get settingsManage => 'Gestionar';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get guestPlaying => 'Estás jugando sin cuenta';

  @override
  String get signInOrCreate => 'Inicia sesión o crea una cuenta';

  @override
  String get yourAccount => 'Tu cuenta';

  @override
  String get signedIn => 'Sesión iniciada';

  @override
  String signedInAs(Object email) {
    return 'Sesión iniciada como $email';
  }

  @override
  String secondsN(Object choice) {
    return '$choice segundos';
  }
}
