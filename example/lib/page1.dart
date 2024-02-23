import 'package:flutter/material.dart';
import "package:transformers/transformers.dart";
import 'package:flutter_window_close/flutter_window_close.dart';

class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  _CounterState createState() => _CounterState();
}

class _CounterState extends State<Counter> {
  int _count = 0;
  Transformers transformers = Transformers.instance;

  void _incrementCounter() {
    setState(() {
      _count = _count + 1;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FlutterWindowClose.setWindowShouldCloseHandler(() async {
      return false;
      // await showDialog(
      //     context: context,
      //     builder: (context) {
      //       return AlertDialog(
      //           title: const Text('Do you really want to quit?'),
      //           actions: [
      //             ElevatedButton(
      //                 onPressed: () => Navigator.of(context).pop(true),
      //                 child: const Text('Yes')),
      //             ElevatedButton(
      //                 onPressed: () => Navigator.of(context).pop(false),
      //                 child: const Text('No')),
      //           ]);
      //     });
    });
  }

  @override
  Widget build(BuildContext context) {
    transformers.onUpdateCallback = () {
      if (mounted) {
        setState(() {});
      }
    };

    return Scaffold(
      appBar: AppBar(title: Text('Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            Text(
              '$_count',
            ),
            transformers.isTransformersLoaded
                ? Text("Loaded true")
                : Text("loaded false"),
            ElevatedButton(
                onPressed: () {
                  transformers.makefalse();
                },
                child: Text("make false"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print(transformers.isTransformersLoaded);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
