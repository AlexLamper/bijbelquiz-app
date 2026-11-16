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

  @override
  String get joinFailed => 'No se pudo unir.';

  @override
  String get joinFailedConnection => 'No se pudo unir. Comprueba tu conexión.';

  @override
  String get trialEndingTitle => 'Tu prueba está por terminar';

  @override
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd) {
    return 'Tu Bible Quizzes Premium empieza en $kTrialReminderDaysBeforeEnd días. ¿No quieres seguir? Cancela en los ajustes de la tienda.';
  }

  @override
  String get trialReminderChannel => 'Recordatorio de prueba';

  @override
  String get trialReminderChannelDescription =>
      'Un recordatorio antes de que termine tu prueba gratis.';

  @override
  String get supportEmail => 'info@biblequizzes.app';

  @override
  String get groupCodeIncomplete => 'Introduce el código de grupo completo.';

  @override
  String groupJoined(Object name) {
    return 'Ahora formas parte de $name.';
  }

  @override
  String get groupLicenseGoToSite =>
      'Ve a biblequizzes.app/group-license en tu navegador.';

  @override
  String get groupLicense => 'Licencia de grupo';

  @override
  String mailUsAt(Object supportEmail) {
    return 'Escríbenos a $supportEmail.';
  }

  @override
  String get groupCodeIntro =>
      '¿Tu líder de jóvenes, pastor o profesor tiene un código de grupo? Introdúcelo abajo y tendrás Premium al instante.';

  @override
  String get premiumViaGroup => 'Premium a través de tu grupo';

  @override
  String get yourGroups => 'Tus grupos';

  @override
  String get premiumWholeGroup => 'Premium para todo tu grupo';

  @override
  String get forChurches => 'Para iglesias, escuelas y asociaciones';

  @override
  String get groupPerkAll => 'Todo Premium para cada miembro';

  @override
  String get groupPerkCode => 'Un código que lees en voz alta en la sala';

  @override
  String get groupPerkManage => 'Tú decides quién participa';

  @override
  String get groupLicenseWebsiteOnly =>
      'La licencia de grupo se compra en el sitio web, porque una compra en la App Store va ligada a una sola cuenta y no a un grupo.';

  @override
  String get openWebsite => 'Abrir biblequizzes.app';

  @override
  String get youManageGroup => 'Administras este grupo';

  @override
  String get youTakePart => 'Participas';

  @override
  String get groupCode => 'Código de grupo';

  @override
  String get purchaseReceivedNotActive =>
      'Recibimos tu compra, pero Premium aún no está activo. Toca \"Restaurar\" en un minuto.';

  @override
  String noPurchaseFound(Object storeName) {
    return 'No encontramos ninguna compra Premium en esta cuenta de $storeName.';
  }

  @override
  String purchasePending(Object storeName) {
    return 'Tu compra aún espera aprobación o pago. Premium se activará solo cuando $storeName la complete.';
  }

  @override
  String get noInternetRetry =>
      'Sin conexión a internet. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get alreadyPurchased =>
      'Ya lo compraste. Toca \"Restaurar\" para recuperarlo.';

  @override
  String get purchaseOtherAccount =>
      'Esta compra ya pertenece a otra cuenta de Bible Quizzes. Inicia sesión con esa cuenta para usar tu Premium.';

  @override
  String purchasesNotAllowed(Object store) {
    return 'No se permiten compras en este dispositivo. Revisa los ajustes de tu cuenta de $store.';
  }

  @override
  String subscriptionUnavailable(Object store) {
    return 'Esta suscripción no está disponible en $store ahora mismo. Inténtalo más tarde.';
  }

  @override
  String storeError(Object store) {
    return '$store devolvió un error. Inténtalo más tarde.';
  }

  @override
  String get purchasesNotInVersion =>
      'Las compras no están disponibles en esta versión de la app.';

  @override
  String get restoreFailed => 'No se pudo restaurar. Inténtalo de nuevo.';

  @override
  String get introPerkExplain =>
      'Una explicación en cada pregunta: por qué la respuesta es correcta';

  @override
  String get introPerkAll => 'Todos los quizzes, todas las veces que quieras';

  @override
  String get introPerkReview => 'Una revisión completa después de cada quiz';

  @override
  String get introPerkDaily => 'Un quiz nuevo cada día, sin límite';

  @override
  String get introPerkStick =>
      'Una explicación en cada pregunta, para que se quede';

  @override
  String get introPerkLookBack => 'Revisa tus respuestas después de cada quiz';

  @override
  String get introPerkTogetherFree =>
      'Jugar juntos sigue siendo gratis para todos';

  @override
  String get introPerkSoloUnlimited => 'Además, juego individual ilimitado';

  @override
  String get introPerkDiscuss =>
      'Una explicación en cada pregunta para comentar juntos';

  @override
  String stepOfThree(Object page) {
    return 'Paso $page de 3';
  }

  @override
  String get actionNext => 'Siguiente';

  @override
  String get introGrowQuestion => '¿En qué quieres crecer?';

  @override
  String get introGrowSubtitle =>
      'Te mostraremos lo que Premium hace para ello.';

  @override
  String get introGoalKnowledge => 'Más conocimiento bíblico';

  @override
  String get introGoalKnowledgeBody =>
      'Entender por qué una respuesta es correcta.';

  @override
  String get introGoalDaily => 'Aprender algo cada día';

  @override
  String get introGoalDailyBody => 'Crear un hábito y mantenerlo.';

  @override
  String get introGoalGroupBody => 'En familia o en grupo, unos contra otros.';

  @override
  String get introYouGet => 'Esto es lo que obtienes';

  @override
  String get introOneMembership =>
      'Todo en una sola suscripción, en web y app.';

  @override
  String get choosePlan => 'Elige tu plan';

  @override
  String get pricesNextPage =>
      'En la siguiente página verás los precios. Puedes cancelar cuando quieras.';

  @override
  String get accountWebAndApp =>
      'Tu cuenta funciona a la vez en la web y en la app. Una compra en tu teléfono también te da Premium en el sitio web, y al revés.';

  @override
  String get paywallHeadlineDefault => 'Juega sin límites\ncon Premium';

  @override
  String paywallHeadlineLimit(Object kFreeQuizLimit) {
    return 'Ya jugaste tus\n$kFreeQuizLimit quizzes gratis';
  }

  @override
  String get paywallHeadlineTogether => 'Sigue jugando juntos\nsin límites';

  @override
  String get paywallHeadlineGroup => 'Juega con todo\ntu grupo';

  @override
  String get paywallHeadlineExplain => 'Lee el porqué\nde cada pregunta';

  @override
  String get paywallHeadlineUnlock => 'Desbloquea\ntodos los quizzes';

  @override
  String get premiumRestored => 'Premium restaurado';

  @override
  String get welcomePremium => 'Bienvenido a Premium';

  @override
  String get premiumBackOn =>
      'Tu Premium vuelve a estar activo en esta cuenta.';

  @override
  String get premiumFullAccess =>
      'Ya tienes acceso completo a todas las funciones Premium, en la app y en la web. ¡Disfruta!';

  @override
  String get playOnPremium => 'Sigue jugando con Premium.';

  @override
  String get chooseSubscription => 'Elige una suscripción';

  @override
  String get yearly => 'Anual';

  @override
  String get perYear => 'al año';

  @override
  String get monthly => 'Mensual';

  @override
  String get perMonth => 'al mes';

  @override
  String get noTrial => 'Sin prueba';

  @override
  String get reloadPrices => 'Volver a cargar precios';

  @override
  String storeUnreachable(Object storeName) {
    return 'No se puede acceder a $storeName ahora. Comprueba tu conexión.';
  }

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get terms => 'Términos';

  @override
  String get privacy => 'Privacidad';

  @override
  String get alreadyPremium =>
      'Ya tienes Premium en esta cuenta. No se ha cobrado nada.';

  @override
  String get premiumOn => 'Premium está activo';

  @override
  String get restoreSignIn =>
      'Inicia sesión con tu cuenta y restauraremos tus compras en ella.';

  @override
  String get needAccountForPremium =>
      'Primero crea una cuenta gratis o inicia sesión, así Premium será tuyo - en la app y en la web.';

  @override
  String get accountNeeded => 'Se necesita una cuenta';

  @override
  String get pleaseWait => 'Un momento';

  @override
  String get nothingToRestore => 'Nada que restaurar';

  @override
  String get viewAllPlans => 'Ver todos los planes';

  @override
  String get explainEveryAnswer => 'Explicación en cada respuesta';

  @override
  String paywallFreeLimit(Object kFreeQuizLimit) {
    return 'Gratis juegas $kFreeQuizLimit quizzes. Con Premium se abren todos los libros de la Biblia, también Salmos y Apocalipsis.';
  }

  @override
  String get premiumEverythingOpen => 'Todo abierto con Premium';

  @override
  String get abbrGenesis => 'Gn';

  @override
  String get quizzes12 => '12 quizzes';

  @override
  String get abbrPsalms => 'Sal';

  @override
  String get quizzes15 => '15 quizzes';

  @override
  String get abbrRevelation => 'Ap';

  @override
  String get bookRevelation => 'Apocalipsis';

  @override
  String get quizzes9 => '9 quizzes';

  @override
  String get free => 'Gratis';

  @override
  String get orLifetime => 'O pago único: Premium de por vida';

  @override
  String lifetimeOnce(Object price) {
    return 'Premium de por vida, $price una vez';
  }

  @override
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears) {
    return '$weekly a la semana durante $lifetimeHorizonYears años';
  }

  @override
  String get lifetimePremium => 'Premium de por vida';

  @override
  String get payNothingToday => 'Hoy no pagas nada.';

  @override
  String payNothingTodayReminder(Object day) {
    return 'Hoy no pagas nada. Recordatorio el día $day.';
  }

  @override
  String get cancelAnytime => 'Cancela cuando quieras.';

  @override
  String get payOnceNoSub => 'Pago único, sin suscripción.';

  @override
  String get startPremium => 'Empezar Premium';

  @override
  String tryTrial(Object label) {
    return 'Prueba $label';
  }

  @override
  String get badgeFirstStepsDesc => 'Completa tu primer quiz.';

  @override
  String get badgeKnowledgeSeeker => 'Buscador de saber';

  @override
  String get badgeKnowledgeSeekerDesc => 'Juega 10 quizzes distintos.';

  @override
  String get badgePerfect => 'Sin errores';

  @override
  String get badgePerfectDesc => 'Consigue un 100% en un quiz.';

  @override
  String get badgeOnARoll => 'En racha';

  @override
  String get badgeOnARollDesc => 'Consigue una racha de 3 días.';

  @override
  String get badgeDedicated => 'Constante';

  @override
  String get badgeDedicatedDesc => 'Juega 7 días seguidos.';

  @override
  String get badgeScholar => 'Erudito';

  @override
  String get badgeMaster => 'Maestro';

  @override
  String get badgeAllRounder => 'Todoterreno';

  @override
  String get badgeAllRounderDesc => 'Juega una amplia variedad de quizzes.';

  @override
  String get rankSeeker => 'Buscador';

  @override
  String get saveFailed => 'No se pudo guardar. Inténtalo de nuevo.';

  @override
  String get saveFailedConnection =>
      'No se pudo guardar. Comprueba tu conexión.';

  @override
  String get achievements => 'Logros';

  @override
  String get achievementsLoadFailed => 'No se cargaron los logros';

  @override
  String get noBadgesYet =>
      'Aún no tienes insignias. Juega quizzes para desbloquear la primera.';

  @override
  String stillToEarn(Object lockedCount) {
    return 'Por conseguir · $lockedCount';
  }

  @override
  String badgesEarnedA11y(Object unlocked, Object total) {
    return '$unlocked de $total insignias conseguidas';
  }

  @override
  String badgesOf(Object unlocked, Object total) {
    return '$unlocked de $total insignias';
  }

  @override
  String get allEarned => 'Todo conseguido';

  @override
  String leftToEarn(Object left) {
    return 'Faltan $left';
  }

  @override
  String get profileUpdated => 'Perfil actualizado.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get profileLoadFailed => 'No se cargó el perfil';

  @override
  String get actionSave => 'Guardar';

  @override
  String get surpriseMe => 'Sorpréndeme';

  @override
  String get displayName => 'Nombre visible';

  @override
  String get displayNameHint => 'Cómo apareces en la clasificación';

  @override
  String get displayNameHelp =>
      'Visible en la clasificación y en multijugador. Se puede cambiar una vez cada 30 días.';

  @override
  String get buildMascot => 'Crea tu mascota';

  @override
  String get figure => 'Figura';

  @override
  String get color => 'Color';

  @override
  String get background => 'Fondo';

  @override
  String get accessory => 'Accesorio';

  @override
  String get notSignedIn => 'Sin sesión iniciada';

  @override
  String get settings => 'Ajustes';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get recentlyPlayed => 'Jugado recientemente';

  @override
  String levelN(Object level) {
    return 'Nivel $level';
  }

  @override
  String get maxLevel => 'Nivel máximo alcanzado';

  @override
  String progressToLevel(Object level) {
    return 'Progreso hacia el nivel $level';
  }

  @override
  String xpToLevel(Object xpRemaining, Object level) {
    return '$xpRemaining XP para el nivel $level';
  }

  @override
  String get daysInARow => 'Días seguidos';

  @override
  String get quizzesPlayed => 'Quizzes jugados';

  @override
  String get averageScore => 'Puntuación media';

  @override
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount) {
    return 'Ver todos los logros, $unlockedCount de $overviewCount conseguidos';
  }

  @override
  String allOf(Object unlockedCount, Object overviewCount) {
    return 'Los $unlockedCount de $overviewCount';
  }

  @override
  String get youHavePremium => 'Tienes Premium';

  @override
  String get youPlayFree => 'Juegas gratis';

  @override
  String scoreOfTotal(Object score, Object totalQuestions) {
    return '$score de $totalQuestions correctas';
  }

  @override
  String get completed => 'Completado';

  @override
  String get guestPerkKeep => 'Puntos, nivel y racha que se quedan';

  @override
  String get guestPerkLeaderboard => 'Un puesto en la clasificación';

  @override
  String get guestPerkBadges => 'Insignias por tus logros';

  @override
  String get guestPerkWebsite => 'El mismo progreso en biblequizzes.app';

  @override
  String get saveYourProgress => 'Guarda tu progreso';

  @override
  String get guestExplain =>
      'Juegas sin cuenta. No pasa nada, pero tu puntuación, puntos y racha solo se guardan con una cuenta gratis.';

  @override
  String get createFreeAccount => 'Crear una cuenta gratis';

  @override
  String get pendingOne => 'Un quiz espera tu cuenta';

  @override
  String pendingMany(Object pendingCount) {
    return '$pendingCount quizzes esperan tu cuenta';
  }

  @override
  String get withAccount => 'Con una cuenta';

  @override
  String get oneQuiz => '1 quiz';

  @override
  String quizzesN(Object total) {
    return '$total quizzes';
  }

  @override
  String playedOf(Object played, Object total) {
    return '$played de $total jugados';
  }

  @override
  String get quizzesLoadFailed => 'No se cargaron los quizzes';

  @override
  String get byBibleBook => 'Por libro de la Biblia';

  @override
  String booksAndQuizzes(Object booksCount, Object quizzes) {
    return '$booksCount libros · $quizzes quizzes';
  }

  @override
  String get bibleBook => 'Libro de la Biblia';

  @override
  String quizzesCountList(Object quizzesCount) {
    return '$quizzesCount quizzes';
  }

  @override
  String playedOfList(Object played, Object quizzesCount) {
    return '$played de $quizzesCount jugados';
  }

  @override
  String get noQuizzesForBook => 'Aún no hay quizzes de este libro.';

  @override
  String allQuizzesAbout(Object name) {
    return 'Todos los quizzes de $name';
  }

  @override
  String get startWith => 'EMPIEZA CON';

  @override
  String get continueWith => 'SIGUE CON';

  @override
  String get anyLevel => 'Cualquier nivel';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get results => 'Resultados';

  @override
  String get allQuizzes => 'Todos los quizzes';

  @override
  String get popular => 'Populares';

  @override
  String get allBooks => 'Todos los libros';

  @override
  String get searchHint => 'Busca un libro de la Biblia o un tema';

  @override
  String get clear => 'Borrar';

  @override
  String questionsAndMinutes(Object questionCount, Object questionCount2) {
    return '$questionCount preguntas · $questionCount2 min';
  }

  @override
  String get notPlayedYet => 'Aún no jugado';

  @override
  String get noQuizzesFilters =>
      'No se encontraron quizzes con los filtros actuales.';

  @override
  String get sortBibleOrder => 'Orden bíblico';

  @override
  String get sortMostPopular => 'Más populares';

  @override
  String get sortNewest => 'Más recientes';

  @override
  String get sortShortest => 'Más cortos';

  @override
  String get sort => 'Ordenar';

  @override
  String get hideText => 'Ocultar texto';

  @override
  String hideTextOf(Object reference) {
    return 'Ocultar el texto de $reference';
  }

  @override
  String get unlockPremiumExplain =>
      'Desbloquea Premium para ver la explicación';

  @override
  String get readWhyWrong => 'Lee por qué era incorrecto';

  @override
  String get timeUp => 'Se acabó el tiempo';

  @override
  String get finishQuiz => 'Terminar quiz';

  @override
  String get a11yYourAnswerRight => ', tu respuesta, correcta';

  @override
  String get a11yCorrectAnswer => ', la respuesta correcta';

  @override
  String get a11yYourAnswerWrong => ', tu respuesta, incorrecta';

  @override
  String questionOf(Object current, Object total) {
    return 'Pregunta $current de $total';
  }

  @override
  String secondsLeft(Object secondsLeft) {
    return 'Quedan $secondsLeft segundos';
  }

  @override
  String get wellPlayed => 'Bien jugado';

  @override
  String get niceTry => 'Buen intento';

  @override
  String get nextQuiz => 'Siguiente quiz';

  @override
  String get playWithOthers => 'Juega con otros';

  @override
  String get viewAnswers => 'Ver respuestas';

  @override
  String scoreA11yShort(Object correct, Object total) {
    return 'Puntuación $correct de $total';
  }

  @override
  String get newBestScore => 'Nueva mejor puntuación';

  @override
  String get scoreNotSaved => 'Tu puntuación aún no se ha guardado';

  @override
  String get scoreSaving => 'Guardando tu puntuación';

  @override
  String get again => 'Otra vez';

  @override
  String get noExtraXp => 'Sin XP extra esta vez';

  @override
  String get replayRule => 'Repetir solo cuenta si mejoras tu puntuación.';

  @override
  String xpToLevelResult(Object xpToNextLevel, Object level) {
    return '$xpToNextLevel XP para el nivel $level';
  }

  @override
  String get playTomorrowStreak => 'Juega mañana para mantener tu racha';

  @override
  String keepScoreXp(Object previewXp) {
    return 'Guarda tu puntuación, $previewXp XP y tu racha';
  }

  @override
  String get keepScoreBody =>
      'Inicia sesión o crea una cuenta gratis y esta puntuación se añadirá al instante. Tus quizzes contarán para tu nivel y la clasificación.';

  @override
  String get yourAnswers => 'Tus respuestas';

  @override
  String get allCorrectReview =>
      'Todo correcto. Mira la explicación de cada pregunta.';

  @override
  String wrongOf(Object wrongCount, Object questionsCount) {
    return '$wrongCount de las $questionsCount preguntas incorrectas.';
  }

  @override
  String get fullExplainPremium =>
      'La explicación completa de cada pregunta es parte de Premium.';

  @override
  String get unlockFullReview => 'Desbloquea la revisión completa';

  @override
  String get correct => 'Correcta';

  @override
  String get wrong => 'Incorrecta';

  @override
  String correctAnswerIs(Object text) {
    return 'Respuesta correcta: $text';
  }

  @override
  String get quizLoadFailed => 'No se cargó el quiz';

  @override
  String get howToPlay => '¿Cómo quieres jugar?';

  @override
  String get rememberedNext =>
      'Se recordará para tus próximos quizzes, también en la web.';

  @override
  String get freeLeftPrefix => 'Tienes ';

  @override
  String get freeLeftOne => ' quiz gratis';

  @override
  String get freeLeftMany => ' quizzes gratis';

  @override
  String get unlockWithPremium => 'Desbloquear con Premium';

  @override
  String readAndStart(Object label) {
    return 'Lee $label y empieza';
  }

  @override
  String get startQuiz => 'Empezar quiz';

  @override
  String readFirstLabel(Object label) {
    return 'Lee primero $label';
  }

  @override
  String get alreadyPlayed => 'Ya jugado';

  @override
  String get playAgainBetter => 'Juega de nuevo para mejorar tu puntuación';

  @override
  String get yourBestScore => 'Tu mejor puntuación';

  @override
  String lastPlayed(Object last) {
    return 'Jugado por última vez $last';
  }

  @override
  String get testKnowledge => 'Pon a prueba lo que sabes de este tema.';

  @override
  String get aboutQuiz => 'Sobre este quiz';

  @override
  String get finished => 'Terminado';

  @override
  String get readChapterExplain =>
      'Lees el capítulo del quiz antes de que empiecen las preguntas.';

  @override
  String get timePerQuestion => 'Tiempo por pregunta';

  @override
  String get timerExplain =>
      'Desactivado por defecto. Activa un reloj si quieres un reto.';

  @override
  String get off => 'No';

  @override
  String get noChapterToRead => 'No hay capítulo que leer';

  @override
  String get multiChapter =>
      'Este quiz trata de más de un capítulo. Puedes empezar el quiz directamente.';

  @override
  String get chapterFetchFailed =>
      'No se pudo cargar este capítulo ahora. Puedes empezar el quiz directamente.';

  @override
  String get readFirst => 'Lee primero';

  @override
  String readBeforeQuiz(Object title) {
    return 'Lee antes del quiz $title';
  }

  @override
  String get bibleVersionName => 'Reina-Valera 1909';

  @override
  String get keepStreakQuestion => '¿Mantener tu racha?';

  @override
  String keepStreakBody(Object streak) {
    return 'Has jugado $streak días seguidos. ¿Te avisamos a las 19:00 los días que aún no hayas jugado?';
  }

  @override
  String get noQuestionsYet => 'Aún no hay preguntas';

  @override
  String get quizNoQuestions => 'Este quiz aún no tiene preguntas.';

  @override
  String get goBack => 'Volver';

  @override
  String get today => 'hoy';

  @override
  String get yesterday => 'ayer';

  @override
  String daysAgo(Object days) {
    return 'hace $days días';
  }

  @override
  String onDate(Object date) {
    return 'el $date';
  }

  @override
  String get mpQuotaFailed => 'No se pudo cargar tu cupo de partidas.';

  @override
  String get mpCreateFailed => 'No se pudo crear una sala.';

  @override
  String mpJoinFailed(Object code) {
    return 'No se pudo entrar en la sala $code.';
  }

  @override
  String mpLoadFailed(Object code) {
    return 'No se pudo cargar la sala $code.';
  }

  @override
  String get mpStartFailed => 'No se pudo empezar el quiz.';

  @override
  String get mpNextFailed => 'No se pudo pasar a la siguiente pregunta.';

  @override
  String get mpAnswerFailed => 'No se pudo enviar tu respuesta.';

  @override
  String get mpResultsFailed => 'No se pudieron cargar los resultados.';

  @override
  String get unexpectedServerResponse => 'Respuesta inesperada del servidor.';

  @override
  String get roomNotFoundDot => 'Sala no encontrada.';

  @override
  String get playTogether => 'Jugar juntos';

  @override
  String get backToPlayTogether => 'Volver a Jugar juntos';

  @override
  String get stopQuiz => 'Detener quiz';

  @override
  String get leaveGame => 'Salir de la partida';

  @override
  String get multiplayerQuiz => 'Quiz multijugador';

  @override
  String roomCodeLabel(Object code) {
    return 'Sala $code';
  }

  @override
  String get waitingNextQuestion => 'Esperando la siguiente pregunta…';

  @override
  String get nextIn => 'Siguiente en ';

  @override
  String correctOfPlayers(Object correctCount, Object playersCount) {
    return '$correctCount de $playersCount acertaron';
  }

  @override
  String get standings => 'Clasificación';

  @override
  String get stopQuizQuestion => '¿Detener el quiz?';

  @override
  String get stopQuizBody =>
      '¿Quieres detener este quiz multijugador para todos?';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get stopQuizAction => 'Detener';

  @override
  String get leaveGameQuestion => '¿Salir de la partida?';

  @override
  String get leaveGameBody =>
      'Tu puntuación se guarda si vuelves desde Jugar juntos.';

  @override
  String get stay => 'Quedarme';

  @override
  String get leaveGameAction => 'Salir';

  @override
  String questionNumberOf(Object number, Object total) {
    return 'Pregunta $number de $total';
  }

  @override
  String secondsRemaining(Object seconds) {
    return 'Quedan $seconds segundos';
  }

  @override
  String nextQuestionIn(Object seconds) {
    return 'Siguiente pregunta en $seconds segundos';
  }

  @override
  String get a11yYourAnswer => ', tu respuesta';

  @override
  String get a11yRightAnswer => ', respuesta correcta';

  @override
  String get a11yWrongShort => ', incorrecta';

  @override
  String a11yChosenTimes(Object count) {
    return ', elegida $count veces';
  }

  @override
  String get noAnswerLower => 'sin respuesta';

  @override
  String get stillThinking => 'pensando';

  @override
  String get noAnswer => 'Sin respuesta';

  @override
  String get rightExclaim => '¡Correcto!';

  @override
  String get tooBad => 'Lástima';

  @override
  String get correctMarkedGreen =>
      'La respuesta correcta está marcada en verde.';

  @override
  String get yourAnswerCorrect => 'Tu respuesta es correcta.';

  @override
  String get yourChoiceMarked =>
      'Tu elección está marcada junto a la respuesta correcta.';

  @override
  String pointsGained(Object gained) {
    return '+$gained puntos';
  }

  @override
  String get nextQuestion => 'Siguiente pregunta';

  @override
  String get hostMovingOn =>
      'El anfitrión pasará pronto a la siguiente pregunta.';

  @override
  String get submitted => 'Enviado';

  @override
  String get waitingOtherPlayers => 'Esperando a los demás jugadores…';

  @override
  String get hostSetsPace =>
      'Tú marcas el ritmo. Muestra las respuestas cuando todos terminen.';

  @override
  String get showAnswers => 'Mostrar respuestas';

  @override
  String get startQuestions => 'Empezar las preguntas';

  @override
  String get waitHostQuestions =>
      'Espera a que el anfitrión empiece las preguntas.';

  @override
  String get waitingHostQuestions =>
      'Esperando a que el anfitrión empiece las preguntas…';

  @override
  String readBeforeQuizMp(Object quizTitle) {
    return 'Lee antes del quiz $quizTitle';
  }

  @override
  String get readChapterCalmly =>
      'Lee este capítulo con calma. Las preguntas tratan de él, así que leer ayuda de verdad.';

  @override
  String get chapterNotLoaded => 'No se cargó el capítulo';

  @override
  String get chapterFetchFailedHost =>
      'No se pudo cargar este capítulo ahora. El anfitrión puede empezar las preguntas directamente.';

  @override
  String get lobby => 'Sala de espera';

  @override
  String get closeRoom => 'Cerrar sala';

  @override
  String get leaveRoom => 'Salir de la sala';

  @override
  String get closeRoomQuestion => '¿Cerrar la sala?';

  @override
  String get leaveRoomQuestion => '¿Salir de la sala?';

  @override
  String get closeRoomBody =>
      'Si eres el único, la sala se cierra. Si ya hay jugadores, otro será el anfitrión.';

  @override
  String get rejoinLater => 'Puedes volver a unirte luego con el mismo código.';

  @override
  String get closeRoomAction => 'Cerrar sala';

  @override
  String get leaveRoomAction => 'Salir';

  @override
  String get freeGamesUsed => 'Se acabaron tus partidas gratis';

  @override
  String get premiumHostUnlimited =>
      'Con Premium creas partidas ilimitadas, con hasta 20 jugadores a la vez. Tu grupo sigue esperando en la sala.';

  @override
  String get newRoomCode => 'Recibirás un nuevo código de sala.';

  @override
  String get startWhenEveryone => 'Empieza el quiz cuando estén todos.';

  @override
  String get hostStartsWhenEveryone =>
      'El anfitrión empezará el quiz cuando estén todos.';

  @override
  String get roomCodeCopied => 'Código de sala copiado.';

  @override
  String get change => 'Cambiar';

  @override
  String get players => 'Jugadores';

  @override
  String playersOfMax(Object playersCount, Object maxPlayers) {
    return '$playersCount de $maxPlayers';
  }

  @override
  String get startTheQuiz => 'Empezar el quiz';

  @override
  String get oneQuestion => '1 pregunta';

  @override
  String totalQuestionsN(Object totalQuestions) {
    return '$totalQuestions preguntas';
  }

  @override
  String secondsPerQuestion(Object questionTimerSeconds) {
    return '$questionTimerSeconds s por pregunta';
  }

  @override
  String get hostSetsPaceShort => 'El anfitrión marca el ritmo';

  @override
  String get readFirstShort => 'Leer primero';

  @override
  String get joinMyQuizShareTitle => 'Únete a mi partida de Bible Quizzes';

  @override
  String get playersEnterCode =>
      'Los jugadores introducen este código en Jugar juntos';

  @override
  String get shareCode => 'Compartir código';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get newPlayersAppear => 'Los nuevos jugadores aparecen aquí solos.';

  @override
  String get waitHostQuiz => 'Espera a que el anfitrión empiece el quiz.';

  @override
  String get quizCompleted => 'Quiz completado';

  @override
  String get finalStandings => 'Clasificación final';

  @override
  String winnerWith(Object winner, Object score) {
    return 'Ganador: $winner con $score puntos';
  }

  @override
  String get backHome => 'Volver al inicio';

  @override
  String get startNewRoom => 'Crear una sala nueva';

  @override
  String groupSaved(Object savedGroupName) {
    return '\"$savedGroupName\" se ha guardado.';
  }

  @override
  String get groupStandingsOnLeaderboard =>
      'Verás la clasificación de este grupo en la clasificación.';

  @override
  String get saveGroupQuestion => '¿Guardar este grupo?';

  @override
  String saveGroupBody(Object playersCount) {
    return 'Así llevarás tu propia clasificación con estos $playersCount jugadores y podrás invitarlos de nuevo con un toque.';
  }

  @override
  String get saveGroup => 'Guardar grupo';

  @override
  String placeNamePoints(Object place, Object name, Object score) {
    return '$place. $name, $score puntos';
  }

  @override
  String pointsN(Object score) {
    return '$score puntos';
  }

  @override
  String correctOfTotal(Object correctAnswers, Object totalQuestions) {
    return '$correctAnswers de $totalQuestions correctas';
  }

  @override
  String correctN(Object correctAnswers) {
    return '$correctAnswers correctas';
  }

  @override
  String get roomReconnecting =>
      'Sala no disponible por un momento. Reconectando...';

  @override
  String get roomClosedFinal =>
      'La sala está cerrada. Esta es la clasificación final.';

  @override
  String get roomGone =>
      'Esta sala ya no existe. Vuelve y crea una sala nueva.';

  @override
  String get createRoom => 'Crear sala';

  @override
  String get createRoomInvite => 'Crear sala e invitar';

  @override
  String thenInviteGroup(Object name) {
    return 'Después invitaremos a $name.';
  }

  @override
  String get selectQuizFirst => 'Primero elige un quiz.';

  @override
  String get enterRoomCode => 'Introduce un código de sala.';

  @override
  String get roomCodeTooShort => 'El código parece demasiado corto. Revísalo.';

  @override
  String pickQuizThenInvite(Object name) {
    return 'Elige primero un quiz y luego invitaremos a $name.';
  }

  @override
  String get yourGroupsShort => 'Tus grupos';

  @override
  String get pickQuizInviteGroup =>
      'Elige un quiz y envía a tu grupo una nueva invitación con un toque.';

  @override
  String get signInToPlayTogether => 'Inicia sesión para jugar juntos';

  @override
  String get playTogetherNeedsAccount =>
      'Crear o unirte a una sala se puede con una cuenta gratis, para que tu nombre y puntuación sean correctos.';

  @override
  String get playTogetherIntro =>
      'Con tu familia, amigos o el grupo de jóvenes: todos juegan el mismo quiz a la vez, cada uno en su teléfono.';

  @override
  String upToPlayers(Object maxPlayers) {
    return 'Hasta $maxPlayers jugadores por sala';
  }

  @override
  String get youAreHost => 'Eres el anfitrión';

  @override
  String premiumHostRooms(Object maxPlayersPremium) {
    return 'Con Premium creas salas ilimitadas, hasta $maxPlayersPremium jugadores a la vez. Unirse con un código siempre es gratis.';
  }

  @override
  String get viewPremium => 'Ver Premium';

  @override
  String get hostSteps =>
      'Elige un quiz, comparte el código con tu grupo y empieza cuando estén todos.';

  @override
  String get pickQuiz => 'Elige un quiz';

  @override
  String get gameThisMonth => 'Tu partida de este mes';

  @override
  String get lastFreeGame => 'Última partida gratis';

  @override
  String freeGamesLeftN(Object remaining) {
    return 'Quedan $remaining partidas gratis';
  }

  @override
  String get freeGameMonthly =>
      'Esta es tu partida gratis de este mes. El mes que viene tendrás otra. Con Premium creas todas las que quieras.';

  @override
  String get lastFreeGameBody =>
      'Esta es tu última partida gratis como anfitrión. Después recibirás una cada mes. Unirte a la partida de otro sigue siendo gratis.';

  @override
  String freeGamesLeftBody(Object remaining) {
    return 'Te quedan $remaining partidas gratis como anfitrión. Una partida solo cuenta cuando la empiezas.';
  }

  @override
  String get joinWithCode => 'Unirse con un código';

  @override
  String get hostShares6 => 'El anfitrión comparte un código de 6 caracteres';

  @override
  String get join => 'Unirse';

  @override
  String roomCodeA11y(Object length) {
    return 'Código de sala, $length caracteres';
  }

  @override
  String get lobbyStillOpen => 'Tu sala de espera sigue abierta';

  @override
  String get lastGameOver => 'Tu última partida terminó';

  @override
  String get gameStillRunning => 'Tu partida sigue en curso';

  @override
  String resumeA11y(Object label, Object quizTitle, Object code) {
    return '$label. $quizTitle, sala $code. Continuar';
  }

  @override
  String quizRoom(Object quizTitle, Object code) {
    return '$quizTitle - sala $code';
  }

  @override
  String get invite => 'Invitar';

  @override
  String get pickOtherQuiz => 'Elegir otro quiz';

  @override
  String get setUpRoom => 'Configurar sala';

  @override
  String get noQuizzesForRoom =>
      'No se encontraron quizzes para crear una sala.';

  @override
  String get cantLoadQuizzes => 'No se pueden cargar los quizzes';

  @override
  String get numberOfPlayers => 'Número de jugadores';

  @override
  String maxN(Object maxPlayers) {
    return 'Máx. $maxPlayers';
  }

  @override
  String countPlayersPremium(Object count) {
    return '$count jugadores, Premium';
  }

  @override
  String hostCanInvite(Object maxPlayersPremium) {
    return 'Eres el anfitrión y puedes invitar hasta $maxPlayersPremium jugadores.';
  }

  @override
  String freeUpToPlayers(Object maxPlayersFree) {
    return 'Gratis hasta $maxPlayersFree jugadores. Una partida gratis solo cuenta cuando la empiezas.';
  }

  @override
  String maxPlayersNeedsPremium(Object maxPlayers, Object maxPlayersFree) {
    return '$maxPlayers jugadores requiere Premium. Gratis juegas con hasta $maxPlayersFree.';
  }

  @override
  String freeGamesLeftHost(Object freeGamesLeft) {
    return 'Te quedan $freeGamesLeft partidas gratis como anfitrión.';
  }

  @override
  String get readChapterFirst => 'Leer primero el capítulo';

  @override
  String get onlySingleChapter => 'Solo funciona con quizzes de 1 capítulo.';

  @override
  String get pacePerQuestion => 'Ritmo por pregunta';

  @override
  String get youAdvance =>
      'Tú pasas a las respuestas y a la siguiente pregunta.';

  @override
  String everyoneGetsSeconds(Object tempo) {
    return 'Todos tienen $tempo segundos por pregunta.';
  }

  @override
  String get hostDecides => 'Decide el anfitrión';

  @override
  String secondsPerQuestionLong(Object i) {
    return '$i segundos por pregunta';
  }

  @override
  String get player => 'Jugador';

  @override
  String get you => 'Tú';

  @override
  String get sampleName => 'Sara';

  @override
  String get streak7Days => 'Racha de 7 días';

  @override
  String readReference(Object reference) {
    return 'Leer $reference';
  }

  @override
  String get rightAnswer => 'Respuesta correcta';

  @override
  String get wrongAnswer => 'Respuesta incorrecta';

  @override
  String get textFetchFailed => 'No se pudo cargar el texto.';

  @override
  String get leaderboardMonthEmpty =>
      'Nadie ha ganado XP este mes todavía. Juega un quiz y ponte en cabeza.';

  @override
  String get leaderboardMonthEmptyGroup =>
      'Nadie de este grupo ha ganado XP este mes todavía. Juega un quiz y ponte en cabeza.';

  @override
  String trialFree(Object period) {
    return '$period gratis';
  }

  @override
  String trialDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String trialWeeks(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count semanas',
      one: '1 semana',
    );
    return '$_temp0';
  }

  @override
  String trialMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String trialYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String legalLifetime(Object price, Object store) {
    return 'Premium de por vida es una compra única de $price a través de tu cuenta de $store y no se renueva automáticamente.';
  }

  @override
  String legalYearly(Object price) {
    return 'Bible Quizzes Premium Anual: $price al año.';
  }

  @override
  String legalMonthly(Object price) {
    return 'Bible Quizzes Premium Mensual: $price al mes.';
  }

  @override
  String legalTrial(Object period) {
    return ' La suscripción empieza tras una prueba gratis de $period.';
  }

  @override
  String legalRenews(Object store) {
    return ' La suscripción se gestiona con tu cuenta de $store y se renueva automáticamente salvo que canceles al menos 24 horas antes del final del periodo actual.';
  }

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get termsWord => 'términos';

  @override
  String get privacyWord => 'política de privacidad';

  @override
  String get oldTestament => 'Antiguo Testamento';

  @override
  String get newTestament => 'Nuevo Testamento';

  @override
  String get themes => 'Temas';

  @override
  String get correctLower => 'correctas';

  @override
  String get questionsLower => 'preguntas';

  @override
  String get aboutLower => 'aprox.';

  @override
  String get busy => 'Procesando...';

  @override
  String get termsEnd => '.';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageDevice => 'Idioma del teléfono';

  @override
  String get languageExplain =>
      'Cada idioma tiene sus propios quizzes y cuentas. Al cambiar, vuelves a iniciar sesión.';

  @override
  String get languageRestart =>
      'Cierra y vuelve a abrir la app para usar el nuevo idioma.';
}
