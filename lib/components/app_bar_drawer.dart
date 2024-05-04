import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_7/pages/all_messages.dart';
import 'package:flutter_application_7/pages/home_page.dart';
import 'package:flutter_application_7/pages/login_page.dart';
import 'package:flutter_application_7/pages/my_account_page.dart';
import 'package:flutter_application_7/pages/my_messages_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final User? user;
  final Function()? signOut;

  const CustomAppBar({Key? key, this.user, this.signOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Container(
        height: 50, // Adjust the height as needed
        child: Center(
          child: Image.asset('assets/LogoISI.png'),
        ),
      ),
      actions: [
        IconButton(
          onPressed: signOut, // Call the signOut function
          icon: const Icon(Icons.logout),
        )
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.grey[700],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Mon compte'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        MyAccountPage()), // Replace LoginPage with your actual login page
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.list), // Icon for Catégories
            title: Text('Mes Abonnements'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.view_agenda), // Icon for Messages
            title: Text('Explorer Catégories'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllMessagesPage(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.chat), // Icon for Chat
            title: Text('Chat'),
            onTap: () {
              // Handle Chat press
            },
          ),
        ],
      ),
    );
  }
}

class YourHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signOut(BuildContext context) async {
    print('Signing out...');
    await _auth.signOut();
    print('Signed out.');
    // After signing out, navigate to LoginPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Replace LoginPage with your actual login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        signOut: () => _signOut(context), // Pass the signOut function
      ),
      drawer: CustomDrawer(),
      body: LoginPage(),
    );
  }
}
