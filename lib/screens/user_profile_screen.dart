import 'package:flutter/material.dart';
import 'package:lifegrowth/widgets/navigation_drawer.dart';
import 'package:lifegrowth/services/user_profile_service.dart';
import 'package:lifegrowth/services/auth_service.dart';
import 'package:lifegrowth/models/user_profile_model.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserProfileService _profileService = UserProfileService();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  UserProfileModel? _userProfile;
  bool _isLoading = true;
  bool _isSaving = false;
  DateTime? _selectedDateOfBirth;
  String _selectedTimezone = 'UTC';

  // Height-related variables
  final TextEditingController _heightController = TextEditingController();
  String _heightUnit = 'cm'; // cm, ft, m, in
  static const List<String> _heightUnits = ['cm', 'ft', 'm', 'in'];

  // Height conversion utilities
  double? _convertToCm(double? value, String unit) {
    if (value == null) return null;
    switch (unit) {
      case 'cm':
        return value;
      case 'ft':
        return value * 30.48; // 1 foot = 30.48 cm
      case 'm':
        return value * 100; // 1 meter = 100 cm
      case 'in':
        return value * 2.54; // 1 inch = 2.54 cm
      default:
        return value;
    }
  }

  double? _convertFromCm(double? cmValue, String targetUnit) {
    if (cmValue == null) return null;
    switch (targetUnit) {
      case 'cm':
        return cmValue;
      case 'ft':
        return cmValue / 30.48; // cm to feet
      case 'm':
        return cmValue / 100; // cm to meters
      case 'in':
        return cmValue / 2.54; // cm to inches
      default:
        return cmValue;
    }
  }

  String _formatHeight(double? value, String unit) {
    if (value == null) return '';
    switch (unit) {
      case 'cm':
        return value.toStringAsFixed(1);
      case 'ft':
        return value.toStringAsFixed(2);
      case 'm':
        return value.toStringAsFixed(2);
      case 'in':
        return value.toStringAsFixed(1);
      default:
        return value.toStringAsFixed(1);
    }
  }

  void _onHeightUnitChanged(String newUnit) {
    if (_heightController.text.trim().isNotEmpty) {
      final currentValue = double.tryParse(_heightController.text.trim());
      if (currentValue != null) {
        // Convert current value to cm, then to new unit
        final cmValue = _convertToCm(currentValue, _heightUnit);
        final newValue = _convertFromCm(cmValue, newUnit);
        _heightController.text = _formatHeight(newValue, newUnit);
      }
    }
    setState(() {
      _heightUnit = newUnit;
    });
  }

  // Common timezones list
  static const List<Map<String, String>> _timezones = [
    {'value': 'UTC', 'label': 'UTC (Coordinated Universal Time)'},
    {'value': 'GMT', 'label': 'GMT (Greenwich Mean Time)'},
    {'value': 'IST', 'label': 'IST (India Standard Time)'},
    {'value': 'PST', 'label': 'PST (Pacific Standard Time)'},
    {'value': 'EST', 'label': 'EST (Eastern Standard Time)'},
    {'value': 'CST', 'label': 'CST (Central Standard Time)'},
    {'value': 'MST', 'label': 'MST (Mountain Standard Time)'},
    {'value': 'Asia/Kolkata', 'label': 'India (IST)'},
    {'value': 'America/New_York', 'label': 'Eastern Time (US & Canada)'},
    {'value': 'America/Chicago', 'label': 'Central Time (US & Canada)'},
    {'value': 'America/Denver', 'label': 'Mountain Time (US & Canada)'},
    {'value': 'America/Los_Angeles', 'label': 'Pacific Time (US & Canada)'},
    {'value': 'America/Anchorage', 'label': 'Alaska Time'},
    {'value': 'Pacific/Honolulu', 'label': 'Hawaii Time'},
    {'value': 'Europe/London', 'label': 'London (GMT/BST)'},
    {'value': 'Europe/Paris', 'label': 'Paris (CET/CEST)'},
    {'value': 'Europe/Berlin', 'label': 'Berlin (CET/CEST)'},
    {'value': 'Europe/Rome', 'label': 'Rome (CET/CEST)'},
    {'value': 'Europe/Madrid', 'label': 'Madrid (CET/CEST)'},
    {'value': 'Europe/Amsterdam', 'label': 'Amsterdam (CET/CEST)'},
    {'value': 'Europe/Moscow', 'label': 'Moscow (MSK)'},
    {'value': 'Asia/Tokyo', 'label': 'Tokyo (JST)'},
    {'value': 'Asia/Shanghai', 'label': 'Shanghai (CST)'},
    {'value': 'Asia/Hong_Kong', 'label': 'Hong Kong (HKT)'},
    {'value': 'Asia/Singapore', 'label': 'Singapore (SGT)'},
    {'value': 'Asia/Seoul', 'label': 'Seoul (KST)'},
    {'value': 'Asia/Dubai', 'label': 'Dubai (GST)'},
    {'value': 'Australia/Sydney', 'label': 'Sydney (AEST/AEDT)'},
    {'value': 'Australia/Melbourne', 'label': 'Melbourne (AEST/AEDT)'},
    {'value': 'Australia/Perth', 'label': 'Perth (AWST)'},
    {'value': 'Pacific/Auckland', 'label': 'Auckland (NZST/NZDT)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get current user info
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        _emailController.text = currentUser.email ?? '';
      }

      // Get user profile
      final profile = await _profileService.getCurrentUserProfile();
      if (profile != null) {
        setState(() {
          _userProfile = profile;
          _fullNameController.text = profile.fullName ?? '';
          // Validate timezone against available options
          final validTimezone =
              _timezones.any((tz) => tz['value'] == profile.timezone)
                  ? profile.timezone
                  : 'UTC'; // Default to UTC if timezone not found
          _selectedTimezone = validTimezone;
          _selectedDateOfBirth = profile.dateOfBirth;

          // Load height data
          _heightUnit = profile.heightUnit;
          if (profile.heightCm != null) {
            final displayHeight = _convertFromCm(profile.heightCm, _heightUnit);
            _heightController.text = _formatHeight(displayHeight, _heightUnit);
          }
        });
      } else {
        // If no profile exists, get name from auth metadata
        final fullName = currentUser?.userMetadata?['full_name'] as String?;
        if (fullName != null) {
          _fullNameController.text = fullName;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
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

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      // Update auth profile first
      await _authService.updateProfile(
        fullName: _fullNameController.text.trim(),
      );

      // Convert height to cm for storage
      double? heightInCm;
      if (_heightController.text.trim().isNotEmpty) {
        final heightValue = double.tryParse(_heightController.text.trim());
        if (heightValue != null) {
          heightInCm = _convertToCm(heightValue, _heightUnit);
        }
      }

      // Update or create user profile
      if (_userProfile != null) {
        // Update existing profile
        await _profileService.updateProfileFields(
          fullName: _fullNameController.text.trim(),
          dateOfBirth: _selectedDateOfBirth,
          timezone: _selectedTimezone,
          heightCm: heightInCm,
          heightUnit: _heightUnit,
        );
      } else {
        // Create new profile
        final currentUser = _authService.currentUser;
        if (currentUser != null) {
          final newProfile = UserProfileModel(
            id: currentUser.id,
            fullName: _fullNameController.text.trim(),
            dateOfBirth: _selectedDateOfBirth,
            timezone: _selectedTimezone,
            heightCm: heightInCm,
            heightUnit: _heightUnit,
          );
          await _profileService.createUserProfile(newProfile);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload profile to get updated data
        await _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ??
          DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF24B0BA),
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF24B0BA),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: const AppNavigationDrawer(currentPage: 'Profile'),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF24B0BA),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF73C7E3),
                            Color(0xFF24B0BA),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Your Profile',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manage your personal information',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile form
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF24B0BA),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Full Name
                            TextFormField(
                              controller: _fullNameController,
                              decoration: InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF24B0BA),
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email (read-only)
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              readOnly: true,
                            ),
                            const SizedBox(height: 16),

                            // Date of Birth
                            InkWell(
                              onTap: _selectDateOfBirth,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  prefixIcon:
                                      const Icon(Icons.calendar_today_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF24B0BA),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  _selectedDateOfBirth != null
                                      ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                      : 'Select date of birth',
                                  style: TextStyle(
                                    color: _selectedDateOfBirth != null
                                        ? Colors.black87
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Timezone Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedTimezone,
                              decoration: InputDecoration(
                                labelText: 'Timezone',
                                prefixIcon:
                                    const Icon(Icons.access_time_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF24B0BA),
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: _timezones.map((timezone) {
                                return DropdownMenuItem<String>(
                                  value: timezone['value'],
                                  child: Text(
                                    timezone['label']!,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedTimezone = newValue;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select your timezone';
                                }
                                return null;
                              },
                              isExpanded: true,
                              menuMaxHeight: 300,
                            ),
                            const SizedBox(height: 16),

                            // Height field with unit selector
                            Row(
                              children: [
                                // Height input
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _heightController,
                                    decoration: InputDecoration(
                                      labelText: 'Height',
                                      prefixIcon:
                                          const Icon(Icons.height_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF24B0BA),
                                          width: 2,
                                        ),
                                      ),
                                      hintText: 'Enter height',
                                    ),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    validator: (value) {
                                      if (value != null &&
                                          value.trim().isNotEmpty) {
                                        final height =
                                            double.tryParse(value.trim());
                                        if (height == null || height <= 0) {
                                          return 'Please enter a valid height';
                                        }
                                        // Validate reasonable height ranges
                                        final cmHeight =
                                            _convertToCm(height, _heightUnit);
                                        if (cmHeight != null &&
                                            (cmHeight < 50 || cmHeight > 300)) {
                                          return 'Height must be between 50cm and 300cm';
                                        }
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Unit selector
                                Expanded(
                                  flex: 1,
                                  child: DropdownButtonFormField<String>(
                                    value: _heightUnit,
                                    decoration: InputDecoration(
                                      labelText: 'Unit',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                          color: Color(0xFF24B0BA),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    items: _heightUnits.map((unit) {
                                      return DropdownMenuItem<String>(
                                        value: unit,
                                        child: Text(unit.toUpperCase()),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      if (newValue != null) {
                                        _onHeightUnitChanged(newValue);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Save button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF24B0BA),
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'Save Profile',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
