import 'package:azure_devops/src/models/work_item_updates.dart';
import 'package:azure_devops/src/models/work_items.dart';
import 'package:azure_devops/src/screens/work_item_detail/base_work_item_detail.dart';
import 'package:azure_devops/src/services/azure_api_service.dart';
import 'package:azure_devops/src/services/storage_service.dart';
import 'package:azure_devops/src/widgets/add_comment_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

import 'api_service_mock.dart';

class _WorkItemDetailMock extends AzureApiServiceMock {
  @override
  Future<ApiResponse<WorkItemWithUpdates>> getWorkItemDetail({
    required String projectName,
    required int workItemId,
  }) async {
    return ApiResponse.ok(
      WorkItemWithUpdates(
        item: WorkItem(
          id: 1234,
          rev: 0,
          fields: ItemFields(
            systemTeamProject: 'TestProject',
            systemAreaPath: 'TestArea',
            systemIterationPath: 'TestIteration',
            systemWorkItemType: 'TestType',
            systemState: 'Active',
            systemCreatedDate: DateTime.now(),
            systemChangedDate: DateTime.now(),
            systemTitle: 'Test work item title',
            systemReason: '',
            systemCommentCount: 0,
            microsoftVstsCommonStateChangeDate: DateTime.now(),
            systemAssignedTo: WorkItemUser(
              id: '',
              imageUrl: '',
              descriptor: '',
              uniqueName: 'Test User Assignee',
              displayName: 'Test User Assignee',
            ),
            systemCreatedBy: WorkItemUser(
              id: '',
              imageUrl: '',
              descriptor: '',
              uniqueName: 'Test User Creator',
              displayName: 'Test User Creator',
            ),
            systemChangedBy: WorkItemUser(
              id: '',
              imageUrl: '',
              descriptor: '',
              uniqueName: 'Test User Creator',
              displayName: 'Test User Creator',
            ),
          ),
        ),
        updates: [
          CommentItemUpdate(
            id: 1,
            workItemId: 1234,
            text: 'Test comment 1',
            updatedBy: UpdateUser(
              descriptor: '',
              displayName: 'Test User',
            ),
            updateDate: DateTime.now(),
            format: 'markdown',
          ),
        ],
      ),
    );
  }
}

/// Mock work item is taken from [_WorkItemDetailMock.getWorkItemDetail]
void main() {
  setUp(() => VisibilityDetectorController.instance.updateInterval = Duration.zero);

  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Page building test', (t) async {
    final app = AzureApiServiceWidget(
      api: _WorkItemDetailMock(),
      child: StorageServiceWidget(
        storage: StorageServiceMock(),
        child: MaterialApp(
          theme: mockTheme,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => WorkItemDetailPage(),
            settings: RouteSettings(arguments: (project: 'TestProject', id: 1234)),
          ),
        ),
      ),
    );

    await t.pumpWidget(app);

    await t.pump();

    expect(find.byType(WorkItemDetailPage), findsOneWidget);
    expect(find.textContaining('Work Item #1234'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Test work item title'), findsOneWidget);
    expect(find.text('TestProject'), findsOneWidget);
    expect(find.byType(AddCommentField), findsOneWidget);

    // Check if history is rendered
    expect(find.text('History'), findsOneWidget);

    // Check if comment is rendered
    expect(find.text('Test comment 1'), findsOneWidget);
  });
}
