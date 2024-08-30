import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'update_donor_page.dart';

class DonorDetailPage extends StatelessWidget {
  final DocumentSnapshot donor;

  const DonorDetailPage({super.key, required this.donor});

  void _deleteDonor(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
        myTransaction.delete(donor.reference);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doador deletado com sucesso')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao deletar doador: $e')));
      }
    }
  }

  void _updateDonor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateDonorPage(donor: donor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Doador'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteDonor(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _updateDonor(context),
          ),
        ],
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: <Widget>[
              Text('Nome: ${donor.get('name') ?? 'Nome não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Email: ${donor.get('email') ?? 'Email não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Telefone: ${donor.get('phone') ?? 'Telefone não informado'}', style: const TextStyle(color: Colors.white)),
              Text('CPF: ${donor.get('cpf') ?? 'CPF não informado'}', style: const TextStyle(color: Colors.white)),
              Text('RG: ${donor.get('rg') ?? 'RG não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Nascimento: ${donor.get('birth') ?? 'Data de nascimento não informada'}', style: const TextStyle(color: Colors.white)),
              Text('Endereço: ${donor.get('address') ?? 'Endereço não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Número de Pessoas na Residência: ${donor.get('numberPersonHouse') ?? 'Número não informado'}', style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
