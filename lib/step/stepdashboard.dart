import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruracare/services/api_service.dart';
//import 'package:ruracare/services/models.dart';

class StepDashboard extends StatefulWidget {

  const StepDashboard({
    super.key,
  });

  @override
  State<StepDashboard> createState() => _StepDashboardState();
}

class _StepDashboardState extends State<StepDashboard> {
  //final ApiService _apiService = ApiService();
  final TextEditingController _stepCountController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  List<XFile> _selectedImages = [];
  bool _isSubmitting = false;
  bool _isLoading = false;
  int _todaySteps = 0;
  int _weeklySteps = 0;
  int _monthlySteps = 0;
  int _stepTarget = 10000;

  @override
  void initState() {
    super.initState();
    _loadStepData();
  }

  Future<void> _loadStepData() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Load user step data from API
      // This would typically come from your backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      if (mounted) {
        setState(() {
          _todaySteps = 3500;
          _weeklySteps = 24500;
          _monthlySteps = 89000;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load step data: $e');
      }
    }
  }

  Future<void> _submitSteps() async {
    if (_isSubmitting) return;

    final stepCount = int.tryParse(_stepCountController.text.trim());
    if (stepCount == null || stepCount <= 0) {
      _showErrorSnackBar('Please enter a valid step count');
      return;
    }

    if (mounted) {
      setState(() => _isSubmitting = true);
    }

    try {
      // Submit steps to API
      //await _apiService.submitSteps(
      //  widget.userId,
      //  stepCount,
      //  _selectedImages,
      //);

      if (!mounted) return;

      // Update local state
      setState(() {
        _todaySteps += stepCount;
        _weeklySteps += stepCount;
        _monthlySteps += stepCount;
        _stepCountController.clear();
        _selectedImages.clear();
      });

      _showSuccessSnackBar('Successfully submitted $stepCount steps!');
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to submit steps: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images != null && images.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedImages.addAll(images);
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 90,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _removeImage(int index) {
    if (mounted) {
      setState(() {
        _selectedImages.removeAt(index);
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  double _getProgressPercentage(int steps) {
    return steps / _stepTarget;
  }

  String _formatSteps(int steps) {
    return steps.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Step Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onBackground,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadStepData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Step Statistics Cards
                    _buildStepStatistics(theme, colorScheme),
                    
                    const SizedBox(height: 32),
                    
                    // Manual Step Input Section
                    _buildStepInputSection(theme, colorScheme),
                    
                    const SizedBox(height: 32),
                    
                    // Image Upload Section
                    _buildImageUploadSection(theme, colorScheme),
                    
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    _buildSubmitButton(theme, colorScheme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStepStatistics(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Today's Steps Card
        _buildStepCard(
          theme: theme,
          colorScheme: colorScheme,
          title: "Today's Steps",
          steps: _todaySteps,
          target: _stepTarget,
          color: Colors.blue.shade600,
          icon: Icons.directions_walk,
        ),
        
        const SizedBox(height: 16),
        
        // Weekly and Monthly Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStepCard(
                theme: theme,
                colorScheme: colorScheme,
                title: "This Week",
                steps: _weeklySteps,
                target: _stepTarget * 7,
                color: Colors.green.shade600,
                icon: Icons.calendar_today,
                compact: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStepCard(
                theme: theme,
                colorScheme: colorScheme,
                title: "This Month",
                steps: _monthlySteps,
                target: _stepTarget * 30,
                color: Colors.purple.shade600,
                icon: Icons.trending_up,
                compact: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    required int steps,
    required int target,
    required Color color,
    required IconData icon,
    bool compact = false,
  }) {
    final progress = _getProgressPercentage(steps);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onBackground,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Steps Count
          Text(
            _formatSteps(steps),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // Target
          Text(
            'Target: ${_formatSteps(target)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          
          if (!compact) const SizedBox(height: 16),
          
          if (!compact)
            LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceVariant.withOpacity(0.5),
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          
          if (!compact) const SizedBox(height: 8),
          
          if (!compact)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
                Text(
                  '${_formatSteps((target - steps).clamp(0, target))} to go',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildStepInputSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Manual Step Entry',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Enter your step count for today',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _stepCountController,
            keyboardType: TextInputType.number,
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: 'Step Count',
              hintText: 'Enter number of steps...',
              prefixIcon: const Icon(Icons.numbers),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter step count';
              }
              final steps = int.tryParse(value);
              if (steps == null || steps <= 0) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Tip: You can find your step count in your fitness app or wearable device.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploadSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.photo_library_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Upload Screenshot Proof',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Upload screenshots from your fitness app as proof (optional)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Upload Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _pickImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Choose from Gallery'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Selected Images Grid
          if (_selectedImages.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Selected Images (${_selectedImages.length})',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_selectedImages[index].path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: _isSubmitting
          ? Container(
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            )
          : ElevatedButton(
              onPressed: _submitSteps,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Submit Steps',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}