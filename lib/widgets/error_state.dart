import 'package:flutter/material.dart';

import '../core/auth/auth_repository.dart';
import '../core/theme/app_text_styles.dart';

/// Estado de erro visível — usado sempre que uma consulta ao Supabase falha,
/// para nunca mascarar um problema real de conexão/permissão com dado falso.
class ErrorState extends StatelessWidget {
  final Object? error;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.error, required this.onRetry});

  String get _message {
    final e = error;
    if (e is CuidarAuthException) return e.message;
    return 'Não foi possível carregar os dados: $e';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 36),
            const SizedBox(height: 12),
            Text(_message, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}
