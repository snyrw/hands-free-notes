import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/template.dart';
import 'package:one_touch/Pages/session_create.dart';
import 'package:one_touch/Pages/note_session.dart';

void main() {
  group('Widget Tests', () {
    late Template mockTemplate;
    late List<Map<String, dynamic>> saveCallbackCalls;

    setUp(() {
      mockTemplate = Template(id: 'test-id', name: 'Test Template');
      saveCallbackCalls = [];
    });

    void mockCallback(Template template, String action) {
      saveCallbackCalls.add({'template': template, 'action': action});
    }

    testWidgets('displays template name in AppBar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is RichText &&
              (widget.text as TextSpan).toPlainText().contains('Test Template'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays session title TextField', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Session Title'), findsOneWidget);
    });

    testWidgets('can enter text in TextField', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'My Session');
      await tester.pump();

      expect(find.text('My Session'), findsOneWidget);
    });

    testWidgets('displays create button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      expect(find.text('Create new session'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    late Template mockTemplate;
    late List<Map<String, dynamic>> saveCallbackCalls;

    setUp(() {
      mockTemplate = Template(id: 'test-id', name: 'Test Template');
      saveCallbackCalls = [];
    });

    void mockCallback(Template template, String action) {
      saveCallbackCalls.add({'template': template, 'action': action});
    }

    testWidgets('creates session with entered title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'New Session');
      await tester.tap(find.text('Create new session'));
      await tester.pumpAndSettle();

      expect(saveCallbackCalls.length, 1);
      expect(saveCallbackCalls[0]['action'], 'addSession');
      expect(saveCallbackCalls[0]['template'].name, 'New Session');
    });

    testWidgets('navigates to NoteSession after creation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.tap(find.text('Create new session'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteSession), findsOneWidget);
    });

    testWidgets('creates session with new ID', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SessionCreate(
            template: mockTemplate,
            saveTemplatesCallback: mockCallback,
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.tap(find.text('Create new session'));
      await tester.pumpAndSettle();

      final createdSession = saveCallbackCalls[0]['template'];
      expect(createdSession.id, isNot(mockTemplate.id));
      expect(createdSession.id, isNotEmpty);
    });
  });
}
