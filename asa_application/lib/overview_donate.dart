import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OverviewDonatePage extends StatelessWidget {
  const OverviewDonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visão Geral das Doações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('donations').where('userId', isEqualTo: user.uid).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final donations = snapshot.data!.docs;
              final totalDonations = donations.length;
              final items = <String, int>{};

              // Processar os itens de doação
              for (var doc in donations) {
                for (var item in doc.get('itensDoacao') ?? []) {
                  final itemName = item['descricao'];
                  final itemQuantity = item['quantidade'];
                  if (items.containsKey(itemName)) {
                    items[itemName] = items[itemName]! + (itemQuantity as int);
                  } else {
                    items[itemName] = itemQuantity as int;
                  }
                }
              }

              return Column(
                children: <Widget>[
                  const SizedBox(height: 100), // Adiciona espaço vertical
                  Text('Total de Doações: $totalDonations', style: const TextStyle(fontSize: 24, color: Colors.white)),
                  const SizedBox(height: 20),
                  const Text('Itens Disponíveis para Doação:', style: TextStyle(fontSize: 20, color: Colors.white)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      children: items.entries.map((entry) {
                        return ListTile(
                          title: Text(entry.key, style: const TextStyle(color: Colors.white)),
                          trailing: Text(entry.value.toString(), style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
