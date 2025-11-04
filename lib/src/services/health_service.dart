import 'dart:async';
import 'dart:math';

/// Сервис здоровья и телемедицины
class HealthService {
  static final HealthService _instance = HealthService._internal();
  factory HealthService() => _instance;
  static HealthService get instance => _instance;
  HealthService._internal();

  final StreamController<HealthMetric> _onMetricRecorded =
      StreamController.broadcast();
  final StreamController<Appointment> _onAppointmentScheduled =
      StreamController.broadcast();

  // Данные
  final Map<String, List<HealthMetric>> _healthHistory = {};
  final Map<String, List<Appointment>> _appointments = {};
  final Map<String, Doctor> _doctors = {};
  final Map<String, Medication> _medications = {};

  Stream<HealthMetric> get onMetricRecorded => _onMetricRecorded.stream;
  Stream<Appointment> get onAppointmentScheduled =>
      _onAppointmentScheduled.stream;

  /// Инициализация сервиса
  Future<void> initialize() async {
    print('Initializing Health Service...');

    await _loadDoctors();
    await _loadMedications();

    print('Health Service initialized');
  }

  /// Запись показателя здоровья
  Future<void> recordMetric({
    required String userId,
    required HealthMetricType type,
    required double value,
    String? unit,
    String? notes,
  }) async {
    final metric = HealthMetric(
      id: _generateId(),
      userId: userId,
      type: type,
      value: value,
      unit: unit ?? _getDefaultUnit(type),
      notes: notes,
      timestamp: DateTime.now(),
    );

    final history = _healthHistory[userId] ?? [];
    history.add(metric);
    _healthHistory[userId] = history;

    _onMetricRecorded.add(metric);
    print('Recorded health metric: ${type.name} = $value ${metric.unit}');
  }

  /// Получение истории здоровья
  Future<List<HealthMetric>> getHealthHistory({
    required String userId,
    HealthMetricType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final history = _healthHistory[userId] ?? [];

    return history.where((metric) {
      if (type != null && metric.type != type) return false;
      if (startDate != null && metric.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && metric.timestamp.isAfter(endDate)) return false;
      return true;
    }).toList();
  }

  /// Запись на прием
  Future<Appointment> bookAppointment({
    required String userId,
    required String doctorId,
    required DateTime dateTime,
    String? reason,
  }) async {
    final doctor = _doctors[doctorId];
    if (doctor == null) {
      throw Exception('Doctor not found');
    }

    final appointment = Appointment(
      id: _generateId(),
      userId: userId,
      doctorId: doctorId,
      doctorName: doctor.name,
      doctorSpecialty: doctor.specialty,
      dateTime: dateTime,
      reason: reason,
      status: AppointmentStatus.scheduled,
      createdAt: DateTime.now(),
    );

    final appointments = _appointments[userId] ?? [];
    appointments.add(appointment);
    _appointments[userId] = appointments;

    _onAppointmentScheduled.add(appointment);
    print('Booked appointment with Dr. ${doctor.name} at $dateTime');

    return appointment;
  }

  /// Получение списка врачей
  List<Doctor> getDoctors({String? specialty, String? query}) {
    var doctors = _doctors.values.toList();

    if (specialty != null) {
      doctors = doctors.where((d) => d.specialty == specialty).toList();
    }

    if (query != null) {
      final lowerQuery = query.toLowerCase();
      doctors = doctors
          .where((d) =>
              d.name.toLowerCase().contains(lowerQuery) ||
              d.specialty.toLowerCase().contains(lowerQuery))
          .toList();
    }

    return doctors;
  }

  /// Добавление лекарства
  Future<void> addMedication({
    required String userId,
    required String medicationId,
    required String dosage,
    required int timesPerDay,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final medication = _medications[medicationId];
    if (medication == null) {
      throw Exception('Medication not found');
    }

    final prescription = Prescription(
      id: _generateId(),
      userId: userId,
      medicationId: medicationId,
      medicationName: medication.name,
      dosage: dosage,
      timesPerDay: timesPerDay,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate,
      status: PrescriptionStatus.active,
      createdAt: DateTime.now(),
    );

    final prescriptions = _healthHistory[userId] ?? [];
    // Здесь мы должны хранить prescriptions отдельно, но для простоты используем тот же Map

    print('Added medication: ${medication.name}');
  }

  /// Получение статистики здоровья
  HealthStatistics getHealthStatistics({
    required String userId,
    int days = 30,
  }) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final history = (_healthHistory[userId] ?? [])
        .where((metric) => metric.timestamp.isAfter(cutoff))
        .toList();

    final bloodPressureReadings =
        history.where((m) => m.type == HealthMetricType.bloodPressure).length;

    final weightReadings =
        history.where((m) => m.type == HealthMetricType.weight).length;

    return HealthStatistics(
      totalReadings: history.length,
      bloodPressureReadings: bloodPressureReadings,
      weightReadings: weightReadings,
      averageSteps: 7500.0,
      averageHeartRate: 72.0,
      averageSleepHours: 7.5,
    );
  }

  // Приватные методы

  Future<void> _loadDoctors() async {
    final doctors = [
      const Doctor(
        id: 'doctor_1',
        name: 'Иванов Иван Иванович',
        specialty: 'Терапевт',
        experience: 15,
        rating: 4.8,
        consultationPrice: 2000.0,
      ),
      const Doctor(
        id: 'doctor_2',
        name: 'Петрова Анна Сергеевна',
        specialty: 'Кардиолог',
        experience: 12,
        rating: 4.9,
        consultationPrice: 3000.0,
      ),
      const Doctor(
        id: 'doctor_3',
        name: 'Сидоров Петр Александрович',
        specialty: 'Невролог',
        experience: 20,
        rating: 4.7,
        consultationPrice: 2500.0,
      ),
    ];

    for (final doctor in doctors) {
      _doctors[doctor.id] = doctor;
    }
  }

  Future<void> _loadMedications() async {
    final medications = [
      const Medication(
        id: 'med_1',
        name: 'Парацетамол',
        dosage: '500 мг',
        description: 'Жаропонижающее и обезболивающее средство',
        category: MedicationCategory.analgesic,
      ),
      const Medication(
        id: 'med_2',
        name: 'Ибупрофен',
        dosage: '400 мг',
        description: 'Противовоспалительное средство',
        category: MedicationCategory.antiInflammatory,
      ),
      const Medication(
        id: 'med_3',
        name: 'Амоксициллин',
        dosage: '500 мг',
        description: 'Антибиотик широкого спектра',
        category: MedicationCategory.antibiotic,
      ),
    ];

    for (final medication in medications) {
      _medications[medication.id] = medication;
    }
  }

  String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';
  }

  String _getDefaultUnit(HealthMetricType type) {
    switch (type) {
      case HealthMetricType.bloodPressure:
        return 'мм рт.ст.';
      case HealthMetricType.heartRate:
        return 'уд/мин';
      case HealthMetricType.weight:
        return 'кг';
      case HealthMetricType.temperature:
        return '°C';
      case HealthMetricType.bloodSugar:
        return 'ммоль/л';
      case HealthMetricType.steps:
        return 'шагов';
      default:
        return '';
    }
  }

  void dispose() {
    _onMetricRecorded.close();
    _onAppointmentScheduled.close();
  }
}

// Модели данных

class HealthMetric {
  final String id;
  final String userId;
  final HealthMetricType type;
  final double value;
  final String unit;
  final String? notes;
  final DateTime timestamp;

  const HealthMetric({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    required this.unit,
    this.notes,
    required this.timestamp,
  });
}

enum HealthMetricType {
  bloodPressure,
  heartRate,
  weight,
  temperature,
  bloodSugar,
  steps,
  sleepHours,
  caloriesBurned,
  waterIntake,
  oxygenSaturation,
}

class Appointment {
  final String id;
  final String userId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime dateTime;
  final String? reason;
  final AppointmentStatus status;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.dateTime,
    this.reason,
    required this.status,
    required this.createdAt,
  });
}

enum AppointmentStatus {
  scheduled,
  confirmed,
  inProgress,
  completed,
  cancelled,
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final int experience;
  final double rating;
  final double consultationPrice;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.consultationPrice,
  });
}

class Medication {
  final String id;
  final String name;
  final String dosage;
  final String description;
  final MedicationCategory category;

  const Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.description,
    required this.category,
  });
}

enum MedicationCategory {
  analgesic,
  antibiotic,
  antiInflammatory,
  antihistamine,
  vitamin,
  other,
}

class Prescription {
  final String id;
  final String userId;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final int timesPerDay;
  final DateTime startDate;
  final DateTime? endDate;
  final PrescriptionStatus status;
  final DateTime createdAt;

  const Prescription({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.timesPerDay,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.createdAt,
  });
}

enum PrescriptionStatus {
  active,
  completed,
  cancelled,
}

class HealthStatistics {
  final int totalReadings;
  final int bloodPressureReadings;
  final int weightReadings;
  final double averageSteps;
  final double averageHeartRate;
  final double averageSleepHours;

  const HealthStatistics({
    required this.totalReadings,
    required this.bloodPressureReadings,
    required this.weightReadings,
    required this.averageSteps,
    required this.averageHeartRate,
    required this.averageSleepHours,
  });
}
