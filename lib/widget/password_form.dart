import 'package:flutter/material.dart';
import '../db/sql_helper.dart';

class PasswordForm extends StatefulWidget {
  final int? id;
  final Function onRefresh;
  final int userId;

  const PasswordForm({Key? key, this.id, required this.userId, required this.onRefresh}) : super(key: key);

  @override
  _PasswordFormState createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final TextEditingController _appNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() async {
    final existingData = await SQLHelper.getItem(widget.id!);
    _appNameController.text = existingData[0]['appName'];
    _usernameController.text = existingData[0]['username'];
    _passwordController.text = existingData[0]['password'];
  }

  Future<void> _handleSubmit() async {
    if (widget.id == null) {
      await SQLHelper.createItem(
          _appNameController.text, widget.userId, _usernameController.text, _passwordController.text);
    } else {
      await SQLHelper.updateItem(widget.id!, _appNameController.text,
          _usernameController.text, _passwordController.text);
    }
    widget.onRefresh();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 15,
        left: 15,
        right: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _appNameController,
            decoration: const InputDecoration(hintText: 'Application Name'),
          ),
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Username'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Password',
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _handleSubmit,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}