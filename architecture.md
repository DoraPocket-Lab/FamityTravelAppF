
# Architecture Overview

This project follows a clean architecture approach with a strong emphasis on a **feature-first** directory structure. The goal is to create a highly modular, testable, and maintainable codebase.

## Key Principles

*   **Separation of Concerns:** Each part of the application has a clear responsibility.
*   **Dependency Rule:** Dependencies flow inwards. UI depends on application logic, which depends on domain logic, which depends on data. Nothing should depend on UI.
*   **Testability:** Components are designed to be easily testable in isolation.
*   **Maintainability:** The structure promotes easy understanding and modification of specific features without impacting unrelated parts of the application.

## Feature-First Structure

The `lib/features` directory is the core of this architecture. Each sub-directory within `features` represents a distinct feature of the application (e.g., `auth`, `plan`, `expense`, `memory`).

Within each feature directory, you will typically find:

*   **`data/`**: Contains data sources (e.g., Firebase, Hive) and repositories.
*   **`domain/`**: Defines entities, use cases (interactors), and abstract repositories.
*   **`presentation/`**: Holds UI components (widgets, pages), view models (providers), and controllers.

This structure ensures that all code related to a specific feature is co-located, making it easier to develop, understand, and maintain individual features.

## Core Components (`lib/core`)

The `lib/core` directory contains cross-cutting concerns and shared functionalities that are not specific to any single feature. This includes:

*   **`env/`**: Environment configurations.
*   **`themes/`**: Application themes and styling.
*   **`logger.dart`**: Centralized logging utility.
*   **`utils/`**: General utility functions.

## Data Flow (Simplified)

1.  **UI (Presentation Layer):** Triggers actions (e.g., button press).
2.  **Use Case (Domain Layer):** Orchestrates the business logic, interacts with repositories.
3.  **Repository (Domain Layer Interface):** Defines contracts for data operations.
4.  **Data Source (Data Layer Implementation):** Implements the repository contracts, interacts with external services (Firebase, Hive).
5.  **Data (Data Layer):** Returns data to the Use Case.
6.  **Use Case (Domain Layer):** Processes data and returns to the UI.
7.  **UI (Presentation Layer):** Updates based on the received data.


