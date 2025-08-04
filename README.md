# StackOverflow Users (MVVM-C, UIKit, SOLID)

## Overview
This iOS app displays the top 20 StackOverflow users, showing their profile image, name, reputation, and allows you to follow/unfollow users locally. The app is built using UIKit, follows the MVVM-C (Model-View-ViewModel-Coordinator) architecture, and applies SOLID principles for maintainability and testability. No third-party libraries are used.

## Features
- Fetches and displays the top 20 StackOverflow users.
- Shows user profile image, display name, and reputation.
- Follow/unfollow users locally (persisted with UserDefaults).
- Followed users are indicated in the list.
- Error state UI if the network request fails.
- Fully unit tested (models, networking, view model, follow manager).

## Architecture
- **Model:** Data structures for users and API responses.
- **View:** UIKit-based UI (ViewControllers, custom cells).
- **ViewModel:** Handles business logic, data transformation, and exposes observable properties for the View.
- **Coordinator:** Manages navigation and flow between screens.
- **Service:** Networking and follow state management.

## Technical Decisions
- **MVVM-C:** Chosen for clear separation of concerns, testability, and scalability.
- **SOLID Principles:** Each class has a single responsibility, dependencies are injected for testability, and interfaces are used for abstraction.
- **No 3rd Party Libraries:** All networking, persistence, and UI are implemented using native Swift and UIKit APIs.
- **Persistence:** Followed user IDs are stored in UserDefaults for simplicity and reliability.
- **Async Image Loading:** Profile images are loaded asynchronously with cell reuse safety.
- **Unit Testing:** All business logic and networking are covered by unit tests using dependency injection and mocks.

## Installation
1. Clone the repository:
   ```sh
   git clone <your-repo-url>
   ```
2. Open `StackOverflowUsers.xcodeproj` in Xcode.
3. Build and run the app on the simulator or a device.
4. To run tests, select the test target and press ⌘U.

## How It Works
- On launch, the app fetches the top 20 users from the StackExchange API.
- Users are displayed in a table view. Each cell shows the user's profile image, name, reputation, and a follow/unfollow button.
- Tapping follow/unfollow updates the local state and persists it between launches.
- If the network request fails, an error message is shown.

## Customization & Testing
- To simulate a network error, use `ErrorNetworkService` in the ViewModel.
- All dependencies (networking, follow manager) are injected for easy mocking in tests.

## Contact
For any questions, please contact the repository owner.
