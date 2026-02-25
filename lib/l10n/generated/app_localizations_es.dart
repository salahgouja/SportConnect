// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get navHome => 'Inicio';

  @override
  String get navRides => 'Viajes';

  @override
  String get navChat => 'Mensajes';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get settingsNotifications => 'Notificaciones';

  @override
  String get settingsPushNotifications => 'Notificaciones Push';

  @override
  String get settingsPushNotificationsDesc =>
      'Recibir notificaciones push para actualizaciones importantes';

  @override
  String get settingsRideReminders => 'Recordatorios de viaje';

  @override
  String get settingsRideRemindersDesc => 'Ser recordado de viajes próximos';

  @override
  String get settingsChatMessages => 'Mensajes de chat';

  @override
  String get settingsChatMessagesDesc => 'Notificaciones para nuevos mensajes';

  @override
  String get settingsMarketingTips => 'Marketing y consejos';

  @override
  String get settingsMarketingTipsDesc =>
      'Recibir consejos y ofertas promocionales';

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsDarkMode => 'Modo oscuro';

  @override
  String get settingsDarkModeDesc => 'Cambiar al tema oscuro';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageDesc => 'Idioma de visualización de la aplicación';

  @override
  String get settingsDistanceUnit => 'Unidad de distancia';

  @override
  String get settingsDistanceUnitDesc =>
      'Unidad de medida de distancia preferida';

  @override
  String get settingsPrivacySafety => 'Privacidad y seguridad';

  @override
  String get settingsPublicProfile => 'Perfil público';

  @override
  String get settingsPublicProfileDesc => 'Permitir que otros vean tu perfil';

  @override
  String get settingsShowLocation => 'Mostrar ubicación';

  @override
  String get settingsShowLocationDesc =>
      'Compartir tu ubicación en tiempo real durante los viajes';

  @override
  String get settingsAutoAcceptRides => 'Aceptación automática de viajes';

  @override
  String get settingsAutoAcceptRidesDesc =>
      'Aceptar automáticamente solicitudes de viaje';

  @override
  String get settingsBlockedUsers => 'Usuarios bloqueados';

  @override
  String get settingsBlockedUsersDesc => 'Administrar usuarios bloqueados';

  @override
  String get settingsAccount => 'Cuenta';

  @override
  String get settingsEditProfile => 'Editar perfil';

  @override
  String get settingsEditProfileDesc => 'Actualizar tu información de perfil';

  @override
  String get settingsPaymentMethods => 'Métodos de pago';

  @override
  String get settingsPaymentMethodsDesc => 'Administrar tus opciones de pago';

  @override
  String get settingsVerifyAccount => 'Verificar cuenta';

  @override
  String get settingsVerifyAccountDesc =>
      'Completar la verificación de identidad';

  @override
  String get settingsSupport => 'Soporte y legal';

  @override
  String get settingsHelpCenter => 'Centro de ayuda';

  @override
  String get settingsHelpCenterDesc => 'Obtener ayuda y soporte';

  @override
  String get settingsReportProblem => 'Reportar un problema';

  @override
  String get settingsReportProblemDesc => 'Reportar errores o problemas';

  @override
  String get settingsTermsConditions => 'Términos y condiciones';

  @override
  String get settingsPrivacyPolicy => 'Política de privacidad';

  @override
  String get settingsAbout => 'Acerca de';

  @override
  String get settingsAboutDesc => 'Versión de la aplicación e información';

  @override
  String get settingsDangerZone => 'Zona de peligro';

  @override
  String get settingsLogout => 'Cerrar sesión';

  @override
  String get settingsLogoutDesc => 'Cerrar sesión de tu cuenta';

  @override
  String get settingsDeleteAccount => 'Eliminar cuenta';

  @override
  String get settingsDeleteAccountDesc =>
      'Eliminar permanentemente tu cuenta y datos';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignUp => 'Registrarse';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authConfirmPassword => 'Confirmar contraseña';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authResetPassword => 'Restablecer contraseña';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authContinueWithApple => 'Continuar con Apple';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionEdit => 'Editar';

  @override
  String get actionConfirm => 'Confirmar';

  @override
  String get actionSearch => 'Buscar';

  @override
  String get actionFilter => 'Filtrar';

  @override
  String get actionApply => 'Aplicar';

  @override
  String get actionClose => 'Cerrar';

  @override
  String get actionDone => 'Listo';

  @override
  String get errorNetwork => 'Error de red. Por favor verifica tu conexión.';

  @override
  String get errorInvalidInput =>
      'Entrada inválida. Por favor verifica tu entrada.';

  @override
  String get errorPermissionDenied => 'Permiso denegado.';

  @override
  String get errorUnexpected => 'Ocurrió un error inesperado.';

  @override
  String get errorTimeout =>
      'La solicitud expiró. Por favor inténtalo de nuevo.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageSpanish => 'Español';

  @override
  String get pageNotFound => 'Página no encontrada';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String stepValueOfValue(Object value1, Object value2) {
    return 'Paso $value1 de $value2';
  }

  @override
  String get skipTour => 'Saltar recorrido';

  @override
  String get logs => 'Registros';

  @override
  String get theme => 'Tema';

  @override
  String get themePlayground => 'Área de prueba de temas';

  @override
  String get colorScheme => 'Esquema de colores';

  @override
  String surfaceBlendValue(Object value) {
    return 'Mezcla de superficie: $value%';
  }

  @override
  String get useMaterial3 => 'Usar Material 3';

  @override
  String get componentPreview => 'Vista previa de componentes';

  @override
  String get elevated => 'Elevado';

  @override
  String get filled => 'Relleno';

  @override
  String get outlined => 'Delineado';

  @override
  String get text => 'Texto';

  @override
  String get textField => 'Campo de texto';

  @override
  String get enterText => 'Introducir texto...';

  @override
  String get cardTitle => 'Título de la tarjeta';

  @override
  String get cardSubtitleWithDescription =>
      'Subtítulo de tarjeta con descripción';

  @override
  String get chip1 => 'Chip 1';

  @override
  String get action => 'Acción';

  @override
  String get colorPalette => 'Paleta de colores';

  @override
  String get primary => 'Primario';

  @override
  String get secondary => 'Secundario';

  @override
  String get surface => 'Superficie';

  @override
  String get background => 'Fondo';

  @override
  String get error => 'Error';

  @override
  String get copyThemeCode => 'Copiar código del tema';

  @override
  String get applyTheme => 'Aplicar tema';

  @override
  String get themeCodeCopiedToLogs =>
      '¡Código del tema copiado en los registros!';

  @override
  String themeValueApplied(Object value) {
    return '¡Tema \"$value\" aplicado!';
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
  String get dayStreak => 'Racha de días';

  @override
  String value3(Object value) {
    return '#$value';
  }

  @override
  String get you => 'Tú';

  @override
  String valueXp(Object value) {
    return '+$value XP';
  }

  @override
  String valueValue(Object value1, Object value2) {
    return '$value1/$value2';
  }

  @override
  String get standard => 'estándar';

  @override
  String get standard2 => 'Estándar';

  @override
  String get terrain => 'terreno';

  @override
  String get terrain2 => 'Terreno';

  @override
  String get dark => 'oscuro';

  @override
  String get light => 'claro';

  @override
  String get lightMode => 'Modo claro';

  @override
  String get humanitarian => 'humanitario';

  @override
  String get humanitarian2 => 'Humanitario';

  @override
  String get searchAddressCityOrPlace => 'Buscar dirección, ciudad o lugar...';

  @override
  String get popularCities => 'Ciudades populares';

  @override
  String get selectedLocation => 'Ubicación seleccionada';

  @override
  String get confirmLocation => 'Confirmar ubicación';

  @override
  String get nearbyPlaces => 'Lugares cercanos';

  @override
  String get findUsefulSpotsAlongYour =>
      'Encuentra lugares útiles a lo largo de tu ruta';

  @override
  String get searchRadius => 'Radio de búsqueda';

  @override
  String get selectACategoryToSearch => 'Selecciona una categoría para buscar';

  @override
  String get tapOnAnyCategoryAbove =>
      'Toca cualquier categoría arriba para encontrar lugares cercanos';

  @override
  String get noResultsFound => 'No se encontraron resultados';

  @override
  String get tryIncreasingTheSearchRadius =>
      'Intenta aumentar el radio de búsqueda';

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
    return '$value1 viajes • $value2';
  }

  @override
  String value5(Object value) {
    return '$value €';
  }

  @override
  String valueSeatsLeft(Object value) {
    return '$value asientos disponibles';
  }

  @override
  String get fullyBooked => 'Completamente reservado';

  @override
  String get bookNow => 'Reservar ahora';

  @override
  String valueSeats(Object value) {
    return '$value asientos';
  }

  @override
  String errorSavingVehicleValue(Object value) {
    return 'Error al guardar el vehículo: $value';
  }

  @override
  String get driverSetup => 'Configuración del conductor';

  @override
  String get vehicle => 'Vehículo';

  @override
  String get payouts => 'Pagos';

  @override
  String get addYourVehicle => 'Añade tu vehículo';

  @override
  String get fuelType => 'Tipo de combustible';

  @override
  String get setupPayouts => 'Configurar pagos';

  @override
  String get securePayments => 'Pagos seguros';

  @override
  String get fastTransfers => 'Transferencias rápidas';

  @override
  String get easyTracking => 'Seguimiento fácil';

  @override
  String get skipForNowILl => 'Omitir por ahora, lo configuraré más tarde';

  @override
  String get youCanStillOfferRides =>
      'Aún puedes ofrecer viajes sin configurar pagos, pero no podrás recibir pagos hasta que completes este paso.';

  @override
  String get sportconnect => 'SportConnect';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get signInToContinueYour =>
      'Inicia sesión para continuar tu viaje de carrera';

  @override
  String get rememberMe => 'Recuérdame';

  @override
  String get donTHaveAnAccount => '¿No tienes una cuenta? ';

  @override
  String get enterYourEmailAddressAnd =>
      'Introduce tu dirección de correo y te enviaremos instrucciones para restablecer tu contraseña.';

  @override
  String get passwordResetEmailSentCheck =>
      '¡Correo de restablecimiento de contraseña enviado! Revisa tu bandeja de entrada.';

  @override
  String get pleaseAgreeToTheTerms =>
      'Por favor acepta los Términos de servicio';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get joinOurCommunityOfEco =>
      'Únete a nuestra comunidad de viajeros ecológicos';

  @override
  String get welcomeBonus => 'Bono de bienvenida';

  @override
  String get get100XpWhenYou => '¡Obtén 100 XP al completar tu perfil!';

  @override
  String get iWantTo => 'Quiero:';

  @override
  String get alreadyHaveAnAccount => '¿Ya tienes una cuenta? ';

  @override
  String get findRides => 'Encontrar viajes';

  @override
  String get offerRides => 'Ofrecer viajes';

  @override
  String get pleaseSelectARoleTo =>
      'Por favor selecciona un rol para continuar';

  @override
  String errorValue(Object value) {
    return 'Error: $value';
  }

  @override
  String get iMARider => 'Soy un pasajero';

  @override
  String get iMADriver => 'Soy un conductor';

  @override
  String get youCanChangeYourRole =>
      'Puedes cambiar tu rol más tarde en la configuración';

  @override
  String get howWillYouUseSportconnect => '¿Cómo usarás SportConnect?';

  @override
  String get chooseYourRoleToGet =>
      'Elige tu rol para comenzar.\nEsto personalizará tu experiencia.';

  @override
  String get text2 => '🎉';

  @override
  String get join10000EcoRiders => 'Únete a más de 10,000 viajeros ecológicos';

  @override
  String get get100XpWelcomeBonus => '¡Obtén 100 XP de bono de bienvenida!';

  @override
  String get orSignUpWith => 'O regístrate con';

  @override
  String get strongPasswordTips => 'Consejos para una contraseña fuerte';

  @override
  String get use8CharactersWithLetters =>
      'Usa 8+ caracteres con letras, números y símbolos';

  @override
  String get passwordStrength => 'Fortaleza de la contraseña';

  @override
  String get yourInterestsOptional => 'Tus intereses (Opcional)';

  @override
  String get selectSportsYouReInterested =>
      'Selecciona los deportes que te interesan';

  @override
  String get addAProfilePhoto => 'Añadir una foto de perfil';

  @override
  String get thisHelpsOthersRecognizeYou => 'Esto ayuda a otros a reconocerte';

  @override
  String get readyToJoin => '¡Listo para unirte!';

  @override
  String emailValue(Object value) {
    return 'Correo: $value';
  }

  @override
  String roleValue(Object value) {
    return 'Rol: $value';
  }

  @override
  String get carpoolingForRunners => 'VIAJES COMPARTIDOS PARA CORREDORES';

  @override
  String get shareRidesRunTogetherGo =>
      'Comparte viajes. Corre juntos.\nVe más lejos.';

  @override
  String get loading => 'Cargando...';

  @override
  String get offerRide => 'Ofrecer viaje';

  @override
  String get driver => 'Conductor';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Fuera de línea';

  @override
  String get acceptingRideRequests => 'Aceptando solicitudes de viaje';

  @override
  String get tapToGoOnlineAnd => 'Toca para conectarte y comenzar a ganar';

  @override
  String get failedToLoadStatus => 'Error al cargar el estado';

  @override
  String get todaySEarnings => 'Ganancias de hoy';

  @override
  String get live => 'En vivo';

  @override
  String value6(Object value) {
    return '$value€';
  }

  @override
  String valueRides(Object value) {
    return '$value viajes';
  }

  @override
  String get failedToLoadEarnings => 'Error al cargar las ganancias';

  @override
  String get rideRequests => 'Solicitudes de viaje';

  @override
  String get viewAll => 'Ver todo';

  @override
  String get noPendingRequests => 'No hay solicitudes pendientes';

  @override
  String get failedToLoadRequests => 'Error al cargar las solicitudes';

  @override
  String get noAcceptedRequestsYet => 'Sin solicitudes aceptadas';

  @override
  String get acceptedRequestsWillAppearHere =>
      'Las solicitudes de viaje aceptadas aparecerán aquí';

  @override
  String get upcomingRides => 'Viajes próximos';

  @override
  String get noUpcomingRides => 'No hay viajes próximos';

  @override
  String get failedToLoadRides => 'Error al cargar los viajes';

  @override
  String get kNew => 'Nuevo';

  @override
  String valueSeatValue(Object value1, Object value2) {
    return '$value1 asiento$value2';
  }

  @override
  String get decline => 'Rechazar';

  @override
  String get accept => 'Aceptar';

  @override
  String valueValue2(Object value1, Object value2) {
    return '$value1 → $value2';
  }

  @override
  String get earned => 'ganado';

  @override
  String get gettingLocation => 'Obteniendo ubicación...';

  @override
  String get loadingRoute => 'Cargando ruta...';

  @override
  String valueKm(Object value) {
    return '$value km';
  }

  @override
  String get rides => 'viajes';

  @override
  String get seats => 'asientos';

  @override
  String get whereAreYouGoing => '¿A dónde vas?';

  @override
  String get hotspots => 'Puntos calientes';

  @override
  String get nearbyRides => 'Viajes cercanos';

  @override
  String get followLocation => 'Seguir ubicación';

  @override
  String valueMin(Object value) {
    return '$value min';
  }

  @override
  String get mapStyle => 'Estilo de mapa';

  @override
  String get dark2 => 'Oscuro';

  @override
  String get findARide => 'Encontrar un viaje';

  @override
  String get filters => 'Filtros';

  @override
  String get fromWhere => '¿Desde dónde?';

  @override
  String get toWhere => '¿Hacia dónde?';

  @override
  String valueAvailable(Object value) {
    return '$value disponible';
  }

  @override
  String get noRidesAvailableNearby => 'No hay viajes disponibles cerca';

  @override
  String get tryExpandingYourSearchRadius =>
      'Intenta ampliar tu radio de búsqueda';

  @override
  String get pickupPoint => 'Punto de recogida';

  @override
  String get destination => 'Destino';

  @override
  String get eco => 'Eco';

  @override
  String get premium => 'Premium';

  @override
  String get pickupLocation => 'Lugar de recogida';

  @override
  String get bookThisRide => 'Reservar este viaje';

  @override
  String get ride => 'viaje';

  @override
  String get seat => 'asiento';

  @override
  String get sendingImage => 'Enviando imagen...';

  @override
  String failedToSendImageValue(Object value) {
    return 'Error al enviar la imagen: $value';
  }

  @override
  String failedToStartCallValue(Object value) {
    return 'Error al iniciar la llamada: $value';
  }

  @override
  String get viewProfile => 'Ver perfil';

  @override
  String get searchInChat => 'Buscar en el chat';

  @override
  String get muteNotifications => 'Silenciar notificaciones';

  @override
  String get clearChat => 'Limpiar chat';

  @override
  String get notificationsMutedForThisChat =>
      'Notificaciones silenciadas para este chat';

  @override
  String get areYouSureYouWant =>
      '¿Estás seguro de que quieres eliminar todos los mensajes? Esta acción no se puede deshacer.';

  @override
  String get chatCleared => 'Chat limpiado';

  @override
  String get clear => 'Limpiar';

  @override
  String get noMessagesYet => 'Aún no hay mensajes';

  @override
  String get sendAMessageToStart =>
      'Envía un mensaje para iniciar la conversación';

  @override
  String get typing => 'escribiendo...';

  @override
  String replyingToValue(Object value) {
    return 'Respondiendo a $value';
  }

  @override
  String get tapToOpenMap => 'Toca para abrir el mapa';

  @override
  String get open => 'Abrir';

  @override
  String get thisMessageWasDeleted => 'Este mensaje fue eliminado';

  @override
  String get edited => 'editado';

  @override
  String get reply => 'Responder';

  @override
  String get copy => 'Copiar';

  @override
  String get messageCopied => 'Mensaje copiado';

  @override
  String get editMessage => 'Editar mensaje';

  @override
  String get typeAMessage => 'Escribe un mensaje...';

  @override
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get document => 'Documento';

  @override
  String get location => 'Ubicación';

  @override
  String get gettingYourLocation => 'Obteniendo tu ubicación...';

  @override
  String get locationShared => 'Ubicación compartida';

  @override
  String get coordinatesCopiedToClipboard =>
      'Coordenadas copiadas al portapapeles';

  @override
  String couldNotOpenMapsValue(Object value) {
    return 'No se pudieron abrir los mapas: $value';
  }

  @override
  String get recordingReleaseToSend => 'Grabando... Suelta para enviar';

  @override
  String get voiceNote => 'Nota de voz';

  @override
  String get voiceNotesComingSoonUse =>
      '¡Notas de voz próximamente! Usa texto por ahora.';

  @override
  String get recordingCancelled => 'Grabación cancelada';

  @override
  String get messages => 'Mensajes';

  @override
  String get pleaseLoginToViewChats =>
      'Por favor inicia sesión para ver los chats';

  @override
  String get failedToLoadChats => 'Error al cargar los chats';

  @override
  String get retry => 'Reintentar';

  @override
  String get noConversationsYet => 'Aún no hay conversaciones';

  @override
  String get noGroupChats => 'No hay chats grupales';

  @override
  String get noRideChats => 'No hay chats de viajes';

  @override
  String get callHistory => 'Historial de llamadas';

  @override
  String get noCallHistory => 'No hay historial de llamadas';

  @override
  String get videoCall => 'Video call';

  @override
  String get voiceCall => 'Voice call';

  @override
  String get text3 => ' • ';

  @override
  String get newMessage => 'Nuevo mensaje';

  @override
  String get searchUsersByName => 'Buscar usuarios por nombre...';

  @override
  String get searchForAUserTo => 'Busca un usuario para empezar a chatear';

  @override
  String get typeAtLeast2Characters => 'Escribe al menos 2 caracteres';

  @override
  String noUsersFoundForValue(Object value) {
    return 'No se encontraron usuarios para \"$value\"';
  }

  @override
  String get allNotificationsMarkedAsRead =>
      'Todas las notificaciones marcadas como leídas';

  @override
  String get clearAllNotifications => 'Borrar todas las notificaciones';

  @override
  String get areYouSureYouWant2 =>
      '¿Estás seguro de que quieres borrar todas las notificaciones?';

  @override
  String get allNotificationsCleared => 'Todas las notificaciones borradas';

  @override
  String get failedToClearNotifications => 'Error al borrar las notificaciones';

  @override
  String get clearAll => 'Borrar todo';

  @override
  String get pleaseSignInToView =>
      'Por favor inicia sesión para ver las notificaciones';

  @override
  String get unread => 'No leídas';

  @override
  String valueNew(Object value) {
    return '$value nuevo';
  }

  @override
  String get markAllAsRead => 'Marcar todo como leído';

  @override
  String get clearAll2 => 'Borrar todo';

  @override
  String get noNotifications => 'No hay notificaciones';

  @override
  String get youReAllCaughtUp => '¡Estás al día!';

  @override
  String couldNotOpenChatValue(Object value) {
    return 'No se pudo abrir el chat: $value';
  }

  @override
  String get youReReadyToRun => 'Estás listo para correr';

  @override
  String get createAnAccountToStart =>
      'Crea una cuenta para comenzar a seguir tus carreras y conectar con otros corredores.';

  @override
  String get kContinue => 'Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get earnings => 'Ganancias';

  @override
  String get totalEarnings => 'Ganancias totales';

  @override
  String thisWeekValue(Object value) {
    return 'Esta semana: $value €';
  }

  @override
  String get earningsOverview => 'Resumen de ganancias';

  @override
  String get active => 'Activo';

  @override
  String get ridesEarnings => 'Ganancias de viajes';

  @override
  String get tipsBonuses => 'Propinas y bonificaciones';

  @override
  String get environmentalImpact => 'Impacto ambiental';

  @override
  String valueKgCoSaved(Object value) {
    return '$value kg CO₂ ahorrados';
  }

  @override
  String get stripeConnected => 'Stripe conectado';

  @override
  String get setUpPayouts => 'Configurar pagos';

  @override
  String get receivePaymentsFromRiders => 'Recibir pagos de los pasajeros';

  @override
  String get completeVerification => 'Completar verificación';

  @override
  String get connectYourBankAccount => 'Conecta tu cuenta bancaria';

  @override
  String get availableBalance => 'Saldo disponible';

  @override
  String get confirmPayout => 'Confirmar pago';

  @override
  String withdrawValueToYourConnected(Object value) {
    return '¿Retirar $value € a tu cuenta bancaria conectada?';
  }

  @override
  String get withdraw => 'Retirar';

  @override
  String payoutOfValueInitiated(Object value) {
    return '¡Pago de $value € iniciado!';
  }

  @override
  String get payoutFailedPleaseTryAgain =>
      'Pago fallido. Por favor inténtalo de nuevo.';

  @override
  String get recentTransactions => 'Transacciones recientes';

  @override
  String get noTransactionsYet => 'Aún no hay transacciones';

  @override
  String get failedToLoadTransactions => 'Error al cargar las transacciones';

  @override
  String valueValue3(Object value1, Object value2) {
    return '$value1$value2 €';
  }

  @override
  String get getPaidForYourRides => 'Recibe pagos por tus viajes';

  @override
  String get connectYourBankAccountTo =>
      'Conecta tu cuenta bancaria para recibir pagos directamente de los pasajeros. Impulsado por Stripe para transacciones seguras.';

  @override
  String get instantPayouts => 'Pagos instantáneos';

  @override
  String get secureProtected => 'Seguro y protegido';

  @override
  String get clearTracking => 'Seguimiento claro';

  @override
  String get lowFees => 'Tarifas bajas';

  @override
  String get youLlBeRedirectedTo =>
      'Serás redirigido a Stripe para completar la configuración';

  @override
  String get connectStripe => 'Conectar Stripe';

  @override
  String get stripeAccountConnectedSuccessfully =>
      '¡Cuenta de Stripe conectada con éxito!';

  @override
  String errorLoadingPageValue(Object value) {
    return 'Error al cargar la página: $value';
  }

  @override
  String get pleaseSignInToView2 =>
      'Por favor inicia sesión para ver el historial de pagos';

  @override
  String get paymentHistory => 'Historial de pagos';

  @override
  String get yourTransactions => 'Tus transacciones';

  @override
  String get noPaymentsFound => 'No se encontraron pagos';

  @override
  String get yourPaymentHistoryWillAppear =>
      'Tu historial de pagos aparecerá aquí';

  @override
  String get ridePayment => 'Pago de viaje';

  @override
  String get unknownDate => 'Fecha desconocida';

  @override
  String valueValue4(Object value1, Object value2) {
    return '$value1 $value2';
  }

  @override
  String get paymentDetails => 'Detalles del pago';

  @override
  String get amount => 'Cantidad';

  @override
  String get status => 'Estado';

  @override
  String get seats2 => 'Asientos';

  @override
  String get platformFee => 'Tarifa de plataforma';

  @override
  String get card => 'Tarjeta';

  @override
  String value7(Object value) {
    return '•••• $value';
  }

  @override
  String get date => 'Fecha';

  @override
  String get transactionId => 'ID de transacción';

  @override
  String get requestRefund => 'Solicitar reembolso';

  @override
  String get errorLoadingAchievements => 'Error al cargar los logros';

  @override
  String levelValueValue(Object value1, Object value2) {
    return 'Nivel $value1 - $value2';
  }

  @override
  String valueXp2(Object value) {
    return '$value XP';
  }

  @override
  String valueXpToLevelValue(Object value1, Object value2) {
    return '$value1 XP para nivel $value2';
  }

  @override
  String get text4 => '🏆';

  @override
  String get badges => 'Insignias';

  @override
  String get text5 => '🎯';

  @override
  String get challenges => 'Desafíos';

  @override
  String get text6 => '🚗';

  @override
  String get text7 => '🌍';

  @override
  String get kgCo => 'kg CO₂';

  @override
  String get unlocked => '✓ Desbloqueado';

  @override
  String get locked => '🔒 Bloqueado';

  @override
  String valueComplete(Object value) {
    return '$value% Completado';
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
    return 'Nivel $value';
  }

  @override
  String get verifiedDriver => 'Conductor verificado';

  @override
  String get rating => 'Calificación';

  @override
  String get trips => 'Viajes';

  @override
  String get member => 'Miembro';

  @override
  String get text12 => '...';

  @override
  String get text00 => '0.0';

  @override
  String get quickActions => 'Acciones rápidas';

  @override
  String get performanceOverview => 'Resumen de rendimiento';

  @override
  String get totalTrips => 'Viajes totales';

  @override
  String valueThisMonth(Object value) {
    return '+$value este mes';
  }

  @override
  String valueThisMonth2(Object value) {
    return '+$value € este mes';
  }

  @override
  String get coSaved => 'CO₂ ahorrado';

  @override
  String valueKg(Object value) {
    return '$value kg';
  }

  @override
  String get sinceJoining => 'Desde que te uniste';

  @override
  String get avgRating => 'Calificación promedio';

  @override
  String get last100Trips => 'Últimos 100 viajes';

  @override
  String get noData => 'Sin datos';

  @override
  String get text0 => '0 €';

  @override
  String get text0Kg => '0 kg';

  @override
  String get weeklyActivity => 'Actividad semanal';

  @override
  String get ratingBreakdown => 'Desglose de calificaciones';

  @override
  String get tripsThisWeek => 'Viajes esta semana';

  @override
  String valueTrips(Object value) {
    return '$value viajes';
  }

  @override
  String get driverSettings => 'Configuración de conductor';

  @override
  String get ridePreferences => 'Preferencias de viaje';

  @override
  String get autoAcceptRequests => 'Aceptar solicitudes automáticamente';

  @override
  String get automaticallyAcceptRideRequestsThat =>
      'Aceptar automáticamente solicitudes de viaje que coincidan con tus criterios';

  @override
  String get allowInstantBooking => 'Permitir reserva instantánea';

  @override
  String get letPassengersBookWithoutWaiting =>
      'Permitir a los pasajeros reservar sin esperar aprobación';

  @override
  String get maximumPickupDistance => 'Distancia máxima de recogida';

  @override
  String get onlyReceiveRequestsWithinThis =>
      'Solo recibir solicitudes dentro de esta distancia';

  @override
  String get paymentSettings => 'Configuración de pago';

  @override
  String get acceptCashPayments => 'Aceptar pagos en efectivo';

  @override
  String get allowPassengersToPayWith =>
      'Permitir a los pasajeros pagar en efectivo';

  @override
  String get acceptCardPayments => 'Aceptar pagos con tarjeta';

  @override
  String get allowPassengersToPayWith2 =>
      'Permitir a los pasajeros pagar con tarjeta en la aplicación';

  @override
  String get payoutMethod => 'Método de pago';

  @override
  String get bankAccountEndingIn4532 => 'Cuenta bancaria terminada en 4532';

  @override
  String get taxDocuments => 'Documentos fiscales';

  @override
  String get viewAndDownloadTaxForms => 'Ver y descargar formularios fiscales';

  @override
  String get navigationMap => 'Navegación y mapa';

  @override
  String get showOnDriverMap => 'Mostrar en el mapa del conductor';

  @override
  String get allowPassengersToSeeYour =>
      'Permitir a los pasajeros ver tu ubicación';

  @override
  String get preferredNavigationApp => 'Aplicación de navegación preferida';

  @override
  String get soundEffects => 'Efectos de sonido';

  @override
  String get playSoundsForNewRequests =>
      'Reproducir sonidos para nuevas solicitudes y mensajes';

  @override
  String get vibration => 'Vibración';

  @override
  String get vibrateForImportantAlerts => 'Vibrar para alertas importantes';

  @override
  String get notificationPreferences => 'Preferencias de notificaciones';

  @override
  String get customizeWhatNotificationsYouReceive =>
      'Personaliza qué notificaciones recibes';

  @override
  String get nightMode => 'Modo nocturno';

  @override
  String get reduceEyeStrainInLow => 'Reducir la fatiga visual en poca luz';

  @override
  String get accountSecurity => 'Cuenta y seguridad';

  @override
  String get driverDocuments => 'Documentos de conductor';

  @override
  String get licenseInsuranceAndRegistration => 'Licencia, seguro y registro';

  @override
  String get backgroundCheck => 'Verificación de antecedentes';

  @override
  String get viewYourVerificationStatus => 'Ver tu estado de verificación';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get updateYourAccountPassword =>
      'Actualiza la contraseña de tu cuenta';

  @override
  String get twoFactorAuthentication => 'Autenticación de dos factores';

  @override
  String get addExtraSecurityToYour => 'Añade seguridad extra a tu cuenta';

  @override
  String get support => 'Soporte';

  @override
  String get driverHelpCenter => 'Centro de ayuda para conductores';

  @override
  String get faqsAndTroubleshootingGuides =>
      'Preguntas frecuentes y guías de solución de problemas';

  @override
  String get contactSupport => 'Contactar con soporte';

  @override
  String get chatWithOurSupportTeam => 'Chatea con nuestro equipo de soporte';

  @override
  String get reportASafetyIssue => 'Reportar un problema de seguridad';

  @override
  String get reportIncidentsOrConcerns =>
      'Reportar incidentes o preocupaciones';

  @override
  String get accountActions => 'Acciones de cuenta';

  @override
  String get switchToRiderMode => 'Cambiar a modo pasajero';

  @override
  String get useTheAppAsA => 'Usa la aplicación como pasajero';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get logOutOfYourAccount => 'Cierra sesión en tu cuenta';

  @override
  String get pauseDriverAccount => 'Pausar cuenta de conductor';

  @override
  String get temporarilyStopReceivingRequests =>
      'Deja de recibir solicitudes temporalmente';

  @override
  String get deleteDriverAccount => 'Eliminar cuenta de conductor';

  @override
  String get permanentlyRemoveYourDriverProfile =>
      'Elimina permanentemente tu perfil de conductor';

  @override
  String get sportconnectDriver => 'SportConnect Conductor';

  @override
  String get version210 => 'Versión 2.1.0';

  @override
  String get areYouSureYouWant3 =>
      '¿Estás seguro de que quieres cerrar sesión en tu cuenta?';

  @override
  String get thisActionCannotBeUndone =>
      'Esta acción no se puede deshacer. Todos tus datos de conductor, historial de ganancias y calificaciones se eliminarán permanentemente.';

  @override
  String get pleaseSignInToManage =>
      'Por favor inicia sesión para gestionar vehículos';

  @override
  String get myVehicles => 'Mis vehículos';

  @override
  String get noVehiclesAdded => 'No se han añadido vehículos';

  @override
  String get addYourFirstVehicleTo =>
      'Añade tu primer vehículo para empezar\na ofrecer viajes';

  @override
  String get addVehicle => 'Añadir vehículo';

  @override
  String get vehicleSetAsActive => 'Vehículo establecido como activo';

  @override
  String get deleteVehicle => 'Eliminar vehículo';

  @override
  String areYouSureYouWant4(Object value) {
    return '¿Estás seguro de que quieres eliminar $value?';
  }

  @override
  String get vehicleDeleted => 'Vehículo eliminado';

  @override
  String get setActive => 'Establecer como activo';

  @override
  String get editVehicle => 'Editar vehículo';

  @override
  String get addPhoto => 'Añadir foto';

  @override
  String get make => 'Marca';

  @override
  String get model => 'Modelo';

  @override
  String get year => 'Año';

  @override
  String get color => 'Color';

  @override
  String get licensePlate => 'Placa de matrícula';

  @override
  String get passengerCapacity => 'Capacidad de pasajeros';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get capacity => 'Capacidad';

  @override
  String valuePassengers(Object value) {
    return '$value pasajeros';
  }

  @override
  String get totalRides => 'Viajes totales';

  @override
  String value8(Object value) {
    return '$value ⭐';
  }

  @override
  String get features => 'Características';

  @override
  String get changePhoto => 'Cambiar foto';

  @override
  String get personalInformation => 'Información personal';

  @override
  String get aboutYou => 'Sobre ti';

  @override
  String get demographics => 'Demografía';

  @override
  String get gender => 'Género';

  @override
  String get birthday => 'Fecha de nacimiento';

  @override
  String get sportsInterests => 'Intereses deportivos';

  @override
  String get add => '+ Añadir';

  @override
  String get noInterestsSelected => 'No hay intereses seleccionados';

  @override
  String get profileUpdated => 'Perfil actualizado';

  @override
  String get changeProfilePhoto => 'Cambiar foto de perfil';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get chooseFromGallery => 'Elegir de la galería';

  @override
  String get removePhoto => 'Eliminar foto';

  @override
  String get selectGender => 'Seleccionar género';

  @override
  String get selectSportsInterests => 'Seleccionar intereses deportivos';

  @override
  String get discardChanges => '¿Descartar cambios?';

  @override
  String get youHaveUnsavedChanges => 'Tienes cambios sin guardar.';

  @override
  String get discard => 'Descartar';

  @override
  String get failedToLoadProfile => 'Error al cargar el perfil';

  @override
  String get pleaseCheckYourConnectionAnd =>
      'Por favor verifica tu conexión e inténtalo de nuevo';

  @override
  String get myProfile => 'Mi perfil';

  @override
  String memberSinceValue(Object value) {
    return 'Miembro desde $value';
  }

  @override
  String get newMember => 'Nuevo miembro';

  @override
  String get verifiedInfo => 'Información verificada';

  @override
  String get verified => 'Verificado';

  @override
  String get notVerified => 'No verificado';

  @override
  String get rideStatistics => 'Estadísticas de viajes';

  @override
  String get saved => 'Ahorrado';

  @override
  String get earned2 => 'Ganado';

  @override
  String get profileNotFound => 'Perfil no encontrado';

  @override
  String get yourProfileDataCouldNot =>
      'No se pudieron cargar los datos de tu perfil.\nEsto puede pasar si eres un usuario nuevo.';

  @override
  String get signOutTryAgain => 'Cerrar sesión e intentar de nuevo';

  @override
  String get findPeople => 'Encontrar personas';

  @override
  String get searchByName => 'Buscar por nombre';

  @override
  String get searchUsers => 'Buscar usuarios...';

  @override
  String get findFellowRiders => 'Encontrar compañeros de viaje';

  @override
  String get searchForUsersByTheir =>
      'Busca usuarios por su nombre\npara conectar y compartir viajes';

  @override
  String get popularSearches => 'Búsquedas populares';

  @override
  String get searching => 'Buscando...';

  @override
  String get noResultsFound2 => 'No se encontraron resultados';

  @override
  String noUsersFoundMatchingValue(Object value) {
    return 'No se encontraron usuarios que coincidan con \"$value\"';
  }

  @override
  String get tryADifferentSearchTerm =>
      'Intenta con un término de búsqueda diferente';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get vehicles => 'Vehículos';

  @override
  String get legal => 'Legal';

  @override
  String get sportconnectV100 => 'SportConnect v1.0.0';

  @override
  String get noBlockedUsers => 'No hay usuarios bloqueados';

  @override
  String get usersYouBlockWillAppear =>
      'Los usuarios que bloquees aparecerán aquí';

  @override
  String get comingSoon => 'Próximamente';

  @override
  String get paymentIntegrationWillBeAvailable =>
      'La integración de pagos estará disponible pronto';

  @override
  String get currentPassword => 'Contraseña actual';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmNewPassword => 'Confirmar nueva contraseña';

  @override
  String get passwordUpdatedSuccessfully => 'Contraseña actualizada con éxito';

  @override
  String get update => 'Actualizar';

  @override
  String get gettingStarted => 'Primeros pasos';

  @override
  String get ridesCarpooling => 'Viajes y viajes compartidos';

  @override
  String get safetyTrust => 'Seguridad y confianza';

  @override
  String get accountSettings => 'Cuenta y configuración';

  @override
  String openingValue(Object value) {
    return 'Apertura: $value';
  }

  @override
  String get weReHereToHelp =>
      '¡Estamos aquí para ayudar! Elige cómo quieres contactarnos.';

  @override
  String get emailSupport => 'Soporte por correo';

  @override
  String get couldNotOpenEmailApp => 'No se pudo abrir la aplicación de correo';

  @override
  String get liveChat => 'Chat en vivo';

  @override
  String get liveChatWillBeAvailable =>
      '¡El chat en vivo estará disponible pronto!';

  @override
  String get phoneSupport => 'Soporte telefónico';

  @override
  String get category => 'Categoría';

  @override
  String get describeTheProblem => 'Describe el problema';

  @override
  String get pleaseDescribeWhatHappened => 'Por favor describe qué pasó...';

  @override
  String get thankYouYourReportHas => '¡Gracias! Tu reporte ha sido enviado.';

  @override
  String get submit => 'Enviar';

  @override
  String get areYouSureYouWant5 =>
      '¿Estás seguro de que quieres cerrar sesión en SportConnect?';

  @override
  String get thisActionCannotBeUndone2 =>
      'Esta acción no se puede deshacer. Todos tus datos, incluyendo:';

  @override
  String get rideHistoryAndBookings => 'Historial de viajes y reservas';

  @override
  String get profileAndAchievements => 'Perfil y logros';

  @override
  String get messagesAndConnections => 'Mensajes y conexiones';

  @override
  String get paymentInformation => 'Información de pago';

  @override
  String get typeDeleteToConfirm => 'Escribe \"DELETE\" para confirmar:';

  @override
  String failedToDeleteAccountValue(Object value) {
    return 'Error al eliminar la cuenta: $value';
  }

  @override
  String get addRide => 'Añadir viaje';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get errorLoadingVehicles => 'Error al cargar vehículos';

  @override
  String get myGarage => 'Mi garaje';

  @override
  String valueVehicles(Object value) {
    return '$value vehículos';
  }

  @override
  String get setDefault => 'Establecer por defecto';

  @override
  String get pending => 'Pendiente';

  @override
  String get plate => 'Placa';

  @override
  String get garageIsEmpty => 'El garaje está vacío';

  @override
  String get addAVehicleToStart =>
      'Añade un vehículo para comenzar tu viaje. Conéctate con otros y comparte viajes.';

  @override
  String get quickTip => 'Consejo rápido';

  @override
  String get swipeRightOnAVehicle =>
      'Desliza a la derecha en una tarjeta de vehículo para establecerlo como predeterminado. Desliza a la izquierda para eliminarlo.';

  @override
  String get deleteRide => '¿Eliminar viaje?';

  @override
  String areYouSureYouWant6(Object value) {
    return '¿Estás seguro de que quieres eliminar $value? Esto no se puede deshacer.';
  }

  @override
  String get keepIt => 'Mantenerlo';

  @override
  String get vehicleRemovedFromGarage => 'Vehículo eliminado del garaje';

  @override
  String get editRide => 'Editar viaje';

  @override
  String get newRide => 'Nuevo viaje';

  @override
  String get seatsCapacity => 'Capacidad de asientos';

  @override
  String valueSReviews(Object value) {
    return 'Reseñas de $value';
  }

  @override
  String get noReviewsYet => 'Aún no hay reseñas';

  @override
  String get failedToLoadReviews => 'Error al cargar las reseñas';

  @override
  String valueReviews(Object value) {
    return '$value reseñas';
  }

  @override
  String get rider => 'Pasajero';

  @override
  String get response => 'Respuesta';

  @override
  String get leaveAReview => 'Dejar una reseña';

  @override
  String get howWasYourExperience => '¿Cómo fue tu experiencia?';

  @override
  String get whatStoodOut => '¿Qué destacó?';

  @override
  String get additionalCommentsOptional => 'Comentarios adicionales (opcional)';

  @override
  String get skipForNow => 'Omitir por ahora';

  @override
  String get yourDriver => 'Tu conductor';

  @override
  String get yourPassenger => 'Tu pasajero';

  @override
  String get shareYourExperience => 'Comparte tu experiencia...';

  @override
  String get thankYouForYourReview => '¡Gracias por tu reseña!';

  @override
  String valueValue5(Object value1, Object value2) {
    return '$value1$value2';
  }

  @override
  String get errorLoadingRide => 'Error al cargar el viaje';

  @override
  String get goBack => 'Volver';

  @override
  String get tooltipShowPassword => 'Mostrar contraseña';

  @override
  String get tooltipHidePassword => 'Ocultar contraseña';

  @override
  String get activeRide => 'Viaje activo';

  @override
  String get noActiveRide => 'No hay viaje activo';

  @override
  String get startARideToSee => 'Inicia un viaje para ver la navegación';

  @override
  String get headingToPickup => 'Dirigiéndose a la recogida';

  @override
  String get headingToDestination => 'Dirigiéndose al destino';

  @override
  String etaValueMinValueKm(Object value1, Object value2) {
    return 'ETA: $value1 min • $value2 km restantes';
  }

  @override
  String arrivingAtValue(Object value) {
    return 'Llegando a $value';
  }

  @override
  String get distance => 'Distancia';

  @override
  String get duration => 'Duración';

  @override
  String get fare => 'Tarifa';

  @override
  String get call => 'Llamar';

  @override
  String get message => 'Mensaje';

  @override
  String get text5Min => '5 min';

  @override
  String valueMore(Object value) {
    return '+$value más';
  }

  @override
  String valuePassengerValue(Object value1, Object value2) {
    return '$value1 pasajero$value2';
  }

  @override
  String valueSeatValueBooked(Object value1, Object value2) {
    return '• $value1 asiento$value2 reservado';
  }

  @override
  String valueSeatValueBooked2(Object value1, Object value2) {
    return '$value1 asiento$value2 reservado';
  }

  @override
  String get passengers => 'Pasajeros';

  @override
  String get seat2 => '€/asiento';

  @override
  String get min => 'min';

  @override
  String get pickup => 'Recogida';

  @override
  String get dropoff => 'Entrega';

  @override
  String valuePassengerValueBookedFor(Object value1, Object value2) {
    return '$value1 pasajero$value2 reservado para este viaje';
  }

  @override
  String get cancelRide => '¿Cancelar viaje?';

  @override
  String get areYouSureYouWant7 =>
      '¿Estás seguro de que quieres cancelar este viaje? Esto puede afectar tu calificación como conductor.';

  @override
  String get continueRide => 'Continuar viaje';

  @override
  String get cancelRide2 => 'Cancelar viaje';

  @override
  String get dashboard => 'Panel de control';

  @override
  String get manageYourRidesEarnings => 'Gestiona tus viajes y ganancias';

  @override
  String get requests => 'Solicitudes';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get noPendingRequests2 => 'No hay solicitudes pendientes';

  @override
  String get newRequest => 'NUEVA SOLICITUD';

  @override
  String get tapToRespond => 'Toca para responder';

  @override
  String value9(Object value) {
    return '+€$value';
  }

  @override
  String get earnings2 => 'ganancias';

  @override
  String valueValue6(Object value1, Object value2) {
    return '$value1 • $value2';
  }

  @override
  String get failedToLoadUser => 'Error al cargar el usuario';

  @override
  String get noActiveRides => 'No hay viajes activos';

  @override
  String get rideInProgress => 'VIAJE EN CURSO';

  @override
  String valueValuePassengers(Object value1, Object value2) {
    return '$value1/$value2 pasajeros';
  }

  @override
  String get navigate => 'Navegar';

  @override
  String get complete => 'Completar';

  @override
  String get noScheduledRides => 'No hay viajes programados';

  @override
  String valueSeat(Object value) {
    return '€$value/asiento';
  }

  @override
  String get noCompletedRides => 'No hay viajes completados';

  @override
  String valueValuePassengers2(Object value1, Object value2) {
    return '$value1 • $value2 pasajeros';
  }

  @override
  String get loadingYourRides => 'Cargando tus viajes...';

  @override
  String get signInRequired => 'Inicio de sesión requerido';

  @override
  String get bookingAccepted => '¡Reserva aceptada!';

  @override
  String get bookingDeclined => 'Reserva rechazada';

  @override
  String get rideCompletedWellDone => '¡Viaje completado! Bien hecho 🎉';

  @override
  String get manageVehicles => 'Gestionar vehículos';

  @override
  String get earningsHistory => 'Historial de ganancias';

  @override
  String get preferences => 'Preferencias';

  @override
  String get offerARide => 'Ofrecer un viaje';

  @override
  String get driverAccountRequired => 'Se requiere cuenta de conductor';

  @override
  String get youNeedToRegisterAs =>
      'Necesitas registrarte como conductor y agregar un vehículo para ofrecer viajes.';

  @override
  String get shareYourJourneyEarnMoney => 'Comparte tu viaje, gana dinero';

  @override
  String get yourRoute => 'Tu ruta';

  @override
  String get startingPoint => 'Punto de partida';

  @override
  String get departureTime => 'Hora de salida';

  @override
  String get recurringRide => 'Viaje recurrente';

  @override
  String get offerThisRideRegularly => 'Ofrecer este viaje regularmente';

  @override
  String get addAVehicleToStart2 =>
      'Añade un vehículo para comenzar a ofrecer viajes';

  @override
  String get selectVehicle => 'Seleccionar vehículo';

  @override
  String get add2 => 'Añadir';

  @override
  String get availableSeats => 'Asientos disponibles';

  @override
  String maxValuePassengers(Object value) {
    return 'Máx $value pasajeros';
  }

  @override
  String get selectAVehicleFirst => 'Selecciona un vehículo primero';

  @override
  String get pricePerSeat => 'Precio por asiento';

  @override
  String get priceNegotiable => 'Precio negociable';

  @override
  String get acceptOnlinePayment => 'Aceptar pago en línea';

  @override
  String get receivePaymentsViaStripe => 'Recibir pagos a través de Stripe';

  @override
  String get allowLuggage => 'Permitir equipaje';

  @override
  String get allowPets => 'Permitir mascotas';

  @override
  String get allowSmoking => 'Permitir fumar';

  @override
  String get womenOnly => 'Solo mujeres';

  @override
  String get maxDetour => 'Desvío máximo';

  @override
  String get howFarYouLlGo => 'Qué tan lejos irás para recoger pasajeros';

  @override
  String get rideCreatedSuccessfully => '¡Viaje creado exitosamente!';

  @override
  String get newRideRequestsWillAppear =>
      'Las nuevas solicitudes de viaje aparecerán aquí';

  @override
  String get noDeclinedRequests => 'No hay solicitudes rechazadas';

  @override
  String get youHavenTDeclinedAny => 'Aún no has rechazado ninguna solicitud';

  @override
  String get acceptRequest => '¿Aceptar solicitud?';

  @override
  String youAreAboutToAccept(Object value1, Object value2, Object value3) {
    return 'Estás a punto de aceptar la solicitud de viaje de $value1 para $value2 a las $value3.';
  }

  @override
  String requestAcceptedValueHasBeen(Object value) {
    return '¡Solicitud aceptada! $value ha sido notificado.';
  }

  @override
  String get failedToAcceptRequest => 'Error al aceptar la solicitud';

  @override
  String get requestDeclined => 'Solicitud rechazada';

  @override
  String get failedToDeclineRequest => 'Error al rechazar la solicitud';

  @override
  String requestedValue(Object value) {
    return 'Solicitado $value';
  }

  @override
  String valueSeatValue2(Object value1, Object value2) {
    return '• $value1 asiento$value2';
  }

  @override
  String valueSeatValueRequested(Object value1, Object value2) {
    return '$value1 asiento$value2 solicitado';
  }

  @override
  String get acceptRequest2 => 'Aceptar solicitud';

  @override
  String acceptedValue(Object value) {
    return 'Aceptado $value';
  }

  @override
  String valueAtValue(Object value1, Object value2) {
    return '$value1 a las $value2';
  }

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String declinedValue(Object value) {
    return 'Rechazado $value';
  }

  @override
  String reasonValue(Object value) {
    return 'Razón: $value';
  }

  @override
  String get declineRequest => 'Rechazar solicitud';

  @override
  String pleaseLetValueKnowWhy(Object value) {
    return 'Por favor hazle saber a $value por qué no puedes aceptar este viaje.';
  }

  @override
  String get pleaseSpecify => 'Por favor especifica...';

  @override
  String get rideNotFound => 'Viaje no encontrado';

  @override
  String get yourRide => 'Tu viaje';

  @override
  String get couldnTLoadRide => 'No se pudo cargar el viaje';

  @override
  String get seatsFilled => 'Asientos ocupados';

  @override
  String get perSeat => 'Por asiento';

  @override
  String get route => 'Ruta';

  @override
  String value10(Object value) {
    return '~$value';
  }

  @override
  String valueTotalSeats(Object value) {
    return '$value asientos totales';
  }

  @override
  String get notes => 'Notas';

  @override
  String get newBookingRequestsWillAppear =>
      'Las nuevas solicitudes de reserva aparecerán aquí';

  @override
  String get noPassengersYet => 'Aún no hay pasajeros';

  @override
  String get acceptBookingRequestsToAdd =>
      'Acepta solicitudes de reserva para agregar pasajeros';

  @override
  String get shareRide => 'Compartir viaje';

  @override
  String get duplicateRide => 'Duplicar viaje';

  @override
  String get callPassenger => 'Llamar al pasajero';

  @override
  String get removePassenger => 'Eliminar pasajero';

  @override
  String bookingConfirmedForValue(Object value) {
    return 'Reserva confirmada para $value';
  }

  @override
  String get declineBooking => 'Rechazar reserva';

  @override
  String declineBookingRequestFromValue(Object value) {
    return '¿Rechazar solicitud de reserva de $value?';
  }

  @override
  String removeValueFromThisRide(Object value) {
    return '¿Eliminar a $value de este viaje?';
  }

  @override
  String get remove => 'Eliminar';

  @override
  String get startRide => 'Iniciar viaje';

  @override
  String get markThisRideAsStarted =>
      '¿Marcar este viaje como iniciado? Los pasajeros serán notificados.';

  @override
  String get start => 'Iniciar';

  @override
  String get completeRide => 'Completar viaje';

  @override
  String get markThisRideAsCompleted =>
      '¿Marcar este viaje como completado? Luego podrás calificar a tus pasajeros.';

  @override
  String get areYouSureYouWant8 =>
      '¿Estás seguro de que quieres cancelar este viaje? Todos los pasajeros serán notificados y reembolsados.';

  @override
  String get keepRide => 'Mantener viaje';

  @override
  String get failedToLoadRide => 'Error al cargar el viaje';

  @override
  String get thisRideMayHaveBeen =>
      'Este viaje puede haber sido completado o cancelado';

  @override
  String get rideConfirmed => 'Viaje confirmado';

  @override
  String get driverOnTheWay => 'Conductor en camino';

  @override
  String get rideCompleted => 'Viaje completado';

  @override
  String valueRides2(Object value) {
    return '• $value viajes';
  }

  @override
  String get routeDetails => 'Detalles de la ruta';

  @override
  String get perSeat2 => 'por asiento';

  @override
  String get seatsLeft => 'asientos disponibles';

  @override
  String get departure => 'salida';

  @override
  String passengersValue(Object value) {
    return 'Pasajeros ($value)';
  }

  @override
  String get phoneNumberNotAvailable => 'Número de teléfono no disponible';

  @override
  String get cannotMakePhoneCalls =>
      'No se pueden hacer llamadas en este dispositivo';

  @override
  String get failedToLaunchDialer => 'Error al abrir el marcador telefónico';

  @override
  String get areYouSureYouWant9 =>
      '¿Estás seguro de que quieres cancelar este viaje? Pueden aplicarse políticas de cancelación.';

  @override
  String get rideCancelledSuccessfully => 'Viaje cancelado exitosamente';

  @override
  String failedToCancelRideValue(Object value) {
    return 'Error al cancelar el viaje: $value';
  }

  @override
  String get rateYourRide => 'Califica tu viaje';

  @override
  String get ratingFeatureComingSoonThank =>
      '¡Función de calificación próximamente! Gracias por usar SportConnect.';

  @override
  String get myTrips => 'Mis viajes';

  @override
  String get trackManageYourRides => 'Rastrea y gestiona tus viajes';

  @override
  String get upcoming => 'Próximos';

  @override
  String get history => 'Historial';

  @override
  String get noActiveTrips => 'No hay viajes activos';

  @override
  String get tripInProgress => 'VIAJE EN CURSO';

  @override
  String get text49 => '4.9';

  @override
  String get noUpcomingTrips => 'No hay viajes próximos';

  @override
  String get noTripHistory => 'No hay historial de viajes';

  @override
  String get rebook => 'Reservar de nuevo';

  @override
  String get findRide => 'Buscar viaje';

  @override
  String get loadingYourTrips => 'Cargando tus viajes...';

  @override
  String get cancelTrip => '¿Cancelar viaje?';

  @override
  String areYouSureYouWant10(Object value) {
    return '¿Estás seguro de que quieres cancelar tu viaje a $value?';
  }

  @override
  String get tripCancelled => 'Viaje cancelado';

  @override
  String get openingChat => 'Abriendo chat...';

  @override
  String failedToOpenChatValue(Object value) {
    return 'Error al abrir el chat: $value';
  }

  @override
  String get startingCall => 'Iniciando llamada...';

  @override
  String get whereTo => '¿A dónde?';

  @override
  String get findThePerfectRideFor =>
      'Encuentra el viaje perfecto para tu trayecto';

  @override
  String get whereFrom => '¿Desde dónde?';

  @override
  String get when => '¿Cuándo?';

  @override
  String get today => 'Hoy';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get pickDate => 'Elegir fecha';

  @override
  String get departureTime2 => 'Hora de salida';

  @override
  String get howManySeatsDoYou => '¿Cuántos asientos necesitas?';

  @override
  String get availableRides => 'Viajes disponibles';

  @override
  String get sort => 'Ordenar';

  @override
  String get noRidesFound => 'No se encontraron viajes';

  @override
  String get tryAdjustingYourSearchCriteria =>
      'Intenta ajustar tus criterios de búsqueda\no vuelve a consultar más tarde';

  @override
  String get findingRides => 'Buscando viajes...';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get recommended => 'Recomendado';

  @override
  String get earliestDeparture => 'Salida más temprana';

  @override
  String get lowestPrice => 'Precio más bajo';

  @override
  String get highestRated => 'Mejor calificado';

  @override
  String get searchFailedPleaseTryAgain =>
      'La búsqueda falló. Por favor intenta de nuevo.';

  @override
  String get rideDetails => 'Detalles del viaje';

  @override
  String value11(Object value) {
    return '$value • ';
  }

  @override
  String valueLeft(Object value) {
    return '$value restante';
  }

  @override
  String valueMin2(Object value) {
    return '~$value min';
  }

  @override
  String valueKgCoSavedPer(Object value) {
    return '$value kg CO₂ ahorrado por persona';
  }

  @override
  String get negotiable => 'Negociable';

  @override
  String get onlinePay => 'Pago en línea';

  @override
  String get reviews => 'Reseñas';

  @override
  String get seeAll => 'Ver todo';

  @override
  String get seats3 => 'Asientos:';

  @override
  String get confirmBooking => 'Confirmar reserva';

  @override
  String get pricePerSeat2 => 'Precio por asiento';

  @override
  String get total => 'Total';

  @override
  String get addANoteToThe => 'Añadir una nota al conductor (opcional)';

  @override
  String get bookingRequestSent => '¡Solicitud de reserva enviada!';

  @override
  String get seatsLeft2 => 'Asientos restantes';

  @override
  String get tripDetails => 'Detalles del viaje';

  @override
  String get departure2 => 'Salida';

  @override
  String get amenities => 'Comodidades';

  @override
  String get pets => 'Mascotas';

  @override
  String get smoking => 'Fumar';

  @override
  String get luggage => 'Equipaje';

  @override
  String yourPassengersValue(Object value) {
    return 'Tus pasajeros ($value)';
  }

  @override
  String valueValueSeats(Object value1, Object value2) {
    return '$value1/$value2 asientos';
  }

  @override
  String get noPassengersAcceptedYet => 'Aún no se han aceptado pasajeros';

  @override
  String get noPassengersBookedYet => 'Aún no hay pasajeros reservados';

  @override
  String valueHasBookedThisRide(Object value) {
    return '$value ha reservado este viaje';
  }

  @override
  String valuePassengersHaveBooked(Object value) {
    return '$value pasajeros han reservado';
  }

  @override
  String pendingRequestsValue(Object value) {
    return 'Solicitudes pendientes ($value)';
  }

  @override
  String get requestAccepted => '¡Solicitud aceptada! 🎉';

  @override
  String get seatsBooked => 'Asientos reservados';

  @override
  String get editRideFeatureComingSoon =>
      '¡Función de edición de viaje próximamente!';

  @override
  String get numberOfSeats => 'Número de asientos';

  @override
  String value12(Object value) {
    return '× $value';
  }

  @override
  String get securePaymentWithStripe => 'Pago seguro con Stripe';

  @override
  String get pleaseLogInToBook =>
      'Por favor inicia sesión para reservar un viaje';

  @override
  String get paymentSucceededButBookingFailed =>
      'El pago tuvo éxito pero la reserva falló. Por favor contacta a soporte.';

  @override
  String get paymentCancelled => 'Pago cancelado';

  @override
  String paymentFailedValue(Object value) {
    return 'El pago falló: $value';
  }

  @override
  String get paymentMethod => 'Método de pago';

  @override
  String get thisDriverAcceptsCashPayment =>
      'Este conductor solo acepta pago en efectivo.';

  @override
  String get payWithCash => 'Pagar en efectivo';

  @override
  String get failedToBookRidePlease =>
      'Error al reservar el viaje. Por favor intenta de nuevo.';

  @override
  String get paymentSuccessful => '¡Pago exitoso!';

  @override
  String youPaidValueValue(Object value1, Object value2) {
    return 'Pagaste $value1 $value2';
  }

  @override
  String get yourRideHasBeenBooked => 'Tu viaje ha sido reservado.';

  @override
  String get youEarned25Xp => '¡Ganaste 25 XP!';

  @override
  String get backToSearch => 'Volver a la búsqueda';

  @override
  String get bookingConfirmed => '¡Reserva confirmada!';

  @override
  String get yourRideHasBeenBooked2 =>
      'Tu viaje ha sido reservado. Paga al conductor en efectivo.';

  @override
  String get pleaseEnterBothLocations => 'Por favor ingresa ambas ubicaciones';

  @override
  String get pleaseSelectLocationsFromThe =>
      'Por favor selecciona ubicaciones del selector';

  @override
  String maxValue(Object value) {
    return 'Máx $value €';
  }

  @override
  String get femaleOnly => 'Solo mujeres';

  @override
  String get instantBook => 'Reserva instantánea';

  @override
  String get petFriendly => 'Admite mascotas';

  @override
  String valueRating(Object value) {
    return '$value+ calificación';
  }

  @override
  String get activeFilters => 'Filtros activos';

  @override
  String valueRidesAvailable(Object value) {
    return '$value viajes disponibles';
  }

  @override
  String filtersValue(Object value) {
    return 'Filtros$value';
  }

  @override
  String get reset => 'Restablecer';

  @override
  String get priceRange => 'Rango de precio';

  @override
  String get text52 => '5 €';

  @override
  String get text100 => '100 €';

  @override
  String get minimumRating => 'Calificación mínima';

  @override
  String get any => 'Cualquiera';

  @override
  String value13(Object value) {
    return '$value+';
  }

  @override
  String get verifiedDriver2 => 'Conductor verificado';

  @override
  String get musicAllowed => 'Música permitida';

  @override
  String get vehicleType => 'Tipo de vehículo';

  @override
  String get electric => 'Eléctrico';

  @override
  String get comfort => 'Confort';

  @override
  String get book => 'Reservar';

  @override
  String get sortBy2 => 'Ordenar por';

  @override
  String get lowestPrice2 => 'Precio más bajo';

  @override
  String get earliestDeparture2 => 'Salida más temprana';

  @override
  String get highestRated2 => 'Mejor calificado';

  @override
  String get shortestDuration => 'Duración más corta';

  @override
  String get signInFailedPleaseTry =>
      'Error al iniciar sesión. Por favor intenta de nuevo.';

  @override
  String get email => 'Email';

  @override
  String get enterYourEmail => 'Ingresa tu email';

  @override
  String get password => 'Contraseña';

  @override
  String get enterYourPassword => 'Ingresa tu contraseña';

  @override
  String get orSignInWithEmail => 'o iniciar sesión con email';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get continueWithApple => 'Continuar con Apple';

  @override
  String get tryAgain => 'Intentar de nuevo';

  @override
  String get avgPerRide => 'Promedio por viaje';

  @override
  String get driveTime => 'Tiempo de conducción';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get failedToLoadNotifications => 'Error al cargar las notificaciones';

  @override
  String get checkYourConnectionAndTry =>
      'Verifica tu conexión e intenta de nuevo';

  @override
  String get couldNotOpenChat => 'No se pudo abrir el chat';

  @override
  String get searchConversations => 'Buscar conversaciones...';

  @override
  String get direct => 'Directo';

  @override
  String get groups => 'Grupos';

  @override
  String get all => 'Todo';

  @override
  String get startAConversationWith =>
      'Inicia una conversación con tus compañeros de viaje';

  @override
  String get joinOrCreateAGroup =>
      'Únete o crea un grupo para comenzar a chatear';

  @override
  String get joinARideToChat =>
      'Únete a un viaje para chatear con otros viajeros';

  @override
  String get driverCreateRide => 'Crear viaje';

  @override
  String get driverThisWeek => 'Esta semana';

  @override
  String get driverThisMonth => 'Este mes';

  @override
  String get driverCo2Saved => 'CO₂ ahorrado';

  @override
  String get driverHoursOnline => 'Horas en línea';

  @override
  String get locationRequired => 'Ubicación requerida';

  @override
  String get enableLocationForBetterExperience =>
      'Activa la ubicación para una mejor experiencia de conducción';

  @override
  String get openSettings => 'Abrir configuración';

  @override
  String get enable => 'Activar';

  @override
  String get createARideToStartEarning => 'Crea un viaje para comenzar a ganar';

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
  String get periodToday => 'Hoy';

  @override
  String get periodThisWeek => 'Esta semana';

  @override
  String get periodThisMonth => 'Este mes';

  @override
  String get periodAllTime => 'Todo el tiempo';

  @override
  String get statRides => 'Viajes';

  @override
  String get statEarnings => 'Ganancias';

  @override
  String get statOnlineHours => 'Horas en línea';

  @override
  String get statAvgRating => 'Calif. prom.';

  @override
  String get connectStripeAccount => 'Conectar cuenta Stripe';

  @override
  String get benefitInstantPayoutsDesc =>
      'Recibe tu dinero en minutos, no en días';

  @override
  String get benefitSecureDesc => 'Seguridad bancaria con Stripe';

  @override
  String get benefitTrackingDesc => 'Consulta cada pago de viaje en detalle';

  @override
  String get benefitLowFeesDesc => 'Conserva el 85% de cada pago de viaje';

  @override
  String get pleaseSignInToContinue => 'Inicia sesión para continuar';

  @override
  String get poweredByStripe => 'Con tecnología de Stripe • Seguro y cifrado';

  @override
  String get cancelSetupTitle => '¿Cancelar configuración?';

  @override
  String get cancelSetupMessage =>
      '¿Estás seguro de que quieres cancelar? No podrás recibir pagos hasta que completes esta configuración.';

  @override
  String get continueSetup => 'Continuar configuración';

  @override
  String get filterAll => 'Todo';

  @override
  String get filterCompleted => 'Completado';

  @override
  String get filterPending => 'Pendiente';

  @override
  String get filterRefunded => 'Reembolsado';

  @override
  String get filterFailed => 'Fallido';

  @override
  String get statusCompleted => 'Completado';

  @override
  String get statusPending => 'Pendiente';

  @override
  String get statusProcessing => 'Procesando';

  @override
  String get statusFailed => 'Fallido';

  @override
  String get statusCancelled => 'Cancelado';

  @override
  String get statusRefunded => 'Reembolsado';

  @override
  String get statusPartiallyRefunded => 'Parcialmente reembolsado';

  @override
  String get statusInTransit => 'En tránsito';

  @override
  String get details => 'Detalles';

  @override
  String get refundRequestSubmitted =>
      'Solicitud de reembolso enviada con éxito';

  @override
  String get refundRequestFailed =>
      'Error en la solicitud de reembolso. Inténtalo de nuevo.';

  @override
  String get payoutDetails => 'Detalles del pago';

  @override
  String get payoutNotFound => 'Pago no encontrado';

  @override
  String get totalPayout => 'Pago total';

  @override
  String get breakdown => 'Desglose';

  @override
  String get timeline => 'Cronología';

  @override
  String get grossEarnings => 'Ganancias brutas';

  @override
  String get netPayout => 'Pago neto';

  @override
  String get payoutCreated => 'Pago creado';

  @override
  String get fees => 'Comisiones';

  @override
  String get payoutAmount => 'Monto del pago';

  @override
  String get instantPayout => 'Pago instantáneo';

  @override
  String get payoutDetailsSection => 'Detalles';

  @override
  String get expectedArrival => 'Llegada esperada';

  @override
  String get arrivedAt => 'Llegó el';

  @override
  String get bankName => 'Nombre del banco';

  @override
  String get accountEnding => 'Cuenta terminada en';

  @override
  String get failureReason => 'Motivo del fallo';

  @override
  String get cancelPayout => 'Cancelar pago';

  @override
  String get cancelPayoutConfirm =>
      '¿Estás seguro de que quieres cancelar este pago? Esta acción no se puede deshacer.';

  @override
  String get payoutCancelled => 'Pago cancelado con éxito';

  @override
  String get payoutCancelFailed =>
      'Error al cancelar el pago. Inténtalo de nuevo.';

  @override
  String get payoutPendingDesc =>
      'Tu pago está siendo procesado y se enviará en breve.';

  @override
  String get payoutInTransit => 'En tránsito';

  @override
  String get payoutInTransitDesc =>
      'Tu pago ha sido enviado y está en camino a tu banco.';

  @override
  String get payoutPaid => 'Pagado';

  @override
  String get payoutPaidDesc => 'Tu pago ha llegado a tu cuenta bancaria.';

  @override
  String get payoutFailedDesc =>
      'Este pago falló. Consulta el motivo del fallo a continuación.';

  @override
  String get payoutCancelledDesc => 'Este pago fue cancelado.';

  @override
  String get stripeVerifyingAccount => 'Verificando tu cuenta...';

  @override
  String get stripeAccountCreationFailed =>
      'Error al crear la cuenta de Stripe. Inténtalo de nuevo.';

  @override
  String get stripeSetupFailed =>
      'No se pudo iniciar la configuración de Stripe. Inténtalo de nuevo.';

  @override
  String get stripePageLoadFailed =>
      'Error al cargar la página. Inténtalo de nuevo.';

  @override
  String get stripeLoadingConnect => 'Cargando Stripe Connect...';

  @override
  String get stripeAdditionalInfoNeeded =>
      'Se necesita información adicional. Completa todos los campos.';

  @override
  String get stripeVerifyFailed =>
      'No se pudo verificar la cuenta. Inténtalo de nuevo.';

  @override
  String get unableToLoadData =>
      'No se pudieron cargar los datos. Desliza para actualizar.';

  @override
  String get exportEarningsReport => 'Informe de ganancias';

  @override
  String get exportGenerated => 'Generado';

  @override
  String get exportEarningsSummary => 'RESUMEN DE GANANCIAS';

  @override
  String get exportRideStatistics => 'ESTADÍSTICAS DE VIAJES';

  @override
  String get exportRecentTransactions => 'TRANSACCIONES RECIENTES';

  @override
  String get driverProfileTitle => 'Completa tu perfil';

  @override
  String get driverProfileSubtitle =>
      'Cuéntanos sobre ti para que los pasajeros puedan conocerte.';

  @override
  String get driverCityLabel => 'Ciudad';

  @override
  String get driverCityHint => '¿Dónde te encuentras?';

  @override
  String get driverCityRequired => 'Por favor introduce tu ciudad';

  @override
  String get driverGenderRequired => 'Por favor selecciona tu género.';

  @override
  String get driverInterestsRequired =>
      'Por favor selecciona al menos un interés.';

  @override
  String get driverTermsLabel =>
      'Acepto los Términos de servicio y la Política de privacidad.';

  @override
  String get driverTermsRequired =>
      'Debes aceptar los términos para continuar.';

  @override
  String get driverSaveAndContinue => 'Guardar y continuar';
}
