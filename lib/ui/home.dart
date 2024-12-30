import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:poverty_lens/ui/pindai.dart';
import 'lembaga.dart';
import 'rekap_data.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final http.Client? httpClient;

  HomeScreen({this.httpClient});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _tahun = [];
  List<double> _presentasePendudukMiskin = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _homeNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _pindaiNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _lembagaNavigatorKey =
      GlobalKey<NavigatorState>();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == '/')
            return MaterialPageRoute(
                builder: (context) => HomeScreenContent(
                      isLoading: _isLoading,
                      tahun: _tahun,
                      presentasePendudukMiskin: _presentasePendudukMiskin,
                    ));
          if (settings.name == '/rekap_data')
            return MaterialPageRoute(builder: (context) => RekapDataScreen());
          return null;
        },
      ),
      Navigator(
        key: _pindaiNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => PindaiScreen());
        },
      ),
      Navigator(
        key: _lembagaNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => LembagaScreen());
        },
      ),
    ]);
    _fetchKemiskinanData();
  }

  Future<void> _fetchKemiskinanData() async {
    final url = Uri.parse('http://127.0.0.1:5000/api/data-kemiskinan');
    try {
      final response = await (widget.httpClient ?? http.Client()).get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          _tahun = data.map((item) => item['tahun'].toString()).toList();
          _presentasePendudukMiskin = data.map((item) {
            final value = item['presentase_penduduk_miskin'];
            return (value != null && value != "")
                ? double.tryParse(value) ?? 0.0
                : 0.0;
          }).toList();
          print("Loading selesai, data siap ditampilkan.");
          _isLoading = false;

          // Tambahkan log untuk memvalidasi data
          print('Tahun: $_tahun');
          print('Presentase Penduduk Miskin: $_presentasePendudukMiskin');
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 1) {
        _pindaiNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 2) {
        _lembagaNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        height: 56,
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 208, 232, 197),
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
                icon: _selectedIndex == 0
                    ? const Icon(
                        Icons.home_filled,
                        color: Colors.black,
                        size: 30,
                      )
                    : const Icon(
                        Icons.home_outlined,
                        color: Colors.black,
                        size: 30,
                      )),
            IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                icon: _selectedIndex == 1
                    ? const Icon(
                        Icons.search,
                        color: Colors.black,
                        size: 30,
                      )
                    : const Icon(
                        Icons.search_outlined,
                        color: Colors.black,
                        size: 30,
                      )),
            IconButton(
                enableFeedback: false,
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
                icon: _selectedIndex == 2
                    ? const Icon(
                        Icons.people,
                        color: Colors.black,
                        size: 30,
                      )
                    : const Icon(
                        Icons.people,
                        color: Colors.black,
                        size: 30,
                      )),
          ],
        ),
      ),
    );
  }
}

final List<String> imageUrls = [
  'https://via.placeholder.com/600x400/FF5733/FFFFFF?text=Slide+1',
  'https://via.placeholder.com/600x400/33FF57/FFFFFF?text=Slide+2',
  'https://via.placeholder.com/600x400/3357FF/FFFFFF?text=Slide+3',
  'https://via.placeholder.com/600x400/FF33A1/FFFFFF?text=Slide+4',
];

class HomeScreenContent extends StatelessWidget {
  final bool isLoading;
  final List<String> tahun;
  final List<double> presentasePendudukMiskin;

  HomeScreenContent({
    required this.isLoading,
    required this.tahun,
    required this.presentasePendudukMiskin,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(125.0),
        child: AppBar(
            toolbarHeight: 125.0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            )),
            backgroundColor: Color.fromARGB(255, 208, 232, 197),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 4.0, bottom: 8.0),
                      child: Image.asset(
                        'static/images/logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    Text(
                      'PovertyLens',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Hai, Selamat Datang Povers!',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RekapDataScreen()));
                  },
                  icon: Icon(
                    Icons.insert_chart,
                    color: Colors.white,
                    size: 14,
                  ),
                  label: Text(
                    "Rekap Data",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: Size(100, 32),
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
              ),
            ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(right: 4.0, left: 4.0, top: 0, bottom: 0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(165, 244, 67, 54),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(1, 1))
                    ]),
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Grafik Presentase Penduduk Miskin',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            height: 150,
                            child: isLoading
                                ? Center(child: CircularProgressIndicator())
                                : (tahun.isEmpty || presentasePendudukMiskin.isEmpty)
                                    ? Center(
                                        child: Text(
                                            'Tidak ada data untuk ditampilkan'))
                                    : BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY:
                                              presentasePendudukMiskin.reduce((a, b) => a > b ? a : b) + 10, // Tambahkan margin pada sumbu Y
                                          titlesData: FlTitlesData(
                                            leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                reservedSize: 40,
                                                getTitlesWidget: (value, meta) {
                                                  return Text(
                                                      '${value.toInt()}%');
                                                },
                                              ),
                                            ),
                                            bottomTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                getTitlesWidget: (value, meta) {
                                                  if (value.toInt() <
                                                      tahun.length) {
                                                    return Text(tahun[value.toInt()]);
                                                  }
                                                  return Text('');
                                                },
                                              ),
                                            ),
                                          ),
                                          gridData: FlGridData(show: true),
                                          barGroups: presentasePendudukMiskin
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final value = entry.value;
                                            return BarChartGroupData(
                                              x: index,
                                              barRods: [
                                                BarChartRodData(
                                                  toY: value,
                                                  color: Colors.orange,
                                                  width: 16,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                              ],
                                            );
                                          }).toList(),
                                          borderData: FlBorderData(show: false),
                                        ),
                                      ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 60,
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 208, 232, 197),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 6,
                          offset: Offset(2, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'Inisiatif teknologi untuk menganalisis dan memetakan kemiskinan, menggunakan data terkini dan alat visualisasi. Program ini membantu pemangku kepentingan dalam merancang intervensi yang tepat sasaran, dengan tujuan akhir menciptakan kesejahteraan dan keadilan bagi semua lapisan masyarakat.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -30,
                    left: 0,
                    right: 0,
                    child: Container(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Image.asset(
                              'images/logo.png',
                              width: 45,
                              height: 45,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Text(
                            "PovertyLens",
                            style: TextStyle(
                              backgroundColor: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitur AI PovertyLens',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Fitur uta  ma dari Poverty Lens adalah kemampuan untuk mengunggah gambar tangkapan layar (screenshot) peta atau maps yang disertai dengan teks pertanyaan dari pengguna. Fitur ini memanfaatkan teknologi kecerdasan buatan (AI) untuk menganalisis peta atau gambar yang diunggah dan menjawab pertanyaan yang diajukan.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        'Lihat Selengkapnya',
                        style: TextStyle(
                          color: Color(0xFFC95B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Pakai Fitur AI PovertyLens',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '1. Siapkan screenshot peta atau maps yang ingin kamu tanyakan.\n'
                      '2. Upload file screenshot dan ketik pertanyaanmu di kolom yang tersedia.\n'
                      '3. Setelah itu, AI kita yang super canggih akan langsung menganalisis pertanyaanmu!\n'
                      '4. Kamu tinggal duduk manis sambil nunggu jawabannya keluar.\n'
                      '5. Selamat mencoba dari Mimin Ganteng!',
                      style: TextStyle(color: Color(0xFFC95B1B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
