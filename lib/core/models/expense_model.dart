class Expense {
  final int? id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final bool isRecurring;
  final String type; // "income" or "expense"

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.isRecurring,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring ? 1 : 0,
      'type': type,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      isRecurring: map['isRecurring'] == 1,
      type: map['type'],
    );
  }
}