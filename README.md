# HospitalConnect (CollegeCrossPlatform_HospitalConnect)

A centralized, cross-platform mobile healthcare management application built with **Flutter** and **Material 3** for a B.Tech CSE & AI college project (Cross Platform Application course).

---

## 🏥 Problem Statement
Patients frequently struggle to manage appointments, medical history, prescriptions, and billing across disconnected healthcare portals. **HospitalConnect** solves this by unifying doctor discovery, appointment booking, medical timeline access, digital prescriptions, and itemized billing into a single intuitive, accessible mobile app.

---

## 🚀 Core Features & End-to-End User Journey
1. **Interactive Dashboard**: Greeting, search bar, specialty category chips, quick actions, and upcoming appointment highlights.
2. **Doctor Discovery**: Filterable search, specialty badges, experience, ratings, and detailed doctor profiles.
3. **Appointment Booking**: Real-time slot availability, calendar date picker, interactive time-slot selector, validated patient info form, and instant confirmation dialogs.
4. **Medical Records**: Chronological medical history timeline with diagnosis details and attachment records.
5. **Digital Prescriptions**: Structured medication cards (dosage, frequency, duration) with share/print preview simulation.
6. **Transparent Billing**: Itemized charges breakdown (Consultation + Diagnostics/Lab + Tax) with dynamic total calculation.
7. **Simulated Payment Gateway**: Flexible payment methods (UPI, Cards, Net Banking) with interactive processing dialogs and digital receipts.

---

## 🛠️ Tech Stack & Architecture
- **Framework**: Flutter (Dart null-safe, Material 3)
- **State Management**: `Provider` with `ChangeNotifier`
- **Typography & Icons**: `Google Fonts` (Inter/Outfit), Material Symbols / Icons
- **Formatting & IDs**: `intl` (dates, INR currency), `uuid`
- **Architecture**: Clean Architecture / Repository Pattern with interface-driven mock services:
  - Repositories (`services/repositories/`) decouple business logic from data sources.
  - Providers (`providers/`) handle reactive state and business rule enforcement.
  - Core (`core/`) organizes theme tokens, utilities, and constants.

---

## 📁 Project Directory Structure
```
lib/
  main.dart                     # App initialization and entrypoint
  app.dart                      # Root MaterialApp widget and routing
  core/
    theme/                      # Theme tokens, healthcare palette, typography
    constants/                  # App-wide constants and configurations
    utils/                      # Formatters (currency, date) and form validators
  models/                       # Immutable domain models with const constructors
  services/
    repositories/               # Abstract repository interfaces
    mock/                       # Realistic offline mock data & service implementations
  providers/                    # ChangeNotifier state providers
  screens/
    dashboard/                  # Patient home dashboard
    doctors/                    # Doctor search, filtering, and profile details
    appointments/               # Date/slot selector and booking flow
    records/                    # Medical history timeline
    prescriptions/              # Digital prescription list and preview
    billing/                    # Itemized invoice breakdown
    payment/                    # Multi-method simulated payment gateway
  widgets/                      # Small, reusable, accessible UI components
```

---

## 🏃 Getting Started

### Prerequisites
- Flutter SDK (v3.19.0 or higher recommended)
- Dart SDK (v3.3.0 or higher)

### Installation
1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd CollegeCrossPlatform_HospitalConnect
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run code analysis:
   ```bash
   flutter analyze
   ```
4. Run tests:
   ```bash
   flutter test
   ```
5. Launch the application:
   ```bash
   flutter run
   ```
