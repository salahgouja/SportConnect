// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navRides => 'Trajets';

  @override
  String get navChat => 'Messages';

  @override
  String get navProfile => 'Profil';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPushNotifications => 'Notifications Push';

  @override
  String get settingsPushNotificationsDesc =>
      'Recevoir des notifications push pour les mises à jour importantes';

  @override
  String get settingsRideReminders => 'Rappels de trajet';

  @override
  String get settingsRideRemindersDesc => 'Être rappelé des trajets à venir';

  @override
  String get settingsChatMessages => 'Messages de discussion';

  @override
  String get settingsChatMessagesDesc =>
      'Notifications pour les nouveaux messages';

  @override
  String get settingsMarketingTips => 'Marketing et conseils';

  @override
  String get settingsMarketingTipsDesc =>
      'Recevoir des conseils et des offres promotionnelles';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsDarkMode => 'Mode sombre';

  @override
  String get settingsDarkModeDesc => 'Passer au thème sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageDesc => 'Langue d\'affichage de l\'application';

  @override
  String get settingsDistanceUnit => 'Unité de distance';

  @override
  String get settingsDistanceUnitDesc => 'Unité de mesure de distance préférée';

  @override
  String get settingsPrivacySafety => 'Confidentialité et sécurité';

  @override
  String get settingsPublicProfile => 'Profil public';

  @override
  String get settingsPublicProfileDesc =>
      'Permettre aux autres de voir votre profil';

  @override
  String get settingsShowLocation => 'Afficher la localisation';

  @override
  String get settingsShowLocationDesc =>
      'Partager votre position en temps réel pendant les trajets';

  @override
  String get settingsAutoAcceptRides => 'Acceptation automatique des trajets';

  @override
  String get settingsAutoAcceptRidesDesc =>
      'Accepter automatiquement les demandes de trajet';

  @override
  String get settingsBlockedUsers => 'Utilisateurs bloqués';

  @override
  String get settingsBlockedUsersDesc => 'Gérer les utilisateurs bloqués';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsEditProfile => 'Modifier le profil';

  @override
  String get settingsEditProfileDesc =>
      'Mettre à jour vos informations de profil';

  @override
  String get settingsPaymentMethods => 'Moyens de paiement';

  @override
  String get settingsPaymentMethodsDesc => 'Gérer vos options de paiement';

  @override
  String get settingsVerifyAccount => 'Vérifier le compte';

  @override
  String get settingsVerifyAccountDesc =>
      'Compléter la vérification d\'identité';

  @override
  String get settingsSupport => 'Support et juridique';

  @override
  String get settingsHelpCenter => 'Centre d\'aide';

  @override
  String get settingsHelpCenterDesc => 'Obtenir de l\'aide et du support';

  @override
  String get settingsReportProblem => 'Signaler un problème';

  @override
  String get settingsReportProblemDesc => 'Signaler des bugs ou des problèmes';

  @override
  String get settingsTermsConditions => 'Conditions générales';

  @override
  String get settingsPrivacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get settingsAboutDesc => 'Version de l\'application et informations';

  @override
  String get settingsDangerZone => 'Zone dangereuse';

  @override
  String get settingsLogout => 'Se déconnecter';

  @override
  String get settingsLogoutDesc => 'Se déconnecter de votre compte';

  @override
  String get settingsDeleteAccount => 'Supprimer le compte';

  @override
  String get settingsDeleteAccountDesc =>
      'Supprimer définitivement votre compte et vos données';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authSignUp => 'S\'inscrire';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authResetPassword => 'Réinitialiser le mot de passe';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authContinueWithApple => 'Continuer avec Apple';

  @override
  String get actionSave => 'Enregistrer';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionDelete => 'Supprimer';

  @override
  String get actionEdit => 'Modifier';

  @override
  String get actionConfirm => 'Confirmer';

  @override
  String get actionSearch => 'Rechercher';

  @override
  String get actionFilter => 'Filtrer';

  @override
  String get actionApply => 'Appliquer';

  @override
  String get actionClose => 'Fermer';

  @override
  String get actionDone => 'Terminé';

  @override
  String get errorNetwork =>
      'Erreur réseau. Veuillez vérifier votre connexion.';

  @override
  String get errorInvalidInput =>
      'Entrée invalide. Veuillez vérifier votre saisie.';

  @override
  String get errorPermissionDenied => 'Permission refusée.';

  @override
  String get errorUnexpected => 'Une erreur inattendue s\'est produite.';

  @override
  String get errorTimeout => 'La demande a expiré. Veuillez réessayer.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get pageNotFound => 'Page non trouvée';

  @override
  String get goHome => 'Retour à l\'accueil';

  @override
  String stepValueOfValue(Object value1, Object value2) {
    return 'Étape $value1 sur $value2';
  }

  @override
  String get skipTour => 'Ignorer la visite';

  @override
  String get logs => 'Journaux';

  @override
  String get theme => 'Thème';

  @override
  String get themePlayground => 'Terrain de jeu des thèmes';

  @override
  String get colorScheme => 'Schéma de couleurs';

  @override
  String surfaceBlendValue(Object value) {
    return 'Mélange de surface : $value%';
  }

  @override
  String get useMaterial3 => 'Utiliser Material 3';

  @override
  String get componentPreview => 'Aperçu des composants';

  @override
  String get elevated => 'Élevé';

  @override
  String get filled => 'Rempli';

  @override
  String get outlined => 'Contouré';

  @override
  String get text => 'Texte';

  @override
  String get textField => 'Champ de texte';

  @override
  String get enterText => 'Entrer du texte...';

  @override
  String get cardTitle => 'Titre de la carte';

  @override
  String get cardSubtitleWithDescription =>
      'Sous-titre de la carte avec description';

  @override
  String get chip1 => 'Puce 1';

  @override
  String get action => 'Action';

  @override
  String get colorPalette => 'Palette de couleurs';

  @override
  String get primary => 'Primaire';

  @override
  String get secondary => 'Secondaire';

  @override
  String get surface => 'Surface';

  @override
  String get background => 'Arrière-plan';

  @override
  String get error => 'Erreur';

  @override
  String get copyThemeCode => 'Copier le code du thème';

  @override
  String get applyTheme => 'Appliquer le thème';

  @override
  String get themeCodeCopiedToLogs => 'Code du thème copié dans les journaux !';

  @override
  String themeValueApplied(Object value) {
    return 'Thème \"$value\" appliqué !';
  }

  @override
  String lvlValue(Object value) {
    return 'NIV $value';
  }

  @override
  String valueValueXp(Object value1, Object value2) {
    return '$value1 / $value2 XP';
  }

  @override
  String value(Object value) {
    return '$value%';
  }

  @override
  String value2(Object value) {
    return '$value';
  }

  @override
  String get dayStreak => 'Série de jours';

  @override
  String value3(Object value) {
    return '#$value';
  }

  @override
  String get you => 'Vous';

  @override
  String valueXp(Object value) {
    return '+$value XP';
  }

  @override
  String valueValue(Object value1, Object value2) {
    return '$value1/$value2';
  }

  @override
  String get standard => 'standard';

  @override
  String get standard2 => 'Standard';

  @override
  String get terrain => 'terrain';

  @override
  String get terrain2 => 'Terrain';

  @override
  String get dark => 'sombre';

  @override
  String get light => 'clair';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get humanitarian => 'humanitaire';

  @override
  String get humanitarian2 => 'Humanitaire';

  @override
  String get searchAddressCityOrPlace =>
      'Rechercher une adresse, une ville ou un lieu...';

  @override
  String get popularCities => 'Villes populaires';

  @override
  String get selectedLocation => 'Emplacement sélectionné';

  @override
  String get confirmLocation => 'Confirmer l\'emplacement';

  @override
  String get nearbyPlaces => 'Lieux à proximité';

  @override
  String get findUsefulSpotsAlongYour =>
      'Trouvez des endroits utiles le long de votre trajet';

  @override
  String get searchRadius => 'Rayon de recherche';

  @override
  String get selectACategoryToSearch =>
      'Sélectionnez une catégorie pour rechercher';

  @override
  String get tapOnAnyCategoryAbove =>
      'Appuyez sur n\'importe quelle catégorie ci-dessus pour trouver des lieux à proximité';

  @override
  String get noResultsFound => 'Aucun résultat trouvé';

  @override
  String get tryIncreasingTheSearchRadius =>
      'Essayez d\'augmenter le rayon de recherche';

  @override
  String lvValue(Object value) {
    return 'Niv.$value';
  }

  @override
  String value4(Object value) {
    return '+$value';
  }

  @override
  String get text99 => '99+';

  @override
  String get text9 => '9+';

  @override
  String valueRidesValue(Object value1, Object value2) {
    return '$value1 trajets • $value2';
  }

  @override
  String value5(Object value) {
    return '$value €';
  }

  @override
  String valueSeatsLeft(Object value) {
    return '$value places restantes';
  }

  @override
  String get fullyBooked => 'Complet';

  @override
  String get bookNow => 'Réserver maintenant';

  @override
  String valueSeats(Object value) {
    return '$value places';
  }

  @override
  String errorSavingVehicleValue(Object value) {
    return 'Erreur lors de l\'enregistrement du véhicule : $value';
  }

  @override
  String get driverSetup => 'Configuration du conducteur';

  @override
  String get vehicle => 'Véhicule';

  @override
  String get payouts => 'Paiements';

  @override
  String get addYourVehicle => 'Ajoutez votre véhicule';

  @override
  String get fuelType => 'Type de carburant';

  @override
  String get setupPayouts => 'Configurer les paiements';

  @override
  String get securePayments => 'Paiements sécurisés';

  @override
  String get fastTransfers => 'Transferts rapides';

  @override
  String get easyTracking => 'Suivi facile';

  @override
  String get skipForNowILl =>
      'Ignorer pour l\'instant, je le configurerai plus tard';

  @override
  String get youCanStillOfferRides =>
      'Vous pouvez toujours offrir des trajets sans configurer les paiements, mais vous ne pourrez pas recevoir de paiements tant que vous n\'aurez pas terminé cette étape.';

  @override
  String get sportconnect => 'SportConnect';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get signInToContinueYour =>
      'Connectez-vous pour continuer votre parcours de course';

  @override
  String get rememberMe => 'Se souvenir de moi';

  @override
  String get donTHaveAnAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get enterYourEmailAddressAnd =>
      'Entrez votre adresse e-mail et nous vous enverrons des instructions pour réinitialiser votre mot de passe.';

  @override
  String get passwordResetEmailSentCheck =>
      'E-mail de réinitialisation du mot de passe envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get pleaseAgreeToTheTerms =>
      'Veuillez accepter les conditions d\'utilisation';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get joinOurCommunityOfEco =>
      'Rejoignez notre communauté de covoitureurs écologiques';

  @override
  String get welcomeBonus => 'Bonus de bienvenue';

  @override
  String get get100XpWhenYou =>
      'Obtenez 100 XP lorsque vous complétez votre profil !';

  @override
  String get iWantTo => 'Je veux :';

  @override
  String get alreadyHaveAnAccount => 'Vous avez déjà un compte ? ';

  @override
  String get findRides => 'Trouver des trajets';

  @override
  String get offerRides => 'Offrir des trajets';

  @override
  String get pleaseSelectARoleTo =>
      'Veuillez sélectionner un rôle pour continuer';

  @override
  String errorValue(Object value) {
    return 'Erreur : $value';
  }

  @override
  String get iMARider => 'Je suis un passager';

  @override
  String get iMADriver => 'Je suis un conducteur';

  @override
  String get youCanChangeYourRole =>
      'Vous pouvez changer votre rôle plus tard dans les paramètres';

  @override
  String get howWillYouUseSportconnect =>
      'Comment utiliserez-vous SportConnect ?';

  @override
  String get chooseYourRoleToGet =>
      'Choisissez votre rôle pour commencer.\nCela personnalisera votre expérience.';

  @override
  String get text2 => '🎉';

  @override
  String get join10000EcoRiders => 'Rejoignez plus de 10 000 éco-covoitureurs';

  @override
  String get get100XpWelcomeBonus => 'Obtenez 100 XP de bonus de bienvenue !';

  @override
  String get orSignUpWith => 'Ou inscrivez-vous avec';

  @override
  String get strongPasswordTips => 'Conseils pour un mot de passe fort';

  @override
  String get use8CharactersWithLetters =>
      'Utilisez 8+ caractères avec lettres, chiffres et symboles';

  @override
  String get passwordStrength => 'Force du mot de passe';

  @override
  String get yourInterestsOptional => 'Vos intérêts (Optionnel)';

  @override
  String get selectSportsYouReInterested =>
      'Sélectionnez les sports qui vous intéressent';

  @override
  String get addAProfilePhoto => 'Ajouter une photo de profil';

  @override
  String get thisHelpsOthersRecognizeYou =>
      'Cela aide les autres à vous reconnaître';

  @override
  String get readyToJoin => 'Prêt à rejoindre !';

  @override
  String emailValue(Object value) {
    return 'E-mail : $value';
  }

  @override
  String roleValue(Object value) {
    return 'Rôle : $value';
  }

  @override
  String get carpoolingForRunners => 'COVOITURAGE POUR COUREURS';

  @override
  String get shareRidesRunTogetherGo =>
      'Partagez des trajets. Courez ensemble.\nAllez plus loin.';

  @override
  String get loading => 'Chargement...';

  @override
  String get offerRide => 'Offrir un trajet';

  @override
  String get driver => 'Conducteur';

  @override
  String get online => 'En ligne';

  @override
  String get offline => 'Hors ligne';

  @override
  String get acceptingRideRequests => 'Acceptation des demandes de trajet';

  @override
  String get tapToGoOnlineAnd =>
      'Appuyez pour passer en ligne et commencer à gagner';

  @override
  String get failedToLoadStatus => 'Échec du chargement du statut';

  @override
  String get todaySEarnings => 'Gains d\'aujourd\'hui';

  @override
  String get live => 'En direct';

  @override
  String value6(Object value) {
    return '$value€';
  }

  @override
  String valueRides(Object value) {
    return '$value trajets';
  }

  @override
  String get failedToLoadEarnings => 'Échec du chargement des gains';

  @override
  String get rideRequests => 'Demandes de trajet';

  @override
  String get viewAll => 'Voir tout';

  @override
  String get noPendingRequests => 'Aucune demande en attente';

  @override
  String get failedToLoadRequests => 'Échec du chargement des demandes';

  @override
  String get noAcceptedRequestsYet => 'Aucune demande acceptée';

  @override
  String get acceptedRequestsWillAppearHere =>
      'Les demandes de trajet acceptées apparaîtront ici';

  @override
  String get upcomingRides => 'Trajets à venir';

  @override
  String get noUpcomingRides => 'Aucun trajet à venir';

  @override
  String get failedToLoadRides => 'Échec du chargement des trajets';

  @override
  String get kNew => 'Nouveau';

  @override
  String valueSeatValue(Object value1, Object value2) {
    return '$value1 place$value2';
  }

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String valueValue2(Object value1, Object value2) {
    return '$value1 → $value2';
  }

  @override
  String get earned => 'gagné';

  @override
  String get gettingLocation => 'Obtention de la localisation...';

  @override
  String get loadingRoute => 'Chargement de l\'itinéraire...';

  @override
  String valueKm(Object value) {
    return '$value km';
  }

  @override
  String get rides => 'trajets';

  @override
  String get seats => 'places';

  @override
  String get whereAreYouGoing => 'Où allez-vous ?';

  @override
  String get hotspots => 'Points chauds';

  @override
  String get nearbyRides => 'Trajets à proximité';

  @override
  String get followLocation => 'Suivre la position';

  @override
  String valueMin(Object value) {
    return '$value min';
  }

  @override
  String get mapStyle => 'Style de carte';

  @override
  String get dark2 => 'Sombre';

  @override
  String get findARide => 'Trouver un trajet';

  @override
  String get filters => 'Filtres';

  @override
  String get fromWhere => 'D\'où ?';

  @override
  String get toWhere => 'Pour où ?';

  @override
  String valueAvailable(Object value) {
    return '$value disponible';
  }

  @override
  String get noRidesAvailableNearby => 'Aucun trajet disponible à proximité';

  @override
  String get tryExpandingYourSearchRadius =>
      'Essayez d\'élargir votre rayon de recherche';

  @override
  String get pickupPoint => 'Point de ramassage';

  @override
  String get destination => 'Destination';

  @override
  String get eco => 'Éco';

  @override
  String get premium => 'Premium';

  @override
  String get pickupLocation => 'Lieu de ramassage';

  @override
  String get bookThisRide => 'Réserver ce trajet';

  @override
  String get ride => 'trajet';

  @override
  String get seat => 'place';

  @override
  String get sendingImage => 'Envoi de l\'image...';

  @override
  String failedToSendImageValue(Object value) {
    return 'Échec de l\'envoi de l\'image : $value';
  }

  @override
  String failedToStartCallValue(Object value) {
    return 'Échec du démarrage de l\'appel : $value';
  }

  @override
  String get viewProfile => 'Voir le profil';

  @override
  String get searchInChat => 'Rechercher dans le chat';

  @override
  String get muteNotifications => 'Couper les not ifications';

  @override
  String get clearChat => 'Effacer le chat';

  @override
  String get notificationsMutedForThisChat =>
      'Notifications coupées pour ce chat';

  @override
  String get areYouSureYouWant =>
      'Êtes-vous sûr de vouloir supprimer tous les messages ? Cette action ne peut pas être annulée.';

  @override
  String get chatCleared => 'Chat effacé';

  @override
  String get clear => 'Effacer';

  @override
  String get noMessagesYet => 'Aucun message pour le moment';

  @override
  String get sendAMessageToStart =>
      'Envoyez un message pour lancer la conversation';

  @override
  String get typing => 'en train d\'écrire...';

  @override
  String replyingToValue(Object value) {
    return 'Répondre à $value';
  }

  @override
  String get tapToOpenMap => 'Appuyez pour ouvrir la carte';

  @override
  String get open => 'Ouvrir';

  @override
  String get thisMessageWasDeleted => 'Ce message a été supprimé';

  @override
  String get edited => 'modifié';

  @override
  String get reply => 'Répondre';

  @override
  String get copy => 'Copier';

  @override
  String get messageCopied => 'Message copié';

  @override
  String get editMessage => 'Modifier le message';

  @override
  String get typeAMessage => 'Tapez un message...';

  @override
  String get camera => 'Caméra';

  @override
  String get gallery => 'Galerie';

  @override
  String get document => 'Document';

  @override
  String get location => 'Emplacement';

  @override
  String get gettingYourLocation => 'Obtention de votre position...';

  @override
  String get locationShared => 'Emplacement partagé';

  @override
  String get coordinatesCopiedToClipboard =>
      'Coordonnées copiées dans le presse-papiers';

  @override
  String couldNotOpenMapsValue(Object value) {
    return 'Impossible d\'ouvrir les cartes : $value';
  }

  @override
  String get recordingReleaseToSend =>
      'Enregistrement... Relâchez pour envoyer';

  @override
  String get voiceNote => 'Note vocale';

  @override
  String get voiceNotesComingSoonUse =>
      'Notes vocales bientôt disponibles ! Utilisez le texte pour le moment.';

  @override
  String get recordingCancelled => 'Enregistrement annulé';

  @override
  String get messages => 'Messages';

  @override
  String get pleaseLoginToViewChats =>
      'Veuillez vous connecter pour voir les chats';

  @override
  String get failedToLoadChats => 'Échec du chargement des chats';

  @override
  String get retry => 'Réessayer';

  @override
  String get noConversationsYet => 'Aucune conversation pour le moment';

  @override
  String get noGroupChats => 'Aucun chat de groupe';

  @override
  String get noRideChats => 'Aucun chat de trajet';

  @override
  String get callHistory => 'Historique des appels';

  @override
  String get noCallHistory => 'Aucun historique d\'appels';

  @override
  String get videoCall => 'Video call';

  @override
  String get voiceCall => 'Voice call';

  @override
  String get text3 => ' • ';

  @override
  String get newMessage => 'Nouveau message';

  @override
  String get searchUsersByName => 'Rechercher des utilisateurs par nom...';

  @override
  String get searchForAUserTo =>
      'Rechercher un utilisateur pour commencer à discuter';

  @override
  String get typeAtLeast2Characters => 'Tapez au moins 2 caractères';

  @override
  String noUsersFoundForValue(Object value) {
    return 'Aucun utilisateur trouvé pour \"$value\"';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Toutes les notifications marquées comme lues';

  @override
  String get clearAllNotifications => 'Effacer toutes les notifications';

  @override
  String get areYouSureYouWant2 =>
      'Êtes-vous sûr de vouloir effacer toutes les notifications ?';

  @override
  String get allNotificationsCleared => 'Toutes les notifications effacées';

  @override
  String get failedToClearNotifications =>
      'Échec de l\'effacement des notifications';

  @override
  String get clearAll => 'Tout effacer';

  @override
  String get pleaseSignInToView =>
      'Veuillez vous connecter pour voir les notifications';

  @override
  String get unread => 'Non lus';

  @override
  String valueNew(Object value) {
    return '$value nouveau';
  }

  @override
  String get markAllAsRead => 'Tout marquer comme lu';

  @override
  String get clearAll2 => 'Tout effacer';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get youReAllCaughtUp => 'Vous êtes à jour !';

  @override
  String couldNotOpenChatValue(Object value) {
    return 'Impossible d\'ouvrir le chat : $value';
  }

  @override
  String get youReReadyToRun => 'Vous êtes prêt à courir';

  @override
  String get createAnAccountToStart =>
      'Créez un compte pour commencer à suivre vos courses et vous connecter avec d\'autres coureurs.';

  @override
  String get kContinue => 'Continuer';

  @override
  String get skip => 'Ignorer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get earnings => 'Gains';

  @override
  String get totalEarnings => 'Gains totaux';

  @override
  String thisWeekValue(Object value) {
    return 'Cette semaine : $value €';
  }

  @override
  String get earningsOverview => 'Aperçu des gains';

  @override
  String get active => 'Actif';

  @override
  String get ridesEarnings => 'Gains des trajets';

  @override
  String get tipsBonuses => 'Pourboires et bonus';

  @override
  String get environmentalImpact => 'Impact environnemental';

  @override
  String valueKgCoSaved(Object value) {
    return '$value kg CO₂ économisés';
  }

  @override
  String get stripeConnected => 'Stripe connecté';

  @override
  String get setUpPayouts => 'Configurer les paiements';

  @override
  String get receivePaymentsFromRiders =>
      'Recevoir les paiements des passagers';

  @override
  String get completeVerification => 'Compléter la vérification';

  @override
  String get connectYourBankAccount => 'Connectez votre compte bancaire';

  @override
  String get availableBalance => 'Solde disponible';

  @override
  String get confirmPayout => 'Confirmer le paiement';

  @override
  String withdrawValueToYourConnected(Object value) {
    return 'Retirer $value € sur votre compte bancaire connecté ?';
  }

  @override
  String get withdraw => 'Retirer';

  @override
  String payoutOfValueInitiated(Object value) {
    return 'Paiement de $value € initié !';
  }

  @override
  String get payoutFailedPleaseTryAgain =>
      'Le paiement a échoué. Veuillez réessayer.';

  @override
  String get recentTransactions => 'Transactions récentes';

  @override
  String get noTransactionsYet => 'Aucune transaction pour le moment';

  @override
  String get failedToLoadTransactions => 'Échec du chargement des transactions';

  @override
  String valueValue3(Object value1, Object value2) {
    return '$value1$value2 €';
  }

  @override
  String get getPaidForYourRides => 'Soyez payé pour vos trajets';

  @override
  String get connectYourBankAccountTo =>
      'Connectez votre compte bancaire pour recevoir les paiements directement des passagers. Alimenté par Stripe pour des transactions sécurisées.';

  @override
  String get instantPayouts => 'Paiements instantanés';

  @override
  String get secureProtected => 'Sécurisé et protégé';

  @override
  String get clearTracking => 'Suivi clair';

  @override
  String get lowFees => 'Frais réduits';

  @override
  String get youLlBeRedirectedTo =>
      'Vous serez redirigé vers Stripe pour terminer la configuration';

  @override
  String get connectStripe => 'Connecter Stripe';

  @override
  String get stripeAccountConnectedSuccessfully =>
      'Compte Stripe connecté avec succès !';

  @override
  String errorLoadingPageValue(Object value) {
    return 'Erreur de chargement de la page : $value';
  }

  @override
  String get pleaseSignInToView2 =>
      'Veuillez vous connecter pour voir l\'historique des paiements';

  @override
  String get paymentHistory => 'Historique des paiements';

  @override
  String get yourTransactions => 'Vos transactions';

  @override
  String get noPaymentsFound => 'Aucun paiement trouvé';

  @override
  String get yourPaymentHistoryWillAppear =>
      'Votre historique de paiements apparaîtra ici';

  @override
  String get ridePayment => 'Paiement de trajet';

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String valueValue4(Object value1, Object value2) {
    return '$value1 $value2';
  }

  @override
  String get paymentDetails => 'Détails du paiement';

  @override
  String get amount => 'Montant';

  @override
  String get status => 'Statut';

  @override
  String get seats2 => 'Sièges';

  @override
  String get platformFee => 'Frais de plateforme';

  @override
  String get card => 'Carte';

  @override
  String value7(Object value) {
    return '•••• $value';
  }

  @override
  String get date => 'Date';

  @override
  String get transactionId => 'ID de transaction';

  @override
  String get requestRefund => 'Demander un remboursement';

  @override
  String get errorLoadingAchievements =>
      'Erreur de chargement des réalisations';

  @override
  String levelValueValue(Object value1, Object value2) {
    return 'Niveau $value1 - $value2';
  }

  @override
  String valueXp2(Object value) {
    return '$value XP';
  }

  @override
  String valueXpToLevelValue(Object value1, Object value2) {
    return '$value1 XP pour le niveau $value2';
  }

  @override
  String get text4 => '🏆';

  @override
  String get badges => 'Badges';

  @override
  String get text5 => '🎯';

  @override
  String get challenges => 'Défis';

  @override
  String get text6 => '🚗';

  @override
  String get text7 => '🌍';

  @override
  String get kgCo => 'kg CO₂';

  @override
  String get unlocked => '✓ Débloqué';

  @override
  String get locked => '🔒 Verrouillé';

  @override
  String valueComplete(Object value) {
    return '$value% Terminé';
  }

  @override
  String get text8 => '🥈';

  @override
  String get mikeC => 'Mike C.';

  @override
  String get text112k => '11.2K';

  @override
  String get text10 => '🥇';

  @override
  String get sarahJ => 'Sarah J.';

  @override
  String get text124k => '12.4K';

  @override
  String get text11 => '🥉';

  @override
  String get emilyD => 'Emily D.';

  @override
  String get text98k => '9.8K';

  @override
  String levelValue(Object value) {
    return 'Niveau $value';
  }

  @override
  String get verifiedDriver => 'Conducteur vérifié';

  @override
  String get rating => 'Évaluation';

  @override
  String get trips => 'Trajets';

  @override
  String get member => 'Membre';

  @override
  String get text12 => '...';

  @override
  String get text00 => '0.0';

  @override
  String get quickActions => 'Actions rapides';

  @override
  String get performanceOverview => 'Aperçu des performances';

  @override
  String get totalTrips => 'Trajets totaux';

  @override
  String valueThisMonth(Object value) {
    return '+$value ce mois-ci';
  }

  @override
  String valueThisMonth2(Object value) {
    return '+$value € ce mois-ci';
  }

  @override
  String get coSaved => 'CO₂ économisé';

  @override
  String valueKg(Object value) {
    return '$value kg';
  }

  @override
  String get sinceJoining => 'Depuis votre inscription';

  @override
  String get avgRating => 'Éval. moyenne';

  @override
  String get last100Trips => '100 derniers trajets';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get text0 => '0 €';

  @override
  String get text0Kg => '0 kg';

  @override
  String get weeklyActivity => 'Activité hebdomadaire';

  @override
  String get ratingBreakdown => 'Détail des évaluations';

  @override
  String get tripsThisWeek => 'Trajets cette semaine';

  @override
  String valueTrips(Object value) {
    return '$value trajets';
  }

  @override
  String get driverSettings => 'Paramètres conducteur';

  @override
  String get ridePreferences => 'Préférences de trajet';

  @override
  String get autoAcceptRequests => 'Acceptation automatique des demandes';

  @override
  String get automaticallyAcceptRideRequestsThat =>
      'Accepter automatiquement les demandes de trajet qui correspondent à vos critères';

  @override
  String get allowInstantBooking => 'Autoriser la réservation instantanée';

  @override
  String get letPassengersBookWithoutWaiting =>
      'Permettre aux passagers de réserver sans attendre l\'approbation';

  @override
  String get maximumPickupDistance => 'Distance maximale de prise en charge';

  @override
  String get onlyReceiveRequestsWithinThis =>
      'Ne recevoir que les demandes dans cette distance';

  @override
  String get paymentSettings => 'Paramètres de paiement';

  @override
  String get acceptCashPayments => 'Accepter les paiements en espèces';

  @override
  String get allowPassengersToPayWith =>
      'Permettre aux passagers de payer en espèces';

  @override
  String get acceptCardPayments => 'Accepter les paiements par carte';

  @override
  String get allowPassengersToPayWith2 =>
      'Permettre aux passagers de payer par carte dans l\'application';

  @override
  String get payoutMethod => 'Méthode de paiement';

  @override
  String get bankAccountEndingIn4532 => 'Compte bancaire se terminant par 4532';

  @override
  String get taxDocuments => 'Documents fiscaux';

  @override
  String get viewAndDownloadTaxForms =>
      'Consulter et télécharger les formulaires fiscaux';

  @override
  String get navigationMap => 'Navigation et carte';

  @override
  String get showOnDriverMap => 'Afficher sur la carte conducteur';

  @override
  String get allowPassengersToSeeYour =>
      'Autoriser les passagers à voir votre position';

  @override
  String get preferredNavigationApp => 'Application de navigation préférée';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get playSoundsForNewRequests =>
      'Jouer des sons pour les nouvelles demandes et messages';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateForImportantAlerts => 'Vibrer pour les alertes importantes';

  @override
  String get notificationPreferences => 'Préférences de notification';

  @override
  String get customizeWhatNotificationsYouReceive =>
      'Personnaliser les notifications que vous recevez';

  @override
  String get nightMode => 'Mode nuit';

  @override
  String get reduceEyeStrainInLow =>
      'Réduire la fatigue oculaire en faible luminosité';

  @override
  String get accountSecurity => 'Compte et sécurité';

  @override
  String get driverDocuments => 'Documents conducteur';

  @override
  String get licenseInsuranceAndRegistration =>
      'Permis, assurance et immatriculation';

  @override
  String get backgroundCheck => 'Vérification des antécédents';

  @override
  String get viewYourVerificationStatus => 'Voir votre statut de vérification';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get updateYourAccountPassword =>
      'Mettre à jour le mot de passe de votre compte';

  @override
  String get twoFactorAuthentication => 'Authentification à deux facteurs';

  @override
  String get addExtraSecurityToYour =>
      'Ajouter une sécurité supplémentaire à votre compte';

  @override
  String get support => 'Assistance';

  @override
  String get driverHelpCenter => 'Centre d\'aide conducteur';

  @override
  String get faqsAndTroubleshootingGuides => 'FAQ et guides de dépannage';

  @override
  String get contactSupport => 'Contacter l\'assistance';

  @override
  String get chatWithOurSupportTeam =>
      'Discuter avec notre équipe d\'assistance';

  @override
  String get reportASafetyIssue => 'Signaler un problème de sécurité';

  @override
  String get reportIncidentsOrConcerns =>
      'Signaler des incidents ou des préoccupations';

  @override
  String get accountActions => 'Actions du compte';

  @override
  String get switchToRiderMode => 'Passer en mode passager';

  @override
  String get useTheAppAsA => 'Utiliser l\'application en tant que passager';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get logOutOfYourAccount => 'Vous déconnecter de votre compte';

  @override
  String get pauseDriverAccount => 'Mettre en pause le compte conducteur';

  @override
  String get temporarilyStopReceivingRequests =>
      'Arrêter temporairement de recevoir des demandes';

  @override
  String get deleteDriverAccount => 'Supprimer le compte conducteur';

  @override
  String get permanentlyRemoveYourDriverProfile =>
      'Supprimer définitivement votre profil conducteur';

  @override
  String get sportconnectDriver => 'SportConnect Conducteur';

  @override
  String get version210 => 'Version 2.1.0';

  @override
  String get areYouSureYouWant3 =>
      'Êtes-vous sûr de vouloir vous déconnecter de votre compte ?';

  @override
  String get thisActionCannotBeUndone =>
      'Cette action ne peut pas être annulée. Toutes vos données de conducteur, votre historique de gains et vos évaluations seront définitivement supprimés.';

  @override
  String get pleaseSignInToManage =>
      'Veuillez vous connecter pour gérer les véhicules';

  @override
  String get myVehicles => 'Mes véhicules';

  @override
  String get noVehiclesAdded => 'Aucun véhicule ajouté';

  @override
  String get addYourFirstVehicleTo =>
      'Ajoutez votre premier véhicule pour commencer\nà proposer des trajets';

  @override
  String get addVehicle => 'Ajouter un véhicule';

  @override
  String get vehicleSetAsActive => 'Véhicule défini comme actif';

  @override
  String get deleteVehicle => 'Supprimer le véhicule';

  @override
  String areYouSureYouWant4(Object value) {
    return 'Êtes-vous sûr de vouloir supprimer $value ?';
  }

  @override
  String get vehicleDeleted => 'Véhicule supprimé';

  @override
  String get setActive => 'Définir comme actif';

  @override
  String get editVehicle => 'Modifier le véhicule';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get make => 'Marque';

  @override
  String get model => 'Modèle';

  @override
  String get year => 'Année';

  @override
  String get color => 'Couleur';

  @override
  String get licensePlate => 'Plaque d\'immatriculation';

  @override
  String get passengerCapacity => 'Capacité de passagers';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get capacity => 'Capacité';

  @override
  String valuePassengers(Object value) {
    return '$value passagers';
  }

  @override
  String get totalRides => 'Trajets totaux';

  @override
  String value8(Object value) {
    return '$value ⭐';
  }

  @override
  String get features => 'Caractéristiques';

  @override
  String get changePhoto => 'Changer la photo';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get aboutYou => 'À propos de vous';

  @override
  String get demographics => 'Démographie';

  @override
  String get gender => 'Genre';

  @override
  String get birthday => 'Date de naissance';

  @override
  String get sportsInterests => 'Intérêts sportifs';

  @override
  String get add => '+ Ajouter';

  @override
  String get noInterestsSelected => 'Aucun intérêt sélectionné';

  @override
  String get profileUpdated => 'Profil mis à jour';

  @override
  String get changeProfilePhoto => 'Changer la photo de profil';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get removePhoto => 'Supprimer la photo';

  @override
  String get selectGender => 'Sélectionner le genre';

  @override
  String get selectSportsInterests => 'Sélectionner les intérêts sportifs';

  @override
  String get discardChanges => 'Abandonner les modifications ?';

  @override
  String get youHaveUnsavedChanges =>
      'Vous avez des modifications non enregistrées.';

  @override
  String get discard => 'Abandonner';

  @override
  String get failedToLoadProfile => 'Échec du chargement du profil';

  @override
  String get pleaseCheckYourConnectionAnd =>
      'Veuillez vérifier votre connexion et réessayer';

  @override
  String get myProfile => 'Mon profil';

  @override
  String memberSinceValue(Object value) {
    return 'Membre depuis $value';
  }

  @override
  String get newMember => 'Nouveau membre';

  @override
  String get verifiedInfo => 'Informations vérifiées';

  @override
  String get verified => 'Vérifié';

  @override
  String get notVerified => 'Non vérifié';

  @override
  String get rideStatistics => 'Statistiques de trajet';

  @override
  String get saved => 'Économisé';

  @override
  String get earned2 => 'Gagné';

  @override
  String get profileNotFound => 'Profil introuvable';

  @override
  String get yourProfileDataCouldNot =>
      'Les données de votre profil n\'ont pas pu être chargées.\nCela peut arriver si vous êtes un nouvel utilisateur.';

  @override
  String get signOutTryAgain => 'Se déconnecter et réessayer';

  @override
  String get findPeople => 'Trouver des personnes';

  @override
  String get searchByName => 'Rechercher par nom';

  @override
  String get searchUsers => 'Rechercher des utilisateurs...';

  @override
  String get findFellowRiders => 'Trouver des co-coureurs';

  @override
  String get searchForUsersByTheir =>
      'Recherchez des utilisateurs par leur nom\npour vous connecter et partager des trajets';

  @override
  String get popularSearches => 'Recherches populaires';

  @override
  String get searching => 'Recherche en cours...';

  @override
  String get noResultsFound2 => 'Aucun résultat trouvé';

  @override
  String noUsersFoundMatchingValue(Object value) {
    return 'Aucun utilisateur trouvé correspondant à \"$value\"';
  }

  @override
  String get tryADifferentSearchTerm => 'Essayez un autre terme de recherche';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get vehicles => 'Véhicules';

  @override
  String get legal => 'Légal';

  @override
  String get sportconnectV100 => 'SportConnect v1.0.0';

  @override
  String get noBlockedUsers => 'Aucun utilisateur bloqué';

  @override
  String get usersYouBlockWillAppear =>
      'Les utilisateurs que vous bloquez apparaîtront ici';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get paymentIntegrationWillBeAvailable =>
      'L\'intégration de paiement sera bientôt disponible';

  @override
  String get currentPassword => 'Mot de passe actuel';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmNewPassword => 'Confirmer le nouveau mot de passe';

  @override
  String get passwordUpdatedSuccessfully =>
      'Mot de passe mis à jour avec succès';

  @override
  String get update => 'Mettre à jour';

  @override
  String get gettingStarted => 'Premiers pas';

  @override
  String get ridesCarpooling => 'Trajets et covoiturage';

  @override
  String get safetyTrust => 'Sécurité et confiance';

  @override
  String get accountSettings => 'Compte et paramètres';

  @override
  String openingValue(Object value) {
    return 'Ouverture : $value';
  }

  @override
  String get weReHereToHelp =>
      'Nous sommes là pour vous aider ! Choisissez comment vous souhaitez nous contacter.';

  @override
  String get emailSupport => 'Support par e-mail';

  @override
  String get couldNotOpenEmailApp =>
      'Impossible d\'ouvrir l\'application e-mail';

  @override
  String get liveChat => 'Chat en direct';

  @override
  String get liveChatWillBeAvailable =>
      'Le chat en direct sera bientôt disponible !';

  @override
  String get phoneSupport => 'Assistance téléphonique';

  @override
  String get category => 'Catégorie';

  @override
  String get describeTheProblem => 'Décrire le problème';

  @override
  String get pleaseDescribeWhatHappened =>
      'Veuillez décrire ce qui s\'est passé...';

  @override
  String get thankYouYourReportHas => 'Merci ! Votre signalement a été soumis.';

  @override
  String get submit => 'Soumettre';

  @override
  String get areYouSureYouWant5 =>
      'Êtes-vous sûr de vouloir vous déconnecter de SportConnect ?';

  @override
  String get thisActionCannotBeUndone2 =>
      'Cette action ne peut pas être annulée. Toutes vos données, y compris :';

  @override
  String get rideHistoryAndBookings => 'Historique des trajets et réservations';

  @override
  String get profileAndAchievements => 'Profil et réalisations';

  @override
  String get messagesAndConnections => 'Messages et connexions';

  @override
  String get paymentInformation => 'Informations de paiement';

  @override
  String get typeDeleteToConfirm => 'Tapez \"DELETE\" pour confirmer :';

  @override
  String failedToDeleteAccountValue(Object value) {
    return 'Échec de la suppression du compte : $value';
  }

  @override
  String get addRide => 'Ajouter un trajet';

  @override
  String get userNotFound => 'Utilisateur introuvable';

  @override
  String get errorLoadingVehicles => 'Erreur de chargement des véhicules';

  @override
  String get myGarage => 'Mon garage';

  @override
  String valueVehicles(Object value) {
    return '$value véhicules';
  }

  @override
  String get setDefault => 'Définir par défaut';

  @override
  String get pending => 'En attente';

  @override
  String get plate => 'Plaque';

  @override
  String get garageIsEmpty => 'Le garage est vide';

  @override
  String get addAVehicleToStart =>
      'Ajoutez un véhicule pour commencer votre voyage. Connectez-vous avec d\'autres personnes et partagez des trajets.';

  @override
  String get quickTip => 'Conseil rapide';

  @override
  String get swipeRightOnAVehicle =>
      'Balayez vers la droite sur une carte de véhicule pour la définir par défaut. Balayez vers la gauche pour la supprimer.';

  @override
  String get deleteRide => 'Supprimer le trajet ?';

  @override
  String areYouSureYouWant6(Object value) {
    return 'Êtes-vous sûr de vouloir supprimer $value ? Cela ne peut pas être annulé.';
  }

  @override
  String get keepIt => 'Le garder';

  @override
  String get vehicleRemovedFromGarage => 'Véhicule retiré du garage';

  @override
  String get editRide => 'Modifier le trajet';

  @override
  String get newRide => 'Nouveau trajet';

  @override
  String get seatsCapacity => 'Capacité de sièges';

  @override
  String valueSReviews(Object value) {
    return 'Avis de $value';
  }

  @override
  String get noReviewsYet => 'Aucun avis pour le moment';

  @override
  String get failedToLoadReviews => 'Échec du chargement des avis';

  @override
  String valueReviews(Object value) {
    return '$value avis';
  }

  @override
  String get rider => 'Passager';

  @override
  String get response => 'Réponse';

  @override
  String get leaveAReview => 'Laisser un avis';

  @override
  String get howWasYourExperience => 'Comment s\'est passée votre expérience ?';

  @override
  String get whatStoodOut => 'Qu\'est-ce qui vous a marqué ?';

  @override
  String get additionalCommentsOptional =>
      'Commentaires supplémentaires (facultatif)';

  @override
  String get skipForNow => 'Ignorer pour le moment';

  @override
  String get yourDriver => 'Votre conducteur';

  @override
  String get yourPassenger => 'Votre passager';

  @override
  String get shareYourExperience => 'Partagez votre expérience...';

  @override
  String get thankYouForYourReview => 'Merci pour votre avis !';

  @override
  String valueValue5(Object value1, Object value2) {
    return '$value1$value2';
  }

  @override
  String get errorLoadingRide => 'Erreur de chargement du trajet';

  @override
  String get goBack => 'Retour';

  @override
  String get tooltipShowPassword => 'Afficher le mot de passe';

  @override
  String get tooltipHidePassword => 'Masquer le mot de passe';

  @override
  String get activeRide => 'Trajet actif';

  @override
  String get noActiveRide => 'Aucun trajet actif';

  @override
  String get startARideToSee => 'Démarrez un trajet pour voir la navigation';

  @override
  String get headingToPickup => 'En route vers la prise en charge';

  @override
  String get headingToDestination => 'En route vers la destination';

  @override
  String etaValueMinValueKm(Object value1, Object value2) {
    return 'ETA : $value1 min • $value2 km restants';
  }

  @override
  String arrivingAtValue(Object value) {
    return 'Arrivée à $value';
  }

  @override
  String get distance => 'Distance';

  @override
  String get duration => 'Durée';

  @override
  String get fare => 'Tarif';

  @override
  String get call => 'Appeler';

  @override
  String get message => 'Message';

  @override
  String get text5Min => '5 min';

  @override
  String valueMore(Object value) {
    return '+$value de plus';
  }

  @override
  String valuePassengerValue(Object value1, Object value2) {
    return '$value1 passager$value2';
  }

  @override
  String valueSeatValueBooked(Object value1, Object value2) {
    return '• $value1 siège$value2 réservé';
  }

  @override
  String valueSeatValueBooked2(Object value1, Object value2) {
    return '$value1 siège$value2 réservé';
  }

  @override
  String get passengers => 'Passagers';

  @override
  String get seat2 => '€/siège';

  @override
  String get min => 'min';

  @override
  String get pickup => 'Prise en charge';

  @override
  String get dropoff => 'Dépose';

  @override
  String valuePassengerValueBookedFor(Object value1, Object value2) {
    return '$value1 passager$value2 réservé pour ce trajet';
  }

  @override
  String get cancelRide => 'Annuler le trajet ?';

  @override
  String get areYouSureYouWant7 =>
      'Êtes-vous sûr de vouloir annuler ce trajet ? Cela peut affecter votre note de conducteur.';

  @override
  String get continueRide => 'Continuer le trajet';

  @override
  String get cancelRide2 => 'Annuler le trajet';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get manageYourRidesEarnings => 'Gérez vos trajets et revenus';

  @override
  String get requests => 'Demandes';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get noPendingRequests2 => 'Aucune demande en attente';

  @override
  String get newRequest => 'NOUVELLE DEMANDE';

  @override
  String get tapToRespond => 'Appuyez pour répondre';

  @override
  String value9(Object value) {
    return '+€$value';
  }

  @override
  String get earnings2 => 'revenus';

  @override
  String valueValue6(Object value1, Object value2) {
    return '$value1 • $value2';
  }

  @override
  String get failedToLoadUser => 'Impossible de charger l\'utilisateur';

  @override
  String get noActiveRides => 'Aucun trajet actif';

  @override
  String get rideInProgress => 'TRAJET EN COURS';

  @override
  String valueValuePassengers(Object value1, Object value2) {
    return '$value1/$value2 passagers';
  }

  @override
  String get navigate => 'Naviguer';

  @override
  String get complete => 'Terminer';

  @override
  String get noScheduledRides => 'Aucun trajet programmé';

  @override
  String valueSeat(Object value) {
    return '€$value/siège';
  }

  @override
  String get noCompletedRides => 'Aucun trajet terminé';

  @override
  String valueValuePassengers2(Object value1, Object value2) {
    return '$value1 • $value2 passagers';
  }

  @override
  String get loadingYourRides => 'Chargement de vos trajets...';

  @override
  String get signInRequired => 'Connexion requise';

  @override
  String get bookingAccepted => 'Réservation acceptée !';

  @override
  String get bookingDeclined => 'Réservation refusée';

  @override
  String get rideCompletedWellDone => 'Trajet terminé ! Bien joué 🎉';

  @override
  String get manageVehicles => 'Gérer les véhicules';

  @override
  String get earningsHistory => 'Historique des revenus';

  @override
  String get preferences => 'Préférences';

  @override
  String get offerARide => 'Proposer un trajet';

  @override
  String get driverAccountRequired => 'Compte conducteur requis';

  @override
  String get youNeedToRegisterAs =>
      'Vous devez vous inscrire en tant que conducteur et ajouter un véhicule pour proposer des trajets.';

  @override
  String get shareYourJourneyEarnMoney =>
      'Partagez votre trajet, gagnez de l\'argent';

  @override
  String get yourRoute => 'Votre itinéraire';

  @override
  String get startingPoint => 'Point de départ';

  @override
  String get departureTime => 'Heure de départ';

  @override
  String get recurringRide => 'Trajet récurrent';

  @override
  String get offerThisRideRegularly => 'Proposer ce trajet régulièrement';

  @override
  String get addAVehicleToStart2 =>
      'Ajoutez un véhicule pour commencer à proposer des trajets';

  @override
  String get selectVehicle => 'Sélectionner un véhicule';

  @override
  String get add2 => 'Ajouter';

  @override
  String get availableSeats => 'Sièges disponibles';

  @override
  String maxValuePassengers(Object value) {
    return 'Max $value passagers';
  }

  @override
  String get selectAVehicleFirst => 'Sélectionnez d\'abord un véhicule';

  @override
  String get pricePerSeat => 'Prix par siège';

  @override
  String get priceNegotiable => 'Prix négociable';

  @override
  String get acceptOnlinePayment => 'Accepter le paiement en ligne';

  @override
  String get receivePaymentsViaStripe => 'Recevoir des paiements via Stripe';

  @override
  String get allowLuggage => 'Autoriser les bagages';

  @override
  String get allowPets => 'Autoriser les animaux';

  @override
  String get allowSmoking => 'Autoriser de fumer';

  @override
  String get womenOnly => 'Femmes uniquement';

  @override
  String get maxDetour => 'Détour maximum';

  @override
  String get howFarYouLlGo => 'Jusqu\'où vous irez pour prendre des passagers';

  @override
  String get rideCreatedSuccessfully => 'Trajet créé avec succès !';

  @override
  String get newRideRequestsWillAppear =>
      'Les nouvelles demandes de trajet apparaîtront ici';

  @override
  String get noDeclinedRequests => 'Aucune demande refusée';

  @override
  String get youHavenTDeclinedAny =>
      'Vous n\'avez encore refusé aucune demande';

  @override
  String get acceptRequest => 'Accepter la demande ?';

  @override
  String youAreAboutToAccept(Object value1, Object value2, Object value3) {
    return 'Vous êtes sur le point d\'accepter la demande de trajet de $value1 pour $value2 à $value3.';
  }

  @override
  String requestAcceptedValueHasBeen(Object value) {
    return 'Demande acceptée ! $value a été notifié.';
  }

  @override
  String get failedToAcceptRequest => 'Échec de l\'acceptation de la demande';

  @override
  String get requestDeclined => 'Demande refusée';

  @override
  String get failedToDeclineRequest => 'Échec du refus de la demande';

  @override
  String requestedValue(Object value) {
    return 'Demandé $value';
  }

  @override
  String valueSeatValue2(Object value1, Object value2) {
    return '• $value1 siège$value2';
  }

  @override
  String valueSeatValueRequested(Object value1, Object value2) {
    return '$value1 siège$value2 demandé';
  }

  @override
  String get acceptRequest2 => 'Accepter la demande';

  @override
  String acceptedValue(Object value) {
    return 'Accepté $value';
  }

  @override
  String valueAtValue(Object value1, Object value2) {
    return '$value1 à $value2';
  }

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String declinedValue(Object value) {
    return 'Refusé $value';
  }

  @override
  String reasonValue(Object value) {
    return 'Raison : $value';
  }

  @override
  String get declineRequest => 'Refuser la demande';

  @override
  String pleaseLetValueKnowWhy(Object value) {
    return 'Veuillez faire savoir à $value pourquoi vous ne pouvez pas accepter ce trajet.';
  }

  @override
  String get pleaseSpecify => 'Veuillez préciser...';

  @override
  String get rideNotFound => 'Trajet introuvable';

  @override
  String get yourRide => 'Votre trajet';

  @override
  String get couldnTLoadRide => 'Impossible de charger le trajet';

  @override
  String get seatsFilled => 'Sièges remplis';

  @override
  String get perSeat => 'Par siège';

  @override
  String get route => 'Itinéraire';

  @override
  String value10(Object value) {
    return '~$value';
  }

  @override
  String valueTotalSeats(Object value) {
    return '$value sièges au total';
  }

  @override
  String get notes => 'Notes';

  @override
  String get newBookingRequestsWillAppear =>
      'Les nouvelles demandes de réservation apparaîtront ici';

  @override
  String get noPassengersYet => 'Pas encore de passagers';

  @override
  String get acceptBookingRequestsToAdd =>
      'Acceptez les demandes de réservation pour ajouter des passagers';

  @override
  String get shareRide => 'Partager le trajet';

  @override
  String get duplicateRide => 'Dupliquer le trajet';

  @override
  String get callPassenger => 'Appeler le passager';

  @override
  String get removePassenger => 'Retirer le passager';

  @override
  String bookingConfirmedForValue(Object value) {
    return 'Réservation confirmée pour $value';
  }

  @override
  String get declineBooking => 'Refuser la réservation';

  @override
  String declineBookingRequestFromValue(Object value) {
    return 'Refuser la demande de réservation de $value ?';
  }

  @override
  String removeValueFromThisRide(Object value) {
    return 'Retirer $value de ce trajet ?';
  }

  @override
  String get remove => 'Retirer';

  @override
  String get startRide => 'Démarrer le trajet';

  @override
  String get markThisRideAsStarted =>
      'Marquer ce trajet comme démarré ? Les passagers seront notifiés.';

  @override
  String get start => 'Démarrer';

  @override
  String get completeRide => 'Terminer le trajet';

  @override
  String get markThisRideAsCompleted =>
      'Marquer ce trajet comme terminé ? Vous pourrez ensuite noter vos passagers.';

  @override
  String get areYouSureYouWant8 =>
      'Êtes-vous sûr de vouloir annuler ce trajet ? Tous les passagers seront notifiés et remboursés.';

  @override
  String get keepRide => 'Garder le trajet';

  @override
  String get failedToLoadRide => 'Échec du chargement du trajet';

  @override
  String get thisRideMayHaveBeen =>
      'Ce trajet a peut-être été terminé ou annulé';

  @override
  String get rideConfirmed => 'Trajet confirmé';

  @override
  String get driverOnTheWay => 'Conducteur en route';

  @override
  String get rideCompleted => 'Trajet terminé';

  @override
  String valueRides2(Object value) {
    return '• $value trajets';
  }

  @override
  String get routeDetails => 'Détails de l\'itinéraire';

  @override
  String get perSeat2 => 'par siège';

  @override
  String get seatsLeft => 'sièges restants';

  @override
  String get departure => 'départ';

  @override
  String passengersValue(Object value) {
    return 'Passagers ($value)';
  }

  @override
  String get phoneNumberNotAvailable => 'Numéro de téléphone non disponible';

  @override
  String get cannotMakePhoneCalls =>
      'Impossible de passer des appels sur cet appareil';

  @override
  String get failedToLaunchDialer =>
      'Impossible de lancer le composeur téléphonique';

  @override
  String get areYouSureYouWant9 =>
      'Êtes-vous sûr de vouloir annuler ce trajet ? Des politiques d\'annulation peuvent s\'appliquer.';

  @override
  String get rideCancelledSuccessfully => 'Trajet annulé avec succès';

  @override
  String failedToCancelRideValue(Object value) {
    return 'Échec de l\'annulation du trajet : $value';
  }

  @override
  String get rateYourRide => 'Évaluez votre trajet';

  @override
  String get ratingFeatureComingSoonThank =>
      'La fonction d\'évaluation arrive bientôt ! Merci d\'utiliser SportConnect.';

  @override
  String get myTrips => 'Mes voyages';

  @override
  String get trackManageYourRides => 'Suivez et gérez vos trajets';

  @override
  String get upcoming => 'À venir';

  @override
  String get history => 'Historique';

  @override
  String get noActiveTrips => 'Aucun voyage actif';

  @override
  String get tripInProgress => 'VOYAGE EN COURS';

  @override
  String get text49 => '4.9';

  @override
  String get noUpcomingTrips => 'Aucun voyage à venir';

  @override
  String get noTripHistory => 'Aucun historique de voyage';

  @override
  String get rebook => 'Réserver';

  @override
  String get findRide => 'Trouver un trajet';

  @override
  String get loadingYourTrips => 'Chargement de vos voyages...';

  @override
  String get cancelTrip => 'Annuler le voyage ?';

  @override
  String areYouSureYouWant10(Object value) {
    return 'Êtes-vous sûr de vouloir annuler votre voyage vers $value ?';
  }

  @override
  String get tripCancelled => 'Voyage annulé';

  @override
  String get openingChat => 'Ouverture du chat...';

  @override
  String failedToOpenChatValue(Object value) {
    return 'Échec de l\'ouverture du chat : $value';
  }

  @override
  String get startingCall => 'Démarrage de l\'appel...';

  @override
  String get whereTo => 'Où allez-vous ?';

  @override
  String get findThePerfectRideFor =>
      'Trouvez le trajet parfait pour votre voyage';

  @override
  String get whereFrom => 'D\'où ?';

  @override
  String get when => 'Quand ?';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Demain';

  @override
  String get pickDate => 'Choisir une date';

  @override
  String get departureTime2 => 'Heure de départ';

  @override
  String get howManySeatsDoYou => 'Combien de sièges avez-vous besoin ?';

  @override
  String get availableRides => 'Trajets disponibles';

  @override
  String get sort => 'Trier';

  @override
  String get noRidesFound => 'Aucun trajet trouvé';

  @override
  String get tryAdjustingYourSearchCriteria =>
      'Essayez d\'ajuster vos critères de recherche\nou revenez plus tard';

  @override
  String get findingRides => 'Recherche de trajets...';

  @override
  String get sortBy => 'Trier par';

  @override
  String get recommended => 'Recommandé';

  @override
  String get earliestDeparture => 'Départ le plus tôt';

  @override
  String get lowestPrice => 'Prix le plus bas';

  @override
  String get highestRated => 'Mieux noté';

  @override
  String get searchFailedPleaseTryAgain =>
      'La recherche a échoué. Veuillez réessayer.';

  @override
  String get rideDetails => 'Détails du trajet';

  @override
  String value11(Object value) {
    return '$value • ';
  }

  @override
  String valueLeft(Object value) {
    return '$value restant';
  }

  @override
  String valueMin2(Object value) {
    return '~$value min';
  }

  @override
  String valueKgCoSavedPer(Object value) {
    return '$value kg CO₂ économisé par personne';
  }

  @override
  String get negotiable => 'Négociable';

  @override
  String get onlinePay => 'Paiement en ligne';

  @override
  String get reviews => 'Avis';

  @override
  String get seeAll => 'Tout voir';

  @override
  String get seats3 => 'Sièges :';

  @override
  String get confirmBooking => 'Confirmer la réservation';

  @override
  String get pricePerSeat2 => 'Prix par siège';

  @override
  String get total => 'Total';

  @override
  String get addANoteToThe => 'Ajouter une note au conducteur (optionnel)';

  @override
  String get bookingRequestSent => 'Demande de réservation envoyée !';

  @override
  String get seatsLeft2 => 'Sièges restants';

  @override
  String get tripDetails => 'Détails du voyage';

  @override
  String get departure2 => 'Départ';

  @override
  String get amenities => 'Commodités';

  @override
  String get pets => 'Animaux';

  @override
  String get smoking => 'Fumer';

  @override
  String get luggage => 'Bagages';

  @override
  String yourPassengersValue(Object value) {
    return 'Vos passagers ($value)';
  }

  @override
  String valueValueSeats(Object value1, Object value2) {
    return '$value1/$value2 sièges';
  }

  @override
  String get noPassengersAcceptedYet => 'Aucun passager accepté pour le moment';

  @override
  String get noPassengersBookedYet => 'Aucun passager réservé pour le moment';

  @override
  String valueHasBookedThisRide(Object value) {
    return '$value a réservé ce trajet';
  }

  @override
  String valuePassengersHaveBooked(Object value) {
    return '$value passagers ont réservé';
  }

  @override
  String pendingRequestsValue(Object value) {
    return 'Demandes en attente ($value)';
  }

  @override
  String get requestAccepted => 'Demande acceptée ! 🎉';

  @override
  String get seatsBooked => 'Sièges réservés';

  @override
  String get editRideFeatureComingSoon =>
      'La fonction d\'édition du trajet arrive bientôt !';

  @override
  String get numberOfSeats => 'Nombre de sièges';

  @override
  String value12(Object value) {
    return '× $value';
  }

  @override
  String get securePaymentWithStripe => 'Paiement sécurisé avec Stripe';

  @override
  String get pleaseLogInToBook =>
      'Veuillez vous connecter pour réserver un trajet';

  @override
  String get paymentSucceededButBookingFailed =>
      'Le paiement a réussi mais la réservation a échoué. Veuillez contacter le support.';

  @override
  String get paymentCancelled => 'Paiement annulé';

  @override
  String paymentFailedValue(Object value) {
    return 'Le paiement a échoué : $value';
  }

  @override
  String get paymentMethod => 'Méthode de paiement';

  @override
  String get thisDriverAcceptsCashPayment =>
      'Ce conducteur accepte uniquement le paiement en espèces.';

  @override
  String get payWithCash => 'Payer en espèces';

  @override
  String get failedToBookRidePlease =>
      'Échec de la réservation du trajet. Veuillez réessayer.';

  @override
  String get paymentSuccessful => 'Paiement réussi !';

  @override
  String youPaidValueValue(Object value1, Object value2) {
    return 'Vous avez payé $value1 $value2';
  }

  @override
  String get yourRideHasBeenBooked => 'Votre trajet a été réservé.';

  @override
  String get youEarned25Xp => 'Vous avez gagné 25 XP !';

  @override
  String get backToSearch => 'Retour à la recherche';

  @override
  String get bookingConfirmed => 'Réservation confirmée !';

  @override
  String get yourRideHasBeenBooked2 =>
      'Votre trajet a été réservé. Payez le conducteur en espèces.';

  @override
  String get pleaseEnterBothLocations =>
      'Veuillez entrer les deux emplacements';

  @override
  String get pleaseSelectLocationsFromThe =>
      'Veuillez sélectionner les emplacements depuis le sélecteur';

  @override
  String maxValue(Object value) {
    return 'Max $value €';
  }

  @override
  String get femaleOnly => 'Femmes uniquement';

  @override
  String get instantBook => 'Réservation instantanée';

  @override
  String get petFriendly => 'Animaux acceptés';

  @override
  String valueRating(Object value) {
    return '$value+ note';
  }

  @override
  String get activeFilters => 'Filtres actifs';

  @override
  String valueRidesAvailable(Object value) {
    return '$value trajets disponibles';
  }

  @override
  String filtersValue(Object value) {
    return 'Filtres$value';
  }

  @override
  String get reset => 'Réinitialiser';

  @override
  String get priceRange => 'Fourchette de prix';

  @override
  String get text52 => '5 €';

  @override
  String get text100 => '100 €';

  @override
  String get minimumRating => 'Note minimum';

  @override
  String get any => 'Tout';

  @override
  String value13(Object value) {
    return '$value+';
  }

  @override
  String get verifiedDriver2 => 'Conducteur vérifié';

  @override
  String get musicAllowed => 'Musique autorisée';

  @override
  String get vehicleType => 'Type de véhicule';

  @override
  String get electric => 'Électrique';

  @override
  String get comfort => 'Confort';

  @override
  String get book => 'Réserver';

  @override
  String get sortBy2 => 'Trier par';

  @override
  String get lowestPrice2 => 'Prix le plus bas';

  @override
  String get earliestDeparture2 => 'Départ le plus tôt';

  @override
  String get highestRated2 => 'Mieux noté';

  @override
  String get shortestDuration => 'Durée la plus courte';

  @override
  String get signInFailedPleaseTry =>
      'La connexion a échoué. Veuillez réessayer.';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Entrez votre email';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterYourPassword => 'Entrez votre mot de passe';

  @override
  String get orSignInWithEmail => 'ou se connecter avec l\'email';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get continueWithApple => 'Continuer avec Apple';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get avgPerRide => 'Moy. par trajet';

  @override
  String get driveTime => 'Temps de conduite';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get failedToLoadNotifications =>
      'Échec du chargement des notifications';

  @override
  String get checkYourConnectionAndTry =>
      'Vérifiez votre connexion et réessayez';

  @override
  String get couldNotOpenChat => 'Impossible d\'ouvrir le chat';

  @override
  String get searchConversations => 'Rechercher des conversations...';

  @override
  String get direct => 'Direct';

  @override
  String get groups => 'Groupes';

  @override
  String get all => 'Tout';

  @override
  String get startAConversationWith =>
      'Commencez une conversation avec vos partenaires de trajet';

  @override
  String get joinOrCreateAGroup =>
      'Rejoignez ou créez un groupe pour commencer à discuter';

  @override
  String get joinARideToChat =>
      'Rejoignez un trajet pour discuter avec d\'autres voyageurs';

  @override
  String get driverCreateRide => 'Créer un trajet';

  @override
  String get driverThisWeek => 'Cette semaine';

  @override
  String get driverThisMonth => 'Ce mois-ci';

  @override
  String get driverCo2Saved => 'CO₂ économisé';

  @override
  String get driverHoursOnline => 'Heures en ligne';

  @override
  String get locationRequired => 'Localisation requise';

  @override
  String get enableLocationForBetterExperience =>
      'Activez la localisation pour une meilleure expérience de conduite';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get enable => 'Activer';

  @override
  String get createARideToStartEarning =>
      'Créez un trajet pour commencer à gagner';

  @override
  String get wizardStepWelcome => 'Welcome';

  @override
  String get wizardStepWelcomeSubtitle => 'Let\'s get you started';

  @override
  String get wizardStepSecurity => 'Security';

  @override
  String get wizardStepSecuritySubtitle => 'Create a secure password';

  @override
  String get wizardStepRole => 'Your Role';

  @override
  String get wizardStepRoleSubtitle => 'How will you use SportConnect?';

  @override
  String get wizardStepProfile => 'Profile';

  @override
  String get wizardStepProfileSubtitle => 'Make it personal';

  @override
  String get authFullName => 'Full Name';

  @override
  String get authFullNameHint => 'Enter your full name';

  @override
  String get authEmailAddress => 'Email Address';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPhoneOptional => 'Phone Number (Optional)';

  @override
  String get authPhoneHint => '+216 XX XXX XXX';

  @override
  String get authDateOfBirth => 'Date of Birth *';

  @override
  String get authDobPrompt => 'Tap to select (must be 18+)';

  @override
  String get authDobMinAge =>
      'You must be at least 18 years old to use SportConnect.';

  @override
  String get authDobPicker => 'Select your date of birth';

  @override
  String get authCreatePassword => 'Create Password';

  @override
  String get authPasswordHint => 'Min 8 characters';

  @override
  String get authConfirmPasswordHint => 'Re-enter your password';

  @override
  String get authAboutYou => 'About You (Optional)';

  @override
  String get authAboutYouHint => 'Tell us a bit about yourself...';

  @override
  String get wizardFindRides => 'Find Rides';

  @override
  String get wizardFindRidesDesc =>
      'Search for rides to sporting events, practices, and games';

  @override
  String get wizardOfferRides => 'Offer Rides';

  @override
  String get wizardOfferRidesDesc =>
      'Share your car and earn money while helping others';

  @override
  String get wizardContinue => 'Continue';

  @override
  String get authAgreeTermsError => 'Please agree to the Terms of Service';

  @override
  String get authDobError => 'Please enter your date of birth.';

  @override
  String get otpTitle => 'Phone Verification';

  @override
  String get otpEnterPhone => 'Enter your phone number';

  @override
  String get otpPhoneHint => 'Phone number';

  @override
  String get otpSendCode => 'Send Verification Code';

  @override
  String get otpVerifyTitle => 'Verify OTP';

  @override
  String get otpEnterCode => 'Enter the 6-digit code sent to';

  @override
  String get otpVerify => 'Verify';

  @override
  String otpResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get otpResendCode => 'Resend Code';

  @override
  String get otpInvalidCode => 'Invalid verification code. Please try again.';

  @override
  String get otpExpired =>
      'Verification code expired. Please request a new one.';

  @override
  String get otpPhoneRequired => 'Phone number is required';

  @override
  String get otpInvalidPhone => 'Please enter a valid phone number';

  @override
  String get otpSending => 'Sending verification code...';

  @override
  String get otpVerifying => 'Verifying...';

  @override
  String get otpCodeLabel => 'OTP Code';

  @override
  String get otpPhoneVerified => 'Phone Verified!';

  @override
  String get otpPhoneVerifiedDesc =>
      'Your phone number has been verified successfully.';

  @override
  String get otpContinue => 'Continue';

  @override
  String get otpChangePhone => 'Change phone number';

  @override
  String get otpTryAgain => 'Try Again';

  @override
  String get otpBackToLogin => 'Back to Login';

  @override
  String get reauthTitle => 'Verify Your Identity';

  @override
  String get reauthSubtitle =>
      'For your security, please confirm your identity before continuing with this action.';

  @override
  String get reauthPassword => 'Password';

  @override
  String get reauthPasswordHint => 'Enter your current password';

  @override
  String get reauthPasswordRequired => 'Please enter your password';

  @override
  String get reauthConfirm => 'Confirm';

  @override
  String get reauthWithGoogle => 'Verify with Google';

  @override
  String get reauthCancel => 'Cancel';

  @override
  String get reauthWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get reauthFailed => 'Authentication failed. Please try again.';

  @override
  String get reauthGoogleFailed => 'Google re-authentication failed.';

  @override
  String get emailVerifyTitle => 'Verify Email';

  @override
  String get emailVerifyHeading => 'Verify Your Email';

  @override
  String get emailVerifySentTo => 'We\'ve sent a verification link to:';

  @override
  String get emailVerifyWaiting => 'Waiting for verification...';

  @override
  String get emailVerifyResend => 'Resend Verification Email';

  @override
  String emailVerifyResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get emailVerifyCheckButton => 'I\'ve Verified My Email';

  @override
  String get emailVerifySent => 'Verification email sent!';

  @override
  String get emailVerifySendFailed =>
      'Failed to send verification email. Please try again.';

  @override
  String get emailVerified => 'Email Verified!';

  @override
  String get emailVerifiedRedirecting =>
      'Your email has been verified. Redirecting...';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordHeading => 'Update Your Password';

  @override
  String get changePasswordDesc =>
      'Choose a strong password with at least 8 characters, including uppercase, lowercase, and numbers.';

  @override
  String get changePasswordNew => 'New Password';

  @override
  String get changePasswordNewHint => 'Enter new password';

  @override
  String get changePasswordConfirm => 'Confirm Password';

  @override
  String get changePasswordConfirmHint => 'Re-enter new password';

  @override
  String get changePasswordUpdate => 'Update Password';

  @override
  String get changePasswordSuccess => 'Password Updated!';

  @override
  String get changePasswordSuccessDesc =>
      'Your password has been changed successfully. Use your new password next time you sign in.';

  @override
  String get changePasswordDone => 'Done';

  @override
  String get changePasswordWeakError =>
      'Password is too weak. Please choose a stronger password.';

  @override
  String get changePasswordGenericError =>
      'Could not update password. Please try again.';

  @override
  String get forgotPasswordCheckEmail => 'Check Your Email';

  @override
  String get forgotPasswordResendEmail => 'Resend Email';

  @override
  String forgotPasswordResendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get forgotPasswordBackToLogin => 'Back to Login';

  @override
  String get forgotPasswordEmailRequired => 'Please enter your email';

  @override
  String get forgotPasswordInvalidEmail => 'Please enter a valid email';

  @override
  String get forgotPasswordSendError =>
      'Could not send reset email right now. Please try again.';

  @override
  String get roleSelectionError =>
      'We could not continue right now. Please try again.';

  @override
  String get accountExistsError =>
      'An account already exists with a different sign-in method. Try signing in with email/password or the original provider.';

  @override
  String get loginErrorUserNotFound => 'No account found with this email.';

  @override
  String get loginErrorWrongPassword =>
      'Incorrect email or password. Please try again.';

  @override
  String get loginErrorTooManyRequests =>
      'Too many login attempts. Please try again later.';

  @override
  String get loginErrorNetwork =>
      'Network error. Please check your connection.';

  @override
  String get loginErrorInvalidEmail => 'Invalid email address.';

  @override
  String get signUpFailedPleaseTry => 'Sign up failed. Please try again.';

  @override
  String get periodToday => 'Aujourd\'hui';

  @override
  String get periodThisWeek => 'Cette semaine';

  @override
  String get periodThisMonth => 'Ce mois';

  @override
  String get periodAllTime => 'Tout le temps';

  @override
  String get statRides => 'Trajets';

  @override
  String get statEarnings => 'Gains';

  @override
  String get statOnlineHours => 'Heures en ligne';

  @override
  String get statAvgRating => 'Note moy.';

  @override
  String get connectStripeAccount => 'Connecter un compte Stripe';

  @override
  String get benefitInstantPayoutsDesc =>
      'Recevez votre argent en minutes, pas en jours';

  @override
  String get benefitSecureDesc => 'Sécurité bancaire avec Stripe';

  @override
  String get benefitTrackingDesc =>
      'Consultez chaque paiement de trajet en détail';

  @override
  String get benefitLowFeesDesc => 'Gardez 85% de chaque paiement de trajet';

  @override
  String get pleaseSignInToContinue => 'Veuillez vous connecter pour continuer';

  @override
  String get poweredByStripe => 'Propulsé par Stripe • Sécurisé et chiffré';

  @override
  String get cancelSetupTitle => 'Annuler la configuration ?';

  @override
  String get cancelSetupMessage =>
      'Êtes-vous sûr de vouloir annuler ? Vous ne pourrez pas recevoir de paiements tant que vous n\'aurez pas terminé cette configuration.';

  @override
  String get continueSetup => 'Continuer la configuration';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterCompleted => 'Terminé';

  @override
  String get filterPending => 'En attente';

  @override
  String get filterRefunded => 'Remboursé';

  @override
  String get filterFailed => 'Échoué';

  @override
  String get statusCompleted => 'Terminé';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusProcessing => 'En cours';

  @override
  String get statusFailed => 'Échoué';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusRefunded => 'Remboursé';

  @override
  String get statusPartiallyRefunded => 'Partiellement remboursé';

  @override
  String get statusInTransit => 'En transit';

  @override
  String get details => 'Détails';

  @override
  String get refundRequestSubmitted =>
      'Demande de remboursement soumise avec succès';

  @override
  String get refundRequestFailed =>
      'Échec de la demande de remboursement. Veuillez réessayer.';

  @override
  String get payoutDetails => 'Détails du virement';

  @override
  String get payoutNotFound => 'Virement non trouvé';

  @override
  String get totalPayout => 'Virement total';

  @override
  String get breakdown => 'Répartition';

  @override
  String get timeline => 'Chronologie';

  @override
  String get grossEarnings => 'Gains bruts';

  @override
  String get netPayout => 'Virement net';

  @override
  String get payoutCreated => 'Virement créé';

  @override
  String get fees => 'Frais';

  @override
  String get payoutAmount => 'Montant du virement';

  @override
  String get instantPayout => 'Virement instantané';

  @override
  String get payoutDetailsSection => 'Détails';

  @override
  String get expectedArrival => 'Arrivée prévue';

  @override
  String get arrivedAt => 'Arrivé le';

  @override
  String get bankName => 'Nom de la banque';

  @override
  String get accountEnding => 'Compte se terminant par';

  @override
  String get failureReason => 'Raison de l\'échec';

  @override
  String get cancelPayout => 'Annuler le virement';

  @override
  String get cancelPayoutConfirm =>
      'Êtes-vous sûr de vouloir annuler ce virement ? Cette action est irréversible.';

  @override
  String get payoutCancelled => 'Virement annulé avec succès';

  @override
  String get payoutCancelFailed =>
      'Échec de l\'annulation du virement. Veuillez réessayer.';

  @override
  String get payoutPendingDesc =>
      'Votre virement est en cours de traitement et sera envoyé sous peu.';

  @override
  String get payoutInTransit => 'En transit';

  @override
  String get payoutInTransitDesc =>
      'Votre virement a été envoyé et est en route vers votre banque.';

  @override
  String get payoutPaid => 'Payé';

  @override
  String get payoutPaidDesc =>
      'Votre virement est arrivé sur votre compte bancaire.';

  @override
  String get payoutFailedDesc =>
      'Ce virement a échoué. Vérifiez la raison de l\'échec ci-dessous.';

  @override
  String get payoutCancelledDesc => 'Ce virement a été annulé.';

  @override
  String get stripeVerifyingAccount => 'Vérification de votre compte...';

  @override
  String get stripeAccountCreationFailed =>
      'Échec de la création du compte Stripe. Veuillez réessayer.';

  @override
  String get stripeSetupFailed =>
      'Impossible de démarrer la configuration Stripe. Veuillez réessayer.';

  @override
  String get stripePageLoadFailed =>
      'Échec du chargement de la page. Veuillez réessayer.';

  @override
  String get stripeLoadingConnect => 'Chargement de Stripe Connect...';

  @override
  String get stripeAdditionalInfoNeeded =>
      'Informations supplémentaires requises. Veuillez compléter tous les champs.';

  @override
  String get stripeVerifyFailed =>
      'Impossible de vérifier le compte. Veuillez réessayer.';

  @override
  String get unableToLoadData =>
      'Impossible de charger les données. Tirez pour actualiser.';

  @override
  String get exportEarningsReport => 'Rapport de revenus';

  @override
  String get exportGenerated => 'Généré';

  @override
  String get exportEarningsSummary => 'RÉSUMÉ DES REVENUS';

  @override
  String get exportRideStatistics => 'STATISTIQUES DES TRAJETS';

  @override
  String get exportRecentTransactions => 'TRANSACTIONS RÉCENTES';

  @override
  String get driverProfileTitle => 'Complétez votre profil';

  @override
  String get driverProfileSubtitle =>
      'Parlez-nous de vous pour que les passagers puissent vous connaître.';

  @override
  String get driverCityLabel => 'Ville';

  @override
  String get driverCityHint => 'Où êtes-vous basé ?';

  @override
  String get driverCityRequired => 'Veuillez entrer votre ville';

  @override
  String get driverGenderRequired => 'Veuillez sélectionner votre genre.';

  @override
  String get driverInterestsRequired =>
      'Veuillez sélectionner au moins un intérêt.';

  @override
  String get driverTermsLabel =>
      'J\'accepte les Conditions d\'utilisation et la Politique de confidentialité.';

  @override
  String get driverTermsRequired =>
      'Vous devez accepter les conditions pour continuer.';

  @override
  String get driverSaveAndContinue => 'Enregistrer et continuer';
}
