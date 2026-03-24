import 'package:get/get.dart';

class CounterController extends GetxController {
  var count = 0.obs;

  void increment() {
    if (count < 7) {
      count++;
    }
  }

  void decrement() {
    if (count > 0) {
      count--;
    }
  }

  void reset() {
    count.value = 0;
  }
}
