import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class DiabetesTestPage extends StatefulWidget {
  const DiabetesTestPage({Key? key}) : super(key: key);

  @override
  _DiabetesTestPageState createState() => _DiabetesTestPageState();
}

class _DiabetesTestPageState extends State<DiabetesTestPage> {
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
  }

  Future<void> _initializeModel() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      if (!manifest.listAssets().contains('assets/modelaferconvert.tflite')) {
        throw Exception('Model file not found in assets. Check pubspec.yaml and assets folder.');
      }
      _interpreter = await Interpreter.fromAsset(
        'assets/modelaferconvert.tflite',
        options: InterpreterOptions()..threads = 4,
      );
      setState(() => _isModelLoaded = true);
    } catch (e) {
      setState(() {
        result = 'Model Error: ${e.toString().replaceAll('Exception: ', '')}';
        _isModelLoaded = false;
      });
    }
  }

  @override
  void dispose() {
    if (_isModelLoaded) _interpreter.close();
    ageController.dispose();
    bmiController.dispose();
    hba1cController.dispose();
    glucoseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diabetes Test',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildInputFields(),
                const SizedBox(height: 20),
                _buildResultDisplay(),
                if (!_isModelLoaded) _buildModelError(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.medical_services, size: 50, color: Color(0xFF6C63FF)),
          const SizedBox(height: 15),
          const Text(
            'Diabetes Risk Assessment',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2D2D3A)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Provide accurate health information for reliable results',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        _buildGenderDropdown(),
        const SizedBox(height: 12),
        _buildNumberInput(
          controller: ageController,
          label: 'Age',
          validator: (v) => _validateRange(v, _normParams['age']!['min']!, _normParams['age']!['max']!),
        ),
        const SizedBox(height: 12),
        _buildCheckbox('Hypertension', hasHypertension, (v) => setState(() => hasHypertension = v ?? false)),
        _buildCheckbox('Heart Disease', hasHeartDisease, (v) => setState(() => hasHeartDisease = v ?? false)),
        const SizedBox(height: 12),
        _buildNumberInput(
          controller: bmiController,
          label: 'BMI',
          validator: (v) => _validateRange(v, _normParams['bmi']!['min']!, _normParams['bmi']!['max']!),
        ),
        const SizedBox(height: 12),
        _buildNumberInput(
          controller: hba1cController,
          label: 'HbA1c (%)',
          validator: (v) => _validateRange(v, _normParams['hba1c']!['min']!, _normParams['hba1c']!['max']!),
        ),
        const SizedBox(height: 12),
        _buildNumberInput(
          controller: glucoseController,
          label: 'Glucose (mg/dL)',
          validator: (v) => _validateRange(v, _normParams['glucose']!['min']!, _normParams['glucose']!['max']!),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isModelLoaded && !_isProcessing ? _handlePrediction : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
            backgroundColor: const Color(0xFF6C63FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: _isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Check Risk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownButtonFormField<String>(
      value: _gender,
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [
        DropdownMenuItem(value: 'Male', child: Text('Male')),
        DropdownMenuItem(value: 'Female', child: Text('Female')),
      ],
      validator: (value) => value == null ? 'Please select gender' : null,
      onChanged: (value) => setState(() => _gender = value),
    );
  }

  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: validator,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*'))],
    );
  }

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6C63FF),
        ),
        Text(label, style: const TextStyle(fontSize: 16)),
      ],
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

  Widget _buildResultDisplay() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                _isModelLoaded
                    ? (result.isNotEmpty ? 'Diabetes Risk: $result' : '')
                    : 'Model not loaded',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: result.startsWith('Positive')
                      ? Colors.red
                      : (result.startsWith('Negative') ? Colors.green : Colors.grey),
                ),
                textAlign: TextAlign.center,
              ),
              if (_isModelLoaded && result.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Probability: ${(probabilityValue * 100).toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          result,
          style: const TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Future<void> _handlePrediction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      result = '';
    });

    try {
      final rawInputs = [
        _gender == 'Female' ? 1.0 : 0.0,
        double.parse(ageController.text),
        hasHypertension ? 1.0 : 0.0,
        hasHeartDisease ? 1.0 : 0.0,
        double.parse(bmiController.text),
        double.parse(hba1cController.text),
        double.parse(glucoseController.text),
      ];

      final input = [rawInputs].reshape([1, 7]);
      final output = List.filled(1, 0.0).reshape([1, 1]);
      _interpreter.run(input, output);

      final probability = output[0][0];
      

      setState(() {
        probabilityValue = probability;
        result = probability >= 0.5
            ? 'Positive '
            : 'Negative ';
      });
    } catch (e) {
      setState(() => result = 'Prediction failed. Check inputs');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
