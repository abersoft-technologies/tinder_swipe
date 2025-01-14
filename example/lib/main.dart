import 'package:flutter/material.dart';
import 'package:tinder_swipe/tinder_swipe.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final SwipeController<String> _controller = SwipeController<String>();
  List<String> myList = [
    "String 1",
    "String 2",
    "String 3",
    "String 4",
  ];

  @override
  void initState() {
    super.initState();
    _controller.addData(myList);
    _controller.initCallback(
      callback: swipeCallback,
      nextCardCallback: nextCardCallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: TinderSwipe<String>(
                controller: _controller,
                builder: (context, value, index) {
                  return Container(
                    width: double.infinity,
                    color: Colors.grey,
                    child: Column(
                      children: [
                        const Text("KARTU"),
                        Text(value),
                      ],
                    ),
                  );
                },
                swipingBadge: (status) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: status == CardStatus.like
                            ? Colors.green
                            : Colors.red,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status == CardStatus.like ? "PAKIT" : "MONJOWW",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: status == CardStatus.like
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  _controller.dislike();
                },
                child: const Text("Dislike"),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.removed();
                },
                child: const Text("Removed"),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.rewind(prevData: "String 4");
                },
                child: const Text("Rewind"),
              ),
              ElevatedButton(
                onPressed: () {
                  _controller.like();
                },
                child: const Text("Like"),
              ),
            ],
          )
        ],
      ),
    );
  }

  void swipeCallback<String>(CardStatus status, int length, String? data) {
    debugPrint(status.toString());
    debugPrint(length.toString());
    debugPrint('$data');
  }

  void nextCardCallback<String>(String? data) {
    debugPrint("Next Card: $data");
  }
}
