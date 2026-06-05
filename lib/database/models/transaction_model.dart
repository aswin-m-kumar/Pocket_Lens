import 'package:isar/isar.dart';

part 'transaction_model.g.dart';

@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  late double amount;

  @enumerated
  late TransactionType type;

  late String category;

  String? note;

  @Index()
  late DateTime date;

  late DateTime createdAt;
}

enum TransactionType { income, expense }
