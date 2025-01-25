import 'package:flutter/material.dart';
import 'news_page.dart';

class NewsCategoryPage extends StatelessWidget {
  final List<String> categories = [
    'Gundem',
    'Turkiye',
    'Dunya',
    'Ekonomi',
    'Spor',
  ]; // haber türleri

  final Map<String, IconData> categoryIcons = {
    'Gundem': Icons.trending_up,
    'Turkiye': Icons.flag,
    'Dunya': Icons.public,
    'Ekonomi': Icons.attach_money,
    'Spor': Icons.sports_handball,
  }; // Her haber türü için simgeler

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kategoriler',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              leading:
                  Icon(categoryIcons[category], color: Colors.deepOrangeAccent),
              title: Text(
                category,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsPage(category: category),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
