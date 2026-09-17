import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/post.dart';
import '../../widgets/cuidar_card.dart';
import '../../widgets/error_state.dart';

/// Mural de notícias público (`public.posts`) — avisos, campanhas e eventos
/// da rede de saúde, no espírito do Instagram da prefeitura.
class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _repository = CareRepository();
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchPublishedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(error: snapshot.error, onRetry: () => setState(() => _future = _repository.fetchPublishedPosts()));
        }
        final posts = snapshot.data!;
        if (posts.isEmpty) {
          return const Center(child: Text('Nenhuma notícia publicada ainda.'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _repository.fetchPublishedPosts()),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppRadii.spaceMd),
            itemCount: posts.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppRadii.spaceMd),
            itemBuilder: (context, index) => _PostCard(post: posts[index]),
          ),
        );
      },
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
                  decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(AppRadii.chip)),
                  child: Text(post.categoryLabel, style: AppTextStyles.label.copyWith(fontSize: 11)),
                ),
                const SizedBox(height: 8),
                Text(post.title, style: AppTextStyles.titleMd),
                if (post.subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(post.subtitle!, style: AppTextStyles.bodySm),
                ],
                if (post.publishedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(DateFormat('dd/MM/yyyy').format(post.publishedAt!), style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
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

  @override
  Widget build(BuildContext context) {
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
          Text(post.title, style: AppTextStyles.displayLg),
          if (post.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(post.subtitle!, style: AppTextStyles.subtitle),
          ],
          const SizedBox(height: AppRadii.spaceLg),
          Text(post.body, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
