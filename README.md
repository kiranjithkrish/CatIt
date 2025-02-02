# CatIt

CatIt is a SwiftUI-based mobile application that displays cat breeds and images. The app is built using a custom architectural pattern that favours composition and portability. The primary goal is to keep the UI and data domains completely separate and independent, making the data layer usable with any UI framework or even as a headless client.

## Project Overview

- **User Interface:**  
  - SwiftUI for the UI  
  - Combine for reactive data binding (using ObservableObject, @StateObject, and @ObservedObject)

- **Separation of Concerns:**  
  - **UI Domain:** All views are “dumb” and only responsible for displaying data.  
  - **Data Domain:** Divided into a networking layer, a repository layer, and a service layer (or view model layer). This layer is completely UI-agnostic.

- **Navigation:**  
  - Navigation is handled outside of the views using a `NavigationCoordinator` and `RootFlow` (or dedicated navigation handlers). This keeps the views decoupled from navigation logic.

- **Image Caching:**  
  - A custom image loader, `BasicCachedAsyncImage`, uses URLCache for asynchronous image loading and caching to optimize network usage.

- **Splash Screen:**  
  - A dynamic splash screen is displayed on launch as an overlay while the main content loads in the background.

## Key Features

- **Breeds List Screen:**  
  Displays a list of cat breeds using a persistent `BreedsService` that loads data asynchronously from a repository.

- **Detail Screen:**  
  When a breed is selected, the detail screen shows the breed description and a grid of images. The grid layout adapts to different device sizes using an adaptive grid.

- **Custom Asynchronous Image Loader:**  
  `BasicCachedAsyncImage` handles image loading and caching, ensuring images are loaded from cache on subsequent views.

- **Splash Screen:**  
  The splash screen appears at app launch and is dismissed after a short delay, revealing the main content (RootView).

- **Navigation Flow:**  
  Navigation is managed by a `NavigationCoordinator` and `RootFlow`, which assemble dependencies and handle navigation actions (e.g., pushing a detail view).

## Architecture

- **Custom Architectural Pattern:**  
  - **Entities:** Models such as `Breed` and `CatImageInfo` are decoded from the API. Custom decoding logic ensures each model instance receives a stable, unique identifier.  
  - **Repository:** The repository layer uses a reusable networking layer (based on URLSession and a RESTDataStore abstraction) to request data from endpoints.  
  - **Service Layer:** The service (or view model) layer sits between the repository and the UI. It exposes data and handles pagination and error management.  
  - **Views:** Scenes are built with SwiftUI, and the UI remains “dumb” by only observing published state from the service layer.

- **Flow Pattern:**  
  - **NavigationCoordinator:** Manages navigation paths using SwiftUI’s NavigationStack.  
  - **RootFlow:** Assembles dependencies for screens and handles navigation actions (for example, pushing a detail screen when a breed is selected). Future flows for additional screens can be added independently.

- **Networking:**  
  - A reusable networking layer provides abstraction for testing.  
  - An `Endpoint` type is used to configure URL endpoints; repositories use these endpoints to fetch data via the RESTDataStore.

- **Dependency Passing:**  
  - No dependency containers are used. All required dependencies are passed explicitly, keeping the architecture simple and portable.

## How It Works

1. **App Launch:**  
   Upon tapping the app icon, iOS displays the launch screen (configured via LaunchScreen.storyboard) followed by a SwiftUI splash screen (`SplashView`) as an overlay while `RootView` loads in the background.

2. **Main Screen (BreedsView):**  
   The app creates a persistent navigation coordinator and a RootFlow. A persistent `BreedsService` is created and injected into BreedsView along with a navigation callback. The breeds list is loaded asynchronously.

3. **Detail Screen (BreedDetailsView):**  
   When a breed is selected, RootFlow assembles the dependencies for the detail screen (including a dedicated `BreedDetailsService`), then pushes a detail view onto the NavigationStack. The detail screen shows breed details and an adaptive grid of images with pagination.

4. **Caching and Performance:**  
   The custom image loader caches images so that revisiting a detail screen loads images from cache, reducing network calls.

## Additional Notes

- **Error Handling:**  
  The app displays an error toast if data loading fails.
- **Pagination:**  
  The service layers handle pagination for loading both breeds and images.
- **Portability and Testability:**  
  The data domain is completely independent of the UI, making it easy to test or integrate with other UI frameworks. Lower layers can be mocked for unit testing.

## Improvements

- **Unit Testing:**  
  Future improvements include adding unit tests for each layer (networking, repository, service). The architecture is designed to be testable by mocking the lower layers.
- **Persistent Storage:**  
  Introducing a storage layer at the repository level would allow selecting between memory and disk storage, enabling data persistence and offline access.
- **Further UI Optimizations:**  
  More rigorous testing is needed to ensure the UI behaves well across all device sizes.

## How to Run

1. Open the project in Xcode.
2. Build and run the app on a simulator or device.
3. The app will launch with a splash screen, then display the breeds list. Tapping on a breed navigates to the detail screen.

## Conclusion

CatIt demonstrates a modular, testable SwiftUI application built with a custom architectural pattern that separates UI from data logic and decouples navigation from views. This design ensures that the app is portable, maintainable, and easy to extend with new features or different UI layers.
