import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focus_flow/core/widgets/mobile_navigation.dart';

void main() {
  testWidgets('FAB top half and bottom half are clickable in MobileNavigation',
      (WidgetTester tester) async {
    bool addTaskTapped = false;
    int tappedPageIndex = -1;
    bool pageTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MobileNavigation(
            pages: [
              GestureDetector(
                onTap: () {
                  pageTapped = true;
                },
                behavior: HitTestBehavior.opaque,
                child: const Center(
                  child: Text('Page 0 Content'),
                ),
              ),
              const Center(child: Text('Page 1 Content')),
              const Center(child: Text('Page 2 Content')),
              const Center(child: Text('Page 3 Content')),
            ],
            size: const Size(400, 800),
            currentIndex: 0,
            onTap: (index) {
              tappedPageIndex = index;
            },
            onAddTask: () {
              addTaskTapped = true;
            },
          ),
        ),
      ),
    );

    // Verify FAB icon exists
    final addIconFinder = find.byIcon(Icons.add);
    expect(addIconFinder, findsOneWidget);

    final fabCenter = tester.getCenter(addIconFinder);

    // 1. Tap the TOP half of the FAB (protruding area, 15px above the center)
    final topHalfOffset = fabCenter.translate(0, -15);
    await tester.tapAt(topHalfOffset);
    await tester.pumpAndSettle();

    expect(addTaskTapped, isTrue,
        reason: 'The top half of the protruding add button must be clickable');

    // 2. Tap the BOTTOM half of the FAB (15px below the center)
    addTaskTapped = false;
    final bottomHalfOffset = fabCenter.translate(0, 15);
    await tester.tapAt(bottomHalfOffset);
    await tester.pumpAndSettle();

    expect(addTaskTapped, isTrue,
        reason: 'The bottom half of the add button must be clickable');

    // 3. Tap on the page content to ensure touches above the bar still reach the page
    pageTapped = false;
    final pageContentFinder = find.text('Page 0 Content');
    await tester.tap(pageContentFinder);
    await tester.pumpAndSettle();

    expect(pageTapped, isTrue,
        reason: 'Touches on the page content must not be blocked');

    // 4. Tap on another navigation item (e.g., Task at index 1)
    final taskItemFinder = find.text('Task');
    await tester.tap(taskItemFinder);
    await tester.pumpAndSettle();

    expect(tappedPageIndex, equals(1),
        reason: 'Tapping a nav item must trigger onTap with correct index');
  });
}
