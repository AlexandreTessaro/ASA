import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewDonatePage extends StatelessWidget {
  const ViewDonatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('User not authenticated'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualizar Doações'),
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
              .collection('donations')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              children: snapshot.data!.docs.map((document) {
                return ListTile(
                  title: Text(document.get('beneficiario') ?? 'Beneficiário não informado', style: const TextStyle(color: Colors.white)),
                  subtitle: Text(document.get('local') ?? 'Local não informado', style: const TextStyle(color: Colors.white70)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationDetailPage(donation: document),
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

class DonationDetailPage extends StatelessWidget {
  final DocumentSnapshot donation;

  const DonationDetailPage({super.key, required this.donation});

  void _deleteDonation(BuildContext context) async {
    try {
      await FirebaseFirestore.instance.runTransaction((Transaction myTransaction) async {
        myTransaction.delete(donation.reference);
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doação deletada com sucesso')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao deletar doação: $e')));
      }
    }
  }

  void _updateDonation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateDonatePage(donation: donation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Doação'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteDonation(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _updateDonation(context),
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
              Text('Local: ${donation.get('local') ?? 'Local não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Beneficiário: ${donation.get('beneficiario') ?? 'Beneficiário não informado'}', style: const TextStyle(color: Colors.white)),
              Text('CPF: ${donation.get('cpf') ?? 'CPF não informado'}', style: const TextStyle(color: Colors.white)),
              Text('RG: ${donation.get('rg') ?? 'RG não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Telefone: ${donation.get('telefone') ?? 'Telefone não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Endereço: ${donation.get('endereco') ?? 'Endereço não informado'}', style: const TextStyle(color: Colors.white)),
              Text('Número de Pessoas na Residência: ${donation.get('numeroPessoasResidencia') ?? 'Número não informado'}', style: const TextStyle(color: Colors.white)),
              const Text('Itens Doação:', style: TextStyle(color: Colors.white)),
              ...((donation.get('itensDoacao') ?? []) as List).map<Widget>((item) {
                return ListTile(
                  title: Text(item['descricao'] ?? 'Descrição não informada', style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${item['unidade'] ?? 'Unidade não informada'} - ${item['quantidade'] ?? 'Quantidade não informada'}', style: const TextStyle(color: Colors.white70)),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateDonatePage extends StatefulWidget {
  final DocumentSnapshot donation;

  const UpdateDonatePage({super.key, required this.donation});

  @override
  UpdateDonatePageState createState() => UpdateDonatePageState();
}

class UpdateDonatePageState extends State<UpdateDonatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _localController;
  late TextEditingController _beneficiarioController;
  late TextEditingController _cpfController;
  late TextEditingController _rgController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _numeroPessoasResidenciaController;
  late List<Item> _itensDoacao;

  @override
  void initState() {
    super.initState();
    _localController = TextEditingController(text: widget.donation.get('local') ?? '');
    _beneficiarioController = TextEditingController(text: widget.donation.get('beneficiario') ?? '');
    _cpfController = TextEditingController(text: widget.donation.get('cpf') ?? '');
    _rgController = TextEditingController(text: widget.donation.get('rg') ?? '');
    _telefoneController = TextEditingController(text: widget.donation.get('telefone') ?? '');
    _enderecoController = TextEditingController(text: widget.donation.get('endereco') ?? '');
    _numeroPessoasResidenciaController = TextEditingController(text: (widget.donation.get('numeroPessoasResidencia') ?? 0).toString());
    _itensDoacao = List<Item>.from((widget.donation.get('itensDoacao') ?? []).map((item) => Item.fromMap(item)));
  }

  void _updateDonation() {
    if (_formKey.currentState!.validate()) {
      try {
        _formKey.currentState!.save();
        final updatedDonation = Donation(
          local: _localController.text,
          data: widget.donation.get('data').toDate(),
          beneficiario: _beneficiarioController.text,
          cpf: _cpfController.text,
          rg: _rgController.text,
          nascimento: widget.donation.get('nascimento').toDate(),
          telefone: _telefoneController.text,
          endereco: _enderecoController.text,
          numeroPessoasResidencia: int.parse(_numeroPessoasResidenciaController.text),
          itensDoacao: _itensDoacao,
        );
        FirebaseFirestore.instance.runTransaction((transaction) async {
          transaction.update(widget.donation.reference, updatedDonation.toMap());
        }).then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Doação atualizada com sucesso')));
            Navigator.pop(context);
          }
        }).catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar doação: $error')));
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao atualizar doação: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar Doação'),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _localController,
                  decoration: const InputDecoration(
                    labelText: 'Local',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o local';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _beneficiarioController,
                  decoration: const InputDecoration(
                    labelText: 'Beneficiário',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o beneficiário';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(
                    labelText: 'CPF',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o CPF';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _rgController,
                  decoration: const InputDecoration(
                    labelText: 'RG',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o RG';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                    labelText: 'Telefone',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o telefone';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(
                    labelText: 'Endereço',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o endereço';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _numeroPessoasResidenciaController,
                  decoration: const InputDecoration(
                    labelText: 'Número de Pessoas na Residência',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o número de pessoas na residência';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor, insira um número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Itens Doação',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                ..._itensDoacao.asMap().entries.map((entry) {
                  int index = entry.key;
                  Item item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: item.descricao,
                            decoration: const InputDecoration(
                              labelText: 'Descrição',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                item.descricao = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a descrição';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.unidade,
                            decoration: const InputDecoration(
                              labelText: 'Unidade',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            onChanged: (value) {
                              setState(() {
                                item.unidade = value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a unidade';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            initialValue: item.quantidade.toString(),
                            decoration: const InputDecoration(
                              labelText: 'Quantidade',
                              labelStyle: TextStyle(color: Colors.white),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              setState(() {
                                item.quantidade = int.tryParse(value) ?? 0;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira a quantidade';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Por favor, insira um número válido';
                              }
                              return null;
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _itensDoacao.removeAt(index);
                            });
                          },
                        ),
                      ],
                    ),
                  );
                }),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _itensDoacao.add(Item(descricao: '', unidade: '', quantidade: 0));
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Adicionar Item'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Atualizar Doação'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Donation {
  String local;
  DateTime data;
  String beneficiario;
  String cpf;
  String rg;
  DateTime nascimento;
  String telefone;
  String endereco;
  int numeroPessoasResidencia;
  List<Item> itensDoacao;

  Donation({
    required this.local,
    required this.data,
    required this.beneficiario,
    required this.cpf,
    required this.rg,
    required this.nascimento,
    required this.telefone,
    required this.endereco,
    required this.numeroPessoasResidencia,
    required this.itensDoacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'local': local,
      'data': data,
      'beneficiario': beneficiario,
      'cpf': cpf,
      'rg': rg,
      'nascimento': nascimento,
      'telefone': telefone,
      'endereco': endereco,
      'numeroPessoasResidencia': numeroPessoasResidencia,
      'itensDoacao': itensDoacao.map((item) => item.toMap()).toList(),
    };
  }
}

class Item {
  String descricao;
  String unidade;
  int quantidade;

  Item({
    required this.descricao,
    required this.unidade,
    required this.quantidade,
  });

  Map<String, dynamic> toMap() {
    return {
      'descricao': descricao,
      'unidade': unidade,
      'quantidade': quantidade,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      descricao: map['descricao'] ?? '',
      unidade: map['unidade'] ?? '',
      quantidade: map['quantidade'] ?? 0,
    );
  }
}
