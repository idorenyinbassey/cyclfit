import 'package:flutter/material.dart';

class BlogPage extends StatefulWidget {
  const BlogPage({super.key});

  @override
  State<BlogPage> createState() => _BlogPageState();
}

class _BlogPageState extends State<BlogPage> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Training',
    'Nutrition',
    'Gear',
    'Travel',
    'Inspiration',
  ];

  final List<BlogPost> _blogPosts = [
    BlogPost(
      id: '1',
      title: 'Unlock Your Cycling Potential: The Science Behind Power Zones',
      excerpt:
          'Master the art of power-based training to revolutionize your cycling performance. Learn how to identify, train, and optimize your power zones for maximum gains.',
      category: 'Training',
      author: 'Dr. Sarah Mitchell',
      publishDate: DateTime(2024, 1, 15),
      readTime: '8 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      likes: 234,
      comments: 42,
      isBookmarked: true,
    ),
    BlogPost(
      id: '2',
      title: 'Fueling Champions: Nutrition Strategies for Endurance Cyclists',
      excerpt:
          'Discover the nutritional secrets that power professional cyclists through grueling races. From pre-ride fueling to recovery nutrition, get the complete guide.',
      category: 'Nutrition',
      author: 'Chef Marcus Rodriguez',
      publishDate: DateTime(2024, 1, 12),
      readTime: '12 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1490474418585-ba9bad8fd0ea?w=800',
      likes: 189,
      comments: 31,
      isBookmarked: false,
    ),
    BlogPost(
      id: '3',
      title: 'Carbon vs. Aluminum: The Ultimate Bike Frame Showdown',
      excerpt:
          'Confused about choosing your next bike frame? We break down the pros and cons of carbon fiber vs. aluminum frames to help you make the perfect choice.',
      category: 'Gear',
      author: 'James Park',
      publishDate: DateTime(2024, 1, 10),
      readTime: '6 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1517654443271-12c7c2eb83e2?w=800',
      likes: 156,
      comments: 28,
      isBookmarked: false,
    ),
    BlogPost(
      id: '4',
      title: 'Epic Cycling Adventures: 10 Must-Ride Routes Around the World',
      excerpt:
          'From the winding roads of Tuscany to the challenging climbs of the Alps, explore the most breathtaking cycling destinations that should be on every cyclist\'s bucket list.',
      category: 'Travel',
      author: 'Maria Santos',
      publishDate: DateTime(2024, 1, 8),
      readTime: '15 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1544191696-15693329b0fb?w=800',
      likes: 312,
      comments: 67,
      isBookmarked: true,
    ),
    BlogPost(
      id: '5',
      title: 'From Couch to Century: A Beginner\'s Journey to 100 Miles',
      excerpt:
          'Follow the inspiring transformation of complete cycling novice Alex as they train from zero to completing their first century ride in just 6 months.',
      category: 'Inspiration',
      author: 'Alex Chen',
      publishDate: DateTime(2024, 1, 5),
      readTime: '10 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1569169403366-4b9c7e7ef000?w=800',
      likes: 445,
      comments: 89,
      isBookmarked: false,
    ),
    BlogPost(
      id: '6',
      title: 'Winter Cycling Mastery: Staying Warm, Safe, and Motivated',
      excerpt:
          'Don\'t let cold weather derail your training! Learn the essential tips and gear recommendations for safe and enjoyable winter cycling.',
      category: 'Training',
      author: 'Nordic Cycling Club',
      publishDate: DateTime(2024, 1, 3),
      readTime: '7 min read',
      imageUrl:
          'https://images.unsplash.com/photo-1517654443271-12c7c2eb83e2?w=800',
      likes: 167,
      comments: 34,
      isBookmarked: false,
    ),
  ];

  List<BlogPost> get _filteredPosts {
    if (_selectedCategory == 'All') {
      return _blogPosts;
    }
    return _blogPosts
        .where((post) => post.category == _selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CyclFit Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () => _showBookmarks(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryTabs(),
          Expanded(child: _buildBlogContent()),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.grey.shade100,
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBlogContent() {
    if (_filteredPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No articles found',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // TODO: Implement refresh logic
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredPosts.length,
        itemBuilder: (context, index) {
          return _buildBlogPostCard(_filteredPosts[index]);
        },
      ),
    );
  }

  Widget _buildBlogPostCard(BlogPost post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _navigateToArticle(post),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.article,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(post.category),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        post.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: IconButton(
                      icon: Icon(
                        post.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: post.isBookmarked ? Colors.amber : Colors.white,
                      ),
                      onPressed: () => _toggleBookmark(post),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.excerpt,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          post.author
                              .split(' ')
                              .map((name) => name.substring(0, 1))
                              .join(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.author,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              '${_formatDate(post.publishDate)} • ${post.readTime}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInteractionButton(
                        Icons.favorite_border,
                        post.likes.toString(),
                        () => _toggleLike(post),
                      ),
                      const SizedBox(width: 16),
                      _buildInteractionButton(
                        Icons.comment_outlined,
                        post.comments.toString(),
                        () => _showComments(post),
                      ),
                      const Spacer(),
                      _buildInteractionButton(
                        Icons.share_outlined,
                        'Share',
                        () => _shareArticle(post),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Training':
        return Colors.orange;
      case 'Nutrition':
        return Colors.green;
      case 'Gear':
        return Colors.blue;
      case 'Travel':
        return Colors.purple;
      case 'Inspiration':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToArticle(BlogPost post) {
    Navigator.pushNamed(context, '/article', arguments: post);
  }

  void _toggleBookmark(BlogPost post) {
    setState(() {
      post.isBookmarked = !post.isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          post.isBookmarked ? 'Article bookmarked!' : 'Bookmark removed',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleLike(BlogPost post) {
    setState(() {
      post.likes += 1;
    });
  }

  void _showComments(BlogPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comments (${post.comments})',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildCommentItem(
                      'Sarah J.',
                      '2h ago',
                      'This is exactly what I needed to improve my training! Thanks for sharing.',
                    ),
                    _buildCommentItem(
                      'Mike R.',
                      '5h ago',
                      'Great article! I\'ve been struggling with power zones and this clarified everything.',
                    ),
                    _buildCommentItem(
                      'Emma L.',
                      '1d ago',
                      'Love the practical tips. Can\'t wait to try these strategies on my next ride.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentItem(String author, String time, String comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    author.substring(0, 1),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  time,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(comment),
          ],
        ),
      ),
    );
  }

  void _shareArticle(BlogPost post) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would open here'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(context: context, delegate: BlogSearchDelegate(_blogPosts));
  }

  void _showBookmarks(BuildContext context) {
    final bookmarkedPosts = _blogPosts
        .where((post) => post.isBookmarked)
        .toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookmarksPage(posts: bookmarkedPosts),
      ),
    );
  }
}

class BlogPost {
  final String id;
  final String title;
  final String excerpt;
  final String category;
  final String author;
  final DateTime publishDate;
  final String readTime;
  final String imageUrl;
  int likes;
  final int comments;
  bool isBookmarked;

  BlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.category,
    required this.author,
    required this.publishDate,
    required this.readTime,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.isBookmarked,
  });
}

class BlogSearchDelegate extends SearchDelegate<String> {
  final List<BlogPost> posts;

  BlogSearchDelegate(this.posts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredPosts = posts
        .where(
          (post) =>
              post.title.toLowerCase().contains(query.toLowerCase()) ||
              post.excerpt.toLowerCase().contains(query.toLowerCase()) ||
              post.author.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return ListView.builder(
      itemCount: filteredPosts.length,
      itemBuilder: (context, index) {
        final post = filteredPosts[index];
        return ListTile(
          title: Text(post.title),
          subtitle: Text(post.excerpt),
          onTap: () {
            close(context, post.title);
          },
        );
      },
    );
  }
}

class BookmarksPage extends StatelessWidget {
  final List<BlogPost> posts;

  const BookmarksPage({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarked Articles')),
      body: posts.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No bookmarked articles yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(post.title),
                    subtitle: Text('${post.author} • ${post.readTime}'),
                    onTap: () {
                      Navigator.pushNamed(context, '/article', arguments: post);
                    },
                  ),
                );
              },
            ),
    );
  }
}
