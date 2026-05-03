import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/extensions/datetime_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_result_extension.dart';
import 'package:azure_devops/src/extensions/pipeline_status_extension.dart';
import 'package:azure_devops/src/models/pipeline.dart';
import 'package:azure_devops/src/widgets/app_base_page.dart';
import 'package:flutter/material.dart';

class PipelineListTile extends StatelessWidget {
  const PipelineListTile({super.key, required this.onTap, required this.pipe, required this.isLast});

  final VoidCallback onTap;
  final Pipeline pipe;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = context.textTheme.bodySmall!.copyWith(
      color: context.colorScheme.onSecondary.withValues(alpha: context.colorScheme.brightness == Brightness.dark ? 0.6 : 1),
    );
    final isCustomPipelineName = pipe.definition?.name != null && pipe.definition!.name! != pipe.repository?.name;

    final statusText = (pipe.status == PipelineStatus.completed ? pipe.result?.toString() : pipe.status?.toString()) ?? '';
    final statusColor = (pipe.status == PipelineStatus.completed ? pipe.result?.color : pipe.status?.color) ?? Colors.grey;

    return InkWell(
      onTap: onTap,
      key: ValueKey('pipeline_${pipe.id}'),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                if (pipe.status == PipelineStatus.inProgress && pipe.approvals.isNotEmpty)
                  const Icon(Icons.warning, color: Colors.orange)
                else
                  pipe.status == PipelineStatus.completed ? pipe.result.icon : pipe.status.icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pipe.triggerInfo?.ciMessage ?? pipe.reason ?? '',
                              style: context.textTheme.labelLarge,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: statusColor.withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              statusText.toUpperCase(),
                              style: context.textTheme.labelSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(pipe.requestedFor?.displayName ?? '', style: subtitleStyle),
                          Text(' in ', style: subtitleStyle),
                          Expanded(
                            child: Text(
                              pipe.repository?.name ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: subtitleStyle,
                            ),
                          ),
                        ],
                      ),
                      if (isCustomPipelineName) ...[
                        const SizedBox(height: 3),
                        Text(pipe.definition?.name ?? '', style: subtitleStyle),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(pipe.startTime?.minutesAgo ?? '', style: subtitleStyle),
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
