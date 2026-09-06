import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../../themes/app_theme.dart';
import '../../../../widgets/components/common_card.dart';
import '../../controllers/home_controller.dart';

/// The dashboard's order-volume chart. Used to sit next to a date-range
/// dropdown and a calendar picker that looked interactive but weren't
/// wired to anything (`onChanged`/`onSelectionChanged` just called
/// `print(value)`) — removed rather than kept as decoration; the subtitle
/// now just says plainly what the chart actually shows.
class PerformanceChartCard extends StatelessWidget {
  final List<ShopVisitorChartData> data;
  final bool isLoading;

  const PerformanceChartCard({Key? key, required this.data, required this.isLoading}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CommonCard(
      elevation: 0,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'Orders placed per month, last 12 months',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 280,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : SfCartesianChart(
                    plotAreaBorderWidth: 0,
                    plotAreaBorderColor: Colors.transparent,
                    primaryXAxis: CategoryAxis(
                      isVisible: true,
                      axisLine: AxisLine(width: 1, color: Theme.of(context).disabledColor),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    primaryYAxis: NumericAxis(
                      minimum: 0,
                      axisLine: AxisLine(width: 1, color: Theme.of(context).disabledColor),
                      majorGridLines: const MajorGridLines(width: 0),
                    ),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    series: <CartesianSeries<dynamic, dynamic>>[
                      ColumnSeries<ShopVisitorChartData, String>(
                        dataSource: data,
                        xValueMapper: (ShopVisitorChartData d, _) => d.x,
                        yValueMapper: (ShopVisitorChartData d, _) => d.y,
                        name: 'Orders',
                        borderRadius: const BorderRadius.all(Radius.circular(AppRadius.sm)),
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
