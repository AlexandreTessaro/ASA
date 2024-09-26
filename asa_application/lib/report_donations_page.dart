import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportDonationsPage extends StatefulWidget {
  const ReportDonationsPage({super.key});

  @override
  ReportDonationsPageState createState() => ReportDonationsPageState();
}

class ReportDonationsPageState extends State<ReportDonationsPage> {
  final _formKey = GlobalKey<FormState>();
  DateTimeRange? _selectedDateRange;
  String? _selectedDonorName;

  Future<void> _generateReport() async {
    if (_formKey.currentState!.validate()) {
      Query query = FirebaseFirestore.instance.collection('donations');

      // Apply donor filter by name (use 'beneficiario' field)
      if (_selectedDonorName != null && _selectedDonorName!.isNotEmpty) {
        query = query.where('beneficiario', isEqualTo: _selectedDonorName); // Match by 'beneficiario'
      }

      // Apply date range filter if selected
      if (_selectedDateRange != null) {
        // Extend the end date to cover the entire day until 23:59:59
        DateTime startDate = _selectedDateRange!.start;
        DateTime endDate = _selectedDateRange!.end.add(const Duration(hours: 23, minutes: 59, seconds: 59));

        query = query
            .where('data', isGreaterThanOrEqualTo: startDate)
            .where('data', isLessThanOrEqualTo: endDate);
      }

      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nenhuma doação encontrada para os filtros aplicados.')),
        );
      } else {
        _generatePDF(snapshot.docs);
      }
    }
  }

  Future<void> _generatePDF(List<QueryDocumentSnapshot> donations) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Relatório de Doações', style: const pw.TextStyle(fontSize: 24)),
            ),
            if (_selectedDateRange != null)
              pw.Text(
                'Período: ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                style: const pw.TextStyle(fontSize: 16),
              ),
            if (_selectedDonorName != null && _selectedDonorName!.isNotEmpty)
              pw.Text('Doador: $_selectedDonorName', style: const pw.TextStyle(fontSize: 16)),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              headers: ['Data', 'Beneficiário', 'Local', 'Itens Doação', 'Total de Itens'],
              data: donations.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final items = (data['itensDoacao'] as List<dynamic>?)
                    ?.map((item) => item['descricao'] ?? 'Não informado')
                    .join(', ') ?? 'Não informado';
                final totalItems = data['itensDoacao'] != null
                    ? data['itensDoacao'].length.toString()
                    : '0';
                return [
                  DateFormat('dd/MM/yyyy').format((data['data'] as Timestamp?)?.toDate() ?? DateTime.now()),
                  data['beneficiario'] ?? 'Não informado',
                  data['local'] ?? 'Não informado',
                  items,
                  totalItems,
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Doações'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey, Colors.black],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Date Range Picker
              GestureDetector(
                onTap: () async {
                  final DateTimeRange? picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _selectedDateRange,
                  );
                  if (picked != null && picked != _selectedDateRange) {
                    setState(() {
                      _selectedDateRange = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[800],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.date_range, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDateRange == null
                            ? 'Selecionar Período'
                            : '${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MM/yyyy').format(_selectedDateRange!.end)}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Donor Selector Dropdown
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('donors').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  final donors = snapshot.data!.docs;
                  return DropdownButtonFormField<String>(
                    value: _selectedDonorName,
                    items: donors.map((doc) {
                      return DropdownMenuItem<String>(  // Explicitly declare type String
                        value: doc['name'] as String,  // Ensure it is cast to String
                        child: Text(doc['name'] as String),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDonorName = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Selecionar Doador',
                      labelStyle: TextStyle(color: Colors.white),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  );
                },
              ),
              const SizedBox(height: 20),
              // Generate Report Button
              ElevatedButton(
                onPressed: _generateReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Gerar Relatório'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
