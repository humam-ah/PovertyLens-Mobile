import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_svg/svg.dart';
import 'package:poverty_lens/ui/chatbot.dart';
import 'package:poverty_lens/ui/pindai.dart';
import 'lembaga.dart';
import 'rekap_data.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final http.Client? httpClient;

  const HomeScreen({super.key, this.httpClient});

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
  final GlobalKey<NavigatorState> _chatbotNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _pindaiNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _lembagaNavigatorKey =
      GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _rekapNavigatorKey =
      GlobalKey<NavigatorState>();

  final List<Widget> _pages = [];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController ulasanController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == '/') {
            return MaterialPageRoute(
                builder: (context) => HomeScreenContent(
                      isLoading: _isLoading,
                      tahun: _tahun,
                      presentasePendudukMiskin: _presentasePendudukMiskin,
                      emailController: emailController,
                      ulasanController: ulasanController,
                      submitForm: _submitForm,
                    ));
          }
          if (settings.name == '/rekap_data') {
            return MaterialPageRoute(
                builder: (context) => const RekapDataScreen());
          }
          return null;
        },
      ),
      Navigator(
        key: _chatbotNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => ChatPage());
        },
      ),
      Navigator(
        key: _pindaiNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const PindaiScreen());
        },
      ),
      Navigator(
        key: _lembagaNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const LembagaScreen());
        },
      ),
      Navigator(
        key: _rekapNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
              builder: (context) => const RekapDataScreen());
        },
      )
    ]);
    _fetchKemiskinanData();
  }

  Future<void> _submitForm() async {
    final email = emailController.text.trim();
    final ulasan = ulasanController.text.trim();

    if (email.isEmpty || ulasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Semua field harus diisi!")),
      );
      return;
    }

    final url =
        Uri.parse('https://sound-prompt-crawdad.ngrok-free.app/add_ulasan');
    final response = await http.post(
      url,
      body: {'email': email, 'ulasan': ulasan},
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ulasan berhasil dikirim!")),
      );
      emailController.clear();
      ulasanController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengirim ulasan!")),
      );
    }
  }

  Future<void> _fetchKemiskinanData() async {
    final url = Uri.parse('https://povertylens.my.id/api/data-kemiskinan');
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
        _chatbotNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 2) {
        _pindaiNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 3) {
        _lembagaNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 4) {
        _rekapNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: isLandscape
          ? null
          : Container(
              height: 56,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 22, 163, 74),
                  borderRadius: BorderRadius.circular(45)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    key: Key("home-icon"),
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                      });
                    },
                    iconSize: 28,
                    icon: _selectedIndex == 0
                        ? SvgPicture.asset(
                            'assets/images/home.svg', // SVG ketika dipilih
                            width: 28,
                            height: 28,
                          )
                        : SvgPicture.asset(
                            'assets/images/home.svg', // SVG ketika tidak dipilih
                            width: 28,
                            height: 28,
                            color: Colors.white,
                          ),
                  ),
                  IconButton(
                    key: Key("chatbot-icon"),
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 1;
                      });
                    },
                    iconSize: 28,
                    icon: _selectedIndex == 1
                        ? SvgPicture.asset(
                            'assets/images/chatbot.svg', // SVG ketika dipilih
                            width: 28,
                            height: 28,
                          )
                        : SvgPicture.asset(
                            'assets/images/chatbot.svg', // SVG ketika tidak dipilih
                            width: 28,
                            height: 28,
                            color: Colors.white,
                          ),
                  ),
                  IconButton(
                    key: Key("pindai-icon"),
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                    iconSize: 28,
                    icon: _selectedIndex == 2
                        ? SvgPicture.asset(
                            'assets/images/pindai.svg', // SVG ketika dipilih
                            width: 28,
                            height: 28,
                          )
                        : SvgPicture.asset(
                            'assets/images/pindai.svg', // SVG ketika tidak dipilih
                            width: 28,
                            height: 28,
                            color: Colors.white,
                          ),
                  ),
                  IconButton(
                    key: Key("lembaga-icon"),
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                    iconSize: 28,
                    icon: _selectedIndex == 3
                        ? SvgPicture.asset(
                            'assets/images/lembaga.svg', // SVG ketika dipilih
                            width: 28,
                            height: 28,
                          )
                        : SvgPicture.asset(
                            'assets/images/lembaga.svg', // SVG ketika tidak dipilih
                            width: 28,
                            height: 28,
                            color: Colors.white,
                          ),
                  ),
                  IconButton(
                    key: Key("rekap-icon"),
                    enableFeedback: false,
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 4;
                      });
                    },
                    iconSize: 28,
                    icon: _selectedIndex == 4
                        ? SvgPicture.asset(
                            'assets/images/rekap.svg', // SVG ketika dipilih
                            width: 28,
                            height: 28,
                          )
                        : SvgPicture.asset(
                            'assets/images/rekap.svg', // SVG ketika tidak dipilih
                            width: 28,
                            height: 28,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  final bool isLoading;
  final List<String> tahun;
  final List<double> presentasePendudukMiskin;
  final TextEditingController emailController;
  final TextEditingController ulasanController;
  final Future<void> Function() submitForm;

  const HomeScreenContent({
    super.key,
    required this.isLoading,
    required this.tahun,
    required this.presentasePendudukMiskin,
    required this.emailController,
    required this.ulasanController,
    required this.submitForm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(125.0),
        child: AppBar(
            toolbarHeight: 125.0,
            automaticallyImplyLeading: false,
            flexibleSpace: Container(),
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            )),
            backgroundColor: const Color.fromARGB(255, 22, 163, 74),
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
                    const Text(
                      'PovertyLens',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
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
                        builder: (context) => const RekapDataScreen()));
                  },
                  icon: const Icon(
                    Icons.insert_chart,
                    color: Colors.white,
                    size: 14,
                  ),
                  label: const Text(
                    "Rekap Data",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      minimumSize: const Size(100, 32),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8)),
                ),
              ),
            ]),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(right: 4.0, left: 4.0, top: 0, bottom: 0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 305,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: const [
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
                          const Text(
                            'Persentase Penduduk Miskin',
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold
                            ),
                          ),
                          const Text(
                            'Kota Tegal',
                            style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pinkAccent 
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 175,
                            child: isLoading
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : (tahun.isEmpty ||
                                        presentasePendudukMiskin.isEmpty)
                                    ? const Center(
                                        child: Text(
                                            'Tidak ada data untuk ditampilkan'))
                                    : BarChart(
                                        BarChartData(
                                          alignment:
                                              BarChartAlignment.spaceAround,
                                          maxY: presentasePendudukMiskin.reduce(
                                                  (a, b) => a > b ? a : b) +
                                              3, // Tambahkan margin pada sumbu Y
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
                                                    return Transform.rotate(
                                                      angle: -75 *
                                                          3.14159265359 /
                                                          180, // Rotasi -90 derajat
                                                      child: Text(
                                                        tahun[value.toInt()],
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(fontSize: 10),
                                                      ),
                                                    );
                                                  }
                                                  return const Text('');
                                                },
                                              ),
                                            ),
                                            topTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                            rightTitles: AxisTitles(
                                              sideTitles:
                                                  SideTitles(showTitles: false),
                                            ),
                                          ),
                                          gridData:
                                              const FlGridData(show: true),
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
                                                  width: 8,
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
              const SizedBox(
                height: 60,
              ),
              Container(
                height: 400,
                width: double.maxFinite,
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        width: double.maxFinite,
                        height: double.maxFinite,
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/img_subtract.png'),
                            fit: BoxFit.fill,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/logo.png",
                                    height: 18,
                                    width: 36,
                                  ),
                                  SizedBox(
                                    width: 4,
                                  ),
                                  Text(
                                    "PovertyLens",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 28,
                            ),
                            Container(
                              height: 150,
                              width: double.maxFinite,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  image: DecorationImage(
                                      image:
                                          AssetImage("assets/images/img15.png"),
                                      fit: BoxFit.fill)),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            Container(
                              width: double.maxFinite,
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "Inisiatif teknologi untuk menganalisis dan memetakan kemiskinan, menggunakan data terkini dan alat visualisasi. Program ini membantu pemangku kepentingan dalam merancang intervensi yang tepat sasaran, dengan tujuan akhir menciptakan kesejahteraan dan keadilan bagi semua lapisan masyarakat.",
                                maxLines: 8,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontWeight: FontWeight.normal),
                                textAlign: TextAlign.justify,
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
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
                      'Fitur utama dari Poverty Lens adalah kemampuan untuk mengunggah gambar tangkapan layar (screenshot) peta atau maps yang disertai dengan teks pertanyaan dari pengguna. Fitur ini memanfaatkan teknologi kecerdasan buatan (AI) untuk menganalisis peta atau gambar yang diunggah dan menjawab pertanyaan yang diajukan.',
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
              const SizedBox(
                height: 20,
              ),
              //Komentar Pengguna
              Container(
                padding: const EdgeInsets.all(16.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tinggalkan Komentar Anda',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: ulasanController,
                      decoration: const InputDecoration(
                        labelText: 'Komentar',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                        onPressed: submitForm,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 255, 152, 0)),
                        child: const Text(
                          'Kirim',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 64,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
