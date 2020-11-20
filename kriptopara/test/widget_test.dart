import 'package:bezier_chart/bezier_chart.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kripto Para Birimi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: KriptoPara(),
    );
  }
}

class Coin {
  final String name;
  final String fullName;
  final double price;
  final double change;
  final double changeHour;
  final double highDay;
  final double lowDay;

  const Coin({
    this.name,
    this.fullName,
    this.price,
    this.change,
    this.changeHour,
    this.highDay,
    this.lowDay,
  });

  factory Coin.fromJson(Map<String, dynamic> json) {
    return Coin(
      name: json['CoinInfo']['Name'].toString(),
      fullName: json['CoinInfo']['FullName'].toString(),
      price: (json['RAW']['USD']['PRICE'] as num).toDouble(),
      change: (json['RAW']['USD']['CHANGE24HOUR'] as num).toDouble(),
      changeHour: (json['RAW']['USD']['CHANGEHOUR'] as num).toDouble(),
      highDay: (json['RAW']['USD']['HIGH24HOUR'] as num).toDouble(),
      lowDay: (json['RAW']['USD']['LOW24HOUR'] as num).toDouble(),
    );
  }
}

class Services {
  static const int coinNum = 100;

  static Future<List<Coin>> getCoins() async {
    String url =
        'https://min-api.cryptocompare.com/data/top/totalvolfull?limit=$coinNum&tsym=USD&page=0';
    //
    List<Coin> coins = [];
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);
        List<dynamic> coinList = data['Data'];
        coinList.forEach((json) => coins.add(Coin.fromJson(json)));
      }
      return coins;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}

class KriptoPara extends StatefulWidget {
  @override
  _KriptoParaState createState() => _KriptoParaState();
}

class _KriptoParaState extends State<KriptoPara> {
  int coinCounter;
  List<Coin> coins = List();
  List<Coin> filteredCoins = List(); //Coin tipinde liste

  /* @override
  void initState() {
    super.initState();
    Services.getCoins().then((coinsList) {
      coins = coinsList;
      filteredCoins = coins;
    });
  }*/

  Future<Null> _refresh() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      filteredCoins = coins;
    });
    return null;
  }

  Widget buildBody() {
    return FutureBuilder(
      future: Services.getCoins(), // servis sınıfındaki metod
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
          );
        }
        coins = snapshot.data;
        return RefreshIndicator(
          onRefresh: _refresh,
          color: Colors.black,
          backgroundColor: Colors.white,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  child: TextField(
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        icon: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                        ),
                        contentPadding: EdgeInsets.only(left: 20),
                        hintText: 'Coin Ara'),
                    onChanged: (string) {
                      setState(() {
                        filteredCoins = coins
                            .where((u) =>
                                (u.fullName
                                    .toLowerCase()
                                    .contains(string.toLowerCase())) ||
                                (u.name
                                    .toLowerCase()
                                    .contains(string.toLowerCase())))
                            .toList();
                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: filteredCoins.length,
                  itemBuilder: (BuildContext context, int index) {
                    coinCounter = index;
                    return Card(
                      child: ListTile(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetailsPage(filteredCoins[index])));
                        },
                        title: Text(
                          filteredCoins[index].name,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              color: Colors.black),
                        ),
                        subtitle: Text(
                          filteredCoins[index].fullName,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black45),
                        ),
                        trailing: Text(
                          '\$${filteredCoins[index].price.toStringAsFixed(3)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: filteredCoins[index].changeHour > 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('Kripto Para Birimi'))),
      body: buildBody(),
    );
  }
}

class DetailsPage extends StatelessWidget {
  final Coin coinDetail;

  DetailsPage(this.coinDetail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(coinDetail.fullName+": "+ coinDetail.price.toString()),
        ),
        body: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              new Container(
                child: sample1(context),
              ),
              new RefreshIndicator(
                onRefresh: _KriptoParaState()._refresh,
                child: Card(
                  elevation: 5,
                  child: ListTile(
                    title: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "\n 24 Saatlik Değişimi=   "
                                  "\$${coinDetail.change.toStringAsFixed(2)}\n",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: coinDetail.change > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: "\n Saatlik Değişimi=   "
                                  "\$${coinDetail.changeHour.toStringAsFixed(3)}\n",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: coinDetail.changeHour > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            TextSpan(
                              text: "\n Günlük En Yüksek Değer= "
                                  "\$${coinDetail.highDay.toString()}\n",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                              ),
                            ),
                            TextSpan(
                              text: "\n Günlük En Düşük Değer= "
                                  "\$${coinDetail.lowDay.toString()}\n",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget sample1(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigo,
            Colors.indigo,
            Colors.indigo,
            Colors.indigo,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            coinDetail.fullName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          Center(
            child: Card(
              elevation: 30,
              child: Container(
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width * 0.9,
                child: BezierChart(
                  bezierChartScale: BezierChartScale.CUSTOM,
                  xAxisCustomValues: [0, 12, 24],
                  footerValueBuilder: (double value) {
                    return "${formatAsIntOrDouble(value)}\nhours";
                  },
                  series: [
                    BezierLine(
                      lineColor: Colors.indigo,
                      dataPointStrokeColor: Colors.blue,
                      label: "m",
                      data: [
                        DataPoint<double>(value: coinDetail.lowDay),
                        DataPoint<double>(value: coinDetail.highDay),
                        DataPoint<double>(value: coinDetail.price),
                      ],
                    ),
                  ],
                  config: BezierChartConfig(
                    startYAxisFromNonZeroValue: false,
                    bubbleIndicatorColor: Colors.white.withOpacity(0.5),
                    footerHeight: 50,
                    verticalIndicatorStrokeWidth: 5,
                    verticalIndicatorColor: Colors.black26,
                    showVerticalIndicator: true,
                    verticalIndicatorFixedPosition: true,
                    displayYAxis: true,
                    stepsYAxis: coinDetail.price ~/ 4,
                    backgroundGradient: LinearGradient(
                      colors: [
                        Colors.red[300],
                        Colors.red[400],
                        Colors.red[400],
                        Colors.red[500],
                        Colors.red,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.bottomCenter,
                    ),
                    snap: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
