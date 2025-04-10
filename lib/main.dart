import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Auth Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showLogin = true;

  void toggleView() {
    setState(() => showLogin = !showLogin);
  }

  @override
  Widget build(BuildContext context) {
    return showLogin
        ? LoginForm(toggleView: toggleView)
        : RegisterForm(toggleView: toggleView);
  }
}

class RegisterForm extends StatefulWidget {
  final VoidCallback toggleView;
  RegisterForm({required this.toggleView});

  @override
  _RegisterFormState createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '', error = '';
  bool loading = false;

  Future register() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register'), actions: [
        TextButton(onPressed: widget.toggleView, child: Text("Sign In", style: TextStyle(color: Colors.white)))
      ]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Email"),
              onChanged: (val) => email = val,
              validator: (val) => val!.isEmpty ? 'Enter an email' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              onChanged: (val) => password = val,
              validator: (val) => val!.length < 6 ? 'Password must be 6+ chars' : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Register"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  register();
                }
              },
            ),
            SizedBox(height: 12),
            Text(error, style: TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  final VoidCallback toggleView;
  LoginForm({required this.toggleView});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String email = '', password = '', error = '';
  bool loading = false;

  Future login() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login'), actions: [
        TextButton(onPressed: widget.toggleView, child: Text("Register", style: TextStyle(color: Colors.white)))
      ]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: "Email"),
              onChanged: (val) => email = val,
              validator: (val) => val!.isEmpty ? 'Enter an email' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
              onChanged: (val) => password = val,
              validator: (val) => val!.isEmpty ? 'Enter a password' : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Login"),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  login();
                }
              },
            ),
            SizedBox(height: 12),
            Text(error, style: TextStyle(color: Colors.red)),
          ]),
        ),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
              })
        ],
      ),
      body: Center(
        child: Text(
          user != null ? 'Logged in as: ${user!.email}' : 'No user found',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// This wrapper ensures login/logout redirection
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          return snapshot.data != null ? ProfileScreen() : AuthScreen();
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
