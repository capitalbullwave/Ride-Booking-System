import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

@freezed
abstract class WalletInfo with _$WalletInfo {
  const factory WalletInfo({
    @JsonKey(name: 'current_balance') @Default(0) double currentBalance,
    @JsonKey(name: 'pending_balance') @Default(0) double pendingBalance,
    @JsonKey(name: 'total_earnings') @Default(0) double totalEarnings,
    @JsonKey(name: 'total_withdrawn') @Default(0) double totalWithdrawn,
    BankInfo? bank,
  }) = _WalletInfo;

  factory WalletInfo.fromJson(Map<String, dynamic> json) =>
      _$WalletInfoFromJson(json);
}

@freezed
abstract class BankInfo with _$BankInfo {
  const factory BankInfo({
    @JsonKey(name: 'account_holder') String? accountHolder,
    @JsonKey(name: 'account_number') String? accountNumber,
    String? ifsc,
    @JsonKey(name: 'bank_name') String? bankName,
    @JsonKey(name: 'upi_id') String? upiId,
  }) = _BankInfo;

  factory BankInfo.fromJson(Map<String, dynamic> json) =>
      _$BankInfoFromJson(json);
}

@freezed
abstract class WalletTransaction with _$WalletTransaction {
  const factory WalletTransaction({
    required String id,
    required String type,
    required double amount,
    required String status,
    String? description,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _WalletTransaction;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      _$WalletTransactionFromJson(json);
}

@freezed
abstract class WithdrawRequest with _$WithdrawRequest {
  const factory WithdrawRequest({
    required double amount,
    @JsonKey(name: 'payment_method') required String paymentMethod,
  }) = _WithdrawRequest;

  factory WithdrawRequest.fromJson(Map<String, dynamic> json) =>
      _$WithdrawRequestFromJson(json);
}
