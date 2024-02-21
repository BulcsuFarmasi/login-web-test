import 'package:flutter/material.dart';
import 'package:login_web_test/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final AuthService authService = AuthService();

  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    authService.authenticate();
    authService.userChanges.listen((user) {
      setState(() {
        if (user != null) {
          isAuthenticated = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Login Web Test'),
      ),
      body: Center(
          child: Text(isAuthenticated ? 'Authenticated' : 'Not Authenticated',
              style: Theme.of(context).textTheme.headlineLarge)),
    );
  }
}
