import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/models/transaccion.dart';
import '../../domain/usecases/get_transactions_usecase.dart';

class ExpensesNotifier extends ChangeNotifier {
  final GetTransactionsUseCase _getTransactionsUseCase;

  List<Transaccion> _transacciones = [];
  List<Transaccion> get transacciones => _transacciones;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  StreamSubscription<List<Transaccion>>? _subscription;

  ExpensesNotifier(this._getTransactionsUseCase) {
    _subscribeToTransactions();
  }

  void _subscribeToTransactions() {
    _subscription = _getTransactionsUseCase.execute().listen(
      (list) {
        _transacciones = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
