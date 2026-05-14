part of pull_request_detail;

class _LocalDetailRow extends StatelessWidget {
  const _LocalDetailRow({
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
                  overflow: TextOverflow.visible,
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




class _PullRequestActions extends StatelessWidget {
  const _PullRequestActions({required this.ctrl});

  final _PullRequestDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    final pr = ctrl.prDetail.value!.data!.pr;
    final prStatus = pr.status;
    final isNotCompletedOrAbandoned = ![PullRequestStatus.completed, PullRequestStatus.abandoned].contains(prStatus);
    final isDraft = pr.isDraft;
    final isMerging = pr.mergeStatus == MergeStatus.queued;

    return DevOpsPopupMenu(
      tooltip: 'pull request actions',
      constraints: BoxConstraints(minWidth: 150),
      items: () => [
        PopupItem(onTap: ctrl.sharePr, text: 'Share', icon: DevOpsIcons.share),
        if (!isMerging) ...[
          if (isNotCompletedOrAbandoned && !isDraft) ...[
            PopupItem(onTap: ctrl.approve, text: 'Approve', icon: DevOpsIcons.success),
            PopupItem(onTap: ctrl.approveWithSugestions, text: 'Approve with suggestions', icon: DevOpsIcons.success),
            PopupItem(onTap: ctrl.waitForAuthor, text: 'Wait for the author', icon: DevOpsIcons.queuedsolid),
            PopupItem(onTap: ctrl.reject, text: 'Reject', icon: DevOpsIcons.failed),
          ],
          if (isNotCompletedOrAbandoned && isDraft)
            PopupItem(onTap: ctrl.publish, text: 'Publish', icon: DevOpsIcons.send)
          else if (isNotCompletedOrAbandoned)
            PopupItem(onTap: ctrl.markAsDraft, text: 'Mark as draft', icon: DevOpsIcons.draft),
          if (prStatus == PullRequestStatus.active) ...[
            if (ctrl.hasAutoCompleteOn)
              PopupItem(
                onTap: () => ctrl.setAutocomplete(autocomplete: false),
                text: 'Cancel auto-complete',
                icon: DevOpsIcons.autocomplete,
              )
            else if (ctrl.mustSatisfyPolicies || ctrl.mustBeApproved)
              PopupItem(
                onTap: () => ctrl.setAutocomplete(autocomplete: true),
                text: 'Set auto-complete',
                icon: DevOpsIcons.autocomplete,
              )
            else if (!isDraft)
              PopupItem(onTap: ctrl.complete, text: 'Complete', icon: DevOpsIcons.merge),
            PopupItem(onTap: ctrl.abandon, text: 'Abandon', icon: DevOpsIcons.trash),
          ],
          if (prStatus == PullRequestStatus.abandoned && ctrl.canBeReactivated)
            PopupItem(onTap: ctrl.reactivate, text: 'Reactivate', icon: DevOpsIcons.send),
        ],
      ],
    );
  }
}

class _PageTabs extends StatelessWidget {
  const _PageTabs({required this.ctrl, required this.visiblePage, required this.prWithDetails});

  final _PullRequestDetailController ctrl;
  final int visiblePage;
  final PullRequestWithDetails prWithDetails;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: visiblePage,
      children: [
        _PullRequestOverview(ctrl: ctrl, visiblePage: visiblePage, prWithDetails: prWithDetails),
        _PullRequestChangedFiles(ctrl: ctrl, visiblePage: visiblePage),
        _PullRequestCommits(ctrl: ctrl, visiblePage: visiblePage, prWithDetails: prWithDetails),
      ],
    );
  }
}

class _PullRequestOverview extends StatelessWidget {
  const _PullRequestOverview({required this.ctrl, required this.visiblePage, required this.prWithDetails});

  final _PullRequestDetailController ctrl;
  final int visiblePage;
  final PullRequestWithDetails prWithDetails;

  @override
  Widget build(BuildContext context) {
    final pr = prWithDetails.pr;
    return VisibilityDetector(
      key: ctrl.historyKey,
      onVisibilityChanged: ctrl.onHistoryVisibilityChanged,
      child: Visibility(
        visible: visiblePage == 0,
        child: DefaultTextStyle(
          style: context.textTheme.titleSmall!,
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
                pr.title,
                style: context.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (ctrl.hasAutoCompleteOn) ...[
                _LocalDetailRow(
                  title: 'Auto-complete:',
                  icon: DevOpsIcons.autocomplete,
                  child: Text(
                    '${prWithDetails.pr.autoCompleteSetBy!.displayName} set this pull request to automatically complete when all requirements are met.',
                  ),
                ),
                const SizedBox(height: 10),
              ],
              _LocalDetailRow(
                title: 'Id:',
                icon: Icons.tag,
                child: Text(pr.pullRequestId.toString()),
              ),
              const SizedBox(height: 10),
              _LocalDetailRow(
                title: 'Status:',
                icon: Icons.info_outline,
                child: Row(
                  children: [
                   Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pr.status.color.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(ctrl.prStatus, style: context.textTheme.titleSmall!.copyWith(color: pr.status.color)),
                          if (ctrl.isMerging)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: InProgressPipelineIcon(
                                child: Icon(Icons.refresh_rounded, color: pr.status.color, size: 14),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _LocalDetailRow(
                      title: 'Created by:',
                      icon: DevOpsIcons.profile,
                      child: Row(
                        children: [
                          MemberAvatar(userDescriptor: pr.createdBy.descriptor, radius: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pr.createdBy.displayName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(pr.creationDate.minutesAgo),
                ],
              ),
              const SizedBox(height: 20),
              _LocalDetailRow(
                title: 'Project:',
                icon: DevOpsIcons.project,
                child: ProjectChip(onTap: ctrl.goToProject, projectName: pr.repository.project.name),
              ),
              const SizedBox(height: 8),
              _LocalDetailRow(
                title: 'Repository:',
                icon: DevOpsIcons.repository,
                child: RepositoryChip(onTap: ctrl.goToRepo, repositoryName: pr.repository.name),
              ),
              const SizedBox(height: 16),
              _LocalDetailRow(
                title: 'From:',
                icon: Icons.call_split,
                child: Text(pr.sourceBranch),
              ),
              const SizedBox(height: 8),
              _LocalDetailRow(
                title: 'To:',
                icon: Icons.merge,
                child: Text(pr.targetBranch),
              ),
              const SizedBox(height: 10),
              if (prWithDetails.conflicts.isNotEmpty) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: context.colorScheme.error, width: 2),
                  ),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: GroupedFiles(bottomSpace: false, groupedFiles: ctrl.groupedConflictingFiles),
                ),
              ] else if (ctrl.mustSatisfyPolicies) ...[
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: context.colorScheme.error, width: 2),
                  ),
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: _MissingPolicies(ctrl: ctrl),
                ),
              ],
              if (pr.description != null && pr.description!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.subject, size: 14, color: context.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Description',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary)),
                  ],
                ),
                const SizedBox(height: 5),
                AppMarkdownWidget(
                  data: '${pr.description}',
                  styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                      .copyWith(p: context.textTheme.titleSmall),
                  onTapLink: ctrl.onTapMarkdownLink,
                ),
                const SizedBox(height: 20),
              ],
              if (pr.mergeStatus != null && pr.mergeStatus!.isNotEmpty)
                _LocalDetailRow(
                  title: 'Merge status:',
                  icon: DevOpsIcons.merge,
                  child: Text('${pr.mergeStatus}'),
                ),
              const SizedBox(height: 10),
              _LocalDetailRow(
                title: 'Created at:',
                icon: Icons.calendar_month,
                child: Text(pr.creationDate.toSimpleDate()),
              ),
              if (pr.reviewers.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(DevOpsIcons.users, size: 14, color: context.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Reviewers',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: pr.reviewers.map(
                    (r) {
                      final reviewer = r;
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            MemberAvatar(
                              userDescriptor: ctrl.reviewers.firstWhere((rev) => rev.reviewer.id == reviewer.id).descriptor,
                              radius: 20,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Text(
                                '${reviewer.displayName}${reviewer.isRequired ? ' (required)' : ''}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            if (reviewer.vote > 0)
                              Icon(DevOpsIcons.success, color: Colors.green)
                            else if (reviewer.vote < 0)
                              Icon(DevOpsIcons.failed, color: context.colorScheme.error),
                          ],
                        ),
                      );
                    },
                  ).toList(),
                ),
              ],
              if (prWithDetails.updates.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(Icons.history, size: 14, color: context.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('History',
                        style: context.textTheme.titleSmall!.copyWith(color: context.colorScheme.onSecondary)),
                  ],
                ),
                const SizedBox(height: 5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: prWithDetails.updates.map(
                    (u) {
                      final update = u;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: switch (update) {
                                  VoteUpdate() => Row(
                                    children: [
                                      if (update.content.voteIcon != null) ...[update.content.voteIcon!, const SizedBox(width: 10)],
                                      _UserAvatar(update: update),
                                      Expanded(child: Text('${update.author.displayName} ${update.content.voteDescription}')),
                                    ],
                                  ),
                                  StatusUpdate() => Row(
                                    children: [
                                      _UserAvatar(update: update),
                                      Expanded(
                                        child: Text(
                                          '${update.identity['displayName'] ?? update.author.displayName} ${update.content.statusUpdateDescription} the pull request',
                                        ),
                                      ),
                                    ],
                                  ),
                                  IterationUpdate() => _RefUpdateWidget(ctrl: ctrl, iteration: update),
                                  ThreadUpdate() => Column(
                                    children: update.comments
                                        .map(
                                          (c) => PullRequestCommentCard(
                                            onEditComment: !ctrl.canEditPrComment(c)
                                                ? null
                                                : () => ctrl.editComment(c, threadId: update.id),
                                            onAddComment: () => ctrl.addComment(threadId: update.id, parentCommentId: c.id),
                                            onDeleteComment: !ctrl.canEditPrComment(c)
                                                ? null
                                                : () => ctrl.deleteComment(c, threadId: update.id),
                                            comment: c,
                                            threadId: update.id,
                                            borderRadiusBottom: update.comments.length < 2 || c == update.comments.last,
                                            borderRadiusTop: update.comments.length < 2 || c == update.comments.first,
                                            threadContext: update.threadContext,
                                            onGoToFileDiff: () => ctrl.goToFileDiff(filePath: update.threadContext?.filePath),
                                            status: c == update.comments.first ? update.status : null,
                                            onSetStatus: (s) => ctrl.setStatus(update, s),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                  SystemUpdate() || _ => Row(
                                    children: [
                                      _UserAvatar(update: update),
                                      Expanded(child: Text(update.content)),
                                    ],
                                  ),
                                },
                              ),
                              if (update is! ThreadUpdate) ...[const SizedBox(width: 10), Text(update.date.minutesAgo)],
                            ],
                          ),
                          const Divider(height: 30),
                        ],
                      );
                    }).toList(),
                ),
              ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    MemberAvatar(userDescriptor: pr.createdBy.descriptor, radius: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('${pr.createdBy.displayName} created the pull request')),
                    Text(pr.creationDate.minutesAgo),
                  ],
                ),
              ],
          ),
        ),
      ),
    );
  }
}

class _MissingPolicies extends StatelessWidget {
  const _MissingPolicies({required this.ctrl});

  final _PullRequestDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('This pull request cannot be completed because some requirements are not satisfied:'),
        const SizedBox(height: 8),
        ...ctrl.missingPolicies.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Icon(DevOpsIcons.failed, color: context.colorScheme.error, size: AppTheme.isTablet ? 24 : 16),
                const SizedBox(width: 8),
                Text(p.configuration?.type?.displayName ?? 'Unknown policy'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PullRequestChangedFiles extends StatelessWidget {
  const _PullRequestChangedFiles({required this.visiblePage, required this.ctrl});

  final int visiblePage;
  final _PullRequestDetailController ctrl;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visiblePage == 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ctrl.addedFilesCount > 0)
            GroupedFiles(
              groupedFiles: ctrl.groupedAddedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff, isAdded: true),
            ),
          if (ctrl.editedFilesCount > 0)
            GroupedFiles(
              groupedFiles: ctrl.groupedEditedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff),
            ),
          if (ctrl.deletedFilesCount > 0)
            GroupedFiles(
              groupedFiles: ctrl.groupedDeletedFiles,
              onTap: (diff) => ctrl.goToFileDiff(diff: diff, isDeleted: true),
            ),
        ],
      ),
    );
  }
}

class _PullRequestCommits extends StatelessWidget {
  const _PullRequestCommits({required this.visiblePage, required this.ctrl, required this.prWithDetails});

  final int visiblePage;
  final _PullRequestDetailController ctrl;
  final PullRequestWithDetails prWithDetails;

  @override
  Widget build(BuildContext context) {
    final commits = prWithDetails.updates.whereType<IterationUpdate>().expand((u) => u.commits);
    return Visibility(
      visible: visiblePage == 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commits
            .map(
              (commit) => CommitListTile(
                onTap: () => ctrl.goToCommitDetail(commit.commitId!),
                commit: commit.copyWith(
                  remoteUrl:
                      '${ctrl.api.basePath}/${prWithDetails.pr.repository.project.name}/_git/${prWithDetails.pr.repository.name}/commit/${commit.commitId}',
                ),
                isLast: commit == commits.last,
              ),
            )
            .toList(),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.update});

  final PullRequestUpdate update;

  @override
  Widget build(BuildContext context) {
    if ((update.author.uniqueName.isEmpty) && (update.identity == null)) {
      return const SizedBox();
    }

    return Row(
      children: [
        if (update.author.uniqueName.isNotEmpty) ...[
          MemberAvatar(userDescriptor: update.author.descriptor, radius: 20),
          const SizedBox(width: 10),
        ] else if (update.identity != null) ...[
          MemberAvatar(userDescriptor: update.identity['descriptor']?.toString() ?? '', radius: 20),
          const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _RefUpdateWidget extends StatelessWidget {
  const _RefUpdateWidget({required this.ctrl, required this.iteration});

  final _PullRequestDetailController ctrl;
  final IterationUpdate iteration;

  @override
  Widget build(BuildContext context) {
    final commits = iteration.commits;
    final committerDescriptor = iteration.author.descriptor;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: context.colorScheme.secondaryContainer,
          ),
          child: Center(child: Text(iteration.id.toString(), style: context.textTheme.bodyMedium)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  MemberAvatar(userDescriptor: committerDescriptor, radius: 15),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${iteration.author.displayName} pushed ${commits.length} commit${commits.length == 1 ? '' : 's'}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...commits.map(
                (c) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.comment ?? '-', style: context.textTheme.labelMedium, overflow: TextOverflow.ellipsis),
                    DefaultTextStyle(
                      style: context.textTheme.bodySmall!,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: c.commitId == null ? null : () => ctrl.goToCommitDetail(c.commitId!),
                            child: Text(
                              c.commitId?.substring(0, 8) ?? '-',
                              style: DefaultTextStyle.of(
                                context,
                              ).style.copyWith(decoration: c.commitId == null ? null : TextDecoration.underline),
                            ),
                          ),
                          const SizedBox(width: 10),
                          MemberAvatar(userDescriptor: committerDescriptor, radius: 15),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              c.author?.name ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(c.author?.date?.minutesAgo ?? ''),
                        ],
                      ),
                    ),
                    if (commits.isNotEmpty && c != commits.last) const Divider(endIndent: 40, thickness: .5),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
