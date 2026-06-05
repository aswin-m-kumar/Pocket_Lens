import '../database/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<void> addTransaction(Transaction t);
  Future<void> updateTransaction(Transaction t);
  Future<void> deleteTransaction(int id);
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getByDateRange(DateTime from, DateTime to);
  Future<double> getCurrentBalance();
  Future<Map<String, double>> getCategoryBreakdown(DateTime from, DateTime to);
}
