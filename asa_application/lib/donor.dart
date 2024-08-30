import 'package:cloud_firestore/cloud_firestore.dart';

class Donor {
  final String name;
  final String email;
  final String phone;
  final String userId;
  final String cpf;
  final String rg;
  final String birth;
  final String address;
  final String numberPersonHouse;

  Donor({
    required this.name,
    required this.email,
    required this.phone,
    required this.userId,
    required this.cpf,
    required this.rg,
    required this.birth,
    required this.address,
    required this.numberPersonHouse
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'userId': userId,
      'cpf': cpf,
      'rg': rg,
      'birth': birth,
      'address': address,
      'numberPersonHouse': numberPersonHouse
    };
  }

  static Future<void> registerDonor(Donor donor) async {
    try {
      await FirebaseFirestore.instance.collection('donors').add(donor.toMap());
    } catch (e) {
      throw Exception('Failed to register donor: $e');
    }
  }
}
