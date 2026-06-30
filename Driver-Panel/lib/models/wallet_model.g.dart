// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WalletInfo _$WalletInfoFromJson(Map<String, dynamic> json) => _WalletInfo(
  currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0,
  pendingBalance: (json['pending_balance'] as num?)?.toDouble() ?? 0,
  totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
  totalWithdrawn: (json['total_withdrawn'] as num?)?.toDouble() ?? 0,
  bank: json['bank'] == null
      ? null
      : BankInfo.fromJson(json['bank'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WalletInfoToJson(_WalletInfo instance) =>
    <String, dynamic>{
      'current_balance': instance.currentBalance,
      'pending_balance': instance.pendingBalance,
      'total_earnings': instance.totalEarnings,
      'total_withdrawn': instance.totalWithdrawn,
      'bank': instance.bank,
    };

_BankInfo _$BankInfoFromJson(Map<String, dynamic> json) => _BankInfo(
  accountHolder: json['account_holder'] as String?,
  accountNumber: json['account_number'] as String?,
  ifsc: json['ifsc'] as String?,
  bankName: json['bank_name'] as String?,
  upiId: json['upi_id'] as String?,
);

Map<String, dynamic> _$BankInfoToJson(_BankInfo instance) => <String, dynamic>{
  'account_holder': instance.accountHolder,
  'account_number': instance.accountNumber,
  'ifsc': instance.ifsc,
  'bank_name': instance.bankName,
  'upi_id': instance.upiId,
};

_WalletTransaction _$WalletTransactionFromJson(Map<String, dynamic> json) =>
    _WalletTransaction(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String,
    );

Map<String, dynamic> _$WalletTransactionToJson(_WalletTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'amount': instance.amount,
      'status': instance.status,
      'description': instance.description,
      'created_at': instance.createdAt,
    };

_WithdrawRequest _$WithdrawRequestFromJson(Map<String, dynamic> json) =>
    _WithdrawRequest(
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
    );

Map<String, dynamic> _$WithdrawRequestToJson(_WithdrawRequest instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'payment_method': instance.paymentMethod,
    };
