import 'package:hospital_connect/models/models.dart';

/// Central in-memory mock dataset simulating a hospital backend database.
class MockDataService {
  MockDataService() {
    _initData();
  }

  late List<DoctorModel> _doctors;
  late List<AppointmentModel> _appointments;
  late List<MedicalRecordModel> _medicalRecords;
  late List<PrescriptionModel> _prescriptions;
  late List<BillModel> _bills;

  List<DoctorModel> get doctors => List.unmodifiable(_doctors);
  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);
  List<MedicalRecordModel> get medicalRecords =>
      List.unmodifiable(_medicalRecords);
  List<PrescriptionModel> get prescriptions =>
      List.unmodifiable(_prescriptions);
  List<BillModel> get bills => List.unmodifiable(_bills);

  void _initData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    _doctors = [
      DoctorModel(
        id: 'DOC-01',
        name: 'Dr. Ananya Sharma',
        specialty: 'Cardiology',
        rating: 4.9,
        experienceYears: 14,
        hospitalName: 'Apollo Speciality Hospital',
        clinicAddress: 'Bannerghatta Main Road, Bengaluru',
        consultationFee: 800.0,
        imageUrl: '',
        about:
            'Dr. Ananya Sharma is a senior interventional cardiologist with over 14 years of clinical experience in preventive cardiology, coronary interventions, and echocardiography.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 30),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 30),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 10, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 11, 30),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-01',
            authorName: 'Ramesh Patel',
            rating: 5.0,
            comment:
                'Exceptional doctor. Took the time to clearly explain my ECG reports and adjusted medication calmly.',
            date: today.subtract(const Duration(days: 12)),
          ),
          ReviewModel(
            id: 'REV-02',
            authorName: 'Kavita Rao',
            rating: 4.8,
            comment:
                'Very polite and thorough. Clinic staff was well managed and waiting time was minimal.',
            date: today.subtract(const Duration(days: 24)),
          ),
          ReviewModel(
            id: 'REV-03',
            authorName: 'Vikas Gupta',
            rating: 5.0,
            comment:
                'Prescribed lifestyle modifications that reduced my cholesterol significantly.',
            date: today.subtract(const Duration(days: 45)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-02',
        name: 'Dr. Rajesh Menon',
        specialty: 'Cardiology',
        rating: 4.8,
        experienceYears: 18,
        hospitalName: 'Fortis Memorial Hospital',
        clinicAddress: 'Cunningham Road, Vasanth Nagar, Bengaluru',
        consultationFee: 950.0,
        imageUrl: '',
        about:
            'Dr. Rajesh Menon specializes in adult cardiology, heart rhythm disorders, and catheterization with 18+ years of dedicated practice.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 9, 30),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 14, 30),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-04',
            authorName: 'Deepak Nair',
            rating: 5.0,
            comment:
                'Superb expertise in cardiac diagnostics. Handled my father\'s case with utmost precision.',
            date: today.subtract(const Duration(days: 8)),
          ),
          ReviewModel(
            id: 'REV-05',
            authorName: 'Sunita Joshi',
            rating: 4.5,
            comment:
                'Patient listener and very assuring demeanor. Highly recommend for heart health checks.',
            date: today.subtract(const Duration(days: 30)),
          ),
          ReviewModel(
            id: 'REV-06',
            authorName: 'Amit Saxena',
            rating: 5.0,
            comment:
                'Accurate diagnosis and excellent post-consultation follow-up.',
            date: today.subtract(const Duration(days: 60)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-03',
        name: 'Dr. Priya Sundaram',
        specialty: 'Neurology',
        rating: 4.9,
        experienceYears: 16,
        hospitalName: 'Manipal Hospital',
        clinicAddress: 'HAL Old Airport Road, Kodihalli, Bengaluru',
        consultationFee: 1000.0,
        imageUrl: '',
        about:
            'Dr. Priya Sundaram is an expert neurologist specializing in migraine management, neuromuscular disorders, epilepsy, and neuro-rehabilitation.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 11, 0),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-07',
            authorName: 'Meghna Roy',
            rating: 5.0,
            comment:
                'Finally found relief for my chronic migraines after Dr. Priya revised my regimen.',
            date: today.subtract(const Duration(days: 5)),
          ),
          ReviewModel(
            id: 'REV-08',
            authorName: 'Tanmay Bhatt',
            rating: 4.8,
            comment:
                'Outstanding neuro specialist. Evaluates reflex and motor functions very meticulously.',
            date: today.subtract(const Duration(days: 22)),
          ),
          ReviewModel(
            id: 'REV-09',
            authorName: 'Geetha Swaminathan',
            rating: 5.0,
            comment:
                'Kind, compassionate, and sharp in diagnostics. Best neurologist in Bengaluru.',
            date: today.subtract(const Duration(days: 50)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-04',
        name: 'Dr. Vikram Malhotra',
        specialty: 'Neurology',
        rating: 4.7,
        experienceYears: 11,
        hospitalName: 'Aster CMI Hospital',
        clinicAddress: 'New Airport Road, Sahakar Nagar, Bengaluru',
        consultationFee: 850.0,
        imageUrl: '',
        about:
            'Dr. Vikram Malhotra has extensive experience in acute stroke management, sleep medicine, and peripheral nerve disorders.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 30),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 15, 30),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-10',
            authorName: 'Sanjay Reddy',
            rating: 4.7,
            comment: 'Very analytical and clear explanation of nerve conduction tests.',
            date: today.subtract(const Duration(days: 10)),
          ),
          ReviewModel(
            id: 'REV-11',
            authorName: 'Anita Desai',
            rating: 4.9,
            comment: 'Friendly and made me feel very comfortable regarding my sleep apnea test.',
            date: today.subtract(const Duration(days: 35)),
          ),
          ReviewModel(
            id: 'REV-12',
            authorName: 'Harish Chandra',
            rating: 4.5,
            comment: 'Prompt appointment and helpful medical staff.',
            date: today.subtract(const Duration(days: 70)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-05',
        name: 'Dr. Sneha Kulkarni',
        specialty: 'Pediatrics',
        rating: 4.9,
        experienceYears: 12,
        hospitalName: 'Cloudnine Hospital',
        clinicAddress: '11th Main, 3rd Block, Jayanagar, Bengaluru',
        consultationFee: 650.0,
        imageUrl: '',
        about:
            'Dr. Sneha Kulkarni is a beloved pediatrician dedicated to child nutrition, developmental milestones, and pediatric immunizations.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 30),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 10, 30),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-13',
            authorName: 'Pooja Hegde',
            rating: 5.0,
            comment:
                'My 3-year-old daughter loves Dr. Sneha! Vaccination was virtually painless.',
            date: today.subtract(const Duration(days: 4)),
          ),
          ReviewModel(
            id: 'REV-14',
            authorName: 'Manoj Pillai',
            rating: 4.9,
            comment:
                'Gives practical, calm advice to anxious parents. Always approachable.',
            date: today.subtract(const Duration(days: 19)),
          ),
          ReviewModel(
            id: 'REV-15',
            authorName: 'Bhavna Chawla',
            rating: 4.8,
            comment:
                'Great clinic environment with child play corner. Excellent pediatric care.',
            date: today.subtract(const Duration(days: 40)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-06',
        name: 'Dr. Rohan Deshmukh',
        specialty: 'Pediatrics',
        rating: 4.8,
        experienceYears: 9,
        hospitalName: 'Rainbow Children\'s Hospital',
        clinicAddress: 'Outer Ring Road, Marathahalli, Bengaluru',
        consultationFee: 600.0,
        imageUrl: '',
        about:
            'Dr. Rohan Deshmukh specializes in pediatric infectious diseases, seasonal allergy care, and adolescent general wellness.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 13, 30),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 16, 0),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-16',
            authorName: 'Alok Sen',
            rating: 5.0,
            comment: 'Very gentle with toddlers. Explained symptoms and fever tracking very clearly.',
            date: today.subtract(const Duration(days: 7)),
          ),
          ReviewModel(
            id: 'REV-17',
            authorName: 'Swati Kulkarni',
            rating: 4.6,
            comment: 'Good doctor, avoided unnecessary antibiotics.',
            date: today.subtract(const Duration(days: 28)),
          ),
          ReviewModel(
            id: 'REV-18',
            authorName: 'Kiran Murthy',
            rating: 4.8,
            comment: 'Prompt response and effective treatment for seasonal flu.',
            date: today.subtract(const Duration(days: 55)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-07',
        name: 'Dr. Arjun Nair',
        specialty: 'Orthopedics',
        rating: 4.8,
        experienceYears: 15,
        hospitalName: 'Hosmat Hospital',
        clinicAddress: 'Magrath Road, Richmond Town, Bengaluru',
        consultationFee: 900.0,
        imageUrl: '',
        about:
            'Dr. Arjun Nair is a leading orthopedic surgeon focusing on sports injuries, arthroscopic knee reconstruction, and joint preservation.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 30),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 15, 30),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 9, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 12, 0),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-19',
            authorName: 'Naveen Kumar',
            rating: 5.0,
            comment:
                'Treated my meniscus tear with physiotherapy and targeted care. Back to running now!',
            date: today.subtract(const Duration(days: 14)),
          ),
          ReviewModel(
            id: 'REV-20',
            authorName: 'Shalini Verma',
            rating: 4.8,
            comment:
                'Very honest opinion; did not rush into surgery. Great physical rehab recommendations.',
            date: today.subtract(const Duration(days: 33)),
          ),
          ReviewModel(
            id: 'REV-21',
            authorName: 'Girish Prabhu',
            rating: 4.7,
            comment: 'Extremely knowledgeable in sports medicine.',
            date: today.subtract(const Duration(days: 65)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-08',
        name: 'Dr. Meera Nambiar',
        specialty: 'General Medicine',
        rating: 4.7,
        experienceYears: 10,
        hospitalName: 'Manipal Clinic',
        clinicAddress: 'Sarjapur Main Road, Doddakannelli, Bengaluru',
        consultationFee: 500.0,
        imageUrl: '',
        about:
            'Dr. Meera Nambiar provides comprehensive family medicine, diabetes management, hypertension monitoring, and preventive annual health audits.',
        availableSlots: [
          // 10:00 AM slot is reserved for pre-existing appointment APT-100248
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 14, 0),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 10, 0),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 15, 0),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-22',
            authorName: 'Karthik Somayaji',
            rating: 4.8,
            comment:
                'Our go-to family physician. Pragmatic diagnostics and always patient.',
            date: today.subtract(const Duration(days: 6)),
          ),
          ReviewModel(
            id: 'REV-23',
            authorName: 'Divya Sundar',
            rating: 4.7,
            comment:
                'Thorough health checks and gentle counsel on dietary habits.',
            date: today.subtract(const Duration(days: 21)),
          ),
          ReviewModel(
            id: 'REV-24',
            authorName: 'Pradeep Shenoy',
            rating: 4.9,
            comment:
                'Accurate identification of viral fever and quick recovery guidance.',
            date: today.subtract(const Duration(days: 48)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-09',
        name: 'Dr. Sandeep Varma',
        specialty: 'General Medicine',
        rating: 4.6,
        experienceYears: 8,
        hospitalName: 'St. John\'s Medical Centre',
        clinicAddress: '100 Feet Road, Koramangala 4th Block, Bengaluru',
        consultationFee: 450.0,
        imageUrl: '',
        about:
            'Dr. Sandeep Varma specializes in infectious fever management, lifestyle illnesses, and adult wellness immunizations.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 30),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 30),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 14, 0),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-25',
            authorName: 'Anil Bakshi',
            rating: 4.5,
            comment: 'Very polite and helpful with lab test interpretations.',
            date: today.subtract(const Duration(days: 15)),
          ),
          ReviewModel(
            id: 'REV-26',
            authorName: 'Rekha Chandran',
            rating: 4.7,
            comment: 'Comfortable consultation room and prompt guidance.',
            date: today.subtract(const Duration(days: 38)),
          ),
          ReviewModel(
            id: 'REV-27',
            authorName: 'Sanjay Kapoor',
            rating: 4.6,
            comment: 'Quick and accurate prescription for seasonal cold.',
            date: today.subtract(const Duration(days: 75)),
          ),
        ],
      ),
      DoctorModel(
        id: 'DOC-10',
        name: 'Dr. Kavita Iyer',
        specialty: 'Orthopedics',
        rating: 4.9,
        experienceYears: 17,
        hospitalName: 'SPARSH Super Speciality Hospital',
        clinicAddress: 'Tumkur Road, Yeshwanthpur, Bengaluru',
        consultationFee: 950.0,
        imageUrl: '',
        about:
            'Dr. Kavita Iyer is a renowned orthopedic expert in spine alignment, geriatric osteoporosis care, and joint replacement therapy.',
        availableSlots: [
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 30),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 16, 30),
          DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month, dayAfterTomorrow.day, 11, 30),
        ],
        reviews: [
          ReviewModel(
            id: 'REV-28',
            authorName: 'Usha Padmanabhan',
            rating: 5.0,
            comment: 'Treated my severe lumbar disc compression without invasive surgery. Truly gifted doctor.',
            date: today.subtract(const Duration(days: 9)),
          ),
          ReviewModel(
            id: 'REV-29',
            authorName: 'Raghavan R.',
            rating: 4.9,
            comment: 'Detailed bone density scan review and clear calcium therapy schedule.',
            date: today.subtract(const Duration(days: 27)),
          ),
          ReviewModel(
            id: 'REV-30',
            authorName: 'Archana Patil',
            rating: 4.8,
            comment: 'Empathetic and highly skilled orthopedic specialist.',
            date: today.subtract(const Duration(days: 62)),
          ),
        ],
      ),
    ];

    // Pre-existing upcoming appointment
    _appointments = [
      AppointmentModel(
        id: 'APT-100248',
        doctorId: 'DOC-08',
        doctorName: 'Dr. Meera Nambiar',
        doctorSpecialty: 'General Medicine',
        patientName: 'Aditya Sharma',
        patientAge: 29,
        patientPhone: '9845123456',
        appointmentDate: tomorrow,
        timeSlot: '10:00 AM',
        status: AppointmentStatus.upcoming,
        symptomsNote: 'Persistent seasonal cough and mild fatigue for 5 days.',
      ),
    ];

    // 5+ Medical Records
    _medicalRecords = [
      MedicalRecordModel(
        id: 'REC-501',
        diagnosis: 'Hypertension Stage 1 Follow-up',
        doctorName: 'Dr. Ananya Sharma',
        visitDate: today.subtract(const Duration(days: 15)),
        hospitalName: 'Apollo Speciality Hospital',
        summary:
            'Blood pressure measured at 134/86 mmHg. Electrocardiogram (ECG) normal sinus rhythm. Advised reduced sodium intake and continued morning walking routine.',
        attachments: [
          const RecordAttachmentModel(
            fileName: 'ECG_Report_Sep2026.pdf',
            fileType: 'PDF Document',
          ),
          const RecordAttachmentModel(
            fileName: 'Lipid_Panel_Results.pdf',
            fileType: 'Lab Report',
          ),
        ],
      ),
      MedicalRecordModel(
        id: 'REC-502',
        diagnosis: 'Right Knee Meniscal Strain',
        doctorName: 'Dr. Arjun Nair',
        visitDate: today.subtract(const Duration(days: 42)),
        hospitalName: 'Hosmat Hospital',
        summary:
            'Patient presented with lateral right knee pain post jogging. MRI revealed mild Grade 1 meniscal strain without structural rupture. Advised 4 weeks of targeted quadriceps strengthening.',
        attachments: [
          const RecordAttachmentModel(
            fileName: 'RightKnee_MRI_Scans.dcm',
            fileType: 'Radiology Scan',
          ),
          const RecordAttachmentModel(
            fileName: 'Physiotherapy_Protocol.pdf',
            fileType: 'Clinical Protocol',
          ),
        ],
      ),
      MedicalRecordModel(
        id: 'REC-503',
        diagnosis: 'Migraine with Aura Evaluation',
        doctorName: 'Dr. Priya Sundaram',
        visitDate: today.subtract(const Duration(days: 68)),
        hospitalName: 'Manipal Hospital',
        summary:
            'Unilateral throbbing headache associated with photophobia and visual scintillation. Brain MRI scan within normal limits. Started prophylactic magnesium and sleep scheduling.',
        attachments: [
          const RecordAttachmentModel(
            fileName: 'Brain_MRI_Neuro_Contrast.pdf',
            fileType: 'Imaging Report',
          ),
        ],
      ),
      MedicalRecordModel(
        id: 'REC-504',
        diagnosis: 'Acute Viral Bronchitis',
        doctorName: 'Dr. Meera Nambiar',
        visitDate: today.subtract(const Duration(days: 110)),
        hospitalName: 'Manipal Clinic',
        summary:
            'Patient had productive cough, low-grade pyrexia and throat irritation. Chest auscultation showed coarse wheezing without crepitations. Complete resolution on follow-up.',
        attachments: [
          const RecordAttachmentModel(
            fileName: 'Chest_XRay_PA_View.png',
            fileType: 'Digital X-Ray',
          ),
          const RecordAttachmentModel(
            fileName: 'CBC_Blood_Analysis.pdf',
            fileType: 'Pathology Report',
          ),
        ],
      ),
      MedicalRecordModel(
        id: 'REC-505',
        diagnosis: 'Annual Executive Health Screen',
        doctorName: 'Dr. Sandeep Varma',
        visitDate: today.subtract(const Duration(days: 180)),
        hospitalName: 'St. John\'s Medical Centre',
        summary:
            'Comprehensive metabolic profile, HbA1c at 5.4%, thyroid profile normal, resting vitals stable. Vitamin D level was 18 ng/mL (mild insufficiency), supplemented accordingly.',
        attachments: [
          const RecordAttachmentModel(
            fileName: 'Full_Body_Checkup_Summary.pdf',
            fileType: 'Comprehensive Report',
          ),
        ],
      ),
    ];

    // 4+ Prescriptions
    _prescriptions = [
      PrescriptionModel(
        id: 'RX-701',
        doctorName: 'Dr. Ananya Sharma',
        issueDate: today.subtract(const Duration(days: 15)),
        diagnosis: 'Hypertension Management',
        medications: const [
          MedicationModel(
            name: 'Telmisartan Tablets IP',
            dosage: '40 mg',
            frequency: 'Once daily (Morning after breakfast)',
            duration: '30 Days',
          ),
          MedicationModel(
            name: 'Rosuvastatin Tablets',
            dosage: '10 mg',
            frequency: 'Once daily (Night after dinner)',
            duration: '30 Days',
          ),
        ],
        instructions:
            'Maintain daily blood pressure log. Reduce table salt consumption and walk 30 minutes daily.',
      ),
      PrescriptionModel(
        id: 'RX-702',
        doctorName: 'Dr. Arjun Nair',
        issueDate: today.subtract(const Duration(days: 42)),
        diagnosis: 'Right Knee Meniscal Strain',
        medications: const [
          MedicationModel(
            name: 'Etoricoxib Tablets',
            dosage: '90 mg',
            frequency: 'Once daily for 5 days (After food)',
            duration: '5 Days',
          ),
          MedicationModel(
            name: 'Pantoprazole Gastro-resistant',
            dosage: '40 mg',
            frequency: 'Once daily (Morning empty stomach)',
            duration: '5 Days',
          ),
          MedicationModel(
            name: 'Collagen Peptide Sachets',
            dosage: '10 g',
            frequency: 'Once daily mixed in water',
            duration: '30 Days',
          ),
        ],
        instructions:
            'Avoid squatting and heavy weight bearing. Apply ice pack for 15 mins twice daily.',
      ),
      PrescriptionModel(
        id: 'RX-703',
        doctorName: 'Dr. Priya Sundaram',
        issueDate: today.subtract(const Duration(days: 68)),
        diagnosis: 'Migraine Prophylaxis',
        medications: const [
          MedicationModel(
            name: 'Flunarizine Tablets',
            dosage: '5 mg',
            frequency: 'Once daily (At bedtime)',
            duration: '60 Days',
          ),
          MedicationModel(
            name: 'Naproxen Sodium Tablets',
            dosage: '250 mg',
            frequency: 'SOS (At migraine onset)',
            duration: '10 Days',
          ),
        ],
        instructions:
            'Stay adequately hydrated and maintain regular sleep timings. Keep a headache trigger diary.',
      ),
      PrescriptionModel(
        id: 'RX-704',
        doctorName: 'Dr. Meera Nambiar',
        issueDate: today.subtract(const Duration(days: 110)),
        diagnosis: 'Acute Viral Bronchitis',
        medications: const [
          MedicationModel(
            name: 'Amoxicillin + Clavulanic Acid',
            dosage: '625 mg',
            frequency: 'Twice daily (After meals)',
            duration: '5 Days',
          ),
          MedicationModel(
            name: 'Levocetirizine + Montelukast',
            dosage: '5 mg / 10 mg',
            frequency: 'Once daily (At night)',
            duration: '7 Days',
          ),
          MedicationModel(
            name: 'Guaifenesin Expectorant Syrup',
            dosage: '10 ml',
            frequency: 'Thrice daily with warm water',
            duration: '5 Days',
          ),
        ],
        instructions:
            'Drink plenty of warm fluids. Take steam inhalation twice daily. Complete the full antibiotic course.',
      ),
    ];

    // 4+ Bills in mixed statuses
    _bills = [
      BillModel(
        id: 'BILL-101',
        billDate: today.subtract(const Duration(days: 1)),
        serviceName: 'Cardiology Consultation & ECG Test',
        consultationFee: 800.0,
        labCharges: 450.0,
        tax: 62.5,
        status: BillStatus.unpaid,
      ),
      BillModel(
        id: 'BILL-102',
        billDate: today.subtract(const Duration(days: 15)),
        serviceName: 'Orthopedic Consultation & Knee Radiograph',
        consultationFee: 900.0,
        labCharges: 600.0,
        tax: 75.0,
        status: BillStatus.paid,
        paymentMethod: PaymentMethodType.upi,
        paidAt: today.subtract(const Duration(days: 15, hours: 2)),
      ),
      BillModel(
        id: 'BILL-103',
        billDate: today.subtract(const Duration(days: 25)),
        serviceName: 'Neurology Consultation & Consultation Summary',
        consultationFee: 1000.0,
        labCharges: 0.0,
        tax: 50.0,
        status: BillStatus.pending,
      ),
      BillModel(
        id: 'BILL-104',
        billDate: today.subtract(const Duration(days: 45)),
        serviceName: 'Pediatric Health Checkup & CBC Panel',
        consultationFee: 650.0,
        labCharges: 250.0,
        tax: 45.0,
        status: BillStatus.paid,
        paymentMethod: PaymentMethodType.card,
        paidAt: today.subtract(const Duration(days: 45, hours: 4)),
      ),
      BillModel(
        id: 'BILL-105',
        billDate: today,
        serviceName: 'General Consultation (Dr. Meera Nambiar)',
        consultationFee: 500.0,
        labCharges: 0.0,
        tax: 25.0,
        status: BillStatus.pending,
        appointmentId: 'APT-100248',
      ),
    ];
  }

  // Doctor Mutations
  void updateDoctorSlotAvailability(
      String doctorId, DateTime slot, bool isAvailable) {
    final index = _doctors.indexWhere((d) => d.id == doctorId);
    if (index == -1) return;
    final doctor = _doctors[index];
    final updatedSlots = List<DateTime>.from(doctor.availableSlots);
    if (isAvailable) {
      if (!updatedSlots.any((s) => s.isAtSameMomentAs(slot))) {
        updatedSlots.add(slot);
        updatedSlots.sort();
      }
    } else {
      updatedSlots.removeWhere((s) => s.isAtSameMomentAs(slot));
    }
    _doctors[index] = doctor.copyWith(availableSlots: updatedSlots);
  }

  // Appointment Mutations
  void addAppointment(AppointmentModel appointment) {
    _appointments.insert(0, appointment);
  }

  void updateAppointmentStatus(String appointmentId, AppointmentStatus status) {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index != -1) {
      _appointments[index] = _appointments[index].copyWith(status: status);
    }
  }

  // Bill Mutations
  void addBill(BillModel bill) {
    _bills.insert(0, bill);
  }

  void updateBill(
    String billId,
    BillStatus status, {
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) {
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      _bills[index] = _bills[index].copyWith(
        status: status,
        paymentMethod: paymentMethod ?? _bills[index].paymentMethod,
        paidAt: paidAt ?? _bills[index].paidAt,
      );
    }
  }
}
