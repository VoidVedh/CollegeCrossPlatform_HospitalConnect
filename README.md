# HospitalConnect (CollegeCrossPlatform_HospitalConnect)

A centralized, cross-platform mobile healthcare management application built with **Flutter** and **Material 3** for a B.Tech CSE & AI college project (Cross Platform Application course).

---

## 🏥 Problem Statement
In conventional healthcare workflows, patients struggle with fragmented systems—managing doctor appointments on one portal, tracking diagnostic reports in paper files, carrying physical prescriptions, and clearing hospital bills through separate accounts.

**HospitalConnect** addresses this problem by delivering a single, unified, accessible mobile application. It streamlines the complete patient journey from specialist discovery and dynamic slot booking to chronological medical history review, printable digital prescriptions, and transparent itemized bill payments.

---

## 🎨 Figma Design & Wireframes
- **Figma Design File**: [HospitalConnect UI/UX Architecture (Figma Placeholder)](https://www.figma.com/design/HospitalConnect-Mobile-UI-UX-Architect)
- **Design System**: Material Design 3 (M3)
- **Palette Tokens**:
  - Primary Teal: `#006A6A` (Trust & Clinical Precision)
  - Secondary Emerald: `#006B5D` (Health & Vitality)
  - Error Crimson: `#BA1A1A` (Destructive & Warning Affordances)
  - Soft Ice-Blue / Crisp White Surfaces (`#F4FBF9` / `#FFFFFF`)
- **Typography**: Google Fonts Inter with scalable text hierarchies (`display`, `headline`, `title`, `body`, `label`). Includes test isolation flag (`useGoogleFonts: false`) for hermetic offline testing.

---

## 🚀 Core Features & End-to-End User Journey

```
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Patient Home    │  ──►  │ Doctor Catalog  │  ──►  │ Dynamic Booking │
│ Dashboard       │       │ & Profiles      │       │ Date & Slot Grid│
└─────────────────┘       └─────────────────┘       └─────────────────┘
         │                                                   │
         ▼                                                   ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│ Medical History │  ◄──  │ Printable Digital│ ◄──  │ Live Sync State │
│ Chronology      │       │ Prescriptions   │       │ & Pending Bill  │
└─────────────────┘       └─────────────────┘       └─────────────────┘
         │
         ▼
┌─────────────────┐       ┌─────────────────┐
│ Itemized Bills  │  ──►  │ Payment Gateway │
│ Breakdown       │       │ UPI/Card/Bank   │
└─────────────────┘       └─────────────────┘
```

1. **Patient Home Dashboard**:
   - Time-sensitive patient greeting and quick emergency badge.
   - Real-time search bar with responsive specialty filter chips.
   - Prominent **Upcoming Appointment** gradient hero card updating in real time.
   - Quick Action navigation cards (`Book Visit`, `Prescriptions`, `Records`, `Pay Bills`).
   - Top-rated medical specialists horizontal carousel.

2. **Doctor Discovery & Profile Catalog**:
   - 10+ certified specialists across Cardiology, Neurology, Pediatrics, Orthopedics, and General Medicine.
   - Search by name, hospital, or specialty with sorting options (Highest Rated, Experience, Fee).
   - In-depth profile with verified patient reviews, clinic address, and fee breakdown.

3. **Dynamic Slot Selector & Booking Engine**:
   - 14-day calendar date picker with weekend/past day disabling.
   - Morning and evening dynamic time-slot grid (booked slots visibly disabled and struck through).
   - Validated patient booking form (Name, Age 1-120, 10-digit Indian Mobile, Symptoms min 10 chars).
   - Interactive appointment confirmation dialog with itemized consultation fee + 18% GST.
   - Automatic generation of unique formatted IDs (`APT-XXXXXX`).

4. **Chronological Medical History**:
   - Visual clinical timeline tracking past hospital visits, diagnoses, and attending physicians.
   - Record detail screen with clinical observation notes and simulated diagnostic attachments (PDF, JPG).

5. **Digital Prescriptions with Printable Modal**:
   - Structured medication cards displaying drug names, dosages, frequencies, and durations.
   - Official hospital letterhead printable preview modal with simulated PDF export and sharing.

6. **Itemized Billing & Financial Transparency**:
   - Strict un-stored computed getter: `totalAmount = consultationFee + labCharges + tax`.
   - Outstanding Dues banner with real-time balance aggregation.
   - Status-differentiated badges with icons (Paid green, Unpaid crimson, Pending amber).
   - Itemized charges summary bottom sheet.

7. **Simulated Payment Gateway & Digital Receipts**:
   - Multi-rail payment interface:
     - **UPI**: VPA input with validation and quick app presets (Google Pay, PhonePe, Paytm, BHIM).
     - **Credit / Debit Cards**: 16-digit card input, expiry MM/YY, CVV masking, and card brand badges.
     - **Net Banking**: Popular Indian banks grid (SBI, HDFC, ICICI, Axis) and full bank dropdown.
   - Secure simulated payment processing dialog.
   - Official digital payment receipt modal with download/share simulation and verifiable transaction references (`TXN-XXXX`).

8. **Live Cross-Feature Synchronization**:
   - Booking an appointment marks the doctor slot unavailable, creates an upcoming visit, and adds a pending bill.
   - Cancelling an appointment frees the slot in the doctor's calendar and updates the dashboard immediately.
   - Paying a bill marks the invoice as paid, records payment method and timestamp, and decrements the NavigationBar badge live.

---

## 🛠️ Architecture & Design Patterns

HospitalConnect is engineered using **Clean Architecture** principles decoupled across distinct layers:

```
lib/
├── app.dart                        # Root MaterialApp configuration, theme injection, routes
├── main.dart                       # Dependency injection and application bootstrapping
├── core/
│   ├── constants/                  # Application constants and configuration flags
│   ├── theme/                      # Material 3 tokens, AppColors, AppTextStyles, AppTheme
│   └── utils/                      # AppValidators (regex), AppFormatters (currency, dates)
├── models/                         # Pure, immutable domain entities with const constructors
├── providers/                      # ChangeNotifier state providers (Provider pattern)
├── screens/                        # UI screens for each major functional journey
│   ├── app_shell.dart              # 5-tab Material 3 NavigationBar with live badge
│   ├── dashboard/                  # Patient home dashboard
│   ├── doctors/                    # Doctor search, filters, and detail view
│   ├── appointments/               # Dynamic slot selector, booking form, appointment lists
│   ├── records/                    # Medical history timeline and attachments
│   ├── prescriptions/              # Digital prescription cards and printable modal
│   ├── billing/                    # Itemized dues, breakdown sheet, and invoices
│   └── payment/                    # Simulated payment gateway (UPI, Card, Net Banking)
├── services/
│   ├── repositories/               # Abstract repository contracts (interfaces)
│   └── mock/                       # Concrete mock data and delayed simulated services
└── widgets/                        # Atomic, reusable UI components (cards, dialogs, chips)
```

### Key Design Patterns Employed:
1. **Repository Pattern**: Business logic and UI depend exclusively on abstract interfaces (`DoctorRepository`, `AppointmentRepository`, `BillRepository`, `PaymentGateway`), enabling zero-touch swapping with live REST/GraphQL APIs.
2. **Provider Pattern**: Scoped `ChangeNotifier` state containers manage reactive updates with disposal guards (`_disposed`) preventing memory leaks and post-disposal exceptions.
3. **Data Integrity**: Financial totals (`BillModel.totalAmount`) are strictly computed getters, eliminating data discrepancy bugs.
4. **Accessibility First**:
   - Minimum 48x48dp interactive touch targets across all buttons and chips.
   - High-contrast colors with dual coding (Icon + Text Label + Color).
   - Explicit `Semantics` tags for screen readers.
   - Layouts engineered to survive **1.3x text scaling** without RenderFlex overflows.

---

## 🏃 Getting Started & Running Locally

### Prerequisites
- **Flutter SDK**: v3.22.0 or higher (Tested on Flutter 3.44+)
- **Dart SDK**: `^3.12.2` (as declared in `pubspec.yaml`)

### Installation & Execution
```bash
# 1. Clone repository
git clone https://github.com/VoidVedh/CollegeCrossPlatform_HospitalConnect.git
cd CollegeCrossPlatform_HospitalConnect

# 2. Get dependencies
flutter pub get

# 3. Analyze codebase (100% clean check)
flutter analyze

# 4. Run automated test suite (44+ tests)
flutter test

# 5. Launch the application
flutter run
```

---

## 🧪 Comprehensive Automated Test Suite

HospitalConnect includes 44+ automated unit, widget, and integration tests:

| Test File | Scope & Verification |
|---|---|
| `test/widget_test.dart` | Root AppShell navigation and 5-tab destination switching |
| `test/theme_test.dart` | Material 3 color roles, button min-size, and text styles |
| `test/models_test.dart` | Domain models immutability, `BillModel.totalAmount` getter |
| `test/mock_services_test.dart` | Repository contracts, mock data integrity, delay simulation |
| `test/dashboard_test.dart` | Header greeting, search bar, specialty chips, top specialists |
| `test/doctors_screen_test.dart` | Multi-criteria search, category filters, sorting, empty states |
| `test/doctor_detail_test.dart` | Experience metrics, patient reviews, sticky booking trigger |
| `test/slot_selector_test.dart` | 14-day calendar, available slots, disabled/struck-through slots |
| `test/booking_form_test.dart` | Form regex validation (Name, Age, Phone, Symptoms) |
| `test/appointment_confirmation_test.dart` | `APT-XXXXXX` ID generation, slot blocking, confirmation modal |
| `test/medical_records_test.dart` | Chronological timeline, attachments preview, empty states |
| `test/prescriptions_test.dart` | Medication dosages, expandable cards, printable preview modal |
| `test/billing_test.dart` | Outstanding dues aggregation, itemized sheet, invoice filters |
| `test/payment_screen_test.dart` | UPI, Card, Net Banking tabs, form validation, error handling |
| `test/payment_processing_test.dart` | Payment processing dialog, `payBill()` status update, receipt modal |
| `test/cross_feature_state_test.dart` | Appointments cancellation, slot release, live dashboard & badge sync |
| `test/integration_workflow_test.dart` | Full end-to-end patient journey: Discover -> Book -> Invoicing -> Settle |
| `test/final_audit_test.dart` | Accessibility, 1.3x text scaling resilience, tablet responsive check |

Run all tests:
```bash
flutter test
```

### Continuous Integration (CI)
GitHub Actions workflow configured in `.github/workflows/flutter_ci.yml` runs automated static analysis (`flutter analyze`) and test suite verification (`flutter test --coverage`) on every push to `main`.

---

## 🎓 College Viva & Examination Quick Reference

| Question | Answer & Architectural Defense |
|---|---|
| **Why Provider over Riverpod, Bloc, or GetX?** | `Provider` is the official Flutter team recommended state management solution for mid-scale applications. It offers clean lifecycle control via `ChangeNotifier`, eliminates boilerplate, and demonstrates mastery of core Flutter primitives without unnecessary third-party abstractions. |
| **How is cross-feature state synchronized?** | Disconnected screens (Dashboard, Appointments, Bills) listen to shared domain providers via `context.watch<T>()` and `context.select<T, R>()`. When a booking occurs in `AppointmentProvider`, it automatically triggers updates in `DoctorRepository` and `BillRepository`, which notify all active listeners. |
| **Why is `BillModel.totalAmount` a getter instead of a field?** | Storing computed monetary values violates Single Source of Truth and creates financial discrepancy bugs if consultation fees or taxes are adjusted. A computed getter guarantees mathematical consistency. |
| **How are booked slots prevented from double booking?** | `DoctorRepository.markSlotAvailability()` flags slots as unavailable immediately upon booking. The `SlotSelector` widget inspects doctor availability and existing appointments, visibly striking out and disabling taken slots. |
| **How is the app architected for offline use?** | All operations run against mock implementations adhering to abstract repository interfaces. Data persistence and network latency are simulated with `Future.delayed`, allowing the entire system to run hermetically without external backend dependencies. |

---

## 📌 Known Limitations & Future Roadmap
- **Offline Simulation**: Currently uses realistic mock data; ready for production REST API integration by swapping repository implementations.
- **Biometric Authentication**: Roadmap includes local biometric authentication (FaceID/Fingerprint) for payment authorization.
- **Hardware Integration**: Camera scanning for paper prescriptions using on-device ML Kit OCR.
