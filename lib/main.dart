import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const CekKuotaApp());
}

class CekKuotaApp extends StatelessWidget {
  const CekKuotaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XL Kuota Checker',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue.shade800),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  final _nomorController = TextEditingController(text: '087');
  Map<String, dynamic>? _apiData;
  bool _isLoading = false;
  String _errorMessage = '';

  // Fungsi Utama untuk Fetch Data dari API
  Future<void> _fetchKuota() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _apiData = null;
    });

    final nomor = _nomorController.text.trim();
    if (nomor.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Nomor tidak boleh kosong';
      });
      return;
    }

    final url = Uri.parse('https://orkut.biz.id/api/myxl?nomor=$nomor');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['ok'] == true && responseData['data'] != null) {
          setState(() {
            _apiData = responseData['data'];
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'Data tidak ditemukan atau format salah';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal terhubung ke internet. Coba lagi.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final subsInfo = _apiData?['subs_info'];
    final packages = _apiData?['package_info']?['packages'] as List<dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sidompul Jadi Jadian',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true, // Membuat judul di tengah
        backgroundColor:
            Colors.blue.shade900, // Warna biru lebih gelap khas Sidompul
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Nomor HP
            TextField(
              controller: _nomorController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Masukkan Nomor XL',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _isLoading ? null : _fetchKuota,
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Tombol Cek
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _fetchKuota,
                icon: const Icon(Icons.refresh),
                label: const Text('Cek Kuota Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Loading Indicator
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // Error Message
            if (_errorMessage.isNotEmpty)
              Center(
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),

            // Jika Data API Berhasil Dimuat
            if (_apiData != null && !_isLoading) ...[
              SizedBox(
                width: double.infinity, // Memastikan lebar penuh
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header Kartu
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade800,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'INFORMASI PELANGGAN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Isi Kartu
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.person,
                              'Operator',
                              '${subsInfo?['operator']} (${subsInfo?['net_type']})',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.calendar_month,
                              'Masa Aktif',
                              '${subsInfo?['exp_date']}',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.warning_amber,
                              'Masa Tenggang',
                              '${subsInfo?['grace_until']}',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              Icons.history,
                              'Tenure',
                              '${subsInfo?['tenure']}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Daftar Paket & Kuota Aktif:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // Daftar Paket Loop Dinamis
              if (packages != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final pkt = packages[index];
                    final quotas = pkt['quotas'] as List<dynamic>?;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkt['name'] ?? 'Nama Paket',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              'Expired: ${pkt['expiry'] ?? "-"}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const Divider(),
                            if (quotas != null)
                              ...quotas.map((q) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Tambahkan Expanded di sini agar teks panjang otomatis turun ke bawah
                                        Expanded(
                                          child: Text(
                                            q['name'] ?? 'Kuota',
                                            maxLines:
                                                2, // Maksimal 2 baris jika terlalu panjang
                                            overflow:
                                                TextOverflow
                                                    .ellipsis, // Kalau super panjang, ujungnya jadi titik-titik (...)
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ), // Beri sedikit jarak aman agar tidak menempel
                                        Text(
                                          '${q['remaining']} / ${q['total']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    LinearProgressIndicator(
                                      value: (((q['percent'] ?? 0) as num)
                                                  .toDouble() /
                                              100)
                                          .clamp(0.0, 1.0),
                                      backgroundColor: Colors.grey.shade200,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }
}
