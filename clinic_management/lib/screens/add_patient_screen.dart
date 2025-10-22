import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../models/patient.dart';
import '../providers/patient_provider.dart';
import '../constants/app_theme.dart';
import '../constants/app_strings.dart';

class AddPatientScreen extends ConsumerStatefulWidget {
  final Patient? patient; // null for add, Patient for edit

  const AddPatientScreen({super.key, this.patient});

  @override
  ConsumerState<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends ConsumerState<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  
  // Form state
  Gender _selectedGender = Gender.male;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // If editing, populate fields
    if (widget.patient != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final patient = widget.patient!;
    _firstNameController.text = patient.firstName;
    _lastNameController.text = patient.lastName;
    _phoneController.text = patient.phoneNumber;
    _emailController.text = patient.email ?? '';
    _addressController.text = patient.address ?? '';
    _medicalHistoryController.text = patient.medicalHistory ?? '';
    _selectedGender = patient.gender;
    _selectedBirthDate = patient.birthDate;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.patient != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'ویرایش بیمار' : AppStrings.addNewPatient),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isEditing ? 'ویرایش اطلاعات بیمار' : 'افزودن بیمار جدید',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Personal Information Section
            _buildSectionCard(
              title: 'اطلاعات شخصی',
              icon: Icons.person,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: '${AppStrings.firstName} *',
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: '${AppStrings.lastName} *',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.fieldRequired;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Gender Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.gender} *',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<Gender>(
                            title: Text(AppStrings.male),
                            value: Gender.male,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<Gender>(
                            title: Text(AppStrings.female),
                            value: Gender.female,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value!;
                              });
                            },
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Birth Date
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: AppStrings.birthDate,
                      prefixIcon: const Icon(Icons.cake),
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedBirthDate != null
                          ? _formatDate(_selectedBirthDate!)
                          : 'انتخاب کنید',
                      style: _selectedBirthDate != null
                          ? Theme.of(context).textTheme.bodyMedium
                          : Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Contact Information Section
            _buildSectionCard(
              title: 'اطلاعات تماس',
              icon: Icons.contact_phone,
              children: [
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: '${AppStrings.phoneNumber} *',
                    prefixIcon: const Icon(Icons.phone),
                    hintText: '09123456789',
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.fieldRequired;
                    }
                    if (!RegExp(r'^(\+98|0)?9\d{9}$').hasMatch(value)) {
                      return AppStrings.phoneNumberInvalid;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: const Icon(Icons.email),
                    hintText: 'example@email.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return AppStrings.emailInvalid;
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: AppStrings.address,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Medical Information Section
            _buildSectionCard(
              title: 'اطلاعات پزشکی',
              icon: Icons.medical_services,
              children: [
                TextFormField(
                  controller: _medicalHistoryController,
                  decoration: InputDecoration(
                    labelText: AppStrings.medicalHistory,
                    prefixIcon: const Icon(Icons.history),
                    hintText: 'سابقه بیماری، آلرژی، داروهای مصرفی و...',
                  ),
                  maxLines: 4,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(AppStrings.cancel),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePatient,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(AppStrings.save),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  void _selectBirthDate() async {
    final initialDate = _selectedBirthDate ?? DateTime.now();
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1300),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final patient = Patient(
        id: widget.patient?.id, // Keep existing ID for editing
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        birthDate: _selectedBirthDate,
        gender: _selectedGender,
        medicalHistory: _medicalHistoryController.text.trim().isEmpty 
            ? null 
            : _medicalHistoryController.text.trim(),
        createdAt: widget.patient?.createdAt, // Keep original creation date
      );

      bool success;
      if (widget.patient != null) {
        // Update existing patient
        success = await ref.read(patientListProvider.notifier).updatePatient(patient);
      } else {
        // Add new patient
        success = await ref.read(patientListProvider.notifier).addPatient(patient);
      }

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.patient != null 
                  ? 'بیمار با موفقیت ویرایش شد'
                  : 'بیمار با موفقیت اضافه شد',
            ),
            backgroundColor: AppTheme.secondaryColor,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(AppStrings.operationFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}