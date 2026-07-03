import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/constants/api_endpoints.dart';
import 'package:wavego_driver/core/network/backend_mappers.dart';
import 'package:wavego_driver/core/network/dio_client.dart';
import 'package:wavego_driver/core/storage/auth_token_store.dart';
import 'package:wavego_driver/models/wallet_model.dart';
import 'package:wavego_driver/services/base_api_service.dart';

class WalletService extends BaseApiService {
  WalletService(Dio dio, AuthTokenStore tokenStore) : super(dio, tokenStore);

  Future<WalletInfo> getWallet() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final data = await loadMockJson('wallet.json');
      return WalletInfo.fromJson(data['data'] as Map<String, dynamic>);
    }

    return get(
      ApiEndpoints.wallet,
      parser: (data) =>
          BackendMappers.walletFromJson(data as Map<String, dynamic>),
    );
  }

  Future<List<WalletTransaction>> getTransactions({
    int page = 1,
    int limit = 20,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final list = await loadMockJsonList('wallet_transactions.json');
      return list
          .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return get(
      ApiEndpoints.walletTransactions,
      queryParameters: {'page': page, 'page_size': limit},
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['data'] as List<dynamic>? ?? [];
        return list
            .map(
              (e) => WalletTransaction.fromJson({
                ...(e as Map<String, dynamic>),
                'status': (e)['status'] as String? ?? 'completed',
              }),
            )
            .toList();
      },
    );
  }

  Future<BankInfo> getBankDetails() async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final data = await loadMockJson('wallet.json');
      final bank = (data['data'] as Map<String, dynamic>)['bank']
          as Map<String, dynamic>?;
      if (bank == null) {
        throw Exception('No bank account linked');
      }
      return BankInfo.fromJson(bank);
    }

    return get(
      ApiEndpoints.bankDetails,
      parser: (data) =>
          BackendMappers.bankFromJson(data as Map<String, dynamic>),
    );
  }

  Future<BankInfo> saveBankDetails(BankDetailsRequest request) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return BankInfo(
        accountHolder: request.accountHolderName,
        accountNumber: request.accountNumber != null
            ? '****${request.accountNumber!.substring(request.accountNumber!.length > 4 ? request.accountNumber!.length - 4 : 0)}'
            : null,
        ifsc: request.ifscCode,
        bankName: request.bankName ?? 'UPI',
        upiId: request.upiId,
      );
    }

    return post(
      ApiEndpoints.bankDetails,
      data: request.toJson(),
      parser: (data) =>
          BackendMappers.bankFromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> withdraw(WithdrawRequest request) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(seconds: 1));
      return;
    }

    await post(ApiEndpoints.withdraw, data: request.toJson());
  }
}

final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService(
    ref.watch(dioClientProvider).dio,
    ref.watch(authTokenStoreProvider),
  );
});
