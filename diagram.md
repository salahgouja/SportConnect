classDiagram
    direction TB

    %% ==================== ENUMS ====================
    class UserRole {
        <<enumeration>>
        rider
        driver
    }

    class UserLevel {
        <<enumeration>>
        bronze
        silver
        gold
        platinum
        diamond
        +double minXP
        +double maxXP
        +String name
        +int level
        +fromXP(int xp) UserLevel
    }

    class RideStatus {
        <<enumeration>>
        draft
        active
        full
        inProgress
        completed
        cancelled
    }

    class BookingStatus {
        <<enumeration>>
        pending
        accepted
        rejected
        cancelled
        completed
    }

    class FuelType {
        <<enumeration>>
        gasoline
        diesel
        electric
        hybrid
        pluginHybrid
        hydrogen
        other
    }

    class VehicleVerificationStatus {
        <<enumeration>>
        pending
        verified
        rejected
    }

    class ReviewType {
        <<enumeration>>
        driver
        rider
    }

    class ReviewTag {
        <<enumeration>>
        punctual
        greatConversation
        cleanCar
        safeDriver
        comfortableRide
        goodMusic
        friendly
        professional
        flexible
        respectfulRider
        onTimeRider
        polite
        easyCommunication
    }

    class PaymentStatus {
        <<enumeration>>
        pending
        processing
        succeeded
        failed
        cancelled
        refunded
        partiallyRefunded
    }

    class PaymentMethodType {
        <<enumeration>>
        card
        applePay
        googlePay
        link
    }

    class PayoutStatus {
        <<enumeration>>
        pending
        inTransit
        paid
        failed
        cancelled
    }

    class MessageType {
        <<enumeration>>
        text
        image
        location
        ride
        system
        audio
    }

    class MessageStatus {
        <<enumeration>>
        sending
        sent
        delivered
        read
        failed
    }

    class ChatType {
        <<enumeration>>
        private
        rideGroup
        support
    }

    class CallType {
        <<enumeration>>
        voice
        video
    }

    class CallStatus {
        <<enumeration>>
        pending
        ringing
        connecting
        ongoing
        ended
        missed
        declined
        failed
    }

    class NotificationType {
        <<enumeration>>
        rideBookingRequest
        rideBookingAccepted
        rideBookingRejected
        rideBookingCancelled
        rideStartingSoon
        rideStarted
        rideCompleted
        rideCancelled
        rideUpdated
        newMessage
        newGroupMessage
        newFollower
        followAccepted
        levelUp
        achievementUnlocked
        streakMilestone
        leaderboardRank
        xpEarned
        accountVerified
        profileIncomplete
        systemAlert
        promotion
    }

    class NotificationPriority {
        <<enumeration>>
        low
        normal
        high
        urgent
    }

    %% ==================== USER MODELS ====================
    class UserModel {
        <<sealed>>
        +String uid
        +String email
        +String displayName
        +String? photoUrl
        +String? phoneNumber
        +String? bio
        +DateTime? dateOfBirth
        +String? gender
        +List~String~ interests
        +String? address
        +double? latitude
        +double? longitude
        +String? city
        +String? country
        +bool isEmailVerified
        +bool isPhoneVerified
        +bool isIdVerified
        +bool isActive
        +bool isOnline
        +bool isPremium
        +List~String~ blockedUsers
        +UserPreferences preferences
        +String? fcmToken
        +DateTime? createdAt
        +DateTime? updatedAt
        +DateTime? lastSeenAt
        +UserRole role
        +UserLevel userLevel
        +double levelProgress
        +int xpNeeded
        +int totalXP
        +int totalRides
        +bool isProfileComplete
        +bool isRider
        +bool isDriver
    }

    class RiderModel {
        +List~String~ favoriteRoutes
        +RatingBreakdown rating
        +RiderGamificationStats gamification
        +double moneySaved
        +isFavoriteRoute(String routeId) bool
    }

    class DriverModel {
        +List~Vehicle~ vehicles
        +RatingBreakdown rating
        +DriverGamificationStats gamification
        +String? stripeAccountId
        +bool isStripeEnabled
        +bool isStripeOnboarded
        +Vehicle? defaultVehicle
        +bool hasCompletedOnboarding
        +bool canReceivePayments
    }

    class Achievement {
        +String id
        +String title
        +String description
        +String iconName
        +int xpReward
        +bool isUnlocked
        +DateTime? unlockedAt
    }

    class GamificationStats {
        +int totalXP
        +int level
        +int currentLevelXP
        +int xpToNextLevel
        +int totalRides
        +int currentStreak
        +int longestStreak
        +double co2Saved
        +double totalDistance
        +List~String~ unlockedBadges
        +List~Achievement~ achievements
        +DateTime? lastRideDate
    }

    class RiderGamificationStats {
        +int totalXP
        +int level
        +int currentLevelXP
        +int xpToNextLevel
        +int totalRides
        +int currentStreak
        +int longestStreak
        +double co2Saved
        +double moneySaved
        +double totalDistance
        +List~String~ unlockedBadges
        +List~Achievement~ achievements
        +DateTime? lastRideDate
    }

    class DriverGamificationStats {
        +int totalXP
        +int level
        +int currentLevelXP
        +int xpToNextLevel
        +int totalRides
        +int currentStreak
        +int longestStreak
        +double co2Saved
        +double totalEarnings
        +double totalDistance
        +List~String~ unlockedBadges
        +List~Achievement~ achievements
        +DateTime? lastRideDate
    }

    class UserPreferences {
        +bool notificationsEnabled
        +bool emailNotifications
        +bool rideReminders
        +bool chatNotifications
        +bool marketingEmails
        +String language
        +String theme
        +double maxPickupRadius
        +bool showOnlineStatus
        +bool allowMessages
    }

    class Vehicle {
        +String id
        +String make
        +String model
        +String fuelType
        +int year
        +String color
        +String licensePlate
        +int seats
        +String? imageUrl
        +bool isDefault
        +bool isVerified
    }

    class RatingBreakdown {
        +int total
        +double average
        +int fiveStars
        +int fourStars
        +int threeStars
        +int twoStars
        +int oneStars
    }

    class LeaderboardEntry {
        +String odid
        +String displayName
        +String? photoUrl
        +int totalXP
        +int level
        +int rank
        +int ridesThisMonth
    }

    %% ==================== VEHICLE MODEL ====================
    class VehicleModel {
        +String id
        +String ownerId
        +String make
        +String model
        +String year
        +String color
        +String licensePlate
        +int capacity
        +FuelType fuelType
        +String? imageUrl
        +List~String~ imageUrls
        +bool isActive
        +VehicleVerificationStatus verificationStatus
        +String? verificationNote
        +String? registrationDocUrl
        +String? insuranceDocUrl
        +DateTime? insuranceExpiry
        +bool hasAC
        +bool hasCharger
        +bool hasWifi
        +bool petsAllowed
        +bool smokingAllowed
        +bool hasLuggage
        +int totalRides
        +double averageRating
        +DateTime? createdAt
        +DateTime? updatedAt
        +bool isVerified
        +String displayName
        +String fuelTypeDisplayName
        +List~String~ enabledFeatures
    }

    %% ==================== RIDE MODELS ====================
    class RideModel {
        +String id
        +String driverId
        +String driverName
        +String? driverPhotoUrl
        +double? driverRating
        +LocationPoint origin
        +LocationPoint destination
        +List~RouteWaypoint~ waypoints
        +double? distanceKm
        +int? durationMinutes
        +String? polylineEncoded
        +DateTime departureTime
        +DateTime? arrivalTime
        +int flexibilityMinutes
        +int availableSeats
        +int bookedSeats
        +double pricePerSeat
        +String? currency
        +bool isPriceNegotiable
        +bool acceptsOnlinePayment
        +RideStatus status
        +bool allowPets
        +bool allowSmoking
        +bool allowLuggage
        +bool isWomenOnly
        +bool allowChat
        +int? maxDetourMinutes
        +String? vehicleId
        +String? vehicleInfo
        +List~RideBooking~ bookings
        +List~RideReview~ reviews
        +bool isRecurring
        +List~int~ recurringDays
        +DateTime? recurringEndDate
        +int xpReward
        +String? notes
        +List~String~ tags
        +DateTime? createdAt
        +DateTime? updatedAt
        +int remainingSeats
        +bool isFull
        +bool isBookable
        +int pendingBookingsCount
        +List~RideBooking~ acceptedBookings
        +double averageRating
        +String formattedPrice
        +double co2SavedPerPassenger
    }

    class LocationPoint {
        +String address
        +double latitude
        +double longitude
        +String? placeId
        +String? city
    }

    class RouteWaypoint {
        +LocationPoint location
        +int order
        +DateTime? estimatedArrival
    }

    class RideBooking {
        +String id
        +String passengerId
        +String passengerName
        +String? passengerPhotoUrl
        +int seatsBooked
        +BookingStatus status
        +LocationPoint? pickupLocation
        +LocationPoint? dropoffLocation
        +String? note
        +DateTime? createdAt
        +DateTime? respondedAt
    }

    class RideReview {
        +String id
        +String reviewerId
        +String reviewerName
        +String? reviewerPhotoUrl
        +String revieweeId
        +double rating
        +String? comment
        +List~String~ tags
        +DateTime? createdAt
    }

    class RideSearchFilters {
        +LocationPoint? origin
        +LocationPoint? destination
        +DateTime? departureDate
        +DateTime? departureTimeFrom
        +DateTime? departureTimeTo
        +int minSeats
        +double? maxPrice
        +double? maxRadiusKm
        +bool allowPets
        +bool allowSmoking
        +bool womenOnly
        +double? minDriverRating
        +String sortBy
        +bool sortAscending
    }

    %% ==================== REVIEW MODELS ====================
    class ReviewModel {
        +String id
        +String rideId
        +String reviewerId
        +String reviewerName
        +String? reviewerPhotoUrl
        +String revieweeId
        +String revieweeName
        +String? revieweePhotoUrl
        +ReviewType type
        +double rating
        +String? comment
        +List~String~ tags
        +bool isVisible
        +String? response
        +DateTime? responseAt
        +DateTime createdAt
        +DateTime? updatedAt
        +List~ReviewTag~ reviewTags
        +String formattedRating
        +bool hasResponse
        +String timeAgo
    }

    class RatingStats {
        +int totalReviews
        +double averageRating
        +int fiveStarCount
        +int fourStarCount
        +int threeStarCount
        +int twoStarCount
        +int oneStarCount
        +Map~String, int~ tagCounts
        +DateTime? lastReviewAt
        +DateTime? updatedAt
        +Map~int, double~ distribution
        +List~MapEntry~ topTags
        +String formattedAverage
    }

    class CreateReviewRequest {
        +String rideId
        +String revieweeId
        +String revieweeName
        +String? revieweePhotoUrl
        +ReviewType type
        +double rating
        +String? comment
        +List~String~ tags
    }

    %% ==================== PAYMENT MODELS ====================
    class PaymentTransaction {
        +String id
        +String rideId
        +String riderId
        +String riderName
        +String driverId
        +String driverName
        +double amount
        +String currency
        +PaymentStatus status
        +PaymentMethodType? paymentMethodType
        +String? paymentMethodLast4
        +String? stripePaymentIntentId
        +String? stripeCustomerId
        +String? stripeChargeId
        +double platformFee
        +double stripeFee
        +double driverEarnings
        +int? seatsBooked
        +DateTime? createdAt
        +DateTime? updatedAt
        +DateTime? completedAt
        +DateTime? refundedAt
        +String? failureReason
        +String? refundReason
        +Map~String, dynamic~ metadata
        +String formattedAmount
        +String formattedPlatformFee
        +String formattedDriverEarnings
        +bool isSuccessful
        +bool canBeRefunded
    }

    class DriverPayout {
        +String id
        +String driverId
        +String driverName
        +String connectedAccountId
        +double amount
        +String currency
        +PayoutStatus status
        +String? stripePayoutId
        +String? stripeTransferId
        +List~String~ transactionIds
        +String? bankAccountLast4
        +String? bankName
        +DateTime? createdAt
        +DateTime? expectedArrivalDate
        +DateTime? arrivedAt
        +String? failureReason
        +bool? isInstantPayout
        +Map~String, dynamic~ metadata
        +String formattedAmount
        +bool isCompleted
        +bool isPending
    }

    class DriverConnectedAccount {
        +String id
        +String driverId
        +String stripeAccountId
        +String email
        +String country
        +bool chargesEnabled
        +bool payoutsEnabled
        +bool detailsSubmitted
        +bool? onboardingCompleted
        +DateTime? onboardingCompletedAt
        +String? onboardingUrl
        +String? bankAccountLast4
        +String? bankName
        +String? accountHolderName
        +double totalEarnings
        +double availableBalance
        +double pendingBalance
        +DateTime? createdAt
        +DateTime? updatedAt
        +DateTime? lastPayoutAt
        +Map~String, dynamic~ requirements
        +Map~String, dynamic~ metadata
        +bool isFullySetup
        +bool needsOnboarding
        +String formattedTotalEarnings
        +String formattedAvailableBalance
    }

    class RiderPaymentMethod {
        +String id
        +String riderId
        +String stripeCustomerId
        +String stripePaymentMethodId
        +String brand
        +String last4
        +int exMonth
        +int exYear
        +bool isDefault
        +DateTime? createdAt
        +DateTime? updatedAt
        +String cardDisplay
        +bool isExpired
        +String expirationDisplay
    }

    class EarningsSummary {
        +String driverId
        +double totalEarnings
        +double totalPlatformFees
        +double totalStripeFees
        +double earningsToday
        +double earningsThisWeek
        +double earningsThisMonth
        +double earningsThisYear
        +int totalRidesCompleted
        +int ridesCompletedToday
        +int ridesCompletedThisWeek
        +int ridesCompletedThisMonth
        +double availableBalance
        +double pendingBalance
        +DateTime? lastUpdated
        +DateTime? lastPayoutDate
        +String formattedTotal
        +String formattedAvailable
        +double averagePerRide
    }

    %% ==================== MESSAGING MODELS ====================
    class MessageModel {
        +String id
        +String chatId
        +String senderId
        +String senderName
        +String? senderPhotoUrl
        +String content
        +MessageType type
        +MessageStatus status
        +String? imageUrl
        +String? thumbnailUrl
        +double? latitude
        +double? longitude
        +String? locationName
        +String? rideId
        +String? replyToMessageId
        +String? replyToContent
        +Map~String, List~String~~ reactions
        +List~String~ readBy
        +List~String~ deliveredTo
        +bool isEdited
        +bool isDeleted
        +DateTime? createdAt
        +DateTime? editedAt
        +isFromUser(String userId) bool
        +isReadBy(String userId) bool
        +int totalReactions
    }

    class ChatParticipant {
        +String odid
        +String displayName
        +String? photoUrl
        +bool isOnline
        +bool isAdmin
        +bool isMuted
        +DateTime? lastSeenAt
        +DateTime? joinedAt
    }

    class ChatModel {
        +String id
        +ChatType type
        +List~ChatParticipant~ participants
        +List~String~ participantIds
        +String? groupName
        +String? groupPhotoUrl
        +String? description
        +String? rideId
        +String? lastMessageContent
        +String? lastMessageSenderId
        +String? lastMessageSenderName
        +MessageType lastMessageType
        +DateTime? lastMessageAt
        +Map~String, int~ unreadCounts
        +Map~String, bool~ mutedBy
        +Map~String, bool~ pinnedBy
        +bool isActive
        +DateTime? createdAt
        +DateTime? updatedAt
        +getOtherParticipant(String currentUserId) ChatParticipant?
        +getChatTitle(String currentUserId) String
        +getChatPhoto(String currentUserId) String?
        +getUnreadCount(String userId) int
        +isMutedBy(String userId) bool
        +isPinnedBy(String userId) bool
        +isOtherOnline(String currentUserId) bool
    }

    class TypingIndicator {
        +String odid
        +String displayName
        +String chatId
        +DateTime? startedAt
    }

    %% ==================== CALL MODELS ====================
    class CallModel {
        +String id
        +String chatId
        +CallType type
        +String callerId
        +String callerName
        +String? callerPhotoUrl
        +String calleeId
        +String calleeName
        +String? calleePhotoUrl
        +CallStatus status
        +String? channelName
        +String? sessionId
        +DateTime? createdAt
        +DateTime? answeredAt
        +DateTime? endedAt
        +int duration
        +String? endReason
        +isFromUser(String userId) bool
        +bool isActive
        +getreceiverId(String currentUserId) String
        +getreceiverName(String currentUserId) String
        +String formattedDuration
    }

    class CallHistoryEntry {
        +String id
        +CallType type
        +String receiverId
        +String receiverName
        +String? receiverPhotoUrl
        +bool isOutgoing
        +CallStatus status
        +int duration
        +DateTime? timestamp
    }

    %% ==================== NOTIFICATION MODELS ====================
    class NotificationModel {
        +String id
        +String userId
        +NotificationType type
        +String title
        +String body
        +NotificationPriority priority
        +String? referenceId
        +String? referenceType
        +String? senderId
        +String? senderName
        +String? senderPhotoUrl
        +String? actionUrl
        +Map~String, dynamic~ data
        +bool isRead
        +bool isArchived
        +bool isPushSent
        +DateTime? createdAt
        +DateTime? readAt
        +DateTime? expiresAt
        +String iconName
        +String colorName
        +bool isExpired
    }

    class NotificationPreferences {
        +bool pushEnabled
        +bool rideNotifications
        +bool messageNotifications
        +bool socialNotifications
        +bool gamificationNotifications
        +bool promotionNotifications
        +bool emailEnabled
        +bool emailRideSummary
        +bool emailWeeklyDigest
        +bool quietHoursEnabled
        +String quietHoursStart
        +String quietHoursEnd
        +bool soundEnabled
        +bool vibrationEnabled
    }

    %% ==================== ONBOARDING MODEL ====================
    class OnboardingPage {
        +String title
        +String description
        +String imagePath
        +String? lottieAnimation
    }

    %% ==================== RELATIONSHIPS ====================
    
    %% User Model Inheritance
    UserModel <|-- RiderModel : extends
    UserModel <|-- DriverModel : extends

    %% User Model Compositions
    UserModel *-- UserPreferences : has
    UserModel *-- RatingBreakdown : has
    RiderModel *-- RiderGamificationStats : has
    DriverModel *-- DriverGamificationStats : has
    DriverModel *-- Vehicle : has many
    RiderGamificationStats *-- Achievement : has many
    DriverGamificationStats *-- Achievement : has many

    %% Vehicle Model
    VehicleModel --> FuelType : uses
    VehicleModel --> VehicleVerificationStatus : uses

    %% Ride Model Compositions
    RideModel *-- LocationPoint : origin
    RideModel *-- LocationPoint : destination
    RideModel *-- RouteWaypoint : has many
    RideModel *-- RideBooking : has many
    RideModel *-- RideReview : has many
    RideModel --> RideStatus : uses
    RouteWaypoint *-- LocationPoint : has
    RideBooking --> BookingStatus : uses
    RideBooking *-- LocationPoint : pickup/dropoff
    RideSearchFilters *-- LocationPoint : has

    %% Review Model
    ReviewModel --> ReviewType : uses
    RatingStats --> ReviewModel : computed from

    %% Payment Model Relationships
    PaymentTransaction --> PaymentStatus : uses
    PaymentTransaction --> PaymentMethodType : uses
    DriverPayout --> PayoutStatus : uses

    %% Messaging Model Relationships
    MessageModel --> MessageType : uses
    MessageModel --> MessageStatus : uses
    ChatModel *-- ChatParticipant : has many
    ChatModel --> ChatType : uses

    %% Call Model Relationships
    CallModel --> CallType : uses
    CallModel --> CallStatus : uses
    CallHistoryEntry --> CallModel : from

    %% Notification Model Relationships
    NotificationModel --> NotificationType : uses
    NotificationModel --> NotificationPriority : uses

    %% Cross-Domain Relationships
    RideModel ..> UserModel : driverId references
    RideBooking ..> UserModel : passengerId references
    PaymentTransaction ..> RideModel : rideId references
    PaymentTransaction ..> UserModel : riderId/driverId references
    MessageModel ..> ChatModel : chatId references
    CallModel ..> ChatModel : chatId references
    NotificationModel ..> UserModel : userId references
    ReviewModel ..> RideModel : rideId references
    ReviewModel ..> UserModel : reviewerId/revieweeId references
    DriverConnectedAccount ..> DriverModel : driverId references
    EarningsSummary ..> DriverModel : driverId references
    RiderPaymentMethod ..> RiderModel : riderId references
    VehicleModel ..> DriverModel : ownerId references