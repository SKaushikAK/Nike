import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(UserApp());

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Info App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: UserListPage(),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String errorMessage = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('https://jsonplaceholder.typicode.com/users');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          users = data;
          filteredUsers = data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load users';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  void filterUsers(String query) {
    final filtered = users.where((user) {
      final name = user['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredUsers = filtered;
      searchQuery = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User List'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
              onChanged: filterUsers,
            ),
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(user['name']),
                        subtitle: Text(user['email']),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserDetailPage(user: user),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class UserDetailPage extends StatelessWidget {
  final dynamic user;

  const UserDetailPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Username: ${user['username']}",
                style: TextStyle(fontSize: 16)),
            Text("Email: ${user['email']}", style: TextStyle(fontSize: 16)),
            Text("Phone: ${user['phone']}", style: TextStyle(fontSize: 16)),
            Text("Website: ${user['website']}", style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text("Address:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("${user['address']['street']}, ${user['address']['suite']}"),
            Text("${user['address']['city']} - ${user['address']['zipcode']}"),
          ],
        ),
      ),
    );
  }
}
