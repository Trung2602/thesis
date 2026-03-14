// pay_customer_model.dart
class PayCustomerModel {
  int? id;
  String? date;
  String? customerName;
  String? planName;
  int? price;
  String? txnRef;   // mã giao dịch VNPAY
  String? status;   // PENDING / SUCCESS / FAILED
  String? bankCode; // ngân hàng (optional)

  PayCustomerModel({
    this.id,
    this.date,
    this.customerName,
    this.planName,
    this.price,
    this.txnRef,
    this.status,
    this.bankCode,
  });

  // Chuyển từ JSON sang model
  factory PayCustomerModel.fromJson(Map<String, dynamic> json) {
    return PayCustomerModel(
      id: json['id'] as int?,
      date: json['date'] as String?,
      customerName: json['customerName'] as String?,
      planName: json['planName'] as String?,
      price: json['price'] as int?,
      txnRef: json['txnRef'] as String?,
      status: json['status'] as String?,
      bankCode: json['bankCode'] as String?,
    );
  }

  // Chuyển từ model sang JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'customerName': customerName,
      'planName': planName,
      'price': price,
      'txnRef': txnRef,
      'status': status,
      'bankCode': bankCode,
    };
  }
}
