import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:sport_connect/core/providers/admin_access_provider.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/admin/repositories/admin_repository.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final access = ref.watch(adminAccessProvider);

    return AdaptiveScaffold(
      appBar: AdaptiveAppBar(
        title: 'Admin Dashboard',
      ),
      body: access.when(
        data: (allowed) {
          if (!allowed) {
            return const Center(child: Text('Admin access required'));
          }
          return const _AdminDashboardBody();
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Access check failed: $error')),
      ),
    );
  }
}

class _AdminDashboardBody extends ConsumerWidget {
  const _AdminDashboardBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surface,
            child: const TabBar(
              tabs: [
                Tab(text: 'Refunds'),
                Tab(text: 'Disputes'),
                Tab(text: 'Support'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _IssueList(
                  issues: ref.watch(adminRefundRequestsProvider),
                  emptyText: 'No refund requests',
                  type: _IssueType.refund,
                ),
                _IssueList(
                  issues: ref.watch(adminDisputesProvider),
                  emptyText: 'No disputes',
                  type: _IssueType.dispute,
                ),
                _IssueList(
                  issues: ref.watch(adminSupportTicketsProvider),
                  emptyText: 'No support tickets',
                  type: _IssueType.support,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _IssueType { refund, dispute, support }

class _IssueList extends ConsumerWidget {
  const _IssueList({
    required this.issues,
    required this.emptyText,
    required this.type,
  });

  final AsyncValue<List<AdminIssue>> issues;
  final String emptyText;
  final _IssueType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return issues.when(
      data: (items) {
        if (items.isEmpty) return Center(child: Text(emptyText));
        return RefreshIndicator.adaptive(
          onRefresh: () async {
            switch (type) {
              case _IssueType.refund:
                ref.invalidate(adminRefundRequestsProvider);
                break;
              case _IssueType.dispute:
                ref.invalidate(adminDisputesProvider);
                break;
              case _IssueType.support:
                ref.invalidate(adminSupportTicketsProvider);
                break;
            }
          },
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: items.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) => _IssueTile(
              issue: items[index],
              type: type,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Could not load issues: $error')),
    );
  }
}

class _IssueTile extends ConsumerWidget {
  const _IssueTile({required this.issue, required this.type});

  final AdminIssue issue;
  final _IssueType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = issue.createdAt == null
        ? ''
        : DateFormat('MMM d, HH:mm').format(issue.createdAt!);
    final needsAction = _isOpen(issue.status);

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  issue.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusPill(status: issue.status),
            ],
          ),
          if (date.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              date,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textTertiary),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            issue.subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (type == _IssueType.refund && needsAction)
                _ActionButton(
                  label: 'Approve refund',
                  icon: Icons.undo_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .approveRefundRequest(
                          refundRequestId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.refund && needsAction)
                _ActionButton(
                  label: 'Reject',
                  icon: Icons.close_rounded,
                  isDestructive: true,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .rejectRefundRequest(
                          refundRequestId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.dispute && needsAction)
                _ActionButton(
                  label: 'Refund',
                  icon: Icons.undo_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .approveDisputeRefund(
                          disputeId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.dispute && needsAction)
                _ActionButton(
                  label: 'Close',
                  icon: Icons.done_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .rejectDispute(
                          disputeId: issue.id,
                        ),
                  ),
                ),
              if (type == _IssueType.support && needsAction)
                _ActionButton(
                  label: 'Resolve',
                  icon: Icons.done_rounded,
                  onPressed: () => _run(
                    context,
                    () => ref
                        .read(adminRepositoryProvider)
                        .resolveSupportTicket(
                          ticketId: issue.id,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _isOpen(String status) {
    return !{
      'resolved',
      'closed',
      'rejected',
      'refunded',
      'partiallyRefunded',
      'done',
      'completed',
    }.contains(status);
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      if (!context.mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: 'Updated',
        type: AdaptiveSnackBarType.success,
      );
    } on Exception catch (error) {
      if (!context.mounted) return;
      AdaptiveSnackBar.show(
        context,
        message: error.toString(),
        type: AdaptiveSnackBarType.error,
      );
    }
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16.sp),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDestructive ? AppColors.error : AppColors.primary,
        side: BorderSide(
          color: isDestructive ? AppColors.error : AppColors.primary,
        ),
      ),
    );
  }
}
