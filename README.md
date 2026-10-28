# Facial Attendance System

A Flutter-based student attendance management application that combines student registration, student record management, and **AWS Rekognition-powered facial recognition**. The application uses facial image comparison to support student identity verification, alongside local data storage, cloud integrations, and PDF report generation.

## Features

### Facial Recognition and Identity Verification
- Integrates with Amazon Rekognition through an AWS API endpoint.
- Compares source and target facial images to determine whether they match.
- Uses facial matching to support student identification.

### Student Registration and Management
- Register students and capture relevant personal and academic information.
- Manage student records and profile images.
- Organize student information by school, class level, department, and other registration attributes.
- Work with Nigerian geographical data, including states and local government areas.

### Attendance Management
- Provides an attendance management interface connected to student records.
- Maintains student status information used in attendance-related operations.
- Supports the preparation of student attendance-related reports.

### Local Database
- Uses SQLite through `sqflite` to store student records locally.
- Loads locally stored records for use within the application.
- Supports local data access without requiring every student record to be fetched from a remote service.

### Cloud and External Service Integrations
- **AWS Rekognition:** Facial image comparison through an AWS API endpoint.
- **MongoDB:** Remote database integration.
- **Cloudinary:** Image and media management integration.

### PDF Reports
- Generate PDF reports containing selected student information.
- Save or share generated reports.
- Provides different report-saving options depending on the platform.

### Authentication and User Experience
- Integrates device biometric authentication using `local_auth`.
- Uses `flutter_secure_storage` for secure local storage.
- Supports light and dark themes.
- Uses Provider for application state management.
- Monitors network connectivity and displays connection status messages.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| Provider | State management |
| SQLite (`sqflite`) | Local database and student record persistence |
| Amazon Rekognition | Facial image comparison |
| AWS API endpoint | Communication with the facial-matching service |
| MongoDB | Remote database integration |
| Cloudinary | Image and media management |
| `flutter_secure_storage` | Secure local storage |
| `local_auth` | Device biometric authentication |
| `image_picker` | Selecting images |
| `image_cropper` | Cropping images |
| `pdf` | PDF document generation |
| `printing` | PDF output and printing support |
| `connectivity_plus` | Network connectivity monitoring |

## Project Structure

The project separates its application logic into presentation, data, and shared core components.

```text
lib/
├── core/
│   ├── constants/
│   ├── services/
│   ├── themes/
│   └── widgets/
├── data/
│   ├── database/
│   ├── models/
│   └── repositories/
├── presentation/
│   ├── controllers/
│   └── screens/
├── main.dart
└── ...
```

### Directory Overview

- **`core/`** — Shared constants, application themes, services, and reusable widgets.
- **`data/`** — Database helpers, data models, and repositories for accessing and managing data.
- **`presentation/controllers/`** — Controllers that manage application state and coordinate application operations.
- **`presentation/screens/`** — User interface screens for registration, student management, attendance, and other application features.
- **`main.dart`** — Initializes the database, configures state providers, and starts the application.

The structure is intended to keep UI code, state management, and data operations organized separately.

## Getting Started

### Prerequisites

Before running the application, ensure you have:

- Flutter SDK installed.
- Dart SDK compatible with the project's constraints.
- Android Studio, Visual Studio Code, or another Flutter-compatible IDE.
- An Android emulator or compatible physical device.
- Access to the external services required by the features you want to use.

The project's `pubspec.yaml` specifies a Dart SDK constraint of `^3.6.2`.

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/PhilipNzube/facial_attendance.git
```

**2. Navigate into the project directory**

```bash
cd facial_attendance
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Configure external services**

Review the configuration for AWS, MongoDB, and Cloudinary. Set up the necessary service endpoints, permissions, and credentials using a secure configuration appropriate to each service.

Do not put private credentials directly into the Flutter source code.

**5. Run the application**

```bash
flutter run
```

For additional Flutter environment checks, run:

```bash
flutter doctor
```

## Facial Recognition Workflow

The application integrates with an AWS API endpoint for facial image comparison.

At a high level, the workflow is:

1. Obtain the facial images required for comparison.
2. Send the source and target images to the configured facial-matching endpoint.
3. The backend service performs the facial comparison using AWS Rekognition.
4. The application receives the response indicating whether the faces match.
5. The result can be used by the application's student identification workflow.

The Flutter client communicates with the endpoint rather than needing to perform the AWS facial comparison directly on the device.

## Database and Data Management

The application uses SQLite for local student record storage. Its database helper initializes the local database and creates the student table when the database is first created.

The project also includes integrations for remote data and image management. The behavior of these services depends on their configuration and availability.

For demonstrations, development, and testing, use synthetic student records and sample images rather than real personal or biometric data.

## Security and Privacy

Security is especially important in an application that processes facial images and student information.

- **Protect AWS credentials.** Never embed long-lived AWS secret access keys in a distributed Flutter application.
- **Secure backend operations.** Keep privileged AWS operations behind a properly secured backend or use an appropriate AWS identity configuration.
- **Protect Cloudinary credentials.** Do not expose private API secrets in source code or public repositories.
- **Avoid sensitive logs.** Do not log credentials, secret responses, facial images, or unnecessary personal information.
- **Rotate exposed credentials.** If a secret has been committed to a public repository, revoke or rotate it. Removing it from the latest version does not remove it from Git history.
- **Protect biometric information.** Limit access to facial images and student records, and use appropriate consent, retention, and access-control practices.
- **Use test data.** Avoid committing real student photographs, biometric information, or identifiable student records.

## Current Project Scope

The repository contains functionality and integrations for:

- Student registration and record management.
- Facial matching through AWS Rekognition.
- Local student data persistence.
- Attendance-related screens and reporting.
- Remote database and image-service integrations.
- PDF report generation.
- Authentication-related functionality and application preferences.

The application has been developed with a focus on bringing student management and facial recognition together in a Flutter application.

## Future Improvements

Potential areas for further development include:

- Strengthening authentication and role-based access control.
- Improving synchronization between local and remote student records.
- Expanding attendance analytics and reporting.
- Improving automated testing for facial matching and attendance workflows.
- Enhancing error handling and monitoring for external services.
- Documenting deployment and backend configuration.
- Improving biometric data protection and auditability.
