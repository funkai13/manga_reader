import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DialogService {
  final ProviderRef ref;

  DialogService(this.ref);

  Future<void> showErrorDialog(BuildContext context,
      {required String title, required String message}) async {
    await _showDialog(context, title: title, message: message);
  }

  Future<void> showInfoDialog(BuildContext context,
      {required String title, required String message}) async {
    await _showDialog(context, title: title, message: message);
  }

  Future<void> _showDialog(BuildContext context,
      {required String title, required String message}) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}

final dialogServiceProvider = Provider((ref) => DialogService(ref));
