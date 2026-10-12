import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Studio AI',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _apiKey = 'AQ.Ab8RN6IxzojsXXxCh84QE7-cgt4NiowZSVueFrAtz7HDRPzxBA';

  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _platformController = TextEditingController();

  String _result = '';
  bool _isLoading = false;

  Future<void> _generateScript() async {
    if (_topicController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = '';
    });

    final String prompt = '''
Buatkan skrip video lengkap, judul menarik, dan caption untuk platform ${_platformController.text}.
Topik/Konsep: ${_topicController.text}
Format:
- Judul Video
- Naskah / Skrip (beserta instruksi visual)
- Caption & Tagar
Gunakan bahasa yang santai, komunikatif, dan menarik penonton.
''';

    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        setState(() {
          _result = text;
        });
      } else {
        setState(() {
          _result = 'Gagal mengambil respons dari AI (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Terjadi kesalahan koneksi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generator Naskah Konten AI'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _platformController,
                decoration: const InputDecoration(
                  labelText: 'Platform (contoh: TikTok, FB)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _topicController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Ide/Topik Konten',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generateScript,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isLoading ? 'Membuat Naskah...' : 'Buat Naskah Sekarang'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    _result,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
