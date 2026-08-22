import 'package:flutter/material.dart';
import '../../data/models/book.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    switch (status) {
      case Book.STATUS_APPROVED:
        color = Colors.green;
        text = 'Aprobado';
        break;
      case Book.STATUS_PENDING:
        color = Colors.orange;
        text = 'Pendiente';
        break;
      case Book.STATUS_REJECTED:
        color = Colors.red;
        text = 'Rechazado';
        break;
      case Book.STATUS_SUSPENDED:
        color = Colors.grey;
        text = 'Suspendido';
        break;
      case Book.STATUS_DRAFT:
        color = Colors.blue;
        text = 'Borrador';
        break;
      default:
        color = Colors.black;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
