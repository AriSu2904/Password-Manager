import 'package:flutter/material.dart';
import '../db/sql_helper.dart';
import '../widget/password_form.dart';

class PasswordScreen extends StatefulWidget {
  final int userId;

  const PasswordScreen({Key? key, required this.userId }) : super(key: key);


  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  List<Map<String, dynamic>> _pamans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() async {
    final data = await SQLHelper.getItems(widget.userId);

    print("[ARI] data: $data");

    setState(() {
      _pamans = data;
      _isLoading = false;
    });
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Successfully deleted data!')),
    );
    _refreshData();
  }

  void _showForm(int? id) {
    print("[ARI] id: $id");

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => PasswordForm(
        id: id,
        userId: widget.userId,
        onRefresh: _refreshData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Password Manager'),
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _pamans.length,
              itemBuilder: (context, index) => Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                elevation: 5,
                child: ListTile(
                  onTap: () => _showForm(_pamans[index]['id']),
                  leading: const Icon(Icons.lock_outline, color: Colors.orange),
                  title: Text(
                    _pamans[index]['appName'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username: ${_pamans[index]['username']}'),
                      const SizedBox(height: 5),
                      Text('Password: ******'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showForm(_pamans[index]['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(_pamans[index]['id']),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
    );
  }
}