import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_donate.dart';
import 'overview_donate.dart';
import 'signin.dart';
import 'view_donate.dart';
import 'register_donor.dart';
import 'view_donor_page.dart'; 
import 'report_donations_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Homepage'),
        backgroundColor: Colors.transparent,
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
                color: Colors.blueGrey,
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('Olá, o que deseja fazer?', style: TextStyle(fontSize: 24, color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterDonatePage()),
                  );
                },
                child: const Text('Cadastrar Doações'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewDonatePage()),
                  );
                },
                child: const Text('Visualizar Doações'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OverviewDonatePage()),
                  );
                },
                child: const Text('Visão Geral das Doações'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterDonorPage()),
                  );
                },
                child: const Text('Registrar Doador'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewDonorPage()), // Navigation to ViewDonorPage
                  );
                },
                child: const Text('Visualizar Doadores'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportDonationsPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Gerar Relatório de Doações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
