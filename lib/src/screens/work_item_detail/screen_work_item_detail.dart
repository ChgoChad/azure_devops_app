part of work_item_detail;

IconData _getGroupIcon(String? group) {
  return switch (group?.toLowerCase()) {
    'planning' => DevOpsIcons.sprint,
    'classification' => Icons.category_outlined,
    'development' => DevOpsIcons.commit,
    'system' => DevOpsIcons.settings,
    _ => Icons.article_outlined,
  };
}

class _WorkItemDetailScreen extends StatelessWidget {
  const _WorkItemDetailScreen(this.ctrl, this.parameters);

  final _WorkItemDetailController ctrl;
  final _WorkItemDetailParameters parameters;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        AppPage<WorkItemWithUpdates?>(
          init: ctrl.init,
          dispose: ctrl.dispose,
          title: 'Work Item #${ctrl.args.id}',
          notifier: ctrl.itemDetail,
          actions: [
            ListenableBuilder(
              listenable: ctrl.itemDetail,
              builder: (_, _) => ctrl.itemDetail.value?.data?.item == null
                  ? const SizedBox()
                  : DevOpsPopupMenu(
                      tooltip: 'work item actions',
                      items: () => [
                        PopupItem(onTap: ctrl.shareWorkItem, text: 'Share', icon: DevOpsIcons.share),
                        PopupItem(onTap: ctrl.editWorkItem, text: 'Edit', icon: DevOpsIcons.edit),
                        PopupItem(onTap: ctrl.addAttachment, text: 'Add attachment', icon: DevOpsIcons.link),
                        if (![
                          'Test Suite',
                          'Test Plan',
                        ].contains(ctrl.itemDetail.value?.data?.item.fields.systemWorkItemType))
                          PopupItem(onTap: ctrl.deleteWorkItem, text: 'Delete', icon: DevOpsIcons.failed),
                      ],
                    ),
            ),
            const SizedBox(width: 8),
          ],
          builder: (detWithUpdates) {
            final detail = detWithUpdates!.item;
            final wType = ctrl.api.workItemTypes[detail.fields.systemTeamProject]?.firstWhereOrNull(
              (t) => t.name == detail.fields.systemWorkItemType,
            );
            final state = ctrl.api.workItemStates[detail.fields.systemTeamProject]?[detail.fields.systemWorkItemType]
                ?.firstWhereOrNull((t) => t.name == detail.fields.systemState);

            return DefaultTextStyle(
              style: context.textTheme.titleSmall!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      WorkItemTypeIcon(type: wType),
                      const SizedBox(width: 20),
                      Text(detail.fields.systemWorkItemType.toUpperCase()),
                      const SizedBox(width: 10),
                      Text('#${detail.id}'),
                      const Spacer(),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: state == null || state.color.isEmpty
                              ? context.colorScheme.secondaryContainer
                              : Color(int.parse(state.color.replaceFirst('#', ''), radix: 16)).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: state == null || state.color.isEmpty
                                ? Colors.transparent
                                : Color(int.parse(state.color.replaceFirst('#', ''), radix: 16)).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          detail.fields.systemState.toUpperCase(),
                          style: context.textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: state == null || state.color.isEmpty
                                ? null
                                : Color(int.parse(state.color.replaceFirst('#', ''), radix: 16)).withValues(alpha: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface,
                      borderRadius: BorderRadius.circular(AppTheme.radius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.subject, size: 14, color: context.colorScheme.primary),
                            const SizedBox(width: 4),
                            Text('Title',
                                style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary)),
                          ],
                        ),
                        SelectableText(
                          detail.fields.systemTitle,
                          style: context.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        if (detail.fields.systemCreatedBy != null)
                          DetailRow(
                            title: 'Created by:',
                            icon: DevOpsIcons.profile,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (ctrl.api.organization.isNotEmpty)
                                  MemberAvatar(userDescriptor: detail.fields.systemCreatedBy!.descriptor, radius: 30),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    detail.fields.systemCreatedBy!.displayName ?? '',
                                    style: context.textTheme.titleSmall,
                                    maxLines: 1,
                                  ),
                                ),
                                Text(detail.fields.systemCreatedDate?.minutesAgo ?? ''),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        DetailRow(
                          title: 'Project:',
                          icon: DevOpsIcons.project,
                          child: GestureDetector(
                            onTap: ctrl.goToProject,
                            child: Text(
                              detail.fields.systemTeamProject,
                              style: context.textTheme.titleSmall!.copyWith(decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        DetailRow(
                          title: 'Area:',
                          icon: Icons.account_tree_outlined,
                          child: SelectableText(detail.fields.systemAreaPath, style: context.textTheme.titleSmall),
                        ),
                        const SizedBox(height: 8),
                        DetailRow(
                          title: 'Iteration:',
                          icon: DevOpsIcons.sprint,
                          child: SelectableText(detail.fields.systemIterationPath, style: context.textTheme.titleSmall),
                        ),
                        if (detail.fields.systemTags != null) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(Icons.local_offer_outlined, size: 14, color: context.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text('Tags',
                                  style:
                                      context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final tag in detail.fields.systemTags!.split(';'))
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(tag.trim(),
                                      style: context.textTheme.titleSmall!
                                          .copyWith(height: 1, color: context.colorScheme.primary)),
                                ),
                            ],
                          ),
                        ],
                        if (detail.workItemLinks.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Icon(DevOpsIcons.link, size: 14, color: context.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text('Links',
                                  style:
                                      context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final link in detail.workItemLinks)
                                Builder(
                                  builder: (context) {
                                    final hasComment = (link.attributes?.comment ?? '').isNotEmpty;
                                    return GestureDetector(
                                      onTap: () => ctrl.goToWorkItemDetail(link),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: context.colorScheme.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(100),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(DevOpsIcons.link, size: 14, color: context.colorScheme.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              link.toReadableString(),
                                              style: context.textTheme.titleSmall!
                                                  .copyWith(height: 1, color: context.colorScheme.primary),
                                            ),
                                            if (hasComment) ...[
                                              const SizedBox(width: 8),
                                              DevOpsPopupMenu(
                                                tooltip: link.toReadableString(),
                                                items: () =>
                                                    [PopupItem(text: link.attributes?.comment ?? '', onTap: () {})],
                                                offset: Offset(0, 20),
                                                child: Icon(Icons.forum_outlined, size: 16),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ],
                        if (detail.fields.systemAssignedTo != null) ...[
                          const SizedBox(height: 20),
                          DetailRow(
                            title: 'Assigned to:',
                            icon: DevOpsIcons.profile,
                            child: Row(
                              children: [
                                if (ctrl.api.organization.isNotEmpty)
                                  MemberAvatar(userDescriptor: detail.fields.systemAssignedTo!.descriptor, radius: 30),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SelectableText(
                                    detail.fields.systemAssignedTo!.displayName ?? '',
                                    style: context.textTheme.titleSmall,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  for (final entry in ctrl.fieldsToShow.entries)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ctrl.shouldShowGroupLabel(group: entry.key)) ...[
                          SectionHeader.withIcon(
                            text: entry.key,
                            icon: _getGroupIcon(entry.key),
                          ),
                          const Divider(),
                        ],
                        for (final field in entry.value)
                          Builder(
                            builder: (context) {
                              final textToShow = detail.fields.jsonFields[field.referenceName] ?? field.defaultValue;
                              if (textToShow == null || textToShow.toString().isEmpty) {
                                return const SizedBox();
                              }

                              final shouldShowFieldName = entry.value.length > 1 || field.name != entry.key;

                              GraphUser? userField;

                              if (field.isIdentity) {
                                final userJson = detail.fields.jsonFields[field.referenceName];
                                if (userJson != null) {
                                  try {
                                    userField = GraphUser.fromJson(userJson as Map<String, dynamic>);
                                  } catch (_) {
                                    // ignore
                                  }
                                }
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (shouldShowFieldName)
                                    Text(
                                      field.name,
                                      style: context.textTheme.titleSmall!.copyWith(
                                        color: context.colorScheme.onSecondary,
                                      ),
                                    ),
                                  if (field.type == 'html')
                                    HtmlWidget(data: textToShow.toString(), style: context.textTheme.titleSmall)
                                  else if (field.isIdentity && userField != null)
                                    Row(
                                      children: [
                                        Text(userField.displayName ?? '-', style: context.textTheme.titleSmall),
                                        const SizedBox(width: 8),
                                        MemberAvatar(userDescriptor: userField.descriptor, radius: 20),
                                      ],
                                    )
                                  else
                                    SelectableText(textToShow!.toString().formatted),
                                ],
                              );
                            },
                          ),
                      ],
                    ),
                  const SizedBox(height: 40),
                  DetailRow(
                    title: 'Created at:',
                    icon: Icons.calendar_month,
                    child: Text(detail.fields.systemCreatedDate?.toSimpleDate() ?? '', style: context.textTheme.titleSmall),
                  ),
                  const SizedBox(height: 10),
                  DetailRow(
                    title: 'Modified at:',
                    icon: Icons.edit_calendar,
                    child: Text(detail.fields.systemChangedDate.toSimpleDate(), style: context.textTheme.titleSmall),
                  ),
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: SectionHeader.noMargin(text: 'History', icon: Icons.history)),
                          IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 20,
                            constraints: const BoxConstraints(),
                            onPressed: ctrl.toggleShowUpdatesReversed,
                            icon: const Icon(Icons.swap_vert),
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 5),
                      VisibilityDetector(
                        key: ctrl.historyKey,
                        onVisibilityChanged: ctrl.onHistoryVisibilityChanged,
                        child: ValueListenableBuilder(
                          valueListenable: ctrl.showUpdatesReversed,
                          builder: (_, showUpdatesReversed, _) {
                            final updates = showUpdatesReversed ? ctrl.updates.reversed.toList() : ctrl.updates;
                            return _History(updates: updates, ctrl: ctrl);
                          },
                        ),
                      ),
                      ValueListenableBuilder(
                        valueListenable: ctrl.showCommentField,
                        builder: (_, value, _) => SizedBox(height: value ? 100 : 0),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        AddCommentField(isVisible: ctrl.showCommentField, onTap: ctrl.addComment),
      ],
    );
  }
}
