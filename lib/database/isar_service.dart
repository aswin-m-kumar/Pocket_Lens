import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'models/transaction_model.dart';

class IsarService {
  final Isar isar;

  IsarService(this.isar);

  static Future<IsarService> init() async {
    final dir = await getApplicationDocumentsDirectory();
    final isarInstance = await Isar.open(
      <CollectionSchema<dynamic>>[TransactionSchema],
      directory: dir.path,
    );
    return IsarService(isarInstance);
  }
}

final isarServiceProvider = Provider<IsarService>((Ref ref) {
  throw UnimplementedError('isarServiceProvider must be overridden in main.dart');
});
