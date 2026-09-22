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
