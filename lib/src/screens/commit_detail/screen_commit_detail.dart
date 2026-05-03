
part of commit_detail;



class _CommitDetailScreen extends StatelessWidget {
  const _CommitDetailScreen(this.ctrl, this.parameters);

  final _CommitDetailController ctrl;
  final _CommitDetailParameters parameters;

  @override
  Widget build(BuildContext context) {

    return AppPage<CommitWithChanges?>(
      init: ctrl.init,
      title: 'Commit detail',
      actions: [IconButton(onPressed: ctrl.shareDiff, icon: Icon(DevOpsIcons.share))],
      notifier: ctrl.commitChanges,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      builder: (detail) {
        final author = detail!.commit.author;
        return DefaultTextStyle(
          style: context.textTheme.titleSmall!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(10), // Used literal double instead of AppTheme
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (author != null)
                      DetailRow(
                        title: 'Author:',
                        icon: DevOpsIcons.profile,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (ctrl.api.organization.isNotEmpty && author.imageUrl != null)
                              MemberAvatar(
                                // shows placeholder image for committers not inside the organization
                                imageUrl: author.imageUrl!.startsWith(ctrl.api.basePath) ? null : author.imageUrl,
                                userDescriptor: author.imageUrl!.split('/').last,
                                radius: 30,
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(author.name!, overflow: TextOverflow.ellipsis),
                            ),
                            Text(author.date!.minutesAgo),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    DetailRow(
                      title: 'Project:',
                      icon: DevOpsIcons.project,
                      child: ProjectChip(onTap: ctrl.goToProject, projectName: ctrl.args.project),
                    ),
                    const SizedBox(height: 8),
                    DetailRow(
                      title: 'Repository:',
                      icon: DevOpsIcons.repository,
                      child: RepositoryChip(onTap: ctrl.goToRepo, repositoryName: ctrl.args.repository),
                    ),
                    const SizedBox(height: 10),
                    DetailRow(
                      title: 'Message:',
                      icon: Icons.subject,
                      child: SelectableText(detail.commit.comment!),
                    ),
                    DetailRow(
                      title: 'CommitId:',
                      icon: DevOpsIcons.commit,
                      child: SelectableText(ctrl.args.commitId),
                    ),
                    const SizedBox(height: 20),
                    DetailRow(
                      title: 'Commit at:',
                      icon: Icons.calendar_month,
                      child: Text(author?.date?.toSimpleDate() ?? '-'),
                    ),
                    if (detail.commit.tags?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 20),
                      DetailRow(
                        title: 'Tags:',
                        icon: Icons.local_offer_outlined,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final tag in detail.commit.tags!)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(tag.name.trim(),
                                    style: context.textTheme.titleSmall!
                                        .copyWith(height: 1, color: context.colorScheme.primary)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    if (ctrl.addedFilesCount > 0)
                      GroupedFiles(
                        groupedFiles: ctrl.groupedAddedFiles,
                        onTap: (path) => ctrl.goToFileDiff(diff: path, isAdded: true),
                      ),
                    if (ctrl.editedFilesCount > 0)
                      GroupedFiles(
                        groupedFiles: ctrl.groupedEditedFiles,
                        onTap: (path) => ctrl.goToFileDiff(diff: path),
                      ),
                    if (ctrl.deletedFilesCount > 0)
                      GroupedFiles(
                        groupedFiles: ctrl.groupedDeletedFiles,
                        onTap: (path) => ctrl.goToFileDiff(diff: path, isDeleted: true),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
