import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:html/parser.dart';

class NewsPage extends StatefulWidget {
  final String category; // Haber türünü al

  NewsPage({required this.category});

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  late List news = [];

  //API'den türe göre haber alma işlevi

  Future<void> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.trthaber.com/${widget.category.toLowerCase()}_articles.rss'));

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final document = XmlDocument.parse(utf8.decode(bytes));
        final items = document.findAllElements('item').toList();

        setState(() {
          news = items.map((item) {
            var title = item.findElements('title').single.text;
            var link = item.findElements('link').single.text;
            //var description = item.findElements('description').single.text;
            var publishedAt = item.findElements('pubDate').single.text;
            var image = item.findElements('enclosure').isNotEmpty
                ? item.findElements('enclosure').single.getAttribute('url')
                : null;

            return {
              'title': title,
              // 'description': description,
              'link': link,
              'publishedAt': publishedAt,
              'image': image,
            };
          }).toList();
        });
      } else {
        throw Exception('Haber yüklenemedi');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  void _openNewsDetail(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsDetailPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category} Haberleri',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: news.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: news.length,
              itemBuilder: (context, index) {
                var article = news[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  elevation: 4,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    title: Row(
                      children: [
                        Icon(Icons.article,
                            color: Colors.deepOrangeAccent, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            article['title'] ?? 'No Title',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        /*
                        Text(
                          article['description'] ?? 'No Description',
                          style: TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        */
                        SizedBox(height: 8),
                        Text(
                          'Published: ${article['publishedAt'] ?? 'No Date'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (article['image'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.network(
                              article['image']!,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error);
                              },
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                      _openNewsDetail(article['link']);
                    },
                  ),
                );
              },
            ),
    );
  }
}

class NewsDetailPage extends StatefulWidget {
  final String url;

  NewsDetailPage({required this.url});

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  String? content;
  bool isLoading = true;

  Future<void> fetchNewsDetail() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        final document =
            parse(utf8.decode(response.bodyBytes)); // تحليل الـ HTML
        final description = document.body?.text ?? 'İçerik yok';

        setState(() {
          content = description;
          isLoading = false;
        });
      } else {
        throw Exception('Haber detayları yüklenemedi');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
        content = 'Haber detayları yüklenemedi';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNewsDetail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Haber detayları'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Text(
                content ?? 'İçerik yok',
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}
