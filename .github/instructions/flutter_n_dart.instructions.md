---
description: 'Project context, architectural guidelines, and coding standards for SportConnect.'
applyTo: '**/*.dart'
---

# Project: SportConnect
**Description:** A social carpooling app for students and sports enthusiasts. 
**Core Stack:** Flutter, Dart, Riverpod (State Management), Firebase (Backend/Auth/DB), Stripe (Payments), GoRouter (Navigation), and Flutter Map (Routing).

## 1. AI Assistant Directives
* **Search Requirement:** You MUST always use the **Tavily** search tool when looking up up-to-date documentation, debugging obscure errors, or verifying App Store/Play Store compliance rules.
* **Code Generation:** Write concise, modular, and production-ready code. Omit boilerplate explanations and focus on implementation.

## 2. Store Compliance & Regulations (App Store & Play Store)
As a social carpooling app, strict adherence to store guidelines is mandatory. All generated code and features must account for:
* **Permissions:** Request permissions (Location, Camera, Microphone) *only* in context, using `permission_handler`. Always provide a clear rationale to the user before the OS prompt.
* **User-Generated Content (UGC):** Social features must include the ability to block users, report inappropriate content, and filter objectionable material.
* **Payments:** Carpooling is a physical service, meaning **Stripe** is the correct payment gateway (do NOT use In-App Purchases for ride payments). 
* **Data Deletion:** Provide a clear, accessible way for users to delete their accounts and associated data entirely from Firebase.
* **Background Location:** If tracking rides in the background, ensure background location permissions are strictly justified and visually indicated to the user.

## 3. Architecture & State Management (MVVM)
* **Separation of Concerns:** Strictly separate the app into Data, Domain (optional for complex logic), and UI layers.
* **State Management:** Use `Riverpod` (`Notifier` / `AsyncNotifier`) via the `riverpod_annotation` package. 
* **Dumb UI:** Widgets should *never* contain business logic. They should only contain UI formatting, simple if-statements for visibility, routing, and animations.
* **Repository Pattern:** Use abstract Repository classes in the data layer to handle Firebase/API interactions. Create Services for external tools (e.g., Stripe, Location).
* **Dependency Injection:** Inject all repositories and services using Riverpod. Avoid globally accessible instances.
* **Unidirectional Data Flow:** UI triggers events (Commands) -> ViewModel processes -> ViewModel updates state -> UI rebuilds.

## 4. Coding Standards (Effective Dart & Flutter)
* **Immutability:** Always use immutable data models. Use `freezed` and `json_serializable` for all models handling Firebase/Stripe data.
* **Naming Conventions:**
    * `UpperCamelCase` for types and extensions.
    * `lowercase_with_underscores` for files, directories, and packages.
    * Suffix classes by responsibility (e.g., `HomeViewModel`, `AuthRepository`, `StripeService`, `ProfileScreen`).
* **Null Safety & Asynchrony:**
    * Prefer `async`/`await` over raw `.then()` Futures.
    * Use `Future<void>` for async tasks that return no value.
    * Never force unwrap (`!`) unless absolutely certain; prefer null-check patterns.
* **Widget Construction:**
    * Extract large widget trees into smaller, private widget classes rather than helper methods returning `Widget`.
    * Use `const` constructors aggressively to optimize Flutter rebuilds.
* **Routing:** Use `go_router` for all navigation. Define strongly typed routes where possible.

## 5. Testing & Quality Assurance
* **Error Handling:** Never swallow exceptions. Catch specific errors, log them using `talker_flutter`, and pass user-friendly messages to the UI.
* **Formatting:** Always format code strictly according to `dart format`.