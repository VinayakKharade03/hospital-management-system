import 'package:flutter/material.dart';

class SideMenuItem extends StatelessWidget {

  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;
  final bool expanded;

  const SideMenuItem({
    super.key,

    required this.icon,
    required this.title,
    required this.onTap,

    this.selected = false,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 6,
      ),

      child: InkWell(

        borderRadius:
        BorderRadius.circular(14),

        onTap: onTap,

        child: AnimatedContainer(

          duration:
          const Duration(
            milliseconds: 200,
          ),

          height: 62,

          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          decoration: BoxDecoration(

            gradient: selected
                ? const LinearGradient(
              colors: [
                Color(0xFF18864B),
                Color(0xFF2FA15F),
              ],
            )
                : null,

            color:
            selected
                ? null
                : Colors.transparent,

            borderRadius:
            BorderRadius.circular(14),
          ),

          child: Row(
            children: [

              Icon(

                icon,
                size: 24,

                color: selected
                    ? Colors.white
                    : Colors.black87,
              ),

              if (expanded) ...[

                const SizedBox(
                  width: 16,
                ),

                Expanded(
                  child: Text(

                    title,

                    maxLines: 1,

                    overflow:
                    TextOverflow.ellipsis,

                    style: TextStyle(

                      fontSize: 16,

                      fontWeight:
                      FontWeight.w500,

                      color: selected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}