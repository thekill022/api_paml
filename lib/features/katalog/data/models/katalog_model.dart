import '../../../kategori/data/models/kategori_model.dart';

class KatalogModel {
  const KatalogModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.status,
    required this.path,
    this.kategori,
  });

  final int id;
  final String nama;
  final num harga;
  final bool status;
  final String path;
  final KategoriModel? kategori;

  factory KatalogModel.fromJson(Map<String, dynamic> json) {
    final kategoriJson = json['kategori'];
    return KatalogModel(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse('${json['id']}') ?? 0,
      nama: json['nama'] as String? ?? '',
      harga:
          json['harga'] is num
              ? json['harga'] as num
              : num.tryParse('${json['harga']}') ?? 0,
      status: json['status'] == true || json['status'].toString() == 'true',
      path: json['path'] as String? ?? '',
      kategori:
          kategoriJson is Map<String, dynamic>
              ? KategoriModel.fromJson(kategoriJson)
              : null,
    );
  }
}
