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

  @override
  String get joinFailed => 'Não foi possível participar.';

  @override
  String get joinFailedConnection =>
      'Não foi possível participar. Verifique sua conexão.';

  @override
  String get trialEndingTitle => 'Seu teste está quase acabando';

  @override
  String trialEndingBody(Object kTrialReminderDaysBeforeEnd) {
    return 'Seu Bible Quizzes Premium começa em $kTrialReminderDaysBeforeEnd dias. Não quer continuar? Cancele nas configurações da loja.';
  }

  @override
  String get trialReminderChannel => 'Lembrete de teste';

  @override
  String get trialReminderChannelDescription =>
      'Um lembrete antes do fim do seu teste grátis.';

  @override
  String get supportEmail => 'info@biblequizzes.app';

  @override
  String get groupCodeIncomplete => 'Digite o código do grupo completo.';

  @override
  String groupJoined(Object name) {
    return 'Agora você faz parte de $name.';
  }

  @override
  String get groupLicenseGoToSite =>
      'Acesse biblequizzes.app/group-license no navegador.';

  @override
  String get groupLicense => 'Licença de grupo';

  @override
  String mailUsAt(Object supportEmail) {
    return 'Escreva para $supportEmail.';
  }

  @override
  String get groupCodeIntro =>
      'Seu líder de jovens, pastor ou professor tem um código de grupo? Digite abaixo e ganhe Premium na hora.';

  @override
  String get premiumViaGroup => 'Premium pelo seu grupo';

  @override
  String get yourGroups => 'Seus grupos';

  @override
  String get premiumWholeGroup => 'Premium para o seu grupo inteiro';

  @override
  String get forChurches => 'Para igrejas, escolas e associações';

  @override
  String get groupPerkAll => 'Todo o Premium para cada membro';

  @override
  String get groupPerkCode => 'Um código que você lê em voz alta na sala';

  @override
  String get groupPerkManage => 'Você decide quem participa';

  @override
  String get groupLicenseWebsiteOnly =>
      'A licença de grupo é comprada no site, porque uma compra na App Store fica presa a uma única conta e não a um grupo.';

  @override
  String get openWebsite => 'Abrir biblequizzes.app';

  @override
  String get youManageGroup => 'Você administra este grupo';

  @override
  String get youTakePart => 'Você participa';

  @override
  String get groupCode => 'Código do grupo';

  @override
  String get purchaseReceivedNotActive =>
      'Recebemos sua compra, mas o Premium ainda não está ativo. Toque em \"Restaurar\" daqui a um minuto.';

  @override
  String noPurchaseFound(Object storeName) {
    return 'Não encontramos nenhuma compra Premium nesta conta $storeName.';
  }

  @override
  String purchasePending(Object storeName) {
    return 'Sua compra ainda aguarda aprovação ou pagamento. O Premium liga sozinho quando a $storeName concluir.';
  }

  @override
  String get noInternetRetry =>
      'Sem conexão com a internet. Verifique sua conexão e tente de novo.';

  @override
  String get alreadyPurchased =>
      'Você já comprou isso. Toque em \"Restaurar\" para recuperar.';

  @override
  String get purchaseOtherAccount =>
      'Esta compra já pertence a outra conta do Bible Quizzes. Entre com essa conta para usar seu Premium.';

  @override
  String purchasesNotAllowed(Object store) {
    return 'Compras não são permitidas neste aparelho. Verifique as configurações da sua conta $store.';
  }

  @override
  String subscriptionUnavailable(Object store) {
    return 'Esta assinatura não está disponível na $store agora. Tente mais tarde.';
  }

  @override
  String storeError(Object store) {
    return 'A $store retornou um erro. Tente mais tarde.';
  }

  @override
  String get purchasesNotInVersion =>
      'Compras não estão disponíveis nesta versão do app.';

  @override
  String get restoreFailed => 'Não foi possível restaurar. Tente de novo.';

  @override
  String get introPerkExplain =>
      'Uma explicação em cada pergunta: por que a resposta está certa';

  @override
  String get introPerkAll => 'Todos os quizzes, quantas vezes quiser';

  @override
  String get introPerkReview => 'Uma revisão completa após cada quiz';

  @override
  String get introPerkDaily => 'Um quiz novo todo dia, sem limite';

  @override
  String get introPerkStick => 'Uma explicação em cada pergunta, para fixar';

  @override
  String get introPerkLookBack => 'Reveja suas respostas após cada quiz';

  @override
  String get introPerkTogetherFree => 'Jogar juntos continua grátis para todos';

  @override
  String get introPerkSoloUnlimited => 'Além disso, jogo solo ilimitado';

  @override
  String get introPerkDiscuss =>
      'Uma explicação em cada pergunta para conversar juntos';

  @override
  String stepOfThree(Object page) {
    return 'Etapa $page de 3';
  }

  @override
  String get actionNext => 'Avançar';

  @override
  String get introGrowQuestion => 'Em que você quer crescer?';

  @override
  String get introGrowSubtitle =>
      'Vamos mostrar o que o Premium faz para isso.';

  @override
  String get introGoalKnowledge => 'Mais conhecimento bíblico';

  @override
  String get introGoalKnowledgeBody =>
      'Entender por que uma resposta está certa.';

  @override
  String get introGoalDaily => 'Aprender algo todo dia';

  @override
  String get introGoalDailyBody => 'Criar um hábito e mantê-lo.';

  @override
  String get introGoalGroupBody =>
      'Com a família ou um grupo, uns contra os outros.';

  @override
  String get introYouGet => 'Veja o que você ganha';

  @override
  String get introOneMembership => 'Tudo em uma assinatura, no site e no app.';

  @override
  String get choosePlan => 'Escolha seu plano';

  @override
  String get pricesNextPage =>
      'Na próxima página você vê os preços. Dá para cancelar quando quiser.';

  @override
  String get accountWebAndApp =>
      'Sua conta funciona no site e no app ao mesmo tempo. Uma compra no celular também dá Premium no site, e vice-versa.';

  @override
  String get paywallHeadlineDefault => 'Jogue sem limites\ncom Premium';

  @override
  String paywallHeadlineLimit(Object kFreeQuizLimit) {
    return 'Você jogou seus\n$kFreeQuizLimit quizzes grátis';
  }

  @override
  String get paywallHeadlineTogether => 'Continue jogando juntos\nsem limites';

  @override
  String get paywallHeadlineGroup => 'Jogue com o\nseu grupo inteiro';

  @override
  String get paywallHeadlineExplain => 'Leia o porquê\nde cada pergunta';

  @override
  String get paywallHeadlineUnlock => 'Desbloqueie\ntodos os quizzes';

  @override
  String get premiumRestored => 'Premium restaurado';

  @override
  String get welcomePremium => 'Bem-vindo ao Premium';

  @override
  String get premiumBackOn => 'Seu Premium está ativo de novo nesta conta.';

  @override
  String get premiumFullAccess =>
      'Agora você tem acesso total a todos os recursos Premium, no app e no site. Aproveite!';

  @override
  String get playOnPremium => 'Continue jogando com Premium.';

  @override
  String get chooseSubscription => 'Escolha uma assinatura';

  @override
  String get yearly => 'Anual';

  @override
  String get perYear => 'por ano';

  @override
  String get monthly => 'Mensal';

  @override
  String get perMonth => 'por mês';

  @override
  String get noTrial => 'Sem teste';

  @override
  String get reloadPrices => 'Recarregar preços';

  @override
  String storeUnreachable(Object storeName) {
    return 'A $storeName não está acessível agora. Verifique sua conexão.';
  }

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get terms => 'Termos';

  @override
  String get privacy => 'Privacidade';

  @override
  String get alreadyPremium =>
      'Você já tem Premium nesta conta. Nada foi cobrado.';

  @override
  String get premiumOn => 'Premium está ativo';

  @override
  String get restoreSignIn =>
      'Entre com sua conta e restauraremos suas compras nela.';

  @override
  String get needAccountForPremium =>
      'Primeiro crie uma conta grátis ou entre, assim o Premium fica com você - no app e no site.';

  @override
  String get accountNeeded => 'Conta necessária';

  @override
  String get pleaseWait => 'Aguarde';

  @override
  String get nothingToRestore => 'Nada para restaurar';

  @override
  String get viewAllPlans => 'Ver todos os planos';

  @override
  String get explainEveryAnswer => 'Explicação em cada resposta';

  @override
  String paywallFreeLimit(Object kFreeQuizLimit) {
    return 'De graça você joga $kFreeQuizLimit quizzes. Com Premium todos os livros da Bíblia ficam abertos, inclusive Salmos e Apocalipse.';
  }

  @override
  String get premiumEverythingOpen => 'Tudo liberado com Premium';

  @override
  String get abbrGenesis => 'Gn';

  @override
  String get quizzes12 => '12 quizzes';

  @override
  String get abbrPsalms => 'Sl';

  @override
  String get quizzes15 => '15 quizzes';

  @override
  String get abbrRevelation => 'Ap';

  @override
  String get bookRevelation => 'Apocalipse';

  @override
  String get quizzes9 => '9 quizzes';

  @override
  String get free => 'Grátis';

  @override
  String get orLifetime => 'Ou pagamento único: Premium vitalício';

  @override
  String lifetimeOnce(Object price) {
    return 'Premium vitalício, $price uma vez';
  }

  @override
  String lifetimePerWeek(Object weekly, Object lifetimeHorizonYears) {
    return '$weekly por semana em $lifetimeHorizonYears anos';
  }

  @override
  String get lifetimePremium => 'Premium vitalício';

  @override
  String get payNothingToday => 'Hoje você não paga nada.';

  @override
  String payNothingTodayReminder(Object day) {
    return 'Hoje você não paga nada. Lembrete no dia $day.';
  }

  @override
  String get cancelAnytime => 'Cancele quando quiser.';

  @override
  String get payOnceNoSub => 'Pagamento único, sem assinatura.';

  @override
  String get startPremium => 'Começar Premium';

  @override
  String tryTrial(Object label) {
    return 'Experimente $label';
  }

  @override
  String get badgeFirstStepsDesc => 'Conclua seu primeiro quiz.';

  @override
  String get badgeKnowledgeSeeker => 'Buscador do saber';

  @override
  String get badgeKnowledgeSeekerDesc => 'Jogue 10 quizzes diferentes.';

  @override
  String get badgePerfect => 'Sem erros';

  @override
  String get badgePerfectDesc => 'Tire 100% em um quiz.';

  @override
  String get badgeOnARoll => 'Embalado';

  @override
  String get badgeOnARollDesc => 'Faça uma sequência de 3 dias.';

  @override
  String get badgeDedicated => 'Dedicado';

  @override
  String get badgeDedicatedDesc => 'Jogue 7 dias seguidos.';

  @override
  String get badgeScholar => 'Estudioso';

  @override
  String get badgeMaster => 'Mestre';

  @override
  String get badgeAllRounder => 'Versátil';

  @override
  String get badgeAllRounderDesc => 'Jogue uma grande variedade de quizzes.';

  @override
  String get rankSeeker => 'Buscador';

  @override
  String get saveFailed => 'Não foi possível salvar. Tente de novo.';

  @override
  String get saveFailedConnection =>
      'Não foi possível salvar. Verifique sua conexão.';

  @override
  String get achievements => 'Conquistas';

  @override
  String get achievementsLoadFailed => 'As conquistas não carregaram';

  @override
  String get noBadgesYet =>
      'Ainda sem medalhas. Jogue quizzes para desbloquear a primeira.';

  @override
  String stillToEarn(Object lockedCount) {
    return 'A conquistar · $lockedCount';
  }

  @override
  String badgesEarnedA11y(Object unlocked, Object total) {
    return '$unlocked de $total medalhas conquistadas';
  }

  @override
  String badgesOf(Object unlocked, Object total) {
    return '$unlocked de $total medalhas';
  }

  @override
  String get allEarned => 'Tudo conquistado';

  @override
  String leftToEarn(Object left) {
    return 'Faltam $left';
  }

  @override
  String get profileUpdated => 'Perfil atualizado.';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get profileLoadFailed => 'O perfil não carregou';

  @override
  String get actionSave => 'Salvar';

  @override
  String get surpriseMe => 'Surpreenda-me';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get displayNameHint => 'Como você aparece no ranking';

  @override
  String get displayNameHelp =>
      'Visível no ranking e no multijogador. Pode ser mudado uma vez a cada 30 dias.';

  @override
  String get buildMascot => 'Monte seu mascote';

  @override
  String get figure => 'Figura';

  @override
  String get color => 'Cor';

  @override
  String get background => 'Fundo';

  @override
  String get accessory => 'Acessório';

  @override
  String get notSignedIn => 'Não conectado';

  @override
  String get settings => 'Configurações';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get recentlyPlayed => 'Jogados recentemente';

  @override
  String levelN(Object level) {
    return 'Nível $level';
  }

  @override
  String get maxLevel => 'Nível máximo alcançado';

  @override
  String progressToLevel(Object level) {
    return 'Progresso para o nível $level';
  }

  @override
  String xpToLevel(Object xpRemaining, Object level) {
    return '$xpRemaining XP para o nível $level';
  }

  @override
  String get daysInARow => 'Dias seguidos';

  @override
  String get quizzesPlayed => 'Quizzes jogados';

  @override
  String get averageScore => 'Pontuação média';

  @override
  String viewAllAchievementsA11y(Object unlockedCount, Object overviewCount) {
    return 'Ver todas as conquistas, $unlockedCount de $overviewCount conquistadas';
  }

  @override
  String allOf(Object unlockedCount, Object overviewCount) {
    return 'Todas $unlockedCount de $overviewCount';
  }

  @override
  String get youHavePremium => 'Você tem Premium';

  @override
  String get youPlayFree => 'Você joga grátis';

  @override
  String scoreOfTotal(Object score, Object totalQuestions) {
    return '$score de $totalQuestions certas';
  }

  @override
  String get completed => 'Concluído';

  @override
  String get guestPerkKeep => 'Pontos, nível e sequência que ficam';

  @override
  String get guestPerkLeaderboard => 'Um lugar no ranking';

  @override
  String get guestPerkBadges => 'Medalhas pelas suas conquistas';

  @override
  String get guestPerkWebsite => 'O mesmo progresso em biblequizzes.app';

  @override
  String get saveYourProgress => 'Salve seu progresso';

  @override
  String get guestExplain =>
      'Você está jogando sem conta. Tudo bem, mas sua pontuação, pontos e sequência só ficam salvos com uma conta grátis.';

  @override
  String get createFreeAccount => 'Criar uma conta grátis';

  @override
  String get pendingOne => 'Um quiz está esperando sua conta';

  @override
  String pendingMany(Object pendingCount) {
    return '$pendingCount quizzes estão esperando sua conta';
  }

  @override
  String get withAccount => 'Com uma conta';

  @override
  String get oneQuiz => '1 quiz';

  @override
  String quizzesN(Object total) {
    return '$total quizzes';
  }

  @override
  String playedOf(Object played, Object total) {
    return '$played de $total jogados';
  }

  @override
  String get quizzesLoadFailed => 'Os quizzes não carregaram';

  @override
  String get byBibleBook => 'Por livro da Bíblia';

  @override
  String booksAndQuizzes(Object booksCount, Object quizzes) {
    return '$booksCount livros · $quizzes quizzes';
  }

  @override
  String get bibleBook => 'Livro da Bíblia';

  @override
  String quizzesCountList(Object quizzesCount) {
    return '$quizzesCount quizzes';
  }

  @override
  String playedOfList(Object played, Object quizzesCount) {
    return '$played de $quizzesCount jogados';
  }

  @override
  String get noQuizzesForBook => 'Ainda não há quizzes deste livro.';

  @override
  String allQuizzesAbout(Object name) {
    return 'Todos os quizzes de $name';
  }

  @override
  String get startWith => 'COMECE COM';

  @override
  String get continueWith => 'CONTINUE COM';

  @override
  String get anyLevel => 'Qualquer nível';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Médio';

  @override
  String get hard => 'Difícil';

  @override
  String get results => 'Resultados';

  @override
  String get allQuizzes => 'Todos os quizzes';

  @override
  String get popular => 'Populares';

  @override
  String get allBooks => 'Todos os livros';

  @override
  String get searchHint => 'Busque um livro da Bíblia ou tema';

  @override
  String get clear => 'Limpar';

  @override
  String questionsAndMinutes(Object questionCount, Object questionCount2) {
    return '$questionCount perguntas · $questionCount2 min';
  }

  @override
  String get notPlayedYet => 'Ainda não jogado';

  @override
  String get noQuizzesFilters =>
      'Nenhum quiz encontrado com os filtros atuais.';

  @override
  String get sortBibleOrder => 'Ordem bíblica';

  @override
  String get sortMostPopular => 'Mais populares';

  @override
  String get sortNewest => 'Mais recentes';

  @override
  String get sortShortest => 'Mais curtos';

  @override
  String get sort => 'Ordenar';

  @override
  String get hideText => 'Ocultar texto';

  @override
  String hideTextOf(Object reference) {
    return 'Ocultar o texto de $reference';
  }

  @override
  String get unlockPremiumExplain =>
      'Desbloqueie o Premium para ver a explicação';

  @override
  String get readWhyWrong => 'Leia por que estava errado';

  @override
  String get timeUp => 'Acabou o tempo';

  @override
  String get finishQuiz => 'Concluir quiz';

  @override
  String get a11yYourAnswerRight => ', sua resposta, certa';

  @override
  String get a11yCorrectAnswer => ', a resposta certa';

  @override
  String get a11yYourAnswerWrong => ', sua resposta, errada';

  @override
  String questionOf(Object current, Object total) {
    return 'Pergunta $current de $total';
  }

  @override
  String secondsLeft(Object secondsLeft) {
    return 'Faltam $secondsLeft segundos';
  }

  @override
  String get wellPlayed => 'Bem jogado';

  @override
  String get niceTry => 'Boa tentativa';

  @override
  String get nextQuiz => 'Próximo quiz';

  @override
  String get playWithOthers => 'Jogue com outras pessoas';

  @override
  String get viewAnswers => 'Ver respostas';

  @override
  String scoreA11yShort(Object correct, Object total) {
    return 'Pontuação $correct de $total';
  }

  @override
  String get newBestScore => 'Nova melhor pontuação';

  @override
  String get scoreNotSaved => 'Sua pontuação ainda não foi salva';

  @override
  String get scoreSaving => 'Sua pontuação está sendo salva';

  @override
  String get again => 'De novo';

  @override
  String get noExtraXp => 'Sem XP extra desta vez';

  @override
  String get replayRule => 'Repetir só conta se você melhorar sua pontuação.';

  @override
  String xpToLevelResult(Object xpToNextLevel, Object level) {
    return '$xpToNextLevel XP para o nível $level';
  }

  @override
  String get playTomorrowStreak => 'Jogue amanhã para manter sua sequência';

  @override
  String keepScoreXp(Object previewXp) {
    return 'Salve sua pontuação, $previewXp XP e sua sequência';
  }

  @override
  String get keepScoreBody =>
      'Entre ou crie uma conta grátis e esta pontuação será registrada na hora. Seus quizzes passam a contar para o nível e o ranking.';

  @override
  String get yourAnswers => 'Suas respostas';

  @override
  String get allCorrectReview =>
      'Tudo certo. Veja a explicação de cada pergunta.';

  @override
  String wrongOf(Object wrongCount, Object questionsCount) {
    return '$wrongCount das $questionsCount perguntas erradas.';
  }

  @override
  String get fullExplainPremium =>
      'A explicação completa de cada pergunta faz parte do Premium.';

  @override
  String get unlockFullReview => 'Desbloqueie a revisão completa';

  @override
  String get correct => 'Certa';

  @override
  String get wrong => 'Errada';

  @override
  String correctAnswerIs(Object text) {
    return 'Resposta certa: $text';
  }

  @override
  String get quizLoadFailed => 'O quiz não carregou';

  @override
  String get howToPlay => 'Como você quer jogar?';

  @override
  String get rememberedNext =>
      'Fica salvo para seus próximos quizzes, inclusive no site.';

  @override
  String get freeLeftPrefix => 'Você tem ';

  @override
  String get freeLeftOne => ' quiz grátis';

  @override
  String get freeLeftMany => ' quizzes grátis';

  @override
  String get unlockWithPremium => 'Desbloquear com Premium';

  @override
  String readAndStart(Object label) {
    return 'Leia $label e comece';
  }

  @override
  String get startQuiz => 'Começar quiz';

  @override
  String readFirstLabel(Object label) {
    return 'Leia $label primeiro';
  }

  @override
  String get alreadyPlayed => 'Já jogado';

  @override
  String get playAgainBetter => 'Jogue de novo para melhorar a pontuação';

  @override
  String get yourBestScore => 'Sua melhor pontuação';

  @override
  String lastPlayed(Object last) {
    return 'Jogado pela última vez $last';
  }

  @override
  String get testKnowledge => 'Teste seu conhecimento sobre este tema.';

  @override
  String get aboutQuiz => 'Sobre este quiz';

  @override
  String get finished => 'Concluído';

  @override
  String get readChapterExplain =>
      'Você lê o capítulo deste quiz antes de as perguntas começarem.';

  @override
  String get timePerQuestion => 'Tempo por pergunta';

  @override
  String get timerExplain =>
      'Desligado por padrão. Ative um relógio se quiser um desafio.';

  @override
  String get off => 'Desligado';

  @override
  String get noChapterToRead => 'Nenhum capítulo para ler';

  @override
  String get multiChapter =>
      'Este quiz trata de mais de um capítulo. Você pode começar o quiz direto.';

  @override
  String get chapterFetchFailed =>
      'Não foi possível carregar este capítulo agora. Você pode começar o quiz direto.';

  @override
  String get readFirst => 'Leia primeiro';

  @override
  String readBeforeQuiz(Object title) {
    return 'Leia antes do quiz $title';
  }

  @override
  String get bibleVersionName => 'Bíblia Livre';

  @override
  String get keepStreakQuestion => 'Manter sua sequência?';

  @override
  String keepStreakBody(Object streak) {
    return 'Você jogou $streak dias seguidos. Quer um aviso às 19h nos dias em que ainda não jogou?';
  }

  @override
  String get noQuestionsYet => 'Ainda sem perguntas';

  @override
  String get quizNoQuestions => 'Este quiz ainda não tem perguntas.';

  @override
  String get goBack => 'Voltar';

  @override
  String get today => 'hoje';

  @override
  String get yesterday => 'ontem';

  @override
  String daysAgo(Object days) {
    return 'há $days dias';
  }

  @override
  String onDate(Object date) {
    return 'em $date';
  }

  @override
  String get mpQuotaFailed => 'Não foi possível carregar sua cota de partidas.';

  @override
  String get mpCreateFailed => 'Não foi possível criar uma sala.';

  @override
  String mpJoinFailed(Object code) {
    return 'Não foi possível entrar na sala $code.';
  }

  @override
  String mpLoadFailed(Object code) {
    return 'Não foi possível carregar a sala $code.';
  }

  @override
  String get mpStartFailed => 'Não foi possível começar o quiz.';

  @override
  String get mpNextFailed => 'Não foi possível ir para a próxima pergunta.';

  @override
  String get mpAnswerFailed => 'Não foi possível enviar sua resposta.';

  @override
  String get mpResultsFailed => 'Não foi possível carregar os resultados.';

  @override
  String get unexpectedServerResponse => 'Resposta inesperada do servidor.';

  @override
  String get roomNotFoundDot => 'Sala não encontrada.';

  @override
  String get playTogether => 'Jogar juntos';

  @override
  String get backToPlayTogether => 'Voltar para Jogar juntos';

  @override
  String get stopQuiz => 'Parar quiz';

  @override
  String get leaveGame => 'Sair do jogo';

  @override
  String get multiplayerQuiz => 'Quiz multijogador';

  @override
  String roomCodeLabel(Object code) {
    return 'Sala $code';
  }

  @override
  String get waitingNextQuestion => 'Aguardando a próxima pergunta…';

  @override
  String get nextIn => 'Próxima em ';

  @override
  String correctOfPlayers(Object correctCount, Object playersCount) {
    return '$correctCount de $playersCount acertaram';
  }

  @override
  String get standings => 'Classificação';

  @override
  String get stopQuizQuestion => 'Parar o quiz?';

  @override
  String get stopQuizBody =>
      'Quer parar este quiz multijogador para todos os jogadores?';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get stopQuizAction => 'Parar';

  @override
  String get leaveGameQuestion => 'Sair do jogo?';

  @override
  String get leaveGameBody =>
      'Sua pontuação fica salva se você voltar por Jogar juntos.';

  @override
  String get stay => 'Ficar';

  @override
  String get leaveGameAction => 'Sair';

  @override
  String questionNumberOf(Object number, Object total) {
    return 'Pergunta $number de $total';
  }

  @override
  String secondsRemaining(Object seconds) {
    return 'Faltam $seconds segundos';
  }

  @override
  String nextQuestionIn(Object seconds) {
    return 'Próxima pergunta em $seconds segundos';
  }

  @override
  String get a11yYourAnswer => ', sua resposta';

  @override
  String get a11yRightAnswer => ', resposta certa';

  @override
  String get a11yWrongShort => ', errada';

  @override
  String a11yChosenTimes(Object count) {
    return ', escolhida $count vezes';
  }

  @override
  String get noAnswerLower => 'sem resposta';

  @override
  String get stillThinking => 'pensando';

  @override
  String get noAnswer => 'Sem resposta';

  @override
  String get rightExclaim => 'Certo!';

  @override
  String get tooBad => 'Que pena';

  @override
  String get correctMarkedGreen => 'A resposta certa está marcada em verde.';

  @override
  String get yourAnswerCorrect => 'Sua resposta está certa.';

  @override
  String get yourChoiceMarked =>
      'Sua escolha está marcada ao lado da resposta certa.';

  @override
  String pointsGained(Object gained) {
    return '+$gained pontos';
  }

  @override
  String get nextQuestion => 'Próxima pergunta';

  @override
  String get hostMovingOn =>
      'O anfitrião vai para a próxima pergunta em breve.';

  @override
  String get submitted => 'Enviado';

  @override
  String get waitingOtherPlayers => 'Aguardando os outros jogadores…';

  @override
  String get hostSetsPace =>
      'Você define o ritmo. Mostre as respostas quando todos terminarem.';

  @override
  String get showAnswers => 'Mostrar respostas';

  @override
  String get startQuestions => 'Começar as perguntas';

  @override
  String get waitHostQuestions => 'Espere o anfitrião começar as perguntas.';

  @override
  String get waitingHostQuestions =>
      'Aguardando o anfitrião começar as perguntas…';

  @override
  String readBeforeQuizMp(Object quizTitle) {
    return 'Leia antes do quiz $quizTitle';
  }

  @override
  String get readChapterCalmly =>
      'Leia este capítulo com calma. As perguntas são sobre ele, então ler ajuda de verdade.';

  @override
  String get chapterNotLoaded => 'O capítulo não carregou';

  @override
  String get chapterFetchFailedHost =>
      'Não foi possível carregar este capítulo agora. O anfitrião pode começar as perguntas direto.';

  @override
  String get lobby => 'Sala de espera';

  @override
  String get closeRoom => 'Fechar sala';

  @override
  String get leaveRoom => 'Sair da sala';

  @override
  String get closeRoomQuestion => 'Fechar a sala?';

  @override
  String get leaveRoomQuestion => 'Sair da sala?';

  @override
  String get closeRoomBody =>
      'Se você for o único, a sala fecha. Se já houver jogadores, outra pessoa vira anfitrião.';

  @override
  String get rejoinLater => 'Você pode voltar depois com o mesmo código.';

  @override
  String get closeRoomAction => 'Fechar sala';

  @override
  String get leaveRoomAction => 'Sair';

  @override
  String get freeGamesUsed => 'Suas partidas grátis acabaram';

  @override
  String get premiumHostUnlimited =>
      'Com Premium você cria partidas ilimitadas, com até 20 jogadores ao mesmo tempo. Seu grupo continua esperando na sala.';

  @override
  String get newRoomCode => 'Você vai receber um novo código de sala.';

  @override
  String get startWhenEveryone => 'Comece o quiz quando todos chegarem.';

  @override
  String get hostStartsWhenEveryone =>
      'O anfitrião começa o quiz quando todos chegarem.';

  @override
  String get roomCodeCopied => 'Código da sala copiado.';

  @override
  String get change => 'Mudar';

  @override
  String get players => 'Jogadores';

  @override
  String playersOfMax(Object playersCount, Object maxPlayers) {
    return '$playersCount de $maxPlayers';
  }

  @override
  String get startTheQuiz => 'Começar o quiz';

  @override
  String get oneQuestion => '1 pergunta';

  @override
  String totalQuestionsN(Object totalQuestions) {
    return '$totalQuestions perguntas';
  }

  @override
  String secondsPerQuestion(Object questionTimerSeconds) {
    return '${questionTimerSeconds}s por pergunta';
  }

  @override
  String get hostSetsPaceShort => 'O anfitrião define o ritmo';

  @override
  String get readFirstShort => 'Ler primeiro';

  @override
  String get joinMyQuizShareTitle => 'Entre no meu jogo do Bible Quizzes';

  @override
  String get playersEnterCode =>
      'Os jogadores digitam este código em Jogar juntos';

  @override
  String get shareCode => 'Compartilhar código';

  @override
  String get copyCode => 'Copiar código';

  @override
  String get newPlayersAppear => 'Novos jogadores aparecem aqui sozinhos.';

  @override
  String get waitHostQuiz => 'Espere o anfitrião começar o quiz.';

  @override
  String get quizCompleted => 'Quiz concluído';

  @override
  String get finalStandings => 'Classificação final';

  @override
  String winnerWith(Object winner, Object score) {
    return 'Vencedor: $winner com $score pontos';
  }

  @override
  String get backHome => 'Voltar ao início';

  @override
  String get startNewRoom => 'Criar uma nova sala';

  @override
  String groupSaved(Object savedGroupName) {
    return '\"$savedGroupName\" foi salvo.';
  }

  @override
  String get groupStandingsOnLeaderboard =>
      'Você encontra a classificação deste grupo no ranking.';

  @override
  String get saveGroupQuestion => 'Salvar este grupo?';

  @override
  String saveGroupBody(Object playersCount) {
    return 'Assim você mantém seu próprio ranking com estes $playersCount jogadores e os convida de novo com um toque.';
  }

  @override
  String get saveGroup => 'Salvar grupo';

  @override
  String placeNamePoints(Object place, Object name, Object score) {
    return '$place. $name, $score pontos';
  }

  @override
  String pointsN(Object score) {
    return '$score pontos';
  }

  @override
  String correctOfTotal(Object correctAnswers, Object totalQuestions) {
    return '$correctAnswers de $totalQuestions certas';
  }

  @override
  String correctN(Object correctAnswers) {
    return '$correctAnswers certas';
  }

  @override
  String get roomReconnecting =>
      'Sala indisponível no momento. Reconectando...';

  @override
  String get roomClosedFinal =>
      'A sala foi fechada. Esta é a classificação final.';

  @override
  String get roomGone =>
      'Esta sala não existe mais. Volte e crie uma nova sala.';

  @override
  String get createRoom => 'Criar sala';

  @override
  String get createRoomInvite => 'Criar sala e convidar';

  @override
  String thenInviteGroup(Object name) {
    return 'Depois convidamos $name.';
  }

  @override
  String get selectQuizFirst => 'Primeiro escolha um quiz.';

  @override
  String get enterRoomCode => 'Digite um código de sala.';

  @override
  String get roomCodeTooShort => 'O código parece curto demais. Confira.';

  @override
  String pickQuizThenInvite(Object name) {
    return 'Escolha um quiz primeiro e depois convidamos $name.';
  }

  @override
  String get yourGroupsShort => 'Seus grupos';

  @override
  String get pickQuizInviteGroup =>
      'Escolha um quiz e envie ao seu grupo um novo convite com um toque.';

  @override
  String get signInToPlayTogether => 'Entre para jogar juntos';

  @override
  String get playTogetherNeedsAccount =>
      'Criar ou entrar em uma sala funciona com uma conta grátis, para seu nome e pontuação ficarem certos.';

  @override
  String get playTogetherIntro =>
      'Com a família, os amigos ou o grupo de jovens: todos jogam o mesmo quiz ao mesmo tempo, cada um no seu celular.';

  @override
  String upToPlayers(Object maxPlayers) {
    return 'Até $maxPlayers jogadores por sala';
  }

  @override
  String get youAreHost => 'Você é o anfitrião';

  @override
  String premiumHostRooms(Object maxPlayersPremium) {
    return 'Com Premium você cria salas ilimitadas, até $maxPlayersPremium jogadores ao mesmo tempo. Entrar com um código é sempre grátis.';
  }

  @override
  String get viewPremium => 'Ver Premium';

  @override
  String get hostSteps =>
      'Escolha um quiz, compartilhe o código com seu grupo e comece quando todos chegarem.';

  @override
  String get pickQuiz => 'Escolha um quiz';

  @override
  String get gameThisMonth => 'Sua partida deste mês';

  @override
  String get lastFreeGame => 'Última partida grátis';

  @override
  String freeGamesLeftN(Object remaining) {
    return 'Restam $remaining partidas grátis';
  }

  @override
  String get freeGameMonthly =>
      'Esta é sua partida grátis do mês. No mês que vem você ganha outra. Com Premium você cria quantas quiser.';

  @override
  String get lastFreeGameBody =>
      'Esta é sua última partida grátis como anfitrião. Depois você ganha uma por mês. Entrar no jogo de outra pessoa continua grátis.';

  @override
  String freeGamesLeftBody(Object remaining) {
    return 'Você tem $remaining partidas grátis para criar. Uma partida só conta quando você realmente começa.';
  }

  @override
  String get joinWithCode => 'Entrar com código';

  @override
  String get hostShares6 => 'O anfitrião compartilha um código de 6 caracteres';

  @override
  String get join => 'Entrar';

  @override
  String roomCodeA11y(Object length) {
    return 'Código da sala, $length caracteres';
  }

  @override
  String get lobbyStillOpen => 'Sua sala de espera ainda está aberta';

  @override
  String get lastGameOver => 'Sua última partida terminou';

  @override
  String get gameStillRunning => 'Sua partida ainda está rolando';

  @override
  String resumeA11y(Object label, Object quizTitle, Object code) {
    return '$label. $quizTitle, sala $code. Continuar';
  }

  @override
  String quizRoom(Object quizTitle, Object code) {
    return '$quizTitle - sala $code';
  }

  @override
  String get invite => 'Convidar';

  @override
  String get pickOtherQuiz => 'Escolher outro quiz';

  @override
  String get setUpRoom => 'Configurar sala';

  @override
  String get noQuizzesForRoom => 'Nenhum quiz encontrado para criar uma sala.';

  @override
  String get cantLoadQuizzes => 'Não é possível carregar os quizzes';

  @override
  String get numberOfPlayers => 'Número de jogadores';

  @override
  String maxN(Object maxPlayers) {
    return 'Máx. $maxPlayers';
  }

  @override
  String countPlayersPremium(Object count) {
    return '$count jogadores, Premium';
  }

  @override
  String hostCanInvite(Object maxPlayersPremium) {
    return 'Você é o anfitrião e pode convidar até $maxPlayersPremium jogadores.';
  }

  @override
  String freeUpToPlayers(Object maxPlayersFree) {
    return 'Grátis até $maxPlayersFree jogadores. Uma partida grátis só conta quando você começa.';
  }

  @override
  String maxPlayersNeedsPremium(Object maxPlayers, Object maxPlayersFree) {
    return '$maxPlayers jogadores exige Premium. De graça você joga com até $maxPlayersFree.';
  }

  @override
  String freeGamesLeftHost(Object freeGamesLeft) {
    return 'Você tem $freeGamesLeft partidas grátis para criar.';
  }

  @override
  String get readChapterFirst => 'Ler o capítulo primeiro';

  @override
  String get onlySingleChapter => 'Só funciona com quizzes de 1 capítulo.';

  @override
  String get pacePerQuestion => 'Ritmo por pergunta';

  @override
  String get youAdvance =>
      'Você mesmo avança para as respostas e a próxima pergunta.';

  @override
  String everyoneGetsSeconds(Object tempo) {
    return 'Todos têm $tempo segundos por pergunta.';
  }

  @override
  String get hostDecides => 'O anfitrião decide';

  @override
  String secondsPerQuestionLong(Object i) {
    return '$i segundos por pergunta';
  }
}
