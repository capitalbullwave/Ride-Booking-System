import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/models/wallet_model.dart';
import 'package:wavego_driver/services/wallet_service.dart';

class WalletRepository {
  WalletRepository(this._service);

  final WalletService _service;

  Future<WalletInfo> getWallet() => _service.getWallet();

  Future<List<WalletTransaction>> getTransactions({int page = 1}) =>
      _service.getTransactions(page: page);

  Future<BankInfo?> getBankDetails() async {
    try {
      return await _service.getBankDetails();
    } catch (_) {
      return null;
    }
  }

  Future<BankInfo> fetchBankDetails() => _service.getBankDetails();

  Future<BankInfo> saveBankDetails(BankDetailsRequest request) =>
      _service.saveBankDetails(request);

  Future<void> withdraw(WithdrawRequest request) =>
      _service.withdraw(request);
}

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(walletServiceProvider));
});
