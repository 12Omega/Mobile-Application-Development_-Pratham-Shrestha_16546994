import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('Simple Tests', () {
    test('basic dart test', () {
      expect(1 + 1, equals(2));
      expect('hello'.toUpperCase(), equals('HELLO'));
    });

    testWidgets('basic widget test', (WidgetTester tester) async {
      // Build a simple widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hello World'),
          ),
        ),
      );

      // Verify the widget is displayed
      expect(find.text('Hello World'), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('button tap test', (WidgetTester tester) async {
      int counter = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('Counter: $counter'),
                ElevatedButton(
                  onPressed: () {
                    counter++;
                  },
                  child: const Text('Increment'),
                ),
              ],
            ),
          ),
        ),
      );

      // Find the button and tap it
      expect(find.text('Counter: 0'), findsOneWidget);
      expect(find.text('Increment'), findsOneWidget);
      
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // The counter should still be 0 because we're not using StatefulWidget
      expect(find.text('Counter: 0'), findsOneWidget);
    });

    testWidgets('stateful widget test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const CounterWidget(),
        ),
      );

      // Initial state
      expect(find.text('0'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);

      // Tap the button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Counter should be incremented
      expect(find.text('1'), findsOneWidget);
    });
  });
}

class CounterWidget extends StatefulWidget {
  const CounterWidget({Key? key}) : super(key: key);

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}