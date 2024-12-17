import 'package:flutter/material.dart';
import '../db/sql_helper.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final username = _usernameController.text;
    final fullName = _fullNameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || fullName.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required!';
        _isLoading = false;
      });
      return;
    }

    final userExists = await SQLHelper.getUserByUsername(username);
    if (userExists.isNotEmpty) {
      setState(() {
        _errorMessage = 'Username already exists!';
        _isLoading = false;
      });
      return;
    }

    await SQLHelper.createUser(username, fullName, password);

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                hintText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16.0),
            _isLoading
                ? const CircularProgressIndicator()
                :ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                      padding: MaterialStateProperty.all(const EdgeInsets.symmetric(horizontal: 42.0, vertical: 14.0)),
                    ),
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
            const SizedBox(height: 16.0),
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}