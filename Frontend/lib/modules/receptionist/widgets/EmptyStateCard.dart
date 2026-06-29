import 'package:flutter/material.dart';

class EmptyStateCard
    extends StatelessWidget {

  final String title;
  final String subtitle;
  final IconData icon;

  const EmptyStateCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 360,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),

      child: Column(
        children: [

          // HEADER

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 18,
            ),

            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color:
                  Colors.grey.shade200,
                ),
              ),
            ),

            child: Row(
              children: [

                Icon(
                  icon,
                  color:
                  Colors.black87,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    title,

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BODY

          Expanded(
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  24,
                ),

                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [

                    Container(
                      padding:
                      const EdgeInsets
                          .all(24),

                      decoration:
                      BoxDecoration(
                        color: const Color(
                          0xFFF2FAF4,
                        ),

                        shape:
                        BoxShape.circle,
                      ),

                      child: Icon(
                        icon,
                        size: 42,
                        color:
                        Colors.green,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    Text(
                      "No Data Available",

                      style: TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,

                        color:
                        Colors.grey.shade800,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Text(
                      subtitle,

                      textAlign:
                      TextAlign.center,

                      style: TextStyle(
                        fontSize: 15,

                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}