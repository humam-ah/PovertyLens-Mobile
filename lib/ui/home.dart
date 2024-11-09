import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'pindai.dart';
import 'lembaga.dart';
import 'rekap_data.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<NavigatorState> _lembagaNavigatorKey = GlobalKey<NavigatorState>();

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      Navigator(
        key: _homeNavigatorKey,
        onGenerateRoute: (settings) {
          if (settings.name == '/')
            return MaterialPageRoute(builder: (context) => HomeScreenContent());
          if (settings.name == '/rekap_data')
            return MaterialPageRoute(builder: (context) => RekapDataScreen());
          return null;
        },
      ),
      PindaiScreen(),
      Navigator(
        key: _lembagaNavigatorKey,
        onGenerateRoute: (settings) {
          return MaterialPageRoute(builder: (context) => LembagaScreen());
        },
      ),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _homeNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      } else if (index == 2) {
        _lembagaNavigatorKey.currentState?.popUntil((route) => route.isFirst);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromARGB(25, 254, 1, 84),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 30,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '',
          ),
        ],
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(25, 254, 1, 84),
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 0.0, top: 8.0, bottom: 8.0),
          child: Image.asset(
            'images/logo.png',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'PovertyLens',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RekapDataScreen()
                  )
                );
              },
              icon: Icon(Icons.insert_chart, color: Colors.white, size: 14,),
              label: Text("Rekap Data", style: TextStyle(color: Colors.white, fontSize: 10),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: Size(100, 24),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)
              ),
            ),
          ),
        ]  
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(right: 4.0, left: 4.0, top: 0, bottom: 0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  final parentState = context.findAncestorStateOfType<_HomeScreenState>();
                  parentState?.setState(() {
                    parentState._selectedIndex = 1; 
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFE0154),
                        Color(0xFFC95B1B),
                        Color(0xFF980132),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pindai Wilayahmu Disini',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Icon(Icons.qr_code_scanner, color: Colors.white,),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromARGB(165, 244, 67, 54),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(1, 1)
                      )
                    ]
                  ),
                  padding: const EdgeInsets.all(16.0),
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        'Data Index Kemiskinan',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    const months = [
                                      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 
                                      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
                                    ];
                                    return Text(months[value.toInt()]);
                                  },
                                  reservedSize: 30,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    return Text('${value.toInt()}%');
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(12, (index) {
                              final yValue = (index + 1) * 7 % 100; 
                              return BarChartGroupData(
                                x: index,
                                barRods: [
                                  BarChartRodData(
                                    toY: yValue.toDouble(),
                                    color: Colors.orange,
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 60,),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                    top: -40, 
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color.fromARGB(179, 255, 245, 245),
                      child: Image.asset(
                        'images/logo.png', 
                        width: 50, 
                        height: 50,
                        fit: BoxFit.contain,
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
                      'Fitur utama dari Poverty Lens adalah kemampuan untuk mengunggah gambar tangkapan layar (screenshot) peta atau maps yang disertai dengan teks pertanyaan dari pengguna. Fitur ini memanfaatkan teknologi kecerdasan buatan (AI) untuk menganalisis peta atau gambar yang diunggah dan menjawab pertanyaan yang diajukan.',
                      style: TextStyle(color: Colors.black54),
                    ),
                    SizedBox(height: 10,),
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
              SizedBox(height: 20,),
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
