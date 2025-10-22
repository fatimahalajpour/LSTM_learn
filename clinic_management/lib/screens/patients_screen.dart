import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../constants/app_theme.dart';
import '../constants/app_strings.dart';
import '../widgets/patient_card.dart';
import '../screens/add_patient_screen.dart';

class PatientsScreen extends ConsumerStatefulWidget {
  const PatientsScreen({super.key});

  @override
  ConsumerState<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends ConsumerState<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredPatients = ref.watch(filteredPatientsProvider);
    final patientsAsyncValue = ref.watch(patientListProvider);
    final searchQuery = ref.watch(patientSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.patientManagement),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(patientListProvider.notifier).loadPatients();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceColor,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '${AppStrings.search}...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                ref.read(patientSearchProvider.notifier)
                                    .clearSearch();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      ref.read(patientSearchProvider.notifier)
                          .updateSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                  ),
                ),
              ],
            ),
          ),

          // Patients List
          Expanded(
            child: patientsAsyncValue.when(
              data: (patients) {
                if (filteredPatients.isEmpty) {
                  return _buildEmptyState();
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(patientListProvider.notifier).loadPatients();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return PatientCard(
                        patient: patient,
                        onTap: () => _showPatientDetails(context, patient),
                        onEdit: () => _editPatient(context, patient),
                        onDelete: () => _deletePatient(context, patient),
                      );
                    },
                  ),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stackTrace) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNewPatient(context),
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addNewPatient),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 200,
                    height: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 150,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 120,
                    height: 12,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.noDataFound,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
                     Text(
             ref.watch(patientSearchProvider).isNotEmpty
                 ? 'هیچ بیماری با این جستجو یافت نشد'
                 : 'هنوز هیچ بیماری ثبت نشده است',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addNewPatient(context),
            icon: const Icon(Icons.add),
            label: const Text(AppStrings.addNewPatient),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.error,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(patientListProvider.notifier).loadPatients();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('تلاش مجدد'),
          ),
        ],
      ),
    );
  }

  void _addNewPatient(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddPatientScreen(),
      ),
    );
  }

  void _editPatient(BuildContext context, Patient patient) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddPatientScreen(patient: patient),
      ),
    );
  }

  void _showPatientDetails(BuildContext context, Patient patient) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PatientDetailsSheet(patient: patient),
    );
  }

  void _deletePatient(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: Text('آیا مطمئن هستید که می‌خواهید ${patient.fullName} را حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await ref
                  .read(patientListProvider.notifier)
                  .deletePatient(patient.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('بیمار با موفقیت حذف شد'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.filter),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('همه بیماران'),
              onTap: () {
                ref.read(patientSearchProvider.notifier).clearSearch();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.man),
              title: const Text('بیماران مرد'),
              onTap: () {
                // Implement gender filter
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.woman),
              title: const Text('بیماران زن'),
              onTap: () {
                // Implement gender filter
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Patient Details Sheet Widget
class PatientDetailsSheet extends StatelessWidget {
  final Patient patient;

  const PatientDetailsSheet({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              
              // Header
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      patient.firstName[0] + patient.lastName[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.fullName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          patient.phoneNumber,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Details
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow(Icons.phone, AppStrings.phoneNumber, patient.phoneNumber),
                    if (patient.email != null && patient.email!.isNotEmpty)
                      _buildDetailRow(Icons.email, AppStrings.email, patient.email!),
                    _buildDetailRow(Icons.person, AppStrings.gender, patient.genderText),
                    if (patient.age != null)
                      _buildDetailRow(Icons.cake, 'سن', '${patient.age} سال'),
                    if (patient.address != null && patient.address!.isNotEmpty)
                      _buildDetailRow(Icons.location_on, AppStrings.address, patient.address!),
                    if (patient.medicalHistory != null && patient.medicalHistory!.isNotEmpty)
                      _buildDetailRow(Icons.medical_services, AppStrings.medicalHistory, patient.medicalHistory!),
                    _buildDetailRow(Icons.calendar_today, 'تاریخ ثبت', _formatDate(patient.createdAt)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}