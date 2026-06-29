import 'package:flutter/material.dart';

class QueueTile
    extends StatelessWidget {

  final String queueNumber;
  final String patientName;
  final String doctorName;
  final String time;
  final String status;

  const QueueTile({
    super.key,
    required this.queueNumber,
    required this.patientName,
    required this.doctorName,
    required this.time,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(14),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),

      child: Row(
        children: [

          CircleAvatar(
            backgroundColor:
            Colors.green.shade100,

            child: Text(
              queueNumber,

              style: const TextStyle(
                color: Colors.green,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  patientName,

                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(doctorName),

                const SizedBox(height: 2),

                Text(
                  time,

                  style: TextStyle(
                    color: Colors
                        .grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Chip(
            label: Text(status),

            backgroundColor:
            Colors.green.shade50,
          ),
        ],
      ),
    );
  }
}