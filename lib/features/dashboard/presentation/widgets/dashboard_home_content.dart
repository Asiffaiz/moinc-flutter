import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moinc/features/ai%20agent/app.dart';
import 'package:moinc/features/ai%20agent/widgets/standalone_ai_agent.dart';
import 'package:moinc/features/dashboard/domain/models/dashboard_data_model.dart';
import 'package:moinc/features/dashboard/presentation/bloc/bloc/dashboard_bloc.dart';
import 'package:moinc/widgets/custom_error_dialog.dart';
import 'package:moinc/widgets/dashboard_shimmer.dart';

class DashboardHomeContent extends StatefulWidget {
  const DashboardHomeContent({super.key});

  @override
  State<DashboardHomeContent> createState() => _DashboardHomeContentState();
}

class _DashboardHomeContentState extends State<DashboardHomeContent> {
  @override
  void initState() {
    super.initState();
    // For demo purposes, show dummy data after a delay
    _showDummyData();
  }

  void _showDummyData() {
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        final dummyData = DashboardDataModel(
          welcomeContent:
              '<h2 style="color: #D4AF37;">Welcome David!</h2><p>Your personal AI assistant is ready to help you. Explore the forms below to get started.</p>',
          assignedForms: [],
          agreementSummary: AgreementsSummaryModel(
            totalAgreements: 5,
            totalSigned: 3,
            totalNotSigned: 2,
          ),
        );
        // For demo purposes only, we're using a simulated state update
        // In a real app, this would be handled through proper BLoC events
        if (context.mounted) {
          final bloc = context.read<DashboardBloc>();
          // This is a workaround for demo purposes
          (bloc as dynamic).emit(DashboardLoaded(dashboardData: dummyData));
        }
      }
    });
  }

  _handleRetry() {
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomErrorDialog.show(
              context: context,
              onRetry: () {
                Navigator.pop(context);
                _handleRetry();
              },
            );
          });
        }
      },
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const DashboardShimmer();
        }

        if (state is DashboardLoaded) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: VoiceAssistantApp(),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
