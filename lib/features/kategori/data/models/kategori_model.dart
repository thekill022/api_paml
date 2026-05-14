class KategoriModel {
  const KategoriModel({required this.id, required this.kategori});

  final int id;
  final String kategori;

  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse('${json['id']}') ?? 0,
      kategori: json['kategori'] as String? ?? '',
    );
  }
}
