
# 🌟 Face Recognition System

This project is a Flutter-based face recognition system that uses TensorFlow Lite (TFLite) for face embedding extraction and Supabase for user data storage and management. The application can register a user's face and verify it during.

---

## 📋 **Setup Instructions**

### **1. Prerequisites**

Before you begin, ensure you have the following installed:

- ✅ Flutter SDK (latest stable version)
- ✅ Dart SDK
- ✅ Supabase account
- ✅ TensorFlow Lite model (`facenet.tflite`)

---

### **2. Project Setup**

#### **📂 Clone Repository**

Clone this repository to your local machine:

```bash
git clone https://github.com/nurd0tid/Face-Detection-Flutter.git
cd Face-Detection-Flutter
```

#### **🔧 Add Dependencies**

Ensure the following dependencies are added to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.11.0+2
  google_mlkit_face_detection: ^0.12.0
  supabase_flutter: ^2.8.3
  path_provider: ^2.1.4
  image: ^4.5.2
  image_picker: ^1.0.0
  sqflite: ^2.3.3+1
  tflite_flutter: ^0.11.0
  permission_handler: ^11.3.1
```

Run the following command to install dependencies:

```bash
flutter pub get
```

#### **📁 Add Assets**

1. Place the `facenet.tflite` file in the `assets/models/` directory.
2. Update `pubspec.yaml` to include the assets:

```yaml
flutter:
  assets:
    - assets/models/facenet.tflite
```

---

### **3. 🔑 Supabase Setup**

#### **Step 1: Create a New Project**

1. Log in to your Supabase account.
2. Create a new project.

#### **Step 2: Create a Database Table**

Create a table named `users_faces` with the following schema:

| Column Name   | Data Type | Constraints      |
| ------------- | --------- | ---------------- |
| `id`          | UUID      | Primary Key      |
| `user_id`     | UUID      | Unique, Not Null |
| `name`        | Text      | Not Null         |
| `face_vector` | Text      | Not Null         |

#### **Step 3: Get Supabase Keys**

1. Navigate to **Project Settings > API** in your Supabase dashboard.
2. Copy your **Supabase URL** and **Anon Key**.
3. Replace the placeholders in `constants.dart`:

```dart
const String SUPABASE_URL = '<your_supabase_url>'; // Your Supabase URL
const String SUPABASE_KEY = '<your_supabase_key>'; // Your Supabase Anon Key
```

---

### **4. 🚀 Run the Application**

1. Connect a physical device or emulator.
2. Run the application:

```bash
flutter run
```

---

## 🌟 **Features**

- **Face Registration:**
  - 📸 Capture a user's face and save its embedding vector to Supabase.

- **Face Verification:**
  - 🤖 Compare a captured face with the registered face using cosine similarity.
  - ✅ Verifies if the similarity score exceeds the threshold (`FACE_SIMILARITY_THRESHOLD = 0.8`).

---

## 📂 **Folder Structure**

```
lib/
├── main.dart
├── config/
│   └── constants.dart
├── models/
│   └── user_model.dart
├── services/
│   ├── camera_service.dart
│   ├── face_detection_service.dart
│   ├── ml_service.dart
│   └── supabase_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── register_screen.dart
│   └── verify_screen.dart
├── widgets/
│   ├── camera_preview_widget.dart
│   └── face_painter.dart
├── utils/
│   ├── image_utils.dart
│   ├── validation_utils.dart
│   └── request_permissions.dart
```

---

## 📖 **Usage**

### **Register a Face**

1. Open the app and navigate to the **Register** screen.
2. 📸 Capture a face using the camera.
3. The app will detect the face, extract the embedding vector, and store it in the Supabase database.

### **Verify a Face**

1. Navigate to the **Verify** screen.
2. 📸 Capture a face using the camera.
3. The app will compare the captured face with the registered face.
4. ✅ If the similarity score exceeds the threshold (`FACE_SIMILARITY_THRESHOLD = 0.8`), the face is verified.

---

## 🛠️ **Troubleshooting**

### **1. Model Initialization Failed**

- Ensure `facenet.tflite` is placed in the correct directory (`assets/models/`).
- Confirm the file is listed in `pubspec.yaml`.

### **2. Supabase Connection Issues**

- Verify the Supabase URL and Anon Key in `constants.dart`.
- Ensure the table `users_faces` exists and has the correct schema.

### **3. Face Detection Issues**

- Ensure proper lighting conditions for the camera.
- Use a high-quality camera for better face detection accuracy.

---

## 🤝 **Contributing**

Contributions are welcome! Feel free to fork the repository and submit a pull request.

---

## 📜 **License**

This project is licensed under the MIT License. See the LICENSE file for more information.