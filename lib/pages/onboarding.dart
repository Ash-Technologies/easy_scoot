import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_scoot/appwrite/auth.dart'; // Ensure this is correctly imported
import 'home.dart'; // Ensure this is correctly imported
import 'package:easy_scoot/widgets/Astartup_loading.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({Key? key}) : super(key: key);

  @override
  _OnboardingState createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  void _checkOnboarding() async {
    final auth = Provider.of<AuthAPI>(context, listen: false);
    bool isOnboarded = await auth.isuserOnboarded();
    if (isOnboarded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _completeOnboarding() async {
    final auth = Provider.of<AuthAPI>(context, listen: false);
    await auth.onboardUser();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? StartupLoader() // Show the loading indicator while checking
          : OnboardingPage(),
    );
  }
}

///////

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentStep = 0;

  void _goToNextStep() {
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthenticationSuccessfulPage()),
      );
    }
  }

  double getProgress() {
    if (currentStep == 1) return 0.3;
    if (currentStep == 2) return 0.6;
    if (currentStep == 3) return 0.9;
    if (currentStep == 4) return 1.0;
    return 0.0;
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return WelcomePage(onStart: _goToNextStep);
      case 1:
        return PersonalDetailsPage(onContinue: _goToNextStep);
      case 2:
        return TakeSelfiePage(onContinue: _goToNextStep);
      case 3:
        return AadharScanPage(onContinue: _goToNextStep);
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("easy scoot"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (currentStep != 0) // Show progress bar only after welcome screen
            Padding(
              padding: EdgeInsets.all(15.0),
              child: LinearPercentIndicator(
                width: MediaQuery.of(context).size.width * 0.8,
                lineHeight: 14.0,
                percent: getProgress(),
                center: Text(
                  "${(getProgress() * 100).toStringAsFixed(0)}%",
                  style: TextStyle(fontSize: 12.0),
                ),
                linearStrokeCap: LinearStrokeCap.roundAll,
                backgroundColor: Colors.grey,
                progressColor: Colors.blue,
              ),
            ),
          Expanded(child: _buildCurrentStep()),
        ],
      ),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final VoidCallback onStart;

  WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Welcome new user,",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            "We need some info before you can start using easy scoot. "
            "Sit in a well-lit environment and keep your Aadhar card ready.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onStart,
            child: Text("Start >"),
          ),
        ],
      ),
    );
  }
}

class PersonalDetailsPage extends StatefulWidget {
  final VoidCallback onContinue;

  PersonalDetailsPage({required this.onContinue});

  @override
  _PersonalDetailsPageState createState() => _PersonalDetailsPageState();
}

class _PersonalDetailsPageState extends State<PersonalDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Personal Details",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(labelText: "First Name"),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your first name' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Last Name"),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter your last name' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Email Address"),
              controller: _emailController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z]+\.[a-zA-Z]+")
                    .hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? 'Date of Birth'
                        : 'Date of Birth: ${selectedDate!.toLocal()}'
                            .split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() {
                        selectedDate = picked;
                      });
                    }
                  },
                  child: Text("Select Date"),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate() && selectedDate != null) {
                  widget.onContinue();
                }
              },
              child: Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}

class TakeSelfiePage extends StatelessWidget {
  final VoidCallback onContinue;

  TakeSelfiePage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Take Selfie",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Image.asset('assets/placeholder_selfie.png',
              height: 200), // Mock selfie image
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onContinue,
            child: Text("Capture Photo"),
          ),
        ],
      ),
    );
  }
}

class AadharScanPage extends StatelessWidget {
  final VoidCallback onContinue;

  AadharScanPage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Aadhar Scan",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Image.asset('assets/placeholder_aadhar.png',
              height: 200), // Mock Aadhar image
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onContinue,
            child: Text("Scan Aadhar"),
          ),
        ],
      ),
    );
  }
}

class AuthenticationSuccessfulPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("easy scoot"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Authentication Successful",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Image.asset('assets/placeholder_success.png',
                height: 200), // Mock success image
            SizedBox(height: 20),
            Text(
              "Thank you for going through the verification process.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Let's Go"),
            ),
          ],
        ),
      ),
    );
  }
}
