import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../booking/data/models/booking_model.dart';
import '../../../booking/data/repositories/booking_repository.dart';
import '../../../katalog/data/models/katalog_model.dart';
import '../../../katalog/data/repositories/katalog_repository.dart';
import '../../../kategori/data/models/kategori_model.dart';
import '../../../kategori/data/repositories/kategori_repository.dart';

class MemberHomePage extends StatefulWidget {
  const MemberHomePage({super.key});

  @override
  State<MemberHomePage> createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  final _searchController = TextEditingController();
  late Future<_MemberCatalogData> _future;
  String _keyword = '';
  int? _kategoriId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<_MemberCatalogData> _load() async {
    final results = await Future.wait([
      KatalogRepository().fetchKatalog(),
      KategoriRepository().fetchKategori(),
    ]);
    return _MemberCatalogData(
      katalog: results[0] as List<KatalogModel>,
      kategori: results[1] as List<KategoriModel>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _future = _load();
          });
        },
        child: FutureBuilder<_MemberCatalogData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _MessageState(
                title: 'Katalog gagal dimuat',
                subtitle: '${snapshot.error}',
                actionLabel: 'Coba Lagi',
                onAction: () {
                  setState(() {
                    _future = _load();
                  });
                },
              );
            }
            final data = snapshot.data ?? const _MemberCatalogData();
            final filtered =
                data.katalog.where((item) {
                  final matchesName = item.nama.toLowerCase().contains(
                    _keyword.toLowerCase(),
                  );
                  final matchesKategori =
                      _kategoriId == null || item.kategori?.id == _kategoriId;
                  return matchesName && matchesKategori;
                }).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                const _MemberHero(),
                const SizedBox(height: 18),
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    labelText: 'Cari mobil',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _keyword = value.trim();
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('Semua'),
                          selected: _kategoriId == null,
                          onSelected: (_) {
                            setState(() {
                              _kategoriId = null;
                            });
                          },
                        ),
                      ),
                      for (final kategori in data.kategori)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(kategori.kategori),
                            selected: _kategoriId == kategori.id,
                            onSelected: (_) {
                              setState(() {
                                _kategoriId = kategori.id;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (filtered.isEmpty)
                  const _InlineEmpty()
                else
                  for (final item in filtered) ...[
                    _MemberCarCard(item: item),
                    const SizedBox(height: 12),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class MemberCarDetailPage extends StatefulWidget {
  const MemberCarDetailPage({super.key, required this.item});

  final KatalogModel item;

  @override
  State<MemberCarDetailPage> createState() => _MemberCarDetailPageState();
}

class _MemberCarDetailPageState extends State<MemberCarDetailPage> {
  late Future<AvailabilityResult> _availabilityFuture;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _visibleStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _availabilityFuture = BookingRepository().checkAvailability(
      katalogId: widget.item.id,
      startDate: _formatDate(now),
      endDate: _formatDate(now.add(const Duration(days: 365))),
    );
  }

  bool _isBooked(DateTime day, AvailabilityResult result) {
    final date = _formatDate(day);
    for (final range in result.bookedRanges) {
      if (date.compareTo(range.startDate) >= 0 &&
          date.compareTo(range.endDate) <= 0) {
        return true;
      }
    }
    return false;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isInSelectedRange(DateTime day) {
    if (_startDate == null || _endDate == null) return false;
    final date = DateTime(day.year, day.month, day.day);
    final start = DateTime(
      _startDate!.year,
      _startDate!.month,
      _startDate!.day,
    );
    final end = DateTime(_endDate!.year, _endDate!.month, _endDate!.day);
    return date.compareTo(start) >= 0 && date.compareTo(end) <= 0;
  }

  bool _rangeHasBookedDate(
    DateTime start,
    DateTime end,
    AvailabilityResult result,
  ) {
    var current = start;
    while (current.compareTo(end) <= 0) {
      if (_isBooked(current, result)) return true;
      current = current.add(const Duration(days: 1));
    }
    return false;
  }

  void _selectDate(DateTime day, AvailabilityResult result) {
    if (_isBooked(day, result)) return;

    if (_startDate == null || (_startDate != null && _endDate != null)) {
      setState(() {
        _startDate = day;
        _endDate = null;
      });
      return;
    }

    if (day.isBefore(_startDate!)) {
      setState(() {
        _startDate = day;
        _endDate = null;
      });
      return;
    }

    if (_sameDay(day, _startDate!)) {
      setState(() {
        _startDate = null;
        _endDate = null;
      });
      return;
    }

    if (_rangeHasBookedDate(_startDate!, day, result)) {
      _snack('Range tanggal melewati tanggal yang tidak tersedia');
      return;
    }

    setState(() {
      _endDate = day;
    });
  }

  Future<void> _openWhatsapp() async {
    if (_startDate == null || _endDate == null) {
      _snack('Pilih tanggal sewa terlebih dahulu');
      return;
    }
    final message =
        'Halo Arlys, saya ingin booking mobil ${widget.item.nama} '
        'tanggal ${_formatDate(_startDate!)} sampai ${_formatDate(_endDate!)}.';

    final whatsappUri = Uri.parse(
      'whatsapp://send?phone=6285282867952&text=${Uri.encodeComponent(message)}',
    );
    final webUri = Uri.parse(
      'https://api.whatsapp.com/send?phone=6285282867952&text=${Uri.encodeComponent(message)}',
    );

    var opened = false;
    try {
      opened = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}

    if (opened) return;

    try {
      opened = await launchUrl(webUri, mode: LaunchMode.externalApplication);
    } catch (_) {}

    if (opened) return;

    _snack('Tidak dapat membuka WhatsApp. Restart aplikasi lalu coba lagi.');
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = KatalogRepository().imageUrl(widget.item.path);
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mobil')),
      body: FutureBuilder<AvailabilityResult>(
        future: _availabilityFuture,
        builder: (context, snapshot) {
          final result = snapshot.data;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  imageUrl,
                  height: 230,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        height: 230,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(
                          Icons.directions_car_outlined,
                          size: 54,
                        ),
                      ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                widget.item.nama,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.item.kategori?.kategori ?? 'Tanpa kategori',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp ',
                  decimalDigits: 0,
                ).format(widget.item.harga),
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              if (snapshot.connectionState != ConnectionState.done)
                const Center(child: CircularProgressIndicator())
              else if (snapshot.hasError)
                Text('Availability gagal dimuat: ${snapshot.error}')
              else ...[
                _DateStripPicker(
                  visibleStart: _visibleStart,
                  startDate: _startDate,
                  endDate: _endDate,
                  result: result!,
                  isBooked: _isBooked,
                  sameDay: _sameDay,
                  isInSelectedRange: _isInSelectedRange,
                  onPrevious: () {
                    final previous = _visibleStart.subtract(
                      const Duration(days: 14),
                    );
                    final today = DateTime.now();
                    setState(() {
                      _visibleStart =
                          previous.isBefore(today) ? today : previous;
                    });
                  },
                  onNext: () {
                    setState(() {
                      _visibleStart = _visibleStart.add(
                        const Duration(days: 14),
                      );
                    });
                  },
                  onSelect: (date) => _selectDate(date, result),
                ),
                const SizedBox(height: 14),
                _SelectedRangeSummary(startDate: _startDate, endDate: _endDate),
                const SizedBox(height: 14),
                _AvailabilityNote(result: result),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _openWhatsapp,
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Booking via WhatsApp'),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _MemberHero extends StatelessWidget {
  const _MemberHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.directions_car_filled_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(height: 16),
          Text(
            'Temukan mobil rental',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cari mobil, cek tanggal tersedia, lalu booking lewat WhatsApp admin.',
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _MemberCarCard extends StatelessWidget {
  const _MemberCarCard({required this.item});

  final KatalogModel item;

  @override
  Widget build(BuildContext context) {
    final imageUrl = KatalogRepository().imageUrl(item.path);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MemberCarDetailPage(item: item)),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  width: 92,
                  height: 76,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 92,
                        height: 76,
                        color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.directions_car_outlined),
                      ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.kategori?.kategori ?? 'Tanpa kategori',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      NumberFormat.currency(
                        locale: 'id_ID',
                        symbol: 'Rp ',
                        decimalDigits: 0,
                      ).format(item.harga),
                      style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateStripPicker extends StatelessWidget {
  const _DateStripPicker({
    required this.visibleStart,
    required this.startDate,
    required this.endDate,
    required this.result,
    required this.isBooked,
    required this.sameDay,
    required this.isInSelectedRange,
    required this.onPrevious,
    required this.onNext,
    required this.onSelect,
  });

  final DateTime visibleStart;
  final DateTime? startDate;
  final DateTime? endDate;
  final AvailabilityResult result;
  final bool Function(DateTime, AvailabilityResult) isBooked;
  final bool Function(DateTime, DateTime) sameDay;
  final bool Function(DateTime) isInSelectedRange;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final dates = List.generate(
      14,
      (index) => DateTime(
        visibleStart.year,
        visibleStart.month,
        visibleStart.day + index,
      ),
    );
    final labelStart = DateFormat('d MMM').format(dates.first);
    final labelEnd = DateFormat('d MMM yyyy').format(dates.last);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilih tanggal sewa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Sebelumnya',
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              IconButton(
                tooltip: 'Berikutnya',
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          Text(
            '$labelStart - $labelEnd',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 94,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final date = dates[index];
                final unavailable = isBooked(date, result);
                final selectedStart =
                    startDate != null && sameDay(date, startDate!);
                final selectedEnd = endDate != null && sameDay(date, endDate!);
                final inRange = isInSelectedRange(date);
                return _DateChip(
                  date: date,
                  unavailable: unavailable,
                  selected: selectedStart || selectedEnd,
                  inRange: inRange,
                  onTap: unavailable ? null : () => onSelect(date),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              _LegendDot(color: AppTheme.primary),
              SizedBox(width: 6),
              Text('Dipilih', style: TextStyle(fontSize: 12)),
              SizedBox(width: 14),
              _LegendDot(color: Color(0xFFE2E8F0)),
              SizedBox(width: 6),
              Text('Tidak tersedia', style: TextStyle(fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.date,
    required this.unavailable,
    required this.selected,
    required this.inRange,
    required this.onTap,
  });

  final DateTime date;
  final bool unavailable;
  final bool selected;
  final bool inRange;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final background =
        selected
            ? AppTheme.primary
            : inRange
            ? AppTheme.primary.withValues(alpha: 0.14)
            : unavailable
            ? const Color(0xFFE2E8F0)
            : Colors.white;
    final foreground =
        selected
            ? Colors.white
            : unavailable
            ? AppTheme.textSecondary.withValues(alpha: 0.55)
            : AppTheme.textPrimary;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selected || inRange
                    ? AppTheme.primary
                    : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('E').format(date),
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${date.day}',
              style: TextStyle(
                color: foreground,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _SelectedRangeSummary extends StatelessWidget {
  const _SelectedRangeSummary({required this.startDate, required this.endDate});

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  Widget build(BuildContext context) {
    final text =
        startDate == null
            ? 'Tap tanggal tersedia untuk memilih tanggal mulai.'
            : endDate == null
            ? 'Tanggal mulai: ${_format(startDate!)}. Tap tanggal lain untuk tanggal selesai.'
            : 'Range dipilih: ${_format(startDate!)} sampai ${_format(endDate!)}.';

    return Text(
      text,
      style: const TextStyle(color: AppTheme.textSecondary, height: 1.35),
    );
  }

  String _format(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
}

class _AvailabilityNote extends StatelessWidget {
  const _AvailabilityNote({required this.result});

  final AvailabilityResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        result.bookedRanges.isEmpty
            ? 'Semua tanggal dalam 1 tahun ke depan tersedia.'
            : '${result.bookedRanges.length} rentang tanggal sudah dibooking dan otomatis tidak bisa dipilih.',
        style: const TextStyle(color: AppTheme.textPrimary, height: 1.35),
      ),
    );
  }
}

class _InlineEmpty extends StatelessWidget {
  const _InlineEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Text(
        'Mobil tidak ditemukan.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(
          Icons.error_outline_rounded,
          size: 52,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(height: 18),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppTheme.textSecondary, height: 1.4),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
        ),
      ],
    );
  }
}

class _MemberCatalogData {
  const _MemberCatalogData({this.katalog = const [], this.kategori = const []});

  final List<KatalogModel> katalog;
  final List<KategoriModel> kategori;
}
