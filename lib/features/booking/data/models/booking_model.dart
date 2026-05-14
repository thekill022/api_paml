import '../../../katalog/data/models/katalog_model.dart';

class BookingModel {
  const BookingModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.actualReturnDate,
    this.katalog,
  });

  final int id;
  final String customerName;
  final String? customerPhone;
  final String startDate;
  final String endDate;
  final String? actualReturnDate;
  final String status;
  final KatalogModel? katalog;

  bool get isActive => status == 'active';

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final katalogJson = json['katalog'];
    return BookingModel(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse('${json['id']}') ?? 0,
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String?,
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      actualReturnDate: json['actualReturnDate'] as String?,
      status: json['status'] as String? ?? 'active',
      katalog:
          katalogJson is Map<String, dynamic>
              ? KatalogModel.fromJson(katalogJson)
              : null,
    );
  }
}

class AvailabilityResult {
  const AvailabilityResult({
    required this.available,
    required this.bookedRanges,
  });

  final bool available;
  final List<BookedRange> bookedRanges;

  factory AvailabilityResult.fromJson(Map<String, dynamic> json) {
    final ranges = json['bookedRanges'];
    return AvailabilityResult(
      available: json['available'] == true,
      bookedRanges:
          ranges is List
              ? ranges
                  .whereType<Map<String, dynamic>>()
                  .map(BookedRange.fromJson)
                  .toList()
              : const [],
    );
  }
}

class BookedRange {
  const BookedRange({
    required this.startDate,
    required this.endDate,
    required this.customerName,
  });

  final String startDate;
  final String endDate;
  final String customerName;

  factory BookedRange.fromJson(Map<String, dynamic> json) {
    return BookedRange(
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
    );
  }
}
