import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  List _payments = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getMyPayments();

      final raw = response.data;
      List result = [];
      if (raw is List) {
        result = raw;
      } else if (raw is Map) {
        result = (raw['data'] ?? raw['payments'] ?? raw['results'] ?? []) as List;
      }

      if (mounted) setState(() { _payments = result; _isLoading = false; });
    } catch (e) {
      debugPrint('❌ Payments error: $e');
      if (mounted) setState(() { _isLoading = false; _errorMessage = 'Failed to load payments.'; });
    }
  }

  // ✅ يتعامل مع {$date: "..."} أو ISO string
  String _formatDate(dynamic dateVal) {
    if (dateVal == null) return 'N/A';
    String isoStr = dateVal is Map ? (dateVal['\$date']?.toString() ?? '') : dateVal.toString();
    if (isoStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(isoStr).toLocal();
      const months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) { return isoStr; }
  }

  // ✅ يستخرج الـ ID من {$oid: "..."} أو string
  String _extractId(dynamic val) {
    if (val is Map) return (val['\$oid'] ?? '').toString();
    return val?.toString() ?? '';
  }

  String _formatAmount(dynamic amount) {
    final num a = num.tryParse(amount?.toString() ?? '0') ?? 0;
    if (a >= 1000000) return 'EGP ${(a / 1000000).toStringAsFixed(1)}M';
    if (a >= 1000)    return 'EGP ${(a / 1000).toStringAsFixed(0)}K';
    return 'EGP ${a.toStringAsFixed(0)}';
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':    return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed':  return Colors.red;
      default:        return Colors.grey;
    }
  }

  IconData _methodIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'card':  return Icons.credit_card;
      case 'cash':  return Icons.payments_outlined;
      default:      return Icons.account_balance_wallet_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Color(0xFF1A1A2E)),
          ),
        ),
        title: const Text('My Payments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator(color: Color(0xFF0095FF)));

    if (_errorMessage != null) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 52, color: Colors.redAccent),
        const SizedBox(height: 12),
        Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _fetchPayments,
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0095FF)),
          child: const Text('Retry', style: TextStyle(color: Colors.white)),
        ),
      ]));
    }

    if (_payments.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: const Color(0xFF0095FF).withOpacity(0.08), shape: BoxShape.circle),
          child: const Icon(Icons.payment_outlined, size: 52, color: Color(0xFF0095FF)),
        ),
        const SizedBox(height: 20),
        const Text('No payments yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        const Text('Your payment history will appear here', style: TextStyle(fontSize: 13, color: Colors.grey)),
      ]));
    }

    // إجمالي المدفوعات
    final total = _payments.fold<num>(
      0, (sum, p) => sum + (num.tryParse(p['amount']?.toString() ?? '0') ?? 0),
    );

    return RefreshIndicator(
      onRefresh: _fetchPayments,
      color: const Color(0xFF0095FF),
      child: Column(children: [
        // Summary card
        Container(
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0095FF), Color(0xFF0070CC)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Total Paid', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(_formatAmount(total),
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Transactions', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text('${_payments.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
        // List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _payments.length,
            itemBuilder: (_, i) => _buildPaymentCard(_payments[i]),
          ),
        ),
      ]),
    );
  }

  Widget _buildPaymentCard(dynamic item) {
    final Map<String, dynamic> payment = Map<String, dynamic>.from(item as Map);

    final String method  = payment['paymentMethod']?.toString() ?? 'N/A';
    final String status  = payment['status']?.toString() ?? 'pending';
    final dynamic amount = payment['amount'];
    final String notes   = payment['notes']?.toString() ?? '';

    // ✅ يتعامل مع {$date: "..."} من MongoDB
    final String date = _formatDate(payment['paymentDate'] ?? payment['createdAt']);

    // ✅ يستخرج الـ ID من {$oid: "..."}
    final String txnId = _extractId(payment['transactionId']);
    final String instId = _extractId(payment['installmentId']);
    final String shortTxnId = txnId.length > 8 ? '...${txnId.substring(txnId.length - 8)}' : txnId;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        // Method icon
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0095FF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(_methodIcon(method), color: const Color(0xFF0095FF), size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                method[0].toUpperCase() + method.substring(1),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              Text(
                _formatAmount(amount),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0095FF)),
              ),
            ]),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status[0].toUpperCase() + status.substring(1),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _statusColor(status)),
                ),
              ),
            ]),
            if (txnId.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text('Transaction Ref: $shortTxnId',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
            if (instId.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text('Installment: ...${instId.substring(instId.length > 8 ? instId.length - 8 : 0)}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(notes,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ]),
        ),
      ]),
    );
  }
}