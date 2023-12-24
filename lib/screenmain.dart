import 'dart:convert';
import 'package:flutter/material.dart';
import 'helperdb.dart';
import 'screenapi.dart';
import 'database.dart';
import 'users.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _iconPositionX = 0.0;
  double _iconPositionY = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const Database()),
      );
      await prefs.setBool('first_time', false);
    }
  }

  get url_ => 'https://randomuser.me/api/?results=20';

  List<User> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const UserListScreen()),
              );
            },
            icon: const Icon(Icons.list),
          ),
        ],
        title: const Text(
          'Random Users List',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.lightBlue[300],
      ),
      backgroundColor: Colors.lightBlue[200],
      body: Stack(
        children: [
          ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user.email;
              final gender = user.gender;
              return ListTile(
                title: Text(
                  email,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                subtitle: Text(
                  gender,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white70,
                  ),
                ),
                onTap: () => saveUserToDatabase(user),
              );
            },
          ),
          Positioned(
            left: _iconPositionX,
            top: _iconPositionY,
            child: Draggable(
              feedback: _buildDraggableIcon(),
              child: _isDragging ? Container() : _buildDraggableIcon(),
              onDragEnd: (details) {
                setState(() {
                  _iconPositionX = details.offset.dx;
                  _iconPositionY = details.offset.dy;
                  _isDragging = false;
                });
              },
              onDragStarted: () {
                setState(() {
                  _isDragging = true;
                });
              },
              childWhenDragging: Container(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Container(
          height: 50.0,
          color: Colors.lightBlue[300],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
          
            ],
          ),
        ),
      ),
      floatingActionButton: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: Duration(seconds: 1),
        builder: (BuildContext context, double value, Widget? child) {
          return Transform.rotate(
            angle: value * 6.3,
            child: ElevatedButton(
              onPressed: fetch,
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 20, 160, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildDraggableIcon() {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        'Drag Me',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  void fetch() async {
    try {
      final uri = Uri.parse(url_);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final body = response.body;
        final jsonData = jsonDecode(body);

        setState(() {
          users = (jsonData['results'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        });
      } else {
        print('Request failed with status: ${response.statusCode}.');
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void saveUserToDatabase(User user) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.saveUser(user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "User ${user.email} saved to SQLite database",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 234, 234, 55),
      ),
    );
  }
}
