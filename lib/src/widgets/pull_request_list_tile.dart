import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/models/pull_request.dart';
import 'package:azure_devops/src/theme/dev_ops_icons_icons.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:flutter/material.dart';

class PullRequestListTile extends StatelessWidget {
  const PullRequestListTile({super.key, required this.onTap, required this.pr, required this.isLast});

  final VoidCallback onTap;
  final PullRequest pr;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!.copyWith(
      color: context.colorScheme.onSecondary.withValues(alpha: context.colorScheme.brightness == Brightness.dark ? 0.6 : 1),
    );
    return InkWell(
      key: ValueKey('pr_${pr.pullRequestId}'),
      onTap: onTap,
      child: Column(
        children: [
          ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(DevOpsIcons.pullrequest, color: context.colorScheme.primary),
              ],
            ),
            contentPadding: EdgeInsets.zero,
            minLeadingWidth: 20,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(pr.title, overflow: TextOverflow.ellipsis, style: context.textTheme.labelLarge),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: pr.status.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: pr.status.color.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    pr.isDraft && pr.status != PullRequestStatus.abandoned ? 'Draft' : pr.status.toString().toUpperCase(),
                    style: context.textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: pr.status.color,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text('!${pr.pullRequestId} ${pr.createdBy.displayName}', style: subtitleStyle),
                    Text(' in ', style: subtitleStyle),
                    Expanded(
                      child: Text(pr.repository.name, style: subtitleStyle, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 10),
                    Text(pr.creationDate.minutesAgo, style: subtitleStyle),
                  ],
                ),
              ],
            ),
          ),
          if (!isLast)
            AppLayoutBuilder(
              smartphone: const Divider(height: 1, thickness: 1),
              tablet: const Divider(height: 10, thickness: 1),
            ),
        ],
      ),
    );
  }
}
