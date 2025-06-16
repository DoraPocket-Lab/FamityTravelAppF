
# Family Travel App - MVP Phase 1

This is a starter repository for a Family Travel App, focusing on the Minimum Viable Product (MVP) Phase 1. It's built with Flutter and Firebase, following current best practices for long-term maintainability.

## Setup

1.  **Install Flutter and Dart:**
    Follow the official Flutter installation guide: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

2.  **Configure Firebase:**
    This project uses Firebase. To link your Firebase project, run the following command in your terminal:
    ```bash
    flutterfire configure
    ```
    This will generate the `lib/firebase_options.dart` file with your project-specific configurations. **Remember to re-run this command if you make changes to your Firebase project or add new platforms.**

3.  **Run the App:**
    ```bash
    flutter run
    ```

## Firebase Emulators

For local development and testing, it's highly recommended to use the Firebase Emulators. To start them, navigate to your Firebase project directory (where `firebase.json` is located) and run:

```bash
firebase emulators:start
```

## Melos Scripts

This project can utilize `melos` for managing scripts (if you choose to set it up for a monorepo structure, though not strictly required for this starter). Common scripts would include:

*   `melos run gen`: Runs `build_runner` to generate necessary files (e.g., for Hive adapters).
*   `melos run lint`: Runs lint checks across the project.

## Conventional Commits

This project encourages the use of [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for clear and consistent commit messages. This helps with changelog generation and understanding the history of changes.

Examples:

*   `feat: add user authentication`
*   `fix: resolve login issue`
*   `docs: update setup instructions`
*   `chore: update dependencies`


