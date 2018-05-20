import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(new CryptoSpyApp());

class CryptoSpyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crypto Spy App',
        home : HomeScreen(),
        theme: _buildThemeData()

    );
  }

  ThemeData _buildThemeData(){
    final ThemeData base = ThemeData.light();
    return base.copyWith(
        primaryColor: Colors.deepPurple,
        accentColor: Colors.deepPurpleAccent,
        scaffoldBackgroundColor: Colors.grey,
        cardColor: Colors.white
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Crypto Spy App")
        ),
        body: FutureBuilder(
            future: _getCurrencies(),
            builder: (BuildContext context, AsyncSnapshot snapy){
              switch(snapy.connectionState){
                case ConnectionState.none:
                  return Text("No connection");
                case ConnectionState.waiting:
                  return MessageCard(
                      message: "Waiting for connection"
                  );
                default:
                  if(snapy.hasError){
                    return MessageCard(message: "Error: ${snapy.error}");
                  }
                  return CryptoList(currencies: snapy.data);
              }
            }
        )
    );
  }

  Future<List<Currency>> _getCurrencies() async {
    final String apiUrl = 'https://api.coinmarketcap.com/v1/ticker/?limit=20';
    final http.Response response = await http.get(apiUrl);
    final data = json.decode(response.body);

    List<Currency> list = new List<Currency>();
    for(var x in data){
      list.add(Currency.fromJson(x));
    }
    return list;
  }
}

class MessageCard extends StatefulWidget {
  final String message;

  MessageCard({this.message});

  @override
  _MessageCardState createState() => new _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(8.0),
        child: Card(
            child: ListTile(
              title: Text(widget.message),
            )
        )
    );
  }
}

class Currency{
  final String name;
  final String symbol;
  final String priceUsd;
  final String percentChange1h;

  Currency({this.name, this.symbol, this.priceUsd, this.percentChange1h});

  factory Currency.fromJson(Map<String, dynamic> json){
    return new Currency(
        name: json['name'],
        symbol: json['symbol'],
        priceUsd: json['price_usd'],
        percentChange1h: json['percent_change_1h']
    );
  }
}

class CryptoList extends StatelessWidget {
  final List<Currency> currencies;

  CryptoList({this.currencies});

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Flexible(
                child: ListView.builder(
                  itemCount: currencies.length,
                  itemBuilder: (context, index){
                    final currency = currencies[index];

                    return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: _getPercentageColor(currency.percentChange1h),
                              child: Text(currency.name[0],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              )
                          ),
                          title: Text(currency.name,
                              style: new TextStyle(fontWeight: FontWeight.bold)
                          ),
                          subtitle: _getSubtitleText(currency),
                          isThreeLine: true,
                        )
                    );
                  },
                )
            )
          ],
        )
    );
  }

  Color _getPercentageColor(percentChange1h){
    if (double.parse(percentChange1h) > 0.0){
      return Colors.green;
    }
    return Colors.red;
  }

  RichText _getSubtitleText(Currency currency){
    TextSpan textPrice = new TextSpan(
        text: "\$${currency.priceUsd}\n",
        style: new TextStyle(
            color: Colors.black
        )
    );

    TextSpan textPriceChange = new TextSpan(
        text: "${currency.percentChange1h}% in 1 hour",
        style: new TextStyle(
            color: _getPercentageColor(currency.percentChange1h)
        )
    );

    return new RichText(text: new TextSpan(
        children: [
          textPrice,
          textPriceChange
        ]
    ));
  }
}



