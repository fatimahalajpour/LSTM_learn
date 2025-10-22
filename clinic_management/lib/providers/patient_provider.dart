import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/patient.dart';

// Patient List State Notifier
class PatientListNotifier extends StateNotifier<AsyncValue<List<Patient>>> {
  PatientListNotifier() : super(const AsyncValue.loading()) {
    loadPatients();
  }

  // Load patients (initially with sample data)
  Future<void> loadPatients() async {
    try {
      state = const AsyncValue.loading();
      
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Load sample patients (in real app, this would be from API/Database)
      final patients = Patient.getSamplePatients();
      
      state = AsyncValue.data(patients);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  // Add new patient
  Future<bool> addPatient(Patient patient) async {
    try {
      final currentState = state.value;
      if (currentState == null) return false;

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Add patient to list
      final updatedList = [...currentState, patient];
      state = AsyncValue.data(updatedList);
      
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  // Update patient
  Future<bool> updatePatient(Patient updatedPatient) async {
    try {
      final currentState = state.value;
      if (currentState == null) return false;

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Update patient in list
      final updatedList = currentState.map((patient) {
        return patient.id == updatedPatient.id ? updatedPatient : patient;
      }).toList();
      
      state = AsyncValue.data(updatedList);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  // Delete patient (soft delete)
  Future<bool> deletePatient(String patientId) async {
    try {
      final currentState = state.value;
      if (currentState == null) return false;

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Mark patient as inactive
      final updatedList = currentState.map((patient) {
        return patient.id == patientId 
            ? patient.copyWith(isActive: false, updatedAt: DateTime.now())
            : patient;
      }).toList();
      
      state = AsyncValue.data(updatedList);
      return true;
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
      return false;
    }
  }

  // Search patients
  List<Patient> searchPatients(String query) {
    final currentState = state.value;
    if (currentState == null || query.isEmpty) return currentState ?? [];

    return currentState.where((patient) {
      final fullName = patient.fullName.toLowerCase();
      final phoneNumber = patient.phoneNumber;
      final searchQuery = query.toLowerCase();
      
      return fullName.contains(searchQuery) || 
             phoneNumber.contains(searchQuery);
    }).toList();
  }

  // Get active patients only
  List<Patient> get activePatients {
    final currentState = state.value;
    if (currentState == null) return [];
    
    return currentState.where((patient) => patient.isActive).toList();
  }

  // Get patient by ID
  Patient? getPatientById(String id) {
    final currentState = state.value;
    if (currentState == null) return null;
    
    try {
      return currentState.firstWhere((patient) => patient.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get patients statistics
  Map<String, int> get patientsStatistics {
    final currentState = state.value;
    if (currentState == null) return {};
    
    final activePatients = currentState.where((p) => p.isActive).toList();
    final maleCount = activePatients.where((p) => p.gender == Gender.male).length;
    final femaleCount = activePatients.where((p) => p.gender == Gender.female).length;
    
    // Today's patients (sample logic)
    final today = DateTime.now();
    final todayPatients = activePatients.where((p) {
      return p.createdAt.year == today.year &&
             p.createdAt.month == today.month &&
             p.createdAt.day == today.day;
    }).length;

    return {
      'total': activePatients.length,
      'male': maleCount,
      'female': femaleCount,
      'today': todayPatients,
    };
  }
}

// Patient Search State Notifier
class PatientSearchNotifier extends StateNotifier<String> {
  PatientSearchNotifier() : super('');

  void updateSearchQuery(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}

// Selected Patient State Notifier
class SelectedPatientNotifier extends StateNotifier<Patient?> {
  SelectedPatientNotifier() : super(null);

  void selectPatient(Patient patient) {
    state = patient;
  }

  void clearSelection() {
    state = null;
  }

  void updateSelectedPatient(Patient updatedPatient) {
    if (state?.id == updatedPatient.id) {
      state = updatedPatient;
    }
  }
}

// Providers
final patientListProvider = StateNotifierProvider<PatientListNotifier, AsyncValue<List<Patient>>>((ref) {
  return PatientListNotifier();
});

final patientSearchProvider = StateNotifierProvider<PatientSearchNotifier, String>((ref) {
  return PatientSearchNotifier();
});

final selectedPatientProvider = StateNotifierProvider<SelectedPatientNotifier, Patient?>((ref) {
  return SelectedPatientNotifier();
});

// Computed providers
final filteredPatientsProvider = Provider<List<Patient>>((ref) {
  final patients = ref.watch(patientListProvider);
  final searchQuery = ref.watch(patientSearchProvider);
  
  return patients.when(
    data: (patientList) {
      if (searchQuery.isEmpty) {
        return patientList.where((p) => p.isActive).toList();
      }
      
      return patientList.where((patient) {
        if (!patient.isActive) return false;
        
        final fullName = patient.fullName.toLowerCase();
        final phoneNumber = patient.phoneNumber;
        final query = searchQuery.toLowerCase();
        
        return fullName.contains(query) || phoneNumber.contains(query);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final patientStatsProvider = Provider<Map<String, int>>((ref) {
  final patients = ref.watch(patientListProvider);
  
  return patients.when(
    data: (patientList) {
      final activePatients = patientList.where((p) => p.isActive).toList();
      final maleCount = activePatients.where((p) => p.gender == Gender.male).length;
      final femaleCount = activePatients.where((p) => p.gender == Gender.female).length;
      
      // Today's patients
      final today = DateTime.now();
      final todayPatients = activePatients.where((p) {
        return p.createdAt.year == today.year &&
               p.createdAt.month == today.month &&
               p.createdAt.day == today.day;
      }).length;

      return {
        'total': activePatients.length,
        'male': maleCount,
        'female': femaleCount,
        'today': todayPatients,
      };
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// Patient by ID provider
final patientByIdProvider = Provider.family<Patient?, String>((ref, id) {
  final patients = ref.watch(patientListProvider);
  
  return patients.when(
    data: (patientList) {
      try {
        return patientList.firstWhere((patient) => patient.id == id);
      } catch (e) {
        return null;
      }
    },
    loading: () => null,
    error: (_, __) => null,
  );
});