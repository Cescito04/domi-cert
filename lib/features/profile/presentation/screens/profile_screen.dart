import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:domicert/features/owner/data/services/proprietaire_service.dart';
import 'package:domicert/features/profile/data/services/user_profile_service.dart';
import 'package:domicert/features/house/data/services/maison_service.dart';
import 'package:domicert/features/resident/data/services/habitant_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userProfileService = UserProfileService();
  final _proprietaireService = ProprietaireService();
  final _maisonService = MaisonService();
  final _habitantService = HabitantService();
  bool _isLoading = true;
  String _displayName = '';
  String _phoneNumber = '';
  int _maisonsCount = 0;
  int _habitantsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final proprietaire =
            await _proprietaireService.getProprietaire(user.uid);

        // Récupérer les maisons
        final maisonsStream = _maisonService.getMaisons();
        maisonsStream.listen((maisons) {
          if (mounted) {
            setState(() {
              _maisonsCount = maisons.length;
            });
          }
        });

        // Récupérer les habitants
        final habitantsStream = _habitantService.getHabitants();
        habitantsStream.listen((habitants) {
          if (mounted) {
            setState(() {
              _habitantsCount = habitants.length;
            });
          }
        });

        setState(() {
          _displayName = proprietaire?.nom ?? user.displayName ?? '';
          _phoneNumber = proprietaire?.telephone ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Hero(
                              tag: 'profile_avatar',
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: Text(
                                  _getInitials(_displayName),
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _displayName.isNotEmpty
                                  ? _displayName
                                  : 'Non défini',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildSectionTitle('Informations personnelles'),
                        const SizedBox(height: 16),
                        _buildInfoCard(context, [
                          _buildInfoTile(
                            icon: Icons.person_outline,
                            title: 'Nom',
                            subtitle: _displayName.isNotEmpty
                                ? _displayName
                                : 'Non défini',
                            color: Colors.blue,
                          ),
                          _buildInfoTile(
                            icon: Icons.phone_outlined,
                            title: 'Numéro de téléphone',
                            subtitle: _phoneNumber.isNotEmpty
                                ? _phoneNumber
                                : 'Non défini',
                            color: Colors.green,
                          ),
                          _buildInfoTile(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            subtitle: user?.email ?? 'Non défini',
                            color: Colors.orange,
                          ),
                        ]),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Statistiques'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.home_outlined,
                                title: 'Maisons',
                                value: _maisonsCount.toString(),
                                color: Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard(
                                context,
                                icon: Icons.people_outline,
                                title: 'Habitants',
                                value: _habitantsCount.toString(),
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: children.map((child) {
          final index = children.indexOf(child);
          return Column(
            children: [
              child,
              if (index < children.length - 1) const Divider(height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String displayName) {
    if (displayName.isEmpty) {
      return 'U';
    }
    final nameParts = displayName.trim().split(' ');
    if (nameParts.isEmpty) return 'U';

    if (nameParts.length == 1) {
      return nameParts[0][0].toUpperCase();
    }

    return '${nameParts[0][0]}${nameParts.last[0]}'.toUpperCase();
  }
}
