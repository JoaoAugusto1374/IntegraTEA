import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuração de conexão do Supabase.
///
/// Aponta para o MESMO projeto Supabase usado pelo painel Next.js, garantindo
/// que app mobile e web administrativo compartilhem dados e políticas de RLS.
///
/// Em produção, passe as credenciais via `--dart-define`:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=xxxxx
class SupabaseConfig {
  SupabaseConfig._();

  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'public-anon-key',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
