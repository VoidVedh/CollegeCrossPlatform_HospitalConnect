/// Central repository of user-visible strings for localization readiness.
class AppStrings {
  const AppStrings._();

  // App Identity
  static const String appName = 'HospitalConnect';
  static const String appTagline = 'Compassionate Care, Seamlessly Connected';
  static const String appVersion = 'v1.0.0+1';

  // Navigation Tabs
  static const String tabHome = 'Home';
  static const String tabDoctors = 'Doctors';
  static const String tabAppointments = 'Visits';
  static const String tabRecords = 'Records';
  static const String tabBills = 'Bills';

  // Dashboard
  static const String defaultPatientName = 'Aditya';
  static const String defaultPatientFullName = 'Aditya Sharma';
  static const String defaultPatientInitials = 'AS';
  static const String greetingPrefix = 'Hello, ';
  static const String feelingPrompt = 'How are you feeling today?';
  static const String searchHint = 'Search doctors, specialties...';
  static const String upcomingAppointmentTitle = 'Upcoming Appointment';
  static const String quickActionsTitle = 'Quick Actions';
  static const String findBySpecialtyTitle = 'Find by Specialty';
  static const String topSpecialistsTitle = 'Top Rated Specialists';
  static const String viewAll = 'View All';
  static const String emergencySos = 'SOS 108';

  // Quick Action Labels
  static const String actionBookVisit = 'Book Visit';
  static const String actionBookVisitSub = 'Top Doctors';
  static const String actionPrescriptions = 'Prescriptions';
  static const String actionPrescriptionsSub = 'Digital Rx';
  static const String actionRecords = 'Records';
  static const String actionRecordsSub = 'Lab & Scans';
  static const String actionPayBills = 'Pay Bills';
  static const String actionPayBillsSub = 'Itemized dues';

  // Booking Flow
  static const String stepChooseSlot = 'Choose Slot';
  static const String stepPatientDetails = 'Patient Details';
  static const String stepConfirm = 'Confirm';
  static const String selectDate = 'Select Date';
  static const String selectTimeSlot = 'Select Time Slot';
  static const String slotAvailable = 'Available';
  static const String slotBooked = 'Booked';
  static const String slotPast = 'Past';
  static const String unsavedChangesTitle = 'Discard Booking?';
  static const String unsavedChangesMessage =
      'You have entered booking details. Navigating back will lose your progress.';
  static const String discard = 'Discard';
  static const String keepEditing = 'Keep Editing';

  // Payment
  static const String paymentGatewayTitle = 'Payment Gateway';
  static const String selectPaymentMethod = 'Select Payment Method';
  static const String paySecurely = 'Pay Securely';
  static const String simulateFailurePrompt = 'Simulate Payment Failure';
  static const String paymentDeclinedTitle = 'Payment Authorization Failed';
  static const String paymentDeclinedMessage =
      'Your card or account was declined by the issuer (simulated test). Please try again with an alternative method.';
  static const String tryAgain = 'Try Again';

  // Doctor Detail & Sorting
  static const String sortBy = 'Sort by';
  static const String sortRating = 'Highest Rating';
  static const String sortFeeLowToHigh = 'Fee: Low to High';
  static const String sortExperience = 'Experience';
  static const String nextAvailable = 'Next Available: ';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';

  // Common Feedback & States
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String share = 'Share';
  static const String download = 'Download';
  static const String noRecordsFound = 'No Medical Records Found';
  static const String noAppointmentsFound = 'No Appointments Found';
}
