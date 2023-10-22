import 'dart:developer';

import 'package:dartx/dartx.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/billing.dart';
import '../provider/billing_provider.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _LineChartState();
}

class _LineChartState extends State<ChartPage> {
  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  BillingType billingType = BillingType.expense;
  var currentDate = DateTime.now();
  var chartPeriod = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, billingProvider, child) {
        log('start');
        var billings = billingProvider.billings;

        var weekSpots = generateSpots(
            billings,
            billingType,
            currentDate.subtract(Duration(days: currentDate.weekday - 1)),
            currentDate.add(
                Duration(days: DateTime.daysPerWeek - currentDate.weekday)),
            chartPeriod);

        var monthSpots = generateSpots(
            billings,
            billingType,
            DateTime(currentDate.year, currentDate.month, 1),
            DateTime(currentDate.year, currentDate.month + 1, 1)
                .subtract(const Duration(days: 1)),
            chartPeriod);

        var yearSpots = generateSpots(
            billings,
            billingType,
            DateTime(currentDate.year, 1, 1),
            DateTime(currentDate.year + 1, 1, 1),
            chartPeriod);
        log('end');
        return Column(
          children: [
            TextButton(
              onPressed: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: currentDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    currentDate = date;
                  });
                }
              },
              child: Text(
                DateFormat.yMMMd().format(currentDate),
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Radio(
                  value: ChartPeriod.week,
                  groupValue: chartPeriod,
                  onChanged: (value) {
                    setState(() {
                      chartPeriod = value!;
                    });
                  },
                ),
                const Text('Week'),
                Radio(
                  value: ChartPeriod.month,
                  groupValue: chartPeriod,
                  onChanged: (value) {
                    setState(() {
                      chartPeriod = value!;
                    });
                  },
                ),
                const Text('Month'),
                Radio(
                  value: ChartPeriod.year,
                  groupValue: chartPeriod,
                  onChanged: (value) {
                    setState(() {
                      chartPeriod = value!;
                    });
                  },
                ),
                const Text('Year'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(billingType == BillingType.income ? 'Income' : 'Expense'),
                Switch(
                  value: billingType == BillingType.income,
                  onChanged: (value) {
                    setState(() {
                      billingType =
                          value ? BillingType.income : BillingType.expense;
                    });
                  },
                ),
              ],
            ),
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.70,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 30,
                      bottom: 12,
                    ),
                    child: LineChart(chartPeriod == ChartPeriod.week
                        ? generateLineChartData(weekSpots, false)
                        : chartPeriod == ChartPeriod.month
                            ? generateLineChartData(monthSpots, true)
                            : generateLineChartData(yearSpots, false)),
                  ),
                ),
                SizedBox(
                  width: 60,
                  height: 34,
                  child: Text(
                    chartPeriod.name,
                    style: TextStyle(
                        fontSize: 12, color: Colors.black.withOpacity(0.5)),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  List<FlSpot> generateSpots(
    List<Billing> billings,
    BillingType billingType,
    DateTime startDate,
    DateTime endDate,
    ChartPeriod chartPeriod,
  ) {
    Iterable<FlSpot> spotsPre = billings
        .where((element) =>
            element.type == billingType &&
            element.date.isAfter(startDate) &&
            element.date.isBefore(endDate))
        .sortedBy((element) => element.date)
        .groupBy((element) {
          if (chartPeriod == ChartPeriod.week) {
            return element.date.weekday;
          } else if (chartPeriod == ChartPeriod.month) {
            return element.date.day;
          } else if (chartPeriod == ChartPeriod.year) {
            return element.date.month;
          }
        })
        .map((day, values) => MapEntry(day.toString(),
            values.sumBy((element) => element.amount.toDouble())))
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()));

    return List.generate(
        chartPeriod == ChartPeriod.week
            ? endDate.weekday
            : chartPeriod == ChartPeriod.month
                ? endDate.day
                : chartPeriod == ChartPeriod.year
                    ? 12
                    : 0, (day) {
      var spot = spotsPre.firstWhere((element) => element.x == (day + 1),
          orElse: () => FlSpot(day + 1.0, 0));
      return spot;
    });
  }

  LineChartData generateLineChartData(List<FlSpot> spots, bool isMonthData) {
    var maxY =
        spots.maxBy((element) => element.y.toDouble())!.y.toDouble().toInt() ==
                0
            ? 10.0
            : spots.maxBy((element) => element.y.toDouble())!.y.toDouble();
    var minY = spots.minBy((element) => element.y.toDouble())!.y.toDouble();
    var maxX = spots.maxBy((element) => element.x.toDouble())!.x.toDouble();
    var minX = spots.minBy((element) => element.x.toDouble())!.x.toDouble();

    var bottomTitlesInterval = isMonthData ? 5.0 : 1.0;
    var leftTitlesInterval = (maxY ~/ 10).toDouble();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: AppColors.mainGridLineColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: bottomTitlesInterval,
            getTitlesWidget: (value, meta) {
              if (isMonthData) {
                return value.toInt() % 5 != 0
                    ? Container()
                    : Text(value.toInt().toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.left);
              } else {
                return Text(value.toInt().toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.left);
              }
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: leftTitlesInterval,
            getTitlesWidget: (value, meta) {
              if (value.toInt() % (maxY ~/ 10) != 0) {
                return Container();
              }
              return Text(value.toInt().toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.left);
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

enum ChartPeriod { week, month, year }

class AppColors {
  static const Color primary = contentColorCyan;
  static const Color menuBackground = Color(0xFF090912);
  static const Color itemsBackground = Color(0xFF1B2339);
  static const Color pageBackground = Color(0xFF282E45);
  static const Color mainTextColor1 = Colors.white;
  static const Color mainTextColor2 = Colors.white70;
  static const Color mainTextColor3 = Colors.white38;
  static const Color mainGridLineColor = Colors.white10;
  static const Color borderColor = Colors.white54;
  static const Color gridLinesColor = Color(0x11FFFFFF);

  static const Color contentColorBlack = Colors.black;
  static const Color contentColorWhite = Colors.white;
  static const Color contentColorBlue = Color(0xFF2196F3);
  static const Color contentColorYellow = Color(0xFFFFC300);
  static const Color contentColorOrange = Color(0xFFFF683B);
  static const Color contentColorGreen = Color(0xFF3BFF49);
  static const Color contentColorPurple = Color(0xFF6E1BFF);
  static const Color contentColorPink = Color(0xFFFF3AF2);
  static const Color contentColorRed = Color(0xFFE80054);
  static const Color contentColorCyan = Color(0xFF50E4FF);
}
