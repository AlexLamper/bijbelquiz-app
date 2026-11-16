// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Bible Quizzes';

  @override
  String get inviteFallbackTitle => 'um quiz bíblico';

  @override
  String inviteJoin(String title, String brand) {
    return 'Você topa jogar $title no $brand?';
  }

  @override
  String inviteCode(String code) {
    return 'Ou digite o código: $code';
  }

  @override
  String get errGenericTitle => 'Algo deu errado';

  @override
  String get errGenericMessage =>
      'Não conseguimos concluir isso. Tente de novo daqui a pouco.';

  @override
  String get errNetworkTitle => 'Sem conexão';

  @override
  String get errNetworkMessage =>
      'Verifique sua conexão com a internet e tente de novo.';

  @override
  String get errSignedOutTitle => 'Entre novamente';

  @override
  String get errSignedOutMessage =>
      'Sua sessão expirou. Entre novamente para continuar jogando.';

  @override
  String get errRoomNotFoundTitle => 'Sala não encontrada';

  @override
  String get errRoomNotFoundMessage =>
      'Esta sala não existe mais ou foi fechada. Confira o código ou crie uma nova sala.';

  @override
  String get errRoomFullTitle => 'A sala está cheia';

  @override
  String get errRoomFullMessage =>
      'Não cabem mais jogadores nesta sala. Peça ao anfitrião para abrir uma nova sala.';

  @override
  String get errRoomStartedTitle => 'O jogo já começou';

  @override
  String get errRoomStartedMessage =>
      'Este quiz já está em andamento. Espere a rodada terminar ou crie uma nova sala.';

  @override
  String get errRoomFinishedTitle => 'O jogo terminou';

  @override
  String get errRoomFinishedMessage =>
      'Esta sala está fechada. Crie uma nova sala para continuar jogando.';

  @override
  String get errRoomCodeTitle => 'Código de sala inválido';

  @override
  String get errRoomCodeMessage =>
      'Este código não está certo. Um código de sala tem 6 caracteres.';

  @override
  String get errAlreadyInRoomTitle => 'Você já está nesta sala';

  @override
  String get errAlreadyInRoomMessage =>
      'Volte para a sala para continuar jogando.';

  @override
  String get errPremiumTitle => 'Premium necessário';

  @override
  String get errPremiumMessage =>
      'Criar sua própria sala faz parte do Bible Quizzes Premium. Participar é sempre grátis.';

  @override
  String get errForbiddenTitle => 'Sem acesso';

  @override
  String get errForbiddenMessage => 'Só o anfitrião pode fazer isso.';

  @override
  String get errRateLimitedTitle => 'Calma aí';

  @override
  String get errRateLimitedMessage =>
      'Você tentou muitas vezes seguidas. Espere um pouco e tente de novo.';

  @override
  String get errNotFoundTitle => 'Não encontrado';

  @override
  String get errNotFoundMessage =>
      'Não conseguimos encontrar isso. Volte e tente de novo.';

  @override
  String get errConflictTitle => 'Isso não é possível agora';

  @override
  String get errConflictMessage =>
      'Esta ação não combina com o estado atual do jogo. Atualize e tente de novo.';

  @override
  String get errServerTitle => 'O servidor não responde';

  @override
  String get errServerMessage =>
      'Algo deu errado do nosso lado. Tente de novo em alguns segundos.';

  @override
  String get errLiveLostTitle => 'Conexão ao vivo perdida';

  @override
  String get errLiveLostMessage =>
      'A conexão ao vivo caiu. Estamos buscando o placar automaticamente.';

  @override
  String get errLoginTitle => 'Falha ao entrar';

  @override
  String get errLoginBadCredentials => 'Este e-mail ou senha está incorreto.';

  @override
  String get errAccountExistsTitle => 'A conta já existe';

  @override
  String get errAccountExistsMessage =>
      'Já existe uma conta com este e-mail. Entre.';

  @override
  String get errRegisterTitle => 'Falha no cadastro';

  @override
  String get errRegisterMessage =>
      'Não conseguimos criar sua conta. Tente de novo.';

  @override
  String get errLoginMessage =>
      'Não conseguimos fazer seu login. Tente de novo.';

  @override
  String get errLeaderboardTitle => 'O ranking não carregou';

  @override
  String get errLeaderboardMessage =>
      'Não conseguimos carregar o ranking. Tente de novo.';

  @override
  String get errQuizzesTitle => 'Os quizzes não carregaram';

  @override
  String get errQuizzesMessage =>
      'Não conseguimos carregar os quizzes. Tente de novo.';

  @override
  String get errProfileTitle => 'O perfil não carregou';

  @override
  String get errProfileMessage =>
      'Não conseguimos carregar seu perfil. Tente de novo.';

  @override
  String get errPurchaseTitle => 'Falha na compra';

  @override
  String get errPurchaseMessage =>
      'A compra não foi concluída. Nada foi cobrado.';

  @override
  String get streakReminderTitle => 'Sua sequência está em jogo';

  @override
  String get streakReminderChannel => 'Lembrete de sequência';

  @override
  String get streakReminderChannelDescription =>
      'Um lembrete na noite em que sua sequência está para acabar.';

  @override
  String streakReminderBody(Object streak) {
    return 'Sua sequência de $streak dias termina hoje à noite. Um quiz basta para mantê-la.';
  }

  @override
  String get navQuizzes => 'Quizzes';

  @override
  String get navTogether => 'Juntos';

  @override
  String get navLeaderboard => 'Ranking';

  @override
  String get navProfile => 'Perfil';

  @override
  String get savedQuizFallback => 'seu quiz';

  @override
  String savedScoreOne(Object title, Object xpEarned) {
    return 'Sua pontuação em \"$title\" foi salva (+$xpEarned XP).';
  }

  @override
  String savedScoreMany(Object saved, Object xpEarned) {
    return '$saved quizzes salvos (+$xpEarned XP).';
  }

  @override
  String get progressSaved => 'Progresso salvo';

  @override
  String get navHome => 'Início';

  @override
  String get avatarLamb => 'Cordeiro';

  @override
  String get avatarLion => 'Leão';

  @override
  String get avatarDove => 'Pomba';

  @override
  String get avatarOwl => 'Coruja';

  @override
  String get avatarDeer => 'Cervo';

  @override
  String get avatarOx => 'Boi';

  @override
  String get avatarSand => 'Areia';

  @override
  String get avatarLapis => 'Lápis-lazúli';

  @override
  String get avatarClay => 'Argila';

  @override
  String get avatarOlive => 'Oliva';

  @override
  String get avatarRose => 'Rosa';

  @override
  String get avatarSlate => 'Ardósia';

  @override
  String get avatarParchment => 'Pergaminho';

  @override
  String get avatarSky => 'Céu';

  @override
  String get avatarSage => 'Sálvia';

  @override
  String get avatarSunrise => 'Nascer do sol';

  @override
  String get avatarNight => 'Noite';

  @override
  String get avatarBlush => 'Rubor';

  @override
  String get avatarNone => 'Nenhum';

  @override
  String get avatarGlasses => 'Óculos';

  @override
  String get avatarCap => 'Boné';

  @override
  String get avatarScarf => 'Cachecol';

  @override
  String get avatarCrown => 'Coroa';

  @override
  String avatarWith(Object character, Object accessory) {
    return '$character com $accessory';
  }

  @override
  String get wordmarkFirst => 'Bible';

  @override
  String get wordmarkSecond => 'Quizzes';

  @override
  String get actionClose => 'Fechar';

  @override
  String get actionBack => 'Voltar';

  @override
  String questionsCount(Object questionCount) {
    return '$questionCount perguntas';
  }

  @override
  String get actionStart => 'Começar';

  @override
  String get authGoogleAndroidInterrupted =>
      'O login com Google foi interrompido no Android. Verifique o SHA-1/SHA-256 da chave de release no cliente OAuth do Google Cloud.';

  @override
  String get authGoogleNoToken =>
      'O Google não retornou um token de login. Tente de novo ou escolha outra conta.';

  @override
  String get authAppleUnavailable =>
      'Entrar com a Apple não está disponível neste aparelho.';

  @override
  String get authAppleError1000 =>
      'Não foi possível entrar com a Apple (erro 1000). Verifique se há um Apple ID neste aparelho e tente de novo.';

  @override
  String get authAppleWebNotConfigured =>
      'Entrar com a Apple ainda não está configurado nesta plataforma.';

  @override
  String get authWelcomeBack => 'Bem-vindo de volta';

  @override
  String get authLoginSubtitle =>
      'Entre para salvar seu progresso e participar do ranking.';

  @override
  String get authEmailHint => 'nome@exemplo.com';

  @override
  String get authPassword => 'Senha';

  @override
  String get authPasswordHint => 'Sua senha';

  @override
  String get authSignIn => 'Entrar';

  @override
  String get authNoAccount => 'Ainda não tem conta?';

  @override
  String get authRegister => 'Cadastrar';

  @override
  String get authCreateAccount => 'Criar conta';

  @override
  String get authCreateSubtitle => 'Grátis, e seu progresso fica salvo.';

  @override
  String get authName => 'Nome';

  @override
  String get authNameHelp =>
      'É assim que os outros veem você no ranking e quando jogam juntos.';

  @override
  String get authTermsPrefixRegister =>
      'Ao criar uma conta você concorda com os ';

  @override
  String get authHaveAccount => 'Já tem conta?';

  @override
  String get splashTagline => 'Quanto você conhece a Bíblia?';

  @override
  String get authOrEmail => 'ou com e-mail';

  @override
  String get authTermsPrefix => 'Ao continuar você concorda com os ';

  @override
  String get errLinkTitle => 'O link não abriu';

  @override
  String get errLinkMessage =>
      'Não conseguimos abrir esta página. Tente de novo.';

  @override
  String get authTermsAnd => ' e a ';

  @override
  String get authShowPassword => 'Mostrar senha';

  @override
  String get authHidePassword => 'Ocultar senha';

  @override
  String get authContinueGoogle => 'Continuar com Google';

  @override
  String get authContinueApple => 'Continuar com Apple';

  @override
  String get dataInfoTitle => 'Como tratamos seus dados';

  @override
  String get dataInfoBody =>
      'Ao entrar ou se cadastrar, usamos apenas os dados necessários para sua conta funcionar, como seu nome, e-mail e dados de acesso.\n\nSeus dados são enviados por conexões seguras e não os compartilhamos para publicidade sem sua permissão.\n\nVocê sempre pode pedir a exclusão da sua conta. Fale conosco em info@biblequizzes.app ou pelos canais de suporte do app. Após a exclusão, os dados da sua conta são apagados conforme nossa política de privacidade.';

  @override
  String get dataInfoMore => 'Mais sobre o uso de dados';

  @override
  String get homeContinue => 'Continuar jogando';

  @override
  String get homeAll => 'Tudo';

  @override
  String get homePickTopic => 'Escolha um tema';

  @override
  String get homePopular => 'Quizzes populares';

  @override
  String get streakOneDay => 'Sequência de 1 dia';

  @override
  String streakDays(Object streak) {
    return 'Sequência de $streak dias';
  }

  @override
  String questionsCountShort(Object count) {
    return '$count perguntas';
  }

  @override
  String quizOfTheDayLabel(Object title) {
    return 'Quiz do dia: $title';
  }

  @override
  String get quizOfTheDayKicker => 'QUIZ DO DIA';

  @override
  String get actionUnlock => 'Desbloquear';

  @override
  String get actionPlayNow => 'Jogar agora';

  @override
  String get homeChallengeLoading =>
      'Um novo desafio aparece quando os quizzes carregarem.';

  @override
  String get homeLoadFailed => 'O início não carregou';

  @override
  String get checkConnectionRetry => 'Verifique sua conexão e tente de novo.';

  @override
  String get actionRetry => 'Tentar de novo';

  @override
  String get homeGuestTitle => 'Jogue grátis, sem conta';

  @override
  String get homeGuestBody =>
      'Crie uma para salvar sua pontuação, pontos e sequência.';

  @override
  String get homeGuestAction => 'Salvar progresso';

  @override
  String chapterN(Object chapter) {
    return 'Capítulo $chapter';
  }

  @override
  String scoreCorrect(Object scoreText) {
    return '$scoreText certas';
  }

  @override
  String get played => 'Jogado';

  @override
  String scoreA11y(Object title, Object score, Object total) {
    return '$title, $score de $total certas';
  }

  @override
  String get books39 => '39 livros';

  @override
  String get books27 => '27 livros';

  @override
  String get catGeneral => 'Geral';

  @override
  String get catWholeBible => 'Bíblia inteira';

  @override
  String get catByTheme => 'Por tema';

  @override
  String questionsCountQuiz(Object questionCount) {
    return '$questionCount perguntas';
  }

  @override
  String get groupsLoadFailed => 'Não foi possível carregar seus grupos.';

  @override
  String get groupSaveFailed => 'Não foi possível salvar o grupo.';

  @override
  String get groupSaveFailedTitle => 'Falha ao salvar o grupo';

  @override
  String get groupSaveNoGroup =>
      'O servidor não retornou nenhum grupo. Tente de novo.';

  @override
  String get groupRenameFailed => 'Não foi possível renomear.';

  @override
  String get deleteFailed => 'Não foi possível excluir.';

  @override
  String get groupStandingsFailed =>
      'Não foi possível carregar a classificação deste grupo.';

  @override
  String get groupsTitle => 'Grupos';

  @override
  String get groupSingular => 'Grupo';

  @override
  String get leaderboardLoadFailed => 'O ranking não carregou';

  @override
  String get leaderboardMonthHint => 'XP dos últimos 30 dias';

  @override
  String get leaderboardAllTimeHint => 'Conta todo o XP desde o início';

  @override
  String get periodMonth => 'Este mês';

  @override
  String get periodAllTime => 'Sempre';

  @override
  String get periodLabel => 'Período';

  @override
  String get everyone => 'Todos';

  @override
  String leaderboardGap(Object gap, Object rank) {
    return '$gap XP para o $rankº lugar';
  }

  @override
  String get showLess => 'Mostrar menos';

  @override
  String showAllPlayers(Object total) {
    return 'Mostrar os $total jogadores';
  }

  @override
  String get leaderboardGuestHint => 'Com uma conta grátis seu XP conta.';

  @override
  String get leaderboardNotOnIt => 'Você ainda não está neste ranking';

  @override
  String get leaderboardPlayToJoin => 'Jogue um quiz para participar.';

  @override
  String get leaderboardNoData => 'Ainda não há dados do ranking.';

  @override
  String get leaderboardEmpty => 'Ainda não há ninguém no ranking';

  @override
  String get onboardingTagline =>
      'Quizzes curtos sobre os livros da Bíblia, sozinho ou com outras pessoas.';

  @override
  String get onboardingGuest => 'Jogar primeiro sem conta';

  @override
  String get onboardingPreviewA11y =>
      'Exemplo: uma pergunta com a resposta certa, um duelo contra Sara, XP e uma sequência';

  @override
  String get onboardingSampleQuestion => 'Quantos pães o menino tinha?';

  @override
  String get onboardingSampleStreak => '6 dias seguidos';

  @override
  String get seasonEndsToday => 'Termina hoje';

  @override
  String get seasonOneDayLeft => 'Falta 1 dia';

  @override
  String seasonDaysLeft(Object daysRemaining) {
    return 'Faltam $daysRemaining dias';
  }

  @override
  String get season => 'Temporada';

  @override
  String get manageSubscription => 'Gerenciar assinatura';

  @override
  String get viaWebsite => 'Pelo site';

  @override
  String get lifetime => 'Vitalício';

  @override
  String get active => 'Ativo';

  @override
  String get deleteSignInFirst =>
      'Primeiro entre com a conta que você quer excluir.';

  @override
  String get deleteAccountQuestion => 'Excluir conta?';

  @override
  String get deleteAccountBody =>
      'Sua conta, seu progresso, seu XP e seus duelos serão excluídos para sempre. Não dá para desfazer.\n\nUma assinatura pela App Store ou Google Play não é cancelada por isso: cancele-a antes nas assinaturas do seu celular.';

  @override
  String get deletePermanently => 'Excluir definitivamente';

  @override
  String deleteAccountFailed(Object accountEmail) {
    return 'Não foi possível excluir. Tente de novo ou escreva para $accountEmail.';
  }

  @override
  String get accountNotDeleted => 'Conta não excluída';

  @override
  String get accountDeleted => 'Sua conta foi excluída.';

  @override
  String get notificationsOff =>
      'As notificações estão desativadas para o Bible Quizzes. Ative-as nas configurações do celular.';

  @override
  String get purchasesRestored => 'Compras restauradas';

  @override
  String get settingsReminder => 'Lembrete';

  @override
  String get settingsTime => 'Horário';

  @override
  String get settingsPlaying => 'Jogo';

  @override
  String get settingsReadChapterFirst => 'Ler o capítulo primeiro';

  @override
  String get settingsShowReference => 'Referência bíblica na explicação';

  @override
  String get settingsLargeText => 'Texto da pergunta grande';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get settingsManage => 'Gerenciar';

  @override
  String get signOut => 'Sair';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get guestPlaying => 'Você está jogando sem conta';

  @override
  String get signInOrCreate => 'Entre ou crie uma conta';

  @override
  String get yourAccount => 'Sua conta';

  @override
  String get signedIn => 'Conectado';

  @override
  String signedInAs(Object email) {
    return 'Conectado como $email';
  }

  @override
  String secondsN(Object choice) {
    return '$choice segundos';
  }
}
