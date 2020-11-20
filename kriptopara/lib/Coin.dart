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
