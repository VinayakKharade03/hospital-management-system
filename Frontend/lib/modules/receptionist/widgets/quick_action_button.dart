import 'package:flutter/material.dart';

class QuickActionCard
    extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      borderRadius:
      BorderRadius.circular(18),

      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 26,
          horizontal: 20,
        ),

        decoration: BoxDecoration(
          color: const Color(0xFFF4FAF6),

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: Colors.green.shade100,
          ),
        ),

        child: Row(
          children: [

            Container(
              padding:
              const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color:
                Colors.green.shade100,

                borderRadius:
                BorderRadius.circular(
                  14,
                ),
              ),

              child: Icon(
                icon,
                color:
                const Color(0xFF18864B),
                size: 30,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(
              child: Text(
                title,

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}