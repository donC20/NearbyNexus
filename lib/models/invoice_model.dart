class Invoice {
  final String userName;
  final String vendorName;
  final String invoiceId;
  final DateTime printDate = DateTime.now();
  final String description;
  final String jobName;
  final String payDate;
  final String amount;
  Invoice({
    required this.userName,
    required this.vendorName,
    required this.invoiceId,
    required this.description,
    required this.jobName,
    required this.payDate,
    required this.amount,
  });
}
