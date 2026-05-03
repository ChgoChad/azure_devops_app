import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  const DetailRow({
    super.key,
    required this.title,
    required this.child,
    this.icon,
  });

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: context.colorScheme.primary),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  title,
                  style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: child),
      ],
    );
  }
}
