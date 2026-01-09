class AuctionData {
  final DateTime date;
  final String auctioneer;
  final double maxPrice;
  final double avgPrice;
  final double quantity;
  final double? quantityArrived;
  final int? lots;

  AuctionData({
    required this.date,
    required this.auctioneer,
    required this.maxPrice,
    required this.avgPrice,
    required this.quantity,
    this.quantityArrived,
    this.lots,
  });

  factory AuctionData.fromJson(Map<String, dynamic> json) {
    return AuctionData(
      date: DateTime.parse(json['date']),
      auctioneer: json['auctioneer'],
      maxPrice: (json['maxPrice'] as num).toDouble(),
      avgPrice: (json['avgPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toDouble(),
      quantityArrived: json['quantityArrived'] != null ? (json['quantityArrived'] as num).toDouble() : null,
      lots: json['lots'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'auctioneer': auctioneer,
      'maxPrice': maxPrice,
      'avgPrice': avgPrice,
      'quantity': quantity,
      'quantityArrived': quantityArrived,
      'lots': lots,
    };
  }
}
