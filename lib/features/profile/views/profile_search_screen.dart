import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/core/theme/app_spacing.dart';
import 'package:sport_connect/features/auth/models/models.dart';
import 'package:sport_connect/features/profile/repositories/profile_repository.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

part 'profile_search_screen.g.dart';

/// Search results provider — accepts the query as a family parameter
/// so ephemeral search state stays local to the widget.
@riverpod
Future<List<UserModel>> searchResults(Ref ref, String query) async {
  if (query.isEmpty || query.length < 2) return [];

  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchUsers(query: query);
}

/// Premium Profile Search Screen with autocomplete
class ProfileSearchScreen extends ConsumerStatefulWidget {
  const ProfileSearchScreen({super.key});

  @override
  ConsumerState<ProfileSearchScreen> createState() =>
      _ProfileSearchScreenState();
}

class _ProfileSearchScreenState extends ConsumerState<ProfileSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounceTimer;
  String _searchQuery = '';

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() => _searchQuery = query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _searchQuery = '');
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider(_searchQuery));
    final query = _searchQuery;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: query.isEmpty
                  ? _buildEmptyState()
                  : searchResults.when(
                      data: (users) => users.isEmpty
                          ? _buildNoResults(query)
                          : _buildResults(users),
                      loading: () => _buildLoadingState(),
                      error: (error, _) => _buildErrorState(error.toString()),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: AppSpacing.shadowSm,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).findPeople,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).searchByName,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: AppSpacing.shadowSm,
          border: Border.all(
            color: _searchFocus.hasFocus ? AppColors.primary : AppColors.border,
            width: _searchFocus.hasFocus ? 2 : 1,
          ),
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: _onSearchChanged,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).searchUsers,
            hintStyle: TextStyle(
              fontSize: 16.sp,
              color: AppColors.textTertiary,
            ),
            prefixIcon: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(12.w),
              child: Icon(
                Icons.search_rounded,
                size: 24.sp,
                color: _searchFocus.hasFocus
                    ? AppColors.primary
                    : AppColors.textSecondary,
              ),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Clear search',
                    onPressed: _clearSearch,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColors.textSecondary,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 64.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).findFellowRiders,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).searchForUsersByTheir,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32.h),

          // Quick suggestions
          Text(
            AppLocalizations.of(context).popularSearches,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            alignment: WrapAlignment.center,
            children: ['Drivers', 'Riders', 'Sports', 'Events'].map((tag) {
              return GestureDetector(
                onTap: () {
                  _searchController.text = tag;
                  _onSearchChanged(tag);
                  HapticFeedback.selectionClick();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48.w,
            height: 48.w,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context).searching,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 64.sp,
              color: AppColors.warning,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).noResultsFound2,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).noUsersFoundMatchingValue(query),
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context).tryADifferentSearchTerm,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            AppLocalizations.of(context).somethingWentWrong,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<UserModel> users) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];

        void navigateToProfile() {
          HapticFeedback.lightImpact();
          if (user.role == UserRole.driver) {
            context.pushNamed(
              AppRoutes.driverProfile.path,
              pathParameters: {'userId': user.uid},
            );
          } else {
            context.pushNamed(
              AppRoutes.profile.path,
              pathParameters: {'userId': user.uid},
            );
          }
        }

        return Dismissible(
          key: ValueKey('user_search_${user.uid}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            HapticFeedback.mediumImpact();
            navigateToProfile();
            return false;
          },
          background: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_outline_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
                SizedBox(height: 4.h),
                Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          child: _UserCard(
                user: user,
                onTap: navigateToProfile,
              )
              .animate(delay: Duration(milliseconds: 50 * index))
              .fadeIn()
              .slideX(begin: 0.05),
        );
      },
    );
  }
}

/// User card widget
class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: AppSpacing.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: user.photoUrl == null
                        ? AppColors.primaryGradient
                        : null,
                    image: user.photoUrl != null
                        ? DecorationImage(
                            image: NetworkImage(user.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.photoUrl == null
                      ? Center(
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: 14.w),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.displayName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isIdVerified)
                            Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 14.sp,
                                color: AppColors.info,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          _buildRoleBadge(user.role),
                          SizedBox(width: 8.w),
                          if (user.rating.average > 0)
                            Row(
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 14.sp,
                                  color: AppColors.warning,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  user.rating.average.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (user.bio != null && user.bio!.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Text(
                          user.bio!,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textTertiary,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color badgeColor;
    IconData icon;

    switch (role) {
      case UserRole.driver:
        badgeColor = const Color(0xFF11998e);
        icon = Icons.drive_eta_rounded;
        break;
      case UserRole.rider:
        badgeColor = const Color(0xFF667eea);
        icon = Icons.person_pin_circle_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: badgeColor),
          SizedBox(width: 4.w),
          Text(
            role.displayName,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
