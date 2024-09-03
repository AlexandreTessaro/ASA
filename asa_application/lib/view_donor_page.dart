import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'donor_detail_page.dart';

class ViewDonorPage extends StatelessWidget {
  const ViewDonorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Doadores'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey, Colors.black],
          ),
        ),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('donors')
              .where('userId', isEqualTo: user.uid)  // Filter by current user's ID
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: snapshot.data!.docs.map((document) {
                return ListTile(
                  title: Text(
                    document.get('name') ?? 'Nome não informado',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    document.get('email') ?? 'Email não informado',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonorDetailPage(donor: document),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
