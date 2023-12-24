import 'package:flutter/material.dart';
import 'helperdb.dart';
import 'users.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  late Future<List<User?>> _userList;

  @override
  void initState() {
    super.initState();
    _userList = getUsers();
  }

  Future<List<User?>> getUsers() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    return await dbHelper.get_user_list("user.db");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Users"),
        backgroundColor: Color.fromARGB(255, 58, 235, 90),
      ),
      body: FutureBuilder<List<User?>>(
        future: _userList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            List<User?>? users = snapshot.data;
            return ListView.builder(
              itemCount: users!.length,
              itemBuilder: (context, index) {
                User? user = users[index];
                return Card(
                  color: Colors.lightBlue, 
                  elevation: 2.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(
                      user?.email ?? 'No Email',
                      style: TextStyle(
                        color: Colors.white, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      user?.gender ?? 'No Gender',
                      style: TextStyle(
                        color: Colors.white70, 
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("Can't find users"));
          }
        },
      ),
    );
  }
}
