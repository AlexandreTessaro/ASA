import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_donate.dart';
import 'overview_donate.dart';
import 'signin.dart';
import 'view_donate.dart';
import 'register_donor.dart';
import 'view_donor_page.dart';
import 'report_donations_page.dart';
import 'app_colors.dart';  // Importa a paleta de cores usada no login

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterDonatePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewDonatePage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const OverviewDonatePage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RegisterDonorPage()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ViewDonorPage()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReportDonationsPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Homepage'),
        backgroundColor: AppColors.text,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(FirebaseAuth.instance.currentUser?.displayName ?? 'Usuário'),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? 'Email não disponível'),
              currentAccountPicture: CircleAvatar(
                child: Text(
                  FirebaseAuth.instance.currentUser?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: const BoxDecoration(
                color: AppColors.accent,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Informações do Usuário'),
              onTap: () {
                // Ação ao tocar em Informações do Usuário
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Deslogar'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.primaryDark, // Replaced gradient with solid color
        child: Center(
          child: Text(
            'Escolha uma opção abaixo',
            style: TextStyle(
              color: AppColors.secondary,
              fontSize: isMobile ? 20 : 28,  // Responsive font size
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Ensures background color is applied
        backgroundColor: AppColors.accent,
        unselectedItemColor: AppColors.text,
        selectedItemColor: AppColors.primary,
        iconSize: isMobile ? 24 : 30,  // Adjust icon size based on screen width
        selectedFontSize: isMobile ? 14 : 16,
        unselectedFontSize: isMobile ? 12 : 14,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Cadastrar Doações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Visualizar Doações',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Visão Geral',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Registrar Doador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Visualizar Doadores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Relatório',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
