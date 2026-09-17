import 'package:flutter/material.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/patient.dart';
import '../../models/profile.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../medical_record/medical_record_screen.dart';
import '../news/news_screen.dart';
import '../notifications/notifications_screen.dart';
import '../queue/queue_screen.dart';

/// Casca do app autenticado: carrega o perfil + dependentes do responsável
/// uma única vez e distribui para as 5 abas via navegação inferior.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _authRepository = AuthRepository();
  final _careRepository = CareRepository();

  int _tabIndex = 0;
  String? _selectedPatientId;
  late Future<_ShellData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ShellData> _load() async {
    final profile = await _authRepository.fetchCurrentProfile();
    final patients = await _careRepository.fetchMyPatients(profile.id);
    if (patients.isNotEmpty) {
      _selectedPatientId = patients.first.id;
    }
    return _ShellData(profile: profile, patients: patients);
  }



  Future<void> _signOut() async {
    await _authRepository.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ShellData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return _ErrorScaffold(
            message: snapshot.error is CuidarAuthException
                ? (snapshot.error as CuidarAuthException).message
                : 'Não foi possível conectar ao Cuidar+: ${snapshot.error}',
            onRetry: () => setState(() => _future = _load()),
            onSignOut: _signOut,
          );
        }

        final data = snapshot.data!;
        final hasPatient = _selectedPatientId != null;

        final tabs = <Widget>[
          hasPatient
              ? HomeScreen(
                  key: ValueKey('home-$_selectedPatientId'),
                  patientId: _selectedPatientId!,
                  profileName: data.profile.fullName,

                )
              : const _NoPatientLinked(),

          hasPatient
              ? QueueScreen(key: ValueKey('queue-$_selectedPatientId'), patientId: _selectedPatientId!)
              : const _NoPatientLinked(),
          hasPatient
              ? MedicalRecordScreen(key: ValueKey('record-$_selectedPatientId'), patientId: _selectedPatientId!)
              : const _NoPatientLinked(),
          NotificationsScreen(profileId: data.profile.id),
          const NewsScreen(),
        ];

        return Scaffold(
          appBar: AppBar(
            title: data.patients.length > 1
                ? DropdownButton<String>(
                    value: _selectedPatientId,
                    underline: const SizedBox.shrink(),
                    items: data.patients
                        .map((p) => DropdownMenuItem(value: p.id, child: Text(p.displayName)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedPatientId = value),
                  )
                : Text(data.patients.isNotEmpty ? data.patients.first.displayName : 'Cuidar+'),
            actions: [
              IconButton(onPressed: _signOut, icon: const Icon(Icons.logout_rounded), tooltip: 'Sair'),
            ],
          ),
          body: IndexedStack(index: _tabIndex, children: tabs),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (i) => setState(() => _tabIndex = i),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Início'),
              NavigationDestination(icon: Icon(Icons.groups_outlined), selectedIcon: Icon(Icons.groups_rounded), label: 'Fila'),
              NavigationDestination(icon: Icon(Icons.folder_shared_outlined), selectedIcon: Icon(Icons.folder_shared_rounded), label: 'Prontuário'),
              NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications_rounded), label: 'Avisos'),
              NavigationDestination(icon: Icon(Icons.newspaper_outlined), selectedIcon: Icon(Icons.newspaper_rounded), label: 'Notícias'),
            ],
          ),
        );
      },
    );
  }
}

class _ShellData {
  final Profile profile;
  final List<Patient> patients;
  const _ShellData({required this.profile, required this.patients});
}

class _NoPatientLinked extends StatelessWidget {
  const _NoPatientLinked();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Nenhum dependente vinculado à sua conta ainda. Procure a unidade de saúde para associar seu cadastro.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body,
        ),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onSignOut;

  const _ErrorScaffold({required this.message, required this.onRetry, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.primaryText),
              const SizedBox(height: 12),
              Text('Não foi possível conectar', style: AppTextStyles.titleMd, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(message, style: AppTextStyles.bodySm, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onRetry, child: const Text('Tentar novamente')),
              TextButton(onPressed: onSignOut, child: const Text('Sair da conta')),
            ],
          ),
        ),
      ),
    );
  }
}
