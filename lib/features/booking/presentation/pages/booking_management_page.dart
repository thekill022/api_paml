import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../katalog/data/models/katalog_model.dart';
import '../../../katalog/data/repositories/katalog_repository.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

class BookingManagementPage extends StatefulWidget {
  const BookingManagementPage({super.key});

  static const routeName = '/booking';

  @override
  State<BookingManagementPage> createState() => _BookingManagementPageState();
}

class _BookingManagementPageState extends State<BookingManagementPage> {
  final _repository = BookingRepository();
  late Future<List<BookingModel>> _bookingFuture;

  @override
  void initState() {
    super.initState();
    _bookingFuture = _repository.fetchBookings();
  }

  void _refresh() {
    setState(() {
      _bookingFuture = _repository.fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refresh(),
          child: FutureBuilder<List<BookingModel>>(
            future: _bookingFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _MessageState(
                  title: 'Booking gagal dimuat',
                  subtitle: '${snapshot.error}',
                  icon: Icons.error_outline_rounded,
                  actionLabel: 'Coba Lagi',
                  onAction: _refresh,
                );
              }
              final bookings = snapshot.data ?? [];
              if (bookings.isEmpty) {
                return _MessageState(
                  title: 'Belum ada booking',
                  subtitle:
                      'Tambahkan booking untuk mengunci jadwal sewa mobil.',
                  icon: Icons.event_available_outlined,
                  actionLabel: 'Tambah Booking',
                  onAction: () => _openForm(context),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
                itemCount: bookings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return _BookingTile(
                    booking: booking,
                    onEdit:
                        booking.isActive
                            ? () => _openForm(context, booking: booking)
                            : null,
                    onDelete: () => _confirmDelete(context, booking),
                    onReturn:
                        booking.isActive
                            ? () => _returnEarly(context, booking)
                            : null,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, {BookingModel? booking}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => BookingFormPage(booking: booking)),
    );
    if (changed == true && mounted) _refresh();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    BookingModel booking,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
            contentPadding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            actionsPadding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            title: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Hapus booking?',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'Tutup',
                  onPressed: () => Navigator.pop(dialogContext, false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            content: Text(
              'Booking ${booking.customerName} untuk ${booking.katalog?.nama ?? 'mobil'} akan dihapus.',
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.error,
                  ),
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Hapus'),
                ),
              ),
            ],
          ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _repository.deleteBooking(booking.id);
      if (!mounted) return;
      _snack(this.context, 'Booking berhasil dihapus');
      _refresh();
    } on BookingException catch (error) {
      if (mounted) _snack(this.context, error.message);
    } catch (_) {
      if (mounted) _snack(this.context, 'Tidak dapat terhubung ke server');
    }
  }

  Future<void> _returnEarly(BuildContext context, BookingModel booking) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.parse(booking.startDate),
      lastDate: DateTime.parse(booking.endDate),
    );
    if (selectedDate == null || !context.mounted) return;

    final date = DateFormat('yyyy-MM-dd').format(selectedDate);
    try {
      await _repository.returnEarly(id: booking.id, actualReturnDate: date);
      if (!mounted) return;
      ScaffoldMessenger.of(this.context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Mobil berhasil dikembalikan')),
        );
      _refresh();
    } on BookingException catch (error) {
      if (mounted) _snack(this.context, error.message);
    } catch (_) {
      if (mounted) _snack(this.context, 'Tidak dapat terhubung ke server');
    }
  }

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class BookingFormPage extends StatefulWidget {
  const BookingFormPage({super.key, this.booking});

  final BookingModel? booking;

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bookingRepository = BookingRepository();
  late Future<List<KatalogModel>> _katalogFuture;
  int? _katalogId;
  DateTime? _startDate;
  DateTime? _endDate;
  AvailabilityResult? _availability;
  bool _checking = false;
  bool _submitting = false;
  bool get _isEdit => widget.booking != null;

  @override
  void initState() {
    super.initState();
    _katalogFuture = KatalogRepository().fetchByStatus(true);
    final booking = widget.booking;
    if (booking != null) {
      _customerNameController.text = booking.customerName;
      _phoneController.text = booking.customerPhone ?? '';
      _katalogId = booking.katalog?.id;
      _startDate = DateTime.tryParse(booking.startDate);
      _endDate = DateTime.tryParse(booking.endDate);
      _availability = const AvailabilityResult(
        available: true,
        bookedRanges: [],
      );
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final value = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (value == null) return;
    setState(() {
      _startDate = value;
      final minimumEndDate = value.add(const Duration(days: 1));
      if (_endDate == null || !_endDate!.isAfter(value)) {
        _endDate = minimumEndDate;
      }
      _availability = null;
    });
  }

  Future<void> _pickEndDate() async {
    final minimumEndDate =
        _startDate?.add(const Duration(days: 1)) ??
        DateTime.now().add(const Duration(days: 1));
    final initialDate =
        _endDate != null && !_endDate!.isBefore(minimumEndDate)
            ? _endDate!
            : minimumEndDate;
    final value = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minimumEndDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (value == null) return;
    setState(() {
      _endDate = value;
      _availability = null;
    });
  }

  Future<void> _checkAvailability() async {
    if (_katalogId == null || _startDate == null || _endDate == null) {
      _snack('Pilih mobil dan tanggal terlebih dahulu');
      return;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      _snack('Sewa minimal 1 malam');
      return;
    }
    setState(() => _checking = true);
    try {
      final result = await _bookingRepository.checkAvailability(
        katalogId: _katalogId!,
        startDate: _formatDate(_startDate!),
        endDate: _formatDate(_endDate!),
        excludeId: widget.booking?.id,
      );
      if (!mounted) return;
      setState(() => _availability = result);
    } on BookingException catch (error) {
      if (mounted) _snack(error.message);
    } catch (_) {
      if (mounted) _snack('Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_katalogId == null || _startDate == null || _endDate == null) {
      _snack('Mobil dan tanggal wajib dipilih');
      return;
    }
    if (!_endDate!.isAfter(_startDate!)) {
      _snack('Sewa minimal 1 malam');
      return;
    }
    if (_availability?.available != true) {
      await _checkAvailability();
      if (_availability?.available != true) return;
    }

    setState(() => _submitting = true);
    try {
      if (_isEdit) {
        await _bookingRepository.updateBooking(
          id: widget.booking!.id,
          katalogId: _katalogId!,
          customerName: _customerNameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          startDate: _formatDate(_startDate!),
          endDate: _formatDate(_endDate!),
        );
      } else {
        await _bookingRepository.createBooking(
          katalogId: _katalogId!,
          customerName: _customerNameController.text.trim(),
          customerPhone: _phoneController.text.trim(),
          startDate: _formatDate(_startDate!),
          endDate: _formatDate(_endDate!),
        );
      }
      if (mounted) Navigator.pop(context, true);
    } on BookingException catch (error) {
      if (mounted) _snack(error.message);
    } catch (_) {
      if (mounted) _snack('Tidak dapat terhubung ke server');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Booking' : 'Tambah Booking')),
      body: SafeArea(
        child: FutureBuilder<List<KatalogModel>>(
          future: _katalogFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final katalog = snapshot.data ?? [];
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<int>(
                      value: _katalogId,
                      decoration: const InputDecoration(
                        labelText: 'Mobil',
                        prefixIcon: Icon(Icons.directions_car_outlined),
                      ),
                      items:
                          katalog
                              .map(
                                (item) => DropdownMenuItem<int>(
                                  value: item.id,
                                  child: Text(item.nama),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          _katalogId = value;
                          _availability = null;
                        });
                      },
                      validator:
                          (value) =>
                              value == null ? 'Mobil wajib dipilih' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _customerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama penyewa',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) return 'Nama penyewa wajib diisi';
                        if (text.length < 3) return 'Minimal 3 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Nomor HP',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _DateTile(
                      title: 'Tanggal mulai',
                      value:
                          _startDate == null
                              ? 'Pilih tanggal'
                              : _formatDate(_startDate!),
                      onTap: _pickStartDate,
                    ),
                    const SizedBox(height: 10),
                    _DateTile(
                      title: 'Tanggal selesai',
                      value:
                          _endDate == null
                              ? 'Pilih tanggal'
                              : _formatDate(_endDate!),
                      onTap: _pickEndDate,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _checking ? null : _checkAvailability,
                      icon:
                          _checking
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.event_available_outlined),
                      label: const Text('Cek Availability'),
                    ),
                    if (_availability != null) ...[
                      const SizedBox(height: 12),
                      _AvailabilityBox(result: _availability!),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child:
                          _submitting
                              ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                _isEdit ? 'Simpan Booking' : 'Simpan Booking',
                              ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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

class _BookingTile extends StatelessWidget {
  const _BookingTile({
    required this.booking,
    required this.onEdit,
    required this.onDelete,
    required this.onReturn,
  });

  final BookingModel booking;
  final VoidCallback? onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onReturn;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.status) {
      'active' => AppTheme.primary,
      'returned' => AppTheme.secondary,
      _ => AppTheme.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.katalog?.nama ?? 'Mobil',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _Badge(label: booking.status, color: statusColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            booking.customerName,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),
          Text('${booking.startDate} sampai ${booking.endDate}'),
          if (booking.actualReturnDate != null) ...[
            const SizedBox(height: 6),
            Text('Dikembalikan: ${booking.actualReturnDate}'),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (onEdit != null)
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
              OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Hapus'),
              ),
            ],
          ),
          if (onReturn != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReturn,
                icon: const Icon(Icons.assignment_return_rounded),
                label: const Text('Kembalikan Lebih Awal'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: title,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(value),
      ),
    );
  }
}

class _AvailabilityBox extends StatelessWidget {
  const _AvailabilityBox({required this.result});

  final AvailabilityResult result;

  @override
  Widget build(BuildContext context) {
    final color = result.available ? AppTheme.secondary : AppTheme.error;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.available
                ? 'Mobil tersedia pada tanggal ini'
                : 'Tanggal bertumpuk',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          if (result.bookedRanges.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final range in result.bookedRanges)
              Text(
                '- ${range.startDate} sampai ${range.endDate} (${range.customerName})',
              ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 52, color: AppTheme.textSecondary),
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
