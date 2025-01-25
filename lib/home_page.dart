import 'package:flutter/material.dart';
import 'Weather_page.dart';
import 'news_category_page.dart';
import 'exchange_rates_page.dart';
import 'notes_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  const HomePage({required this.onThemeChanged, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedPage = 'HomePage';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ana Sayıfa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            color: Colors.white,
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
              ),
              child: Text(
                'Listview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(Icons.home, 'Ana Sayıfa', 'HomePage'),
            _buildDrawerItem(Icons.article, 'Haberler', 'NewsCategoryPage'),
            _buildDrawerItem(Icons.cloud, 'Hava Durumu', 'WeatherPage'),
            _buildDrawerItem(
                Icons.attach_money, 'Döviz Kurları', 'ExchangeRatesPage'),
            _buildDrawerItem(Icons.notes, 'Notlar', 'NotesPage'),
            _buildDrawerItem(Icons.settings, 'Ayırları', 'SettingsPage'),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 260,
              backgroundImage: AssetImage('assets/images/osman1.jpg'),
            ),
            SizedBox(height: 20),
            Text(
              'OSMAN MOHAMED ',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, color: Colors.deepOrangeAccent),
                SizedBox(width: 8),
                Text(
                  'Bartin University',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.computer, color: Colors.deepOrangeAccent),
                SizedBox(width: 8),
                Text(
                  'Computer Engineering',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, String page) {
    return ListTile(
      leading: Icon(
        icon,
        color: selectedPage == page ? Colors.deepOrangeAccent : Colors.black,
      ),
      title: Text(title),
      onTap: () {
        setState(() {
          selectedPage = page;
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              switch (page) {
                case 'HomePage':
                  return HomePage(onThemeChanged: widget.onThemeChanged);
                case 'NewsCategoryPage':
                  return NewsCategoryPage();
                case 'WeatherPage':
                  return WeatherPage();
                case 'ExchangeRatesPage':
                  return ExchangeRatesPage();
                case 'NotesPage':
                  return NotesPage();
                case 'SettingsPage':
                  return SettingsPage(onThemeChanged: widget.onThemeChanged);
                default:
                  return HomePage(onThemeChanged: widget.onThemeChanged);
              }
            },
          ),
        );
      },
    );
  }
}
