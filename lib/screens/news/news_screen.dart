import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/post.dart';
import '../../widgets/cuidar_card.dart';

/// Aba de Notícias/Blog completamente mockada com posts reais da Casa Mais Azul
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final List<Post> _displayPosts = [
    Post(
      id: 'mock-news-1',
      title: 'Projeto Laços de Amor 💙',
      subtitle: 'Fortalecendo vínculos entre famílias e profissionais.',
      coverImageUrl: 'https://images.unsplash.com/photo-1594608661623-aa0bd3a69d98?q=80&w=800',
      body: 'Confira como foi o nosso encontro do Projeto Laços de Amor. Um momento de troca, acolhimento e aprendizado para todos os envolvidos no cuidado TEA na Casa Mais Azul.',
      category: 'evento',
      publishedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Post(
      id: 'mock-news-2',
      title: 'Atividades Sensoriais na Rede IntegraTEA',
      subtitle: 'Desenvolvimento e ludicidade no dia a dia.',
      coverImageUrl: 'https://images.unsplash.com/photo-1587654780291-39c9404d746b?q=80&w=800',
      body: 'Nossas sessões de terapia ocupacional utilizam recursos sensoriais para estimular o desenvolvimento cognitivo e motor de nossas crianças com espectro autista.',
      category: 'servico',
      publishedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Post(
      id: 'mock-news-3',
      title: 'Inauguração do Novo Bloco Terapeútico',
      subtitle: 'Mais espaço e qualidade para o atendimento.',
      coverImageUrl: 'https://images.unsplash.com/photo-1516627145497-ae6968895b74?q=80&w=800',
      body: 'É com muita alegria que anunciamos a expansão de nossas instalações em Crateús. Novos consultórios e salas de integração sensorial prontas para acolher a todos.',
      category: 'campanha',
      publishedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppRadii.spaceMd),
        itemCount: _displayPosts.length + 1,
        separatorBuilder: (_, index) => index == 0 ? const SizedBox.shrink() : const SizedBox(height: AppRadii.spaceMd),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Novidades IntegraTEA',
                style: AppTextStyles.titleLg.copyWith(color: AppColors.primary),
              ),
            );
          }
          return _PostCard(post: _displayPosts[index - 1]);
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return CuidarCard(
      padding: EdgeInsets.zero,
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _PostDetailScreen(post: post))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.coverImageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadii.card)),
              child: Image.network(
                post.coverImageUrl!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppRadii.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadii.chip)),
                  child: Text(post.categoryLabel.toUpperCase(), style: AppTextStyles.label.copyWith(fontSize: 10, color: AppColors.primary)),
                ),
                const SizedBox(height: 8),
                Text(post.title, style: AppTextStyles.titleMd),
                if (post.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(post.subtitle!, style: AppTextStyles.bodySm.copyWith(color: AppColors.secondaryText)),
                ],
                if (post.publishedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(DateFormat('dd/MM/yyyy').format(post.publishedAt!), style: AppTextStyles.bodySm.copyWith(fontSize: 11, color: AppColors.secondaryText.withOpacity(0.7))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostDetailScreen extends StatelessWidget {
  final Post post;
  const _PostDetailScreen({required this.post});

  Future<void> _launchInstagram(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? instagramUrl;
    if (post.id == 'mock-news-1') instagramUrl = 'https://www.instagram.com/p/DTxud4BACVF/';
    if (post.id == 'mock-news-2') instagramUrl = 'https://www.instagram.com/p/DSVuQWEAZG3/';
    if (post.id == 'mock-news-3') instagramUrl = 'https://www.instagram.com/p/DGDgbojRHWL/';

    return Scaffold(
      appBar: AppBar(title: Text(post.categoryLabel)),
      body: ListView(
        padding: const EdgeInsets.all(AppRadii.spaceMd),
        children: [
          if (post.coverImageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.card),
              child: Image.network(post.coverImageUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
            ),
          const SizedBox(height: AppRadii.spaceMd),
          Text(post.title, style: AppTextStyles.displayLg.copyWith(color: AppColors.primary)),
          if (post.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(post.subtitle!, style: AppTextStyles.subtitle.copyWith(color: AppColors.secondaryText)),
          ],
          const SizedBox(height: AppRadii.spaceLg),
          Text(post.body, style: AppTextStyles.body),
          if (instagramUrl != null) ...[
            const SizedBox(height: AppRadii.spaceXl),
            OutlinedButton.icon(
              onPressed: () => _launchInstagram(instagramUrl!),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Ver post completo no Instagram'),
            ),
          ],
        ],
      ),
    );
  }
}
