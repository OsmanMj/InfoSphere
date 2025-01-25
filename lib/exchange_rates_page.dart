import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExchangeRatesPage extends StatefulWidget {
  @override
  _ExchangeRatesPageState createState() => _ExchangeRatesPageState();
}

class _ExchangeRatesPageState extends State<ExchangeRatesPage> {
  Map<String, dynamic>? _exchangeRates;
  Map<String, dynamic>? _previousRates;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchExchangeRates();
  }

  Future<void> fetchExchangeRates() async {
    final url = 'https://api.exchangerate-api.com/v4/latest/TRY';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        setState(() {
          _previousRates = _exchangeRates;
          _exchangeRates = data['rates'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Döviz kurları yüklenemedi. Lütfen tekrar deneyin...';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Döviz Kurları', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CurrencySearchDelegate(
                  _exchangeRates ?? {},
                  _previousRates,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(_errorMessage,
                        style: TextStyle(color: Colors.red)))
                : _exchangeRates != null
                    ? ListView.builder(
                        itemCount: _exchangeRates!.keys.length,
                        itemBuilder: (context, index) {
                          final currency = _exchangeRates!.keys.toList()[index];
                          final rate = _exchangeRates![currency];
                          final previousRate = _previousRates?[currency];

                          IconData arrowIcon = Icons.arrow_downward;
                          Color arrowColor = Colors.red;

                          if (previousRate != null) {
                            if (rate > previousRate) {
                              arrowIcon = Icons.arrow_downward;
                              arrowColor = Colors.red;
                            } else if (rate < previousRate) {
                              arrowIcon = Icons.arrow_upward;
                              arrowColor = Colors.green;
                            } else if (rate == previousRate) {
                              arrowIcon = Icons.remove;
                              arrowColor = Colors.grey;
                            }
                          }

                          if (rate > 1) {
                            arrowIcon = Icons.arrow_upward;
                            arrowColor = Colors.green;
                          } else if (rate == 1) {
                            arrowIcon = Icons.remove;
                            arrowColor = Colors.grey;
                          }

                          return Card(
                            elevation: 3,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(
                                currency,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Row(
                                children: [
                                  Text('1 TRY = $rate $currency'),
                                  Icon(arrowIcon, color: arrowColor),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('No data available.')),
      ),
    );
  }
}

class CurrencySearchDelegate extends SearchDelegate {
  final Map<String, dynamic> exchangeRates;
  final Map<String, dynamic>? previousRates;

  CurrencySearchDelegate(this.exchangeRates, this.previousRates);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredCurrencies = exchangeRates.keys
        .where(
            (currency) => currency.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filteredCurrencies.isEmpty) {
      return Center(child: Text('Hiçbir para birimi bulunamadı...'));
    }

    final currency = filteredCurrencies.first;
    final rate = exchangeRates[currency];
    final previousRate = previousRates?[currency];

    IconData arrowIcon = Icons.arrow_downward;
    Color arrowColor = Colors.red;

    if (previousRate != null) {
      if (rate > previousRate) {
        arrowIcon = Icons.arrow_downward;
        arrowColor = Colors.red;
      } else if (rate < previousRate) {
        arrowIcon = Icons.arrow_upward;
        arrowColor = Colors.green;
      } else if (rate == previousRate) {
        arrowIcon = Icons.remove;
        arrowColor = Colors.grey;
      }
    }

    if (rate > 1) {
      arrowIcon = Icons.arrow_upward;
      arrowColor = Colors.green;
    } else if (rate == 1) {
      arrowIcon = Icons.remove;
      arrowColor = Colors.grey;
    }

    return Center(
      child: Card(
        elevation: 5,
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currency,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 16),
              Text('1 TRY = $rate $currency'),
              SizedBox(height: 16),
              Icon(arrowIcon, color: arrowColor, size: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final filteredCurrencies = exchangeRates.keys
        .where(
            (currency) => currency.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredCurrencies.length,
      itemBuilder: (context, index) {
        final currency = filteredCurrencies[index];
        return ListTile(
          title: Text(currency),
          onTap: () {
            query = currency;
            showResults(context);
          },
        );
      },
    );
  }
}
