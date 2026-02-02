import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_touch/Objects/template.dart';
import 'package:one_touch/Objects/note.dart';
import 'package:one_touch/Pages/session_summary.dart';

void main() {
  group('Unit Tests', () {
    test('generatePdf returns true', () {
      final template = Template(name: 'Test Session');
      final summary = SessionSummary(template: template);

      expect(summary.generatePdf(), true);
    });

    test('generatePdf adds page to pdf document', () {
      final template = Template(name: 'Session');
      template.add(SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Question?',
        options: ['A', 'B'],
      ));
      final summary = SessionSummary(template: template);

      summary.generatePdf();

      expect(summary.pdf.document.pdfPageList.pages.length, 1);
    });
  });

  group('Widget Tests', () {
    testWidgets('displays session name', (tester) async {
      final template = Template(name: 'My Session');

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      expect(find.text('My Session'), findsOneWidget);
    });

    testWidgets('displays ListView with notes', (tester) async {
      final template = Template(name: 'Test');
      template.add(SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Pick one',
        options: ['Yes', 'No'],
      ));

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('displays all note questions', (tester) async {
      final template = Template(name: 'Test');
      template.add(SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Question 1',
        options: ['A'],
      ));
      template.add(MultipleChoiceNote(
        noteType: NoteType.multipleChoice,
        question: 'Question 2',
        options: ['B'],
        maxSelections: 1,
      ));

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      expect(find.text('Question 1'), findsOneWidget);
      expect(find.text('Question 2'), findsOneWidget);
    });

    testWidgets('displays Export Notes button', (tester) async {
      final template = Template(name: 'Test');

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      expect(find.text('Export Notes'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays note values when answered', (tester) async {
      final template = Template(name: 'Test');
      final note = SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Pick',
        options: ['Yes', 'No'],
      );
      note.selection = 0;
      template.add(note);

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('shows snackbar after export button tap', (tester) async {
      final template = Template(name: 'Export Test');

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      await tester.tap(find.text('Export Notes'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('PDF exported as'), findsOneWidget);
    });
  });

  group('Integration Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('session_summary_test_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('pdf.save() produces bytes', () async {
      final template = Template(name: 'test_session');
      template.add(SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'Test?',
        options: ['Yes'],
      ));
      final summary = SessionSummary(template: template);

      summary.generatePdf();
      final bytes = await summary.pdf.save();

      expect(bytes, isNotEmpty);
      expect(bytes.length, greaterThan(0));
    });

    testWidgets('complete flow: display and export with multiple notes', (tester) async {
      final template = Template(name: 'Full Test');
      final note1 = SingleChoiceNote(
        noteType: NoteType.singleChoice,
        question: 'How are you?',
        options: ['Good', 'Bad'],
      );
      note1.selection = 0;
      
      final note2 = MultipleChoiceNote(
        noteType: NoteType.multipleChoice,
        question: 'Select colors',
        options: ['Red', 'Blue', 'Green'],
        maxSelections: 2,
      );
      note2.selection = [0, 2];
      
      template.add(note1);
      template.add(note2);

      await tester.pumpWidget(
        MaterialApp(home: SessionSummary(template: template)),
      );

      expect(find.text('Full Test'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Red, Green'), findsOneWidget);

      await tester.tap(find.text('Export Notes'));
      await tester.pump();

      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}