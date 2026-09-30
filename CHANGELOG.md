# Changelog

All notable changes to the **HospitalConnect** cross-platform healthcare management application are documented in this file.
The project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and [Conventional Commits](https://www.conventionalcommits.org/).

---

## [1.0.0] - 2026-09-30

### Phase 1: Correctness & Core Integrity
- **fix(core)**: Resolved double-booking race condition by introducing atomic slot verification and reservation.
- **fix(core)**: Eliminated financial discrepancy bugs by converting `BillModel.totalAmount` into a computed getter (`consultationFee + labCharges + tax`).
- **fix(core)**: Hardened input validation in `AppValidators` with strict regex patterns for patient full names, age ranges (1–120), 10-digit Indian phone numbers, and symptoms note minimum length.

### Phase 2: Architecture & State Decoupling
- **refactor(arch)**: Implemented Clean Architecture with abstract repository contracts (`DoctorRepository`, `AppointmentRepository`, `MedicalRecordRepository`, `PrescriptionRepository`, `BillRepository`, `PaymentGateway`).
- **refactor(arch)**: Introduced `SafeNotifier` mixin with disposal lifecycle guards (`isDisposed`) to prevent post-disposal notification crashes.
- **refactor(arch)**: Created `BookingCoordinator` domain service to orchestrate cross-provider transactions without circular dependencies.
- **refactor(arch)**: Built centralized testing harness in `test/helpers/pump_app.dart` supporting isolated widget and integration tests.

### Phase 3: Screen Decomposition & Reusable Design System
- **refactor(ui)**: Decomposed oversized screen files into modular widget hierarchies:
  - `screens/dashboard/widgets/` (`DashboardHeader`, `UpcomingAppointmentBanner`, `SpecialtyFilterChips`, `TopDoctorsCarousel`).
  - `screens/appointments/widgets/` (`AppointmentCard`, `RescheduleModal`, `CancelConfirmDialog`).
  - `screens/billing/widgets/` (`OutstandingDuesBanner`, `BillCard`, `BillPaymentBottomSheet`, `PaymentReceiptModal`).
  - `screens/records/widgets/` (`RecordTimelineItem`, `AttachmentListModal`).
- **refactor(ui)**: Extracted atomic design tokens and reusable healthcare widgets:
  - `DoctorAvatar`, `StatusBadge`, `MetricCard`, `AppCard`, `InfoRow`, `EmptyStateWidget`.

### Phase 4: Dark Mode, Micro-Interactions & Stepper Booking Flow
- **feat(ux)**: Added full Material 3 Dark Theme with high-contrast surfaces, custom dark container tokens, and teal/cyan accents.
- **feat(ux)**: Implemented 3-step visual progress stepper on `BookingScreen` (`Choose Slot` -> `Patient Details` -> `Review & Confirm`).
- **feat(ux)**: Added unsaved changes `PopScope` guard on `BookingScreen` to prevent accidental data loss.
- **feat(ux)**: Added tactile haptic feedback (`HapticFeedback.selectionClick()`) across chips, cards, and buttons.
- **feat(ux)**: Implemented persistent `ThemeProvider` backed by `SharedPreferences`.

### Phase 5: Accessibility Compliance & Responsive Layouts
- **fix(a11y)**: Enforced 48x48dp minimum interactive touch targets across all buttons, date selector cards, and time slot chips.
- **fix(a11y)**: Added screen-reader accessibility labels with `Semantics` widgets across `TimeSlotGrid`, `StatusBadge`, `DoctorAvatar`, and timeline items.
- **fix(a11y)**: Exceeded WCAG AAA contrast ratios (>7:1) for badge text in both light and dark modes.
- **fix(a11y)**: Added adaptive responsive navigation:
  - Material 3 `NavigationRail` on wide screens (`width >= 720dp`).
  - Master-detail split layout on expanded screens (`width >= 840dp`) in `DoctorsScreen` and `RecordsScreen`.
- **fix(a11y)**: Guaranteed zero `RenderFlex` overflows on compact screens (320x568dp) at 2.0x text scale.

### Phase 6: Deterministic Time Simulation & Full Coverage
- **test(coverage)**: Created `Clock` interface (`SystemClock`, `FakeClock`) for deterministic slot expiration testing.
- **test(coverage)**: Injected `Clock` into `SlotScheduleService` to allow exact testing of past vs upcoming slot availability.
- **test(coverage)**: Added comprehensive end-to-end integration workflow tests (`test/integration_workflow_test.dart`):
  - Full Patient Journey: Doctor discovery -> Stepper booking -> Auto-invoicing -> Payment -> Receipt generation.
  - Reschedule Lifecycle: Atomically frees old slot and books new slot.
  - Cancellation Lifecycle: Frees slot, marks cancelled, and voids pending invoice.
  - UI Stepper & Confirmation Dialog interaction flow.
- **test(coverage)**: Expanded test suite to 98 automated unit, widget, and integration tests with 100% green pass rate and 88.75% code coverage.

### Phase 7: Platform Branding, Offline Fonts & Viva Documentation
- **docs(branding)**: Unified platform branding to `HospitalConnect` across Android (`AndroidManifest.xml`), iOS (`Info.plist`), Web (`manifest.json`), macOS (`AppInfo.xcconfig`), Windows (`main.cpp`), and Linux (`my_application.cc`).
- **feat(theme)**: Added offline system font fallbacks (`Roboto`, `SF Pro Text`, `Segoe UI`, `Helvetica Neue`, `sans-serif`) to ensure zero glyph rendering delays or blank text without network access.
- **docs(viva)**: Comprehensive `README.md` revamp including:
  - Mermaid architecture and sequence diagrams.
  - Screenshots guide table with key capture frames.
  - 3-minute viva demo script for project examination.
  - Top 10 viva questions and architectural defenses.
  - Architecture trade-offs and known limitations.
- **ci**: Automated GitHub Actions CI workflow in `.github/workflows/flutter_ci.yml` verifying `flutter analyze` and `flutter test --coverage`.
