import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DiabetesTestPage extends StatefulWidget {
  const DiabetesTestPage({Key? key}) : super(key: key);

  @override
  _DiabetesTestPageState createState() => _DiabetesTestPageState();
}

class _DiabetesTestPageState extends State<DiabetesTestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();
  final TextEditingController hba1cController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();
  String? _gender;
  bool hasHypertension = false;
  bool hasHeartDisease = false;
  String result = '';
  double probabilityValue = 0.0;
  late Interpreter _interpreter;
  bool _isModelLoaded = false;
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _resultAnimation;

  static const Map<String, Map<String, double>> _normParams = {
    'age': {'min': 0.0, 'max': 100.0},
    'bmi': {'min': 10.0, 'max': 50.0},
    'hba1c': {'min': 4.0, 'max': 15.0},
    'glucose': {'min': 0.0, 'max': 1500.0},
  };

  @override
  void initState() {
    super.initState();
    _initializeModel();

    _animationController = AnimationController(
      // Add Animation in initState
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _resultAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutBack, // You can choose a different curve
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); //Dispose the animation controller
    if (_isModelLoaded) _interpreter.close();
    ageController.dispose();
    bmiController.dispose();
    hba1cController.dispose();
    glucoseController.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (!manifest
          .listAssets()
          .contains('assets/assets/modelaferconvert.tflite')) {
        throw Exception(
            'Model file not found in assets. Check pubspec.yaml and assets folder.');
      }

      print('Model file found in assets manifest.');

      _interpreter = await Interpreter.fromAsset(
        'assets/modelaferconvert.tflite',
        options: InterpreterOptions()..threads = 4,
      );

      print('Interpreter initialized successfully.');

      final inputTensors = _interpreter.getInputTensors();
      final outputTensors = _interpreter.getOutputTensors();

      print('Input tensor shape: ${inputTensors[0].shape}');
      print('Output tensor shape: ${outputTensors[0].shape}');

      if (inputTensors.length != 1 || inputTensors[0].shape[1] != 7) {
        throw Exception('Invalid input shape. Expected [1,7]');
      }
      setState(() => _isModelLoaded = true);
      print('Model loaded and tested successfully!');
    } catch (e) {
      setState(() {
        result = 'Model Error: ${e.toString().replaceAll('Exception: ', '')}';
        _isModelLoaded = false;
      });
      print('Model loading error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildGradientAppBar(),
      body: buildBody(),
    );
  }

  AppBar _buildGradientAppBar() {
    return AppBar(
      title: const Text('Diabetes Risk Assessment',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.1)),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          // Use SingleChildScrollView
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 30), // Increased spacing
                _buildInputSection(), // Use the new input section widget
                const SizedBox(height: 30), // Add spacing before result
                if (!_isModelLoaded) _buildModelError(),
                _buildResultDisplay()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const Icon(Icons.health_and_safety,
            size: 70, color: Color(0xFF6C63FF)), // Increased Icon Size
        const SizedBox(height: 20),
        Text(
          'Diabetes Risk Assessment',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28, // Increased font size
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D2D3A),
                letterSpacing: 1.2,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12), // Increased spacing
        Text(
          'Provide accurate health information for reliable results',
          style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600], // Darker grey
              height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Container(
      padding: const EdgeInsets.all(25), // Increased padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25), // More rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Soft shadow
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGenderDropdown(),
          const SizedBox(height: 20), // Increased spacing
          _buildNumberInputs(),
          const SizedBox(height: 20), // Increased spacing
          _buildHealthConditions(),
          const SizedBox(height: 30), // Increased spacing
          _buildPredictButton(),
        ],
      ),
    );
  }

  Widget _buildResultDisplay() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500), // Adjust duration as needed
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: _isModelLoaded && result.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(25), // Increased padding
              decoration: BoxDecoration(
                color: _getResultColor().withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(20), // Rounded result container
                border: Border.all(
                    color: _getResultColor(), // Stronger border color
                    width: 2),
              ),

              child: Column(
                children: [
                  Icon(
                    result.contains('Positive')
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle, // More modern icons
                    color: _getResultColor(),
                    size: 60, // Increased icon size
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result, //result.split('(')[0], Display only Positive/Negative part in large text
                    style: TextStyle(
                        fontSize: 24, // Increased font size
                        fontWeight: FontWeight.bold,
                        color: _getResultColor()),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    // More prominent progress indicator
                    value: probabilityValue,
                    backgroundColor: Colors.grey.shade300,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_getResultColor()),
                    minHeight: 12, // Increased height
                    borderRadius:
                        BorderRadius.circular(8), // Rounded progress bar
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Probability: ${(probabilityValue * 100).toStringAsFixed(2)}%',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w500, // Slightly bolder probability text
                        color:
                            Colors.grey[700]), // Darker grey probability text
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Color _getResultColorForResult() {
    return result.startsWith('Positive') ? Colors.red : Colors.green;
  }

  Widget _buildModelError() {
    // MODIFIED ERROR WIDGET
    return Center(
      // Centering widget
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          result,
          style: const TextStyle(
            fontSize: 24, // Increased font size
            color: Colors.red, // Changed to white
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: InputDecoration(
        labelText: 'Gender',
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF6C63FF)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // Remove default border
        ),
        filled: true, // Fill the background
        fillColor: const Color(0xFFF8F9FF),
        focusedBorder: OutlineInputBorder(
          // Focused border style
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        enabledBorder: OutlineInputBorder(
          // Enabled border style
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
      ],
      validator: (value) => value == null ? 'Please select gender' : null,
      onChanged: (value) => setState(() => _gender = value),
    );
  }

  Widget _buildNumberInputs() {
    return Column(
      children: [
        _buildNumberInput(
          controller: ageController,
          label: 'Age',
          icon: Icons.cake,
          validator: (v) => _validateRange(
              v, _normParams['age']!['min']!, _normParams['age']!['max']!),
        ),
        const SizedBox(height: 15),
        _buildNumberInput(
          controller: bmiController,
          label: 'BMI',
          icon: Icons.monitor_weight,
          validator: (v) => _validateRange(
              v, _normParams['bmi']!['min']!, _normParams['bmi']!['max']!),
        ),
        const SizedBox(height: 15),
        _buildNumberInput(
          controller: hba1cController,
          label: 'HbA1c (%)',
          icon: Icons.bloodtype,
          validator: (v) => _validateRange(
              v, _normParams['hba1c']!['min']!, _normParams['hba1c']!['max']!),
        ),
        const SizedBox(height: 15),
        _buildNumberInput(
          controller: glucoseController,
          label: 'Glucose (mg/dL)',
          icon: Icons.favorite,
          validator: (v) => _validateRange(v, _normParams['glucose']!['min']!,
              _normParams['glucose']!['max']!),
        ),
      ],
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required IconData icon, // Added icon parameter
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)), // Icon in input
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none, // Remove default border
        ),
        filled: true, // Fill the background
        fillColor: const Color(0xFFF8F9FF),
        focusedBorder: OutlineInputBorder(
          // Focused border style
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF6C63FF)),
        ),
        enabledBorder: OutlineInputBorder(
          // Enabled border style
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          //Error Border
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))
      ],
    );
  }

  Widget _buildHealthConditions() {
    return Column(
      children: [
        _buildConditionSwitch('Hypertension', hasHypertension),
        _buildConditionSwitch('Heart Disease', hasHeartDisease),
      ],
    );
  }

//custom switch
  Widget _buildConditionSwitch(String label, bool value) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeColor: const Color(0xFF6C63FF),
      inactiveTrackColor: Colors.grey.shade300,
      contentPadding: EdgeInsets.zero,
      onChanged: (bool? newValue) {
        setState(() {
          if (label == 'Hypertension') {
            hasHypertension = newValue!;
          } else {
            hasHeartDisease = newValue!;
          }
        });
      },
    );
  }

  Widget _buildPredictButton() {
    return ElevatedButton(
      onPressed: _isModelLoaded && !_isProcessing ? _handlePrediction : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
            vertical: 20, horizontal: 40), // Increased button padding
        backgroundColor: const Color(0xFF6C63FF),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15)), // More rounded button
        elevation: 8, // Increased elevation for more prominent shadow
        shadowColor:
            const Color(0xFF6C63FF).withOpacity(0.5), // More visible shadow
      ),
      child: _isProcessing
          ? const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                  strokeWidth: 3, color: Colors.white))
          : const Text('Check Risk',
              style: TextStyle(
                  fontSize: 18,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600)),
    );
  }

  String? _validateRange(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    final numValue = double.tryParse(value);
    if (numValue == null) {
      return 'Invalid number';
    }
    if (numValue < min || numValue > max) {
      return 'Value must be between $min and $max';
    }
    return null;
  }

  Future<void> _handlePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      result = '';
      _animationController.reset(); // Reset animation
    });

    try {
      print("Age Controller Text: ${ageController.text}");
      print("BMI Controller Text: ${bmiController.text}");
      print("HbA1c Controller Text: ${hba1cController.text}");
      print("Glucose Controller Text: ${glucoseController.text}");
      print("Gender Value: $_gender");
      print("Hypertension: $hasHypertension");
      print("Heart Disease: $hasHeartDisease");

      final rawInputs = [
        _gender == 'Female' ? 1.0 : 0.0,
        double.parse(ageController.text),
        hasHypertension ? 1.0 : 0.0,
        hasHeartDisease ? 1.0 : 0.0,
        double.parse(bmiController.text),
        double.parse(hba1cController.text),
        double.parse(glucoseController.text),
      ];

      print("Raw Inputs: $rawInputs");

      final input = [rawInputs].reshape([1, 7]);
      final output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);

      final probability = output[0][0];
      final probabilityPercentage = (probability * 100).toStringAsFixed(2);
      print("Model Probability: $probability ($probabilityPercentage%)");

      setState(() {
        probabilityValue = probability;
        result = probability >= 0.5
            ? 'Positive ($probabilityPercentage%)'
            : 'Negative ($probabilityPercentage%)';
      });

      _animationController.forward();
    } catch (e) {
      setState(() => result = 'Prediction failed. Check inputs');
      print("Prediction error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Color _getResultColor() {
    if (result.toLowerCase().contains('positive')) {
      return Colors.red;
    } else if (result.toLowerCase().contains('negative')) {
      return Colors.green;
    } else {
      return Colors.grey; // Default color if neither positive nor negative
    }
  }
}
