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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
        backgroundColor: Colors.grey[300],
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0),
          child: SvgPicture.asset(
            'images/logo.svg',
            fit: BoxFit.contain,
          ),
        ),
        title: Text(
          'PovertyLens',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.notifications_none, color: Colors.black),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed('/rekap_data');
              },
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(16.0),
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
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                final parentState = context.findAncestorStateOfType<_HomeScreenState>();
                parentState?.setState(() {
                  parentState._selectedIndex = 1; 
                });
              },
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[200],
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0, right: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pindai Wilayahmu Disini',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.qr_code_scanner),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20,),
            Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16.0)
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'inisiatif teknologi untuk menganalisis dan memetakan kemiskinan, menggunakan data terkini dan alat visualisasi. Program ini membantu pemangku kepentingan dalam merancang intervensi yang tepat sasaran, dengan tujuan akhir menciptakan kesejahteraan dan keadilan bagi semua lapisan masyarakat.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
