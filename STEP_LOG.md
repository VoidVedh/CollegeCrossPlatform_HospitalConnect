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

---

## Step 07: Quick Action Cards & Upcoming Appointment Preview
- **Title**: add Quick Action Cards and Upcoming Appointment preview widget
- **Commit**: `feat(dashboard): add Quick Action Cards and Upcoming Appointment preview widget`
- **Files Created**:
  - `lib/widgets/quick_action_card.dart`
  - `lib/widgets/upcoming_appointment_card.dart`
- **Files Modified**:
  - `lib/widgets/widgets.dart`
  - `lib/screens/dashboard/dashboard_screen.dart`
  - `lib/screens/app_shell.dart`
  - `test/dashboard_test.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test`: all 16 tests pass with zero warnings.
  - Run `flutter run`: verify the Upcoming Appointment card with rich teal gradient, showing Dr. Meera Nambiar's visit tomorrow at 10:00 AM.
  - Verify the 4 Quick Action cards ("Book Visit", "Prescriptions", "Records", "Pay Bills"). Tapping "Pay Bills" switches immediately to the Bills navigation tab.
  - Scroll down to verify the Top Rated Specialists carousel displaying doctors with fees in ₹ INR and "Consult" buttons.
- **Viva Note**:
  `LayoutBuilder` enables adaptive grid configurations (`crossAxisCount = 4` on wide screens / tablets, `2` on phones), preventing UI distortion across form factors. The `UpcomingAppointmentCard` leverages gradient containers with high-contrast text and icons to establish immediate visual hierarchy for critical patient notifications.

---

## Step 08: Doctor Card Component & Rating Badges
- **Title**: create Doctor Card component with specialty badges and rating UI
- **Commit**: `feat(doctors): create Doctor Card component with specialty badges and rating UI`
- **Files Created**:
  - `lib/widgets/doctor_card.dart`
  - `test/doctor_card_test.dart`
- **Files Modified**:
  - `lib/widgets/widgets.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/doctor_card_test.dart`: verifies that doctor details, specialty chip, rating badge, experience, fee in ₹, and action callbacks work as expected.
  - Verify tap targets comply with accessibility standards (min 48x48dp target for buttons).
  - Verify that doctor photos gracefully fall back to an initials avatar when no network image is supplied.
- **Viva Note**:
  Decoupling the `DoctorCard` into a standalone widget adheres to the Component-Driven Development paradigm. Passing explicit callbacks (`onTap`, `onBookVisit`) instead of embedding navigation logic directly within the card preserves UI flexibility across different screen contexts (e.g., search list vs. recommended carousel).

---

## Step 09: Doctor Search & Filter Catalog Screen
- **Title**: build Doctor Search and Filter List view screen
- **Commit**: `feat(doctors): build Doctor Search and Filter List view screen`
- **Files Created**:
  - `lib/screens/doctors/doctor_detail_screen.dart`
  - `test/doctors_screen_test.dart`
- **Files Modified**:
  - `lib/screens/doctors/doctors_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/doctors_screen_test.dart`: verifies full search, category filtering, and empty state reset.
  - Open "Doctors" tab: explore the 10+ doctors catalog.
  - Tap on the sort icon: toggle sorting by Highest Rated, Most Experienced, or Lowest Consultation Fee.
  - Type a query in the SearchBar: list updates reactively. Clearing the query or resetting filters instantly restores the catalog.
- **Viva Note**:
  The `DoctorsScreen` implements declarative UI synchronization with `DoctorProvider.filteredDoctors`. Utilizing `PopupMenuButton` for multi-criteria sorting demonstrates state preservation while empty states provide immediate actionable remediation via "Clear All Filters", adhering to Nielsen Norman usability heuristics.

---

## Step 10: Doctor Detail View with Experience, Bio & Reviews
- **Title**: construct Doctor Detail view with experience, bio, reviews, clinic address, and fees
- **Commit**: `feat(doctors): construct Doctor Detail view with experience, bio, reviews, clinic address, and fees`
- **Files Created**:
  - `lib/screens/appointments/booking_screen.dart`
  - `test/doctor_detail_test.dart`
- **Files Modified**:
  - `lib/screens/doctors/doctor_detail_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/doctor_detail_test.dart`: verifies metrics row, biography, clinic address, patient reviews, and sticky booking bar.
  - Tap any doctor from Doctors tab or Top Specialists carousel on Dashboard: opens comprehensive profile.
  - Verify experience years, rating, and verified patient reviews.
  - Tap sticky bottom button "Book Appointment": transitions directly into the booking flow.
- **Viva Note**:
  The `DoctorDetailScreen` combines key quantitative trust signals (experience, rating, patient counts) with qualitative evidence (verified patient reviews) in an information hierarchy designed for healthcare decision-making. Placing the booking trigger in a persistent, accessible bottom bar ensures the primary conversion action is always accessible without requiring the user to scroll to the end of lengthy reviews.

---

## Step 11: DatePicker & Dynamic Time-Slot Grid Selector
- **Title**: implement DatePicker and dynamic Time-Slot grid selector
- **Commit**: `feat(appointment): implement DatePicker and dynamic Time-Slot grid selector`
- **Files Created**:
  - `lib/widgets/slot_selector.dart`
  - `test/slot_selector_test.dart`
- **Files Modified**:
  - `lib/widgets/widgets.dart`
  - `lib/screens/appointments/booking_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/slot_selector_test.dart`: verifies that 14 days calendar navigation functions, available slots can be chosen, and booked/past slots are visibly disabled with strike-through text.
  - Open Doctor Detail and tap "Book Appointment": explore the 14-day date picker.
  - Tap through morning and evening slots: verify active highlight and selected date/time summary card.
- **Viva Note**:
  `SlotSelector` enforces domain business constraints at the UI layer by checking doctor availability lists and active bookings before enabling interactive callbacks. Visually differentiating disabled states using contrasting strike-through styling and disabled `Semantics` tags ensures accessible affordance.

---

## Step 12: Patient Booking Form with Field Validation
- **Title**: build Patient Booking Form with field validation
- **Commit**: `feat(appointment): build Patient Booking Form with field validation`
- **Files Created**:
  - `lib/widgets/patient_booking_form.dart`
  - `test/booking_form_test.dart`
- **Files Modified**:
  - `lib/widgets/widgets.dart`
  - `lib/screens/appointments/booking_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/booking_form_test.dart`: verifies form validation rules, input constraints, and submission gates.
  - Navigate to Doctor Detail -> Book Appointment -> scroll down to Patient Information.
  - Tap "Review & Confirm Booking" with empty fields to observe specific validation error alerts.
  - Type invalid input (e.g. invalid phone, age > 120, short symptoms < 10 characters) and verify inline validation guidance.
  - Enter valid information and choose a slot to proceed.
- **Viva Note**:
  `PatientBookingForm` leverages Flutter's `Form` and `TextFormField` widgets paired with centralized regex-based `AppValidators`. Restricting numeric input with `FilteringTextInputFormatter` and evaluating fields via `AutovalidateMode.onUserInteraction` ensures that invalid payloads are caught immediately at the UI layer before reaching business logic or services.

---

## Step 13: Appointment Confirmation Modal & Booking Persistence
- **Title**: integrate Appointment Confirmation Modal and persist booking through AppointmentProvider
- **Commit**: `feat(appointment): integrate Appointment Confirmation Modal and persist booking through AppointmentProvider`
- **Files Created**:
  - `lib/widgets/appointment_confirmation_dialog.dart`
  - `test/appointment_confirmation_test.dart`
- **Files Modified**:
  - `lib/core/utils/formatters.dart`
  - `lib/providers/appointment_provider.dart`
  - `lib/widgets/widgets.dart`
  - `lib/screens/appointments/booking_screen.dart`
  - `lib/main.dart`
  - `lib/app.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/appointment_confirmation_test.dart`: verifies `APT-XXXXXX` ID generation, doctor slot blocking, pending bill creation, cancellation slot release, and confirmation dialog flow.
  - From Doctor Detail -> Book Appointment -> pick an available date and slot -> fill patient form -> tap "Review & Confirm Booking".
  - Inspect itemized charges breakdown (Consultation Fee, 18% GST, Total Payable) in the confirmation dialog.
  - Tap "Confirm & Book" to see real-time state mutation and the Success Modal featuring the generated `APT-` ID and navigation options.
- **Viva Note**:
  `AppointmentProvider.bookAppointment()` acts as the single transactional orchestrator for the appointment workflow. It generates a formatted unique identifier (`APT-XXXXXX`), inserts an upcoming appointment, updates the doctor's slot availability in `DoctorRepository`, and automatically creates an itemized pending invoice in `BillRepository`.

---

## Step 14: Medical History Timeline & Record Detail View
- **Title**: construct Medical History timeline and record detail view
- **Commit**: `feat(medical-records): construct Medical History timeline and record detail view`
- **Files Created**:
  - `lib/screens/records/record_detail_screen.dart`
  - `test/medical_records_test.dart`
- **Files Modified**:
  - `lib/providers/medical_record_provider.dart`
  - `lib/screens/records/records_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/medical_records_test.dart`: verifies chronological timeline rendering, detail screen transition, attachment preview interaction, and empty state.
  - From bottom navigation, tap the "Records" tab to open the chronological medical visit timeline.
  - View visit records with date badges, diagnosis titles, treating doctor & hospital info, and attachment counters.
  - Tap any visit card to inspect the full Clinical Summary, doctor notes, and interactive diagnostic attachments (PDF, JPG).
  - Tap an attachment's download icon to trigger an offline report preview notification.
- **Viva Note**:
  The medical history module implements a chronological timeline representation of patient consultations using custom timeline indicators and Material 3 cards. It organizes sensitive clinical observations separately from downloadable attachments with simulated offline document handlers, following healthcare data display standards.

---

## Step 15: Prescription List & Detailed Medication Cards with Share/Print Modal
- **Title**: build Prescription List and detailed Medication Card view with share/print modal
- **Commit**: `feat(prescriptions): build Prescription List and detailed Medication Card view with share/print modal`
- **Files Created**:
  - `lib/widgets/prescription_preview_modal.dart`
  - `lib/screens/prescriptions/prescriptions_screen.dart`
  - `test/prescriptions_test.dart`
- **Files Modified**:
  - `lib/providers/prescription_provider.dart`
  - `lib/widgets/widgets.dart`
  - `lib/app.dart`
  - `lib/screens/dashboard/dashboard_screen.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/prescriptions_test.dart`: verifies prescription listing, expandable medication items (dosage, frequency, duration), modal document generation, and empty state.
  - From Dashboard, tap the "Prescriptions" quick action card to open `PrescriptionsScreen`.
  - Tap on any prescription's medication count to expand detailed medication badges (dosage, timing frequency, course duration).
  - Tap "View & Print" or "Share Rx" to open the simulated official hospital letterhead prescription document with digital doctor signature.
---

## Step 16: Bill Summary Screen with Itemized Charges Breakdown
- **Title**: design Bill Summary screen with itemized charges breakdown
- **Commit**: `feat(billing): design Bill Summary screen with itemized charges breakdown`
- **Files Created**:
  - `lib/widgets/bill_card.dart`
  - `test/billing_test.dart`
- **Files Modified**:
  - `lib/widgets/widgets.dart`
  - `lib/screens/billing/billing_screen.dart`
  - `lib/providers/bill_provider.dart`
  - `STEP_LOG.md`
- **How to Test**:
  - Run `flutter test test/billing_test.dart`: verifies `BillModel.totalAmount` computed getter, Outstanding Dues calculation, itemized breakdown (Consultation, Lab, GST), and Paid/Pending filter chips.
  - From bottom navigation, tap the "Bills" tab.
  - Check the prominent Outstanding Dues banner displaying total pending balance in ₹ INR and count of pending invoices.
  - Toggle filter chips: "All Bills", "Pending / Due", "Paid History".
  - Tap "Pay Now" on any pending bill to open the Itemized Bill Summary bottom sheet with full breakdown.
- **Viva Note**:
  `BillModel.totalAmount` is implemented as an un-stored, strictly computed Dart getter (`consultationFee + labCharges + tax`), preventing data desynchronization bugs. The `BillingScreen` offers transparent financial breakdowns paired with color- and text-differentiated status badges (Paid green, Unpaid crimson, Pending amber), fulfilling accessibility guidelines and financial accounting integrity.

