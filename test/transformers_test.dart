import 'package:flutter_test/flutter_test.dart';

import 'package:transformers/transformers.dart';
// Import your Transformers class

void main() {
  group('Transformers', () {
    late Transformers transformers;

    setUp(() {
      transformers = Transformers.instance;
    });

    test('Singleton instance is created', () {
      expect(transformers, isNotNull);
      expect(transformers, same(Transformers.instance));
    });

    test('Web view controller is initialized', () {
      expect(transformers.transformers, isNotNull);
    });

    // Add more tests as needed for your specific functionalities

    tearDown(() {
      // Cleanup or dispose any resources if needed
    });
  });
}
