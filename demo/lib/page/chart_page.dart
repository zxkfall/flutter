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

  bool period = false;
  BillingType billingType = BillingType.expense;
  var currentDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<BillingProvider>(context, listen: false);
    var billings = provider.billings;

    var firstDayOfWeek =
        currentDate.subtract(Duration(days: currentDate.weekday - 1));
    var lastDayOfWeek = currentDate
        .add(Duration(days: DateTime.daysPerWeek - currentDate.weekday));

    var weekSpots = generateSpots(
        billings, billingType, firstDayOfWeek, lastDayOfWeek, true);

    var firstDayOfMonth = DateTime(currentDate.year, currentDate.month, 1);
    var lastDayOfMonth = DateTime(currentDate.year, currentDate.month + 1, 1)
        .subtract(const Duration(days: 1));

    var monthSpots = generateSpots(
        billings, billingType, firstDayOfMonth, lastDayOfMonth, false);

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
          children: [
            Text(period ? 'Month' : 'Week'),
            Switch(
              value: period,
              onChanged: (value) {
                setState(() {
                  period = value;
                });
              },
            ),
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
                child: LineChart(
                  period
                      ? generateLineChartData(monthSpots, true)
                      : generateLineChartData(weekSpots, false),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 34,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    period = !period;
                  });
                },
                child: Text(
                  'period',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        period ? Colors.black.withOpacity(0.5) : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  List<FlSpot> generateSpots(
    List<Billing> billings,
    BillingType billingType,
    DateTime startDate,
    DateTime endDate,
    bool isWeek,
  ) {
    var spotsPre = billings
        .where((element) =>
            element.type == billingType &&
            element.date.isAfter(startDate) &&
            element.date.isBefore(endDate))
        .sortedBy((element) => element.date)
        .groupBy((element) => isWeek ? element.date.weekday : element.date.day)
        .map((day, values) => MapEntry(day.toString(),
            values.sumBy((element) => element.amount.toDouble())))
        .entries
        .map((e) => FlSpot(double.parse(e.key), e.value))
        .toList();

    return List.generate(isWeek ? endDate.weekday : endDate.day, (day) {
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
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() % (maxY / 10).toInt() != 0) {
                return Container();
              }
              return Text(value.toString(),
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
