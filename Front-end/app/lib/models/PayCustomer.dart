import 'dart:convert';
import 'package:http/http.dart' as http;

class PayCustomer {
  final String? uuid;
  final DateTime? date;

  final String? customerUuid;
  final String? customerName;

  final String? planUuid;
  final String? planName;

  final int? price;

  final String? txnRef;
  final String? status;
  final String? bankCode;

  PayCustomer({
    this.uuid,
    this.date,
    this.customerUuid,
    this.customerName,
    this.planUuid,
    this.planName,
    this.price,
    this.txnRef,
    this.status,
    this.bankCode,
  });

  factory PayCustomer.fromJson(Map<String, dynamic> json) {
    return PayCustomer(
      uuid: json['uuid'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      customerUuid: json['customerUuid'],
      customerName: json['customerName'],
      planUuid: json['planUuid'],
      planName: json['planName'],
      price: json['price'],
      txnRef: json['txnRef'],
      status: json['status'],
      bankCode: json['bankCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'date': date?.toIso8601String().split('T')[0],
      'customerUuid': customerUuid,
      'customerName': customerName,
      'planUuid': planUuid,
      'planName': planName,
      'price': price,
      'txnRef': txnRef,
      'status': status,
      'bankCode': bankCode,
    };
  }
}