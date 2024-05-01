// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'abcd',
    () {
      print("Creating a sample stream...");
      Stream<String> stream = Stream.fromFuture(getData());
      print("Created the stream");

      stream.listen((data) {
        print("DataReceived: $data");
      }, onDone: () {
        print("Task Done");
      }, onError: (error) {
        print("Some Error");
      });

      print("code controller is here");
    },

    timeout: const Timeout(Duration(seconds: 10)),
  );
}

Future<String> getData() async {
  await Future.delayed(const Duration(seconds: 5)); //Mock delay
  print("Fetched Data");
  return "This a test data";
}
