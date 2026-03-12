import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// List of all expense cards.
class AllExpensesList extends StatelessWidget {
  const AllExpensesList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ExpenseCard(title: 'Hotel Booking - Snow Valley R...', amount: '₹8,000', payerName: 'Ashish', payerInitials: 'AS', payerColor: const Color(0xFF9FDFCA), date: 'Dec 20', yourShare: '₹500', status: 'Pending'),
      const SizedBox(height: 10),
      ExpenseCard(title: 'Solang Valley Adventure Sports', amount: '₹3,200', payerName: 'You', payerInitials: 'ME', payerColor: const Color(0xFF87D4F8), date: 'Dec 22', yourShare: '₹3,200', shareTextPrefix: 'You paid', status: 'Settled'),
      const SizedBox(height: 10),
      ExpenseCard(title: 'Dinner at Cafe 1947', amount: '₹2,400', payerName: 'Priya', payerInitials: 'PR', payerColor: const Color(0xFFFABD9E), date: 'Dec 23', yourShare: '₹600', status: 'Pending'),
      const SizedBox(height: 10),
      ExpenseCard(title: 'Taxi to Rohtang Pass', amount: '₹4,000', payerName: 'Rahul', payerInitials: 'RA', payerColor: const Color(0xFFCCB3E6), date: 'Dec 24', yourShare: '₹1,000', status: 'Settled'),
      const SizedBox(height: 10),
      ExpenseCard(title: "Breakfast at Johnson's Cafe", amount: '₹1,800', payerName: 'You', payerInitials: 'ME', payerColor: const Color(0xFF87D4F8), date: 'Dec 25', yourShare: '₹1,800', shareTextPrefix: 'You paid', status: 'Settled'),
    ]);
  }
}

/// Individual expense card widget.
class ExpenseCard extends StatelessWidget {
  final String title, amount, payerName, payerInitials, date, yourShare, status;
  final String shareTextPrefix;
  final Color payerColor;

  const ExpenseCard({
    super.key, required this.title, required this.amount, required this.payerName,
    required this.payerInitials, required this.payerColor, required this.date,
    required this.yourShare, this.shareTextPrefix = 'Your share: ', required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = status == 'Pending';
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB), borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 1),
        boxShadow: const [BoxShadow(color: Color.fromRGBO(56, 51, 46, 0.08), blurRadius: 18, offset: Offset(0, 3.6))],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: const Color(0xFFF0E8F7), borderRadius: BorderRadius.circular(11)),
          child: const Center(child: Text('🧾', style: TextStyle(fontSize: 16))),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14.6, color: const Color(0xFF38332E)), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 10),
            Text(amount, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16.5, color: const Color(0xFF38332E))),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Container(width: 18, height: 18, decoration: BoxDecoration(color: const Color(0xFFEEECE8), shape: BoxShape.circle, border: Border.all(color: payerColor, width: 2)),
              child: Center(child: Text(payerInitials, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 7, color: const Color(0xFF38332E))))),
            const SizedBox(width: 8),
            Text('Paid by ', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 12.8, color: const Color(0xFF8A8075))),
            Text(payerName, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 12.8, color: const Color(0xFF38332E))),
            const SizedBox(width: 6),
            Text('·', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 14.6, color: const Color(0xFF8A8075))),
            const SizedBox(width: 6),
            Text(date, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 12.8, color: const Color(0xFF8A8075))),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              if (shareTextPrefix == 'Your share: ')
                Text(shareTextPrefix, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 12.8, color: const Color(0xFF8A8075))),
              Text(
                shareTextPrefix == 'Your share: ' ? yourShare : '$shareTextPrefix $yourShare',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 12.8,
                    color: shareTextPrefix == 'Your share: ' ? const Color(0xFFD1475E) : const Color(0xFF339977)),
              ),
            ]),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPending ? const Color(0xFFFDF7E2) : const Color(0xFFE0F5EE),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Icon(isPending ? Icons.access_time : Icons.check_circle_outline,
                    color: isPending ? const Color(0xFFCFA117) : const Color(0xFF339977), size: 11),
                const SizedBox(width: 4),
                Text(status, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 11,
                    color: isPending ? const Color(0xFFCFA117) : const Color(0xFF339977))),
              ]),
            ),
          ]),
        ])),
      ]),
    );
  }
}
