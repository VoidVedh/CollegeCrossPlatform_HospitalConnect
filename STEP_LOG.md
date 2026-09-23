# HospitalConnect Execution & Viva Log

This log documents the incremental step-by-step progress, technical architecture, and college viva talking points for the HospitalConnect project.

---

## Step 01: Setup & Project Initialization
- **Title**: initialize Flutter project CollegeCrossPlatform_HospitalConnect and pubspec dependencies
- **Commit**: `feat(setup): initialize Flutter project CollegeCrossPlatform_HospitalConnect and pubspec dependencies`
- **Files Created**:
  - `pubspec.yaml`
  - `analysis_options.yaml`
  - `lib/main.dart`
  - `lib/app.dart`
  - `test/widget_test.dart`
  - `README.md`
  - Folder structure with `.gitkeep` files in `lib/`
- **Files Modified**: none
- **How to Test**:
  - Run `flutter analyze` inside the repo: returns `No issues found!`.
  - Run `flutter test`: returns `All tests passed!`.
  - Run `flutter run`: displays the starter splash screen with app title and completion chip.
- **Viva Note**:
  Separating framework startup (`main.dart`) from UI root widget declaration (`app.dart`) follows the Single Responsibility Principle. This enables unit and widget test harnesses to pump the app tree directly without initializing real system channels.

---

## Step 02: Healthcare Theme & Typography
- **Title**: build Material 3 Healthcare Theme with custom colors and typography
- **Commit**: `feat(theme): build Material 3 Healthcare Theme with custom colors and typography`
- **Files Created**:
  - `lib/core/theme/app_colors.dart`
  - `lib/core/theme/app_text_styles.dart`
  - `lib/core/theme/app_theme.dart`
- **Files Modified**:
  - `lib/app.dart`
  - `test/widget_test.dart`
- **How to Test**:
  - Run `flutter analyze` and `flutter test`: all clean and passing.
  - Run `flutter run`: verify the soft ice-blue surface background (`#F5FAFB`), primary teal buttons (`#006A6A`), and status badges with icons + labels.
  - Focus into text field: verify 2px primary teal border outline.
- **Viva Note**:
  Material 3 theming utilizes `ColorScheme.fromSeed` to establish harmonious tonal palettes. Healthcare status badges explicitly couple icons with text and color to satisfy WCAG 1.4.1 accessibility guidelines for color-blind users.

---

## Step 03: Domain Models & Business Rules
- **Title**: implement Doctor, Review, Appointment, MedicalRecord, Prescription, and Bill models
- **Commit**: `feat(models): implement Doctor, Review, Appointment, MedicalRecord, Prescription, and Bill models`
- **Files Created**:
  - `lib/models/enums.dart`
  - `lib/models/review_model.dart`
  - `lib/models/doctor_model.dart`
  - `lib/models/appointment_model.dart`
  - `lib/models/medical_record_model.dart`
  - `lib/models/prescription_model.dart`
  - `lib/models/bill_model.dart`
  - `lib/models/models.dart`
  - `test/models_test.dart`
- **Files Modified**:
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/models_test.dart`: all model unit tests pass.
  - Verify `BillModel.totalAmount` computes `consultationFee + labCharges + tax` dynamically and cannot be hardcoded or stored.
  - Verify immutability and `copyWith` functionality across domain models.
- **Viva Note**:
  Domain models are defined as immutable classes using `const` constructors and `@immutable`. Computed properties such as `BillModel.totalAmount` prevent data synchronization discrepancies by computing derived values on-the-fly rather than duplicating mutable state.

---

## Step 04: Repository Interfaces & Mock Data Service
- **Title**: create repository interfaces and MockDataService with realistic sample healthcare data
- **Commit**: `feat(services): create repository interfaces and MockDataService with realistic sample healthcare data`
- **Files Created**:
  - `lib/core/utils/formatters.dart`
  - `lib/core/utils/validators.dart`
  - `lib/services/repositories/doctor_repository.dart`
  - `lib/services/repositories/appointment_repository.dart`
  - `lib/services/repositories/medical_record_repository.dart`
  - `lib/services/repositories/prescription_repository.dart`
  - `lib/services/repositories/bill_repository.dart`
  - `lib/services/repositories/payment_gateway.dart`
  - `lib/services/repositories/repositories.dart`
  - `lib/services/mock/mock_data_service.dart`
  - `lib/services/mock/mock_doctor_repository.dart`
  - `lib/services/mock/mock_appointment_repository.dart`
  - `lib/services/mock/mock_medical_record_repository.dart`
  - `lib/services/mock/mock_prescription_repository.dart`
  - `lib/services/mock/mock_bill_repository.dart`
  - `lib/services/mock/mock_payment_gateway.dart`
  - `lib/services/mock/mock_services.dart`
  - `test/validators_test.dart`
  - `test/repositories_test.dart`
- **Files Modified**:
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/repositories_test.dart`: confirms mock dataset contains 10 doctors across 5 specialties, 3+ reviews each, 5 medical records, 4 prescriptions, and 5 bills in mixed statuses.
  - Run `flutter test test/validators_test.dart`: validates phone, age, patient name, and payment field validators.
  - Run `flutter analyze`: zero analyzer issues.
- **Viva Note**:
  Applying the **Repository Pattern** and **Dependency Inversion Principle** (SOLID) decouples presentation and business logic from the persistence layer. By coding state providers against abstract interfaces (`DoctorRepository`, `BillRepository`, etc.), the underlying mock data source can be replaced with real REST or GraphQL APIs in production without altering UI or state management code.

---

## Step 05: Provider State Architecture & App Navigation Shell
- **Title**: set up Provider skeletons, BottomNavigationBar and app shell route system
- **Commit**: `feat(navigation): set up Provider skeletons, BottomNavigationBar and app shell route system`
- **Files Created**:
  - `lib/providers/doctor_provider.dart`
  - `lib/providers/appointment_provider.dart`
  - `lib/providers/medical_record_provider.dart`
  - `lib/providers/prescription_provider.dart`
  - `lib/providers/bill_provider.dart`
  - `lib/providers/providers.dart`
  - `lib/screens/app_shell.dart`
  - `lib/screens/dashboard/dashboard_screen.dart`
  - `lib/screens/doctors/doctors_screen.dart`
  - `lib/screens/appointments/appointments_screen.dart`
  - `lib/screens/records/records_screen.dart`
  - `lib/screens/billing/billing_screen.dart`
- **Files Modified**:
  - `lib/main.dart`
  - `lib/app.dart`
  - `test/widget_test.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test`: all 16 tests pass, verifying that the 5-tab NavigationBar switches between tabs correctly.
  - Launch app: verify 5 bottom navigation tabs (Home, Doctors, Appointments, Records, Bills).
  - Check the Bills icon: note the dynamic notification badge showing the unpaid invoice count.
- **Viva Note**:
  `MultiProvider` registers all domain state holders at the app root, facilitating reactive state distribution down the widget tree using `context.watch()` or `context.select()`. The `IndexedStack` in `AppShell` preserves scroll position and widget state across tab switches, optimizing performance.

---

## Step 06: Patient Dashboard Header, Search & Category Chips
- **Title**: build Patient Dashboard top header, search bar, and category chips
- **Commit**: `feat(dashboard): build Patient Dashboard top header, search bar, and category chips`
- **Files Created**:
  - `lib/widgets/specialty_chip.dart`
  - `lib/widgets/widgets.dart`
  - `test/dashboard_test.dart`
- **Files Modified**:
  - `lib/screens/dashboard/dashboard_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/dashboard_test.dart`: verifies that the greeting, SOS emergency pill, SearchBar, and category chips render and interact cleanly.
  - Run `flutter run`: verify "Hello, Aditya 👋", initials avatar, and emergency SOS 108 tag.
  - Tap different specialty chips (Cardiology, Neurology, Pediatrics, Orthopedics): verify smooth active background transition and filtered doctor count updates live.
- **Viva Note**:
  Reusable UI components like `SpecialtyChip` incorporate `Semantics` tags and explicit state animation (`AnimatedContainer`), satisfying mobile accessibility and responsive design guidelines. Real-time filtering through `context.watch<DoctorProvider>()` updates the UI reactively on every keystroke or chip tap.
