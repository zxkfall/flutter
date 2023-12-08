import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:decimal/decimal.dart';
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

  var billingType = BillingType.expense;
  var currentDate = DateTime.now();
  var chartPeriod = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingProvider>(
      builder: (context, billingProvider, child) {
        var billings = billingProvider.billings;

        var allPeriodKindData = billings
            .where((element) =>
                element.type == billingType && isInDateRange(element))
            .groupBy((element) => element.kind)
            .map((kind, values) {
          var total =
              values.fold(Decimal.zero, (sum, value) => sum + value.amount);
          return MapEntry(kind, total);
        }).toList();

        return ListView(
          children: [
            Container(
              height: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          billingType == BillingType.expense
                              ? billingType = BillingType.income
                              : billingType = BillingType.expense;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                        fixedSize: const Size(96, 16),
                        padding: const EdgeInsets.all(0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        billingType == BillingType.income
                            ? 'Income'
                            : 'Expense',
                        style: const TextStyle(color: Colors.black),
                      )),
                ],
              ),
            ),
            Container(
              height: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        chartPeriod = ChartPeriod.week;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: chartPeriod == ChartPeriod.week
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      fixedSize: const Size(96, 16),
                      padding: const EdgeInsets.all(0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Week',
                      style: TextStyle(
                          color: chartPeriod == ChartPeriod.week
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Colors.white,
                          fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        chartPeriod = ChartPeriod.month;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: chartPeriod == ChartPeriod.month
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      fixedSize: const Size(96, 16),
                      padding: const EdgeInsets.all(0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Month',
                      style: TextStyle(
                          color: chartPeriod == ChartPeriod.month
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Colors.white,
                          fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        chartPeriod = ChartPeriod.year;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: chartPeriod == ChartPeriod.year
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0),
                      ),
                      fixedSize: const Size(96, 16),
                      padding: const EdgeInsets.all(0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Year',
                      style: TextStyle(
                          color: chartPeriod == ChartPeriod.year
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Colors.white,
                          fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      chartPeriod == ChartPeriod.week
                          ? currentDate =
                              currentDate.subtract(const Duration(days: 7))
                          : chartPeriod == ChartPeriod.month
                              ? currentDate = DateTime(currentDate.year,
                                  currentDate.month - 1, currentDate.day)
                              : currentDate = DateTime(currentDate.year - 1,
                                  currentDate.month, currentDate.day);
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 16,
                    )),
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
                    style: const TextStyle(fontSize: 14.0),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      chartPeriod == ChartPeriod.week
                          ? currentDate =
                              currentDate.add(const Duration(days: 7))
                          : chartPeriod == ChartPeriod.month
                              ? currentDate = DateTime(currentDate.year,
                                  currentDate.month + 1, currentDate.day)
                              : currentDate = DateTime(currentDate.year + 1,
                                  currentDate.month, currentDate.day);
                      setState(() {});
                    },
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    )),
              ],
            ),
            Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: 1.50,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 18,
                      left: 12,
                      top: 32,
                      bottom: 12,
                    ),
                    child: buildLineChart(billings),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 12,
                  child: Text(
                    chartPeriod.name,
                    style: TextStyle(
                        fontSize: 12, color: Colors.black.withOpacity(0.5)),
                  ),
                ),
              ],
            ),
            Column(
              children: allPeriodKindData.map((e) {
                return Padding(
                    padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                    child: Card(
                      color: Color.fromRGBO(Random().nextInt(255),
                          Random().nextInt(255), Random().nextInt(255), 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: ListTile(
                        title: Text(e.first.name),
                        trailing: Text(e.second.toString()),
                        leading: Icon(
                            BillingIconMapper.getIcon(billingType, e.first)),
                      ),
                    ));
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  bool isInDateRange(Billing billing) {
    if (chartPeriod == ChartPeriod.week) {
      return billing.date.isAfter(
              currentDate.subtract(Duration(days: currentDate.weekday - 1))) &&
          billing.date.isBefore(currentDate.add(
              Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1)));
    } else if (chartPeriod == ChartPeriod.month) {
      return billing.date
              .isAfter(DateTime(currentDate.year, currentDate.month, 1)) &&
          billing.date
              .isBefore(DateTime(currentDate.year, currentDate.month + 1, 1));
    } else if (chartPeriod == ChartPeriod.year) {
      return billing.date.isAfter(DateTime(currentDate.year, 1, 1)) &&
          billing.date.isBefore(DateTime(currentDate.year + 1, 1, 1));
    }
    return false;
  }

  LineChart buildLineChart(List<Billing> billings) {
    if (chartPeriod == ChartPeriod.week) {
      var weekSpots = generateSpots(
          billings,
          billingType,
          currentDate.subtract(Duration(days: currentDate.weekday - 1)),
          currentDate.add(
              Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1)),
          chartPeriod);
      return LineChart(generateLineChartData(weekSpots, false));
    } else if (chartPeriod == ChartPeriod.month) {
      var monthSpots = generateSpots(
          billings,
          billingType,
          DateTime(currentDate.year, currentDate.month, 1),
          DateTime(currentDate.year, currentDate.month + 1, 1),
          chartPeriod);
      return LineChart(generateLineChartData(monthSpots, true));
    } else if (chartPeriod == ChartPeriod.year) {
      var yearSpots = generateSpots(
          billings,
          billingType,
          DateTime(currentDate.year, 1, 1),
          DateTime(currentDate.year + 1, 1, 1),
          chartPeriod);
      return LineChart(generateLineChartData(yearSpots, false));
    }
    var weekSpots = generateSpots(
        billings,
        billingType,
        currentDate.subtract(Duration(days: currentDate.weekday - 1)),
        currentDate.add(
            Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1)),
        chartPeriod);
    return LineChart(generateLineChartData(weekSpots, false));
  }

  int getDayByPeriod(ChartPeriod chartPeriod, DateTime date) {
    if (chartPeriod == ChartPeriod.week) {
      return date.weekday;
    } else if (chartPeriod == ChartPeriod.month) {
      return date.day;
    } else if (chartPeriod == ChartPeriod.year) {
      return date.month;
    } else {
      return 0;
    }
  }

  List<FlSpot> generateSpots(
    List<Billing> billings,
    BillingType billingType,
    DateTime startDate,
    DateTime endDate,
    ChartPeriod chartPeriod,
  ) {
    var spotsPre = billings
        .where((element) =>
            element.type == billingType &&
            element.date.isAfter(startDate) &&
            element.date.isBefore(endDate))
        .sortedBy((element) => element.date)
        .groupBy((element) => getDayByPeriod(chartPeriod, element.date))
        .map((day, values) {
          var total =
              values.fold(Decimal.zero, (sum, value) => sum + value.amount);
          return MapEntry(day.toString(), total);
        })
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
        .toList();

    return List.generate(
      getPeriodCountByDate(chartPeriod, endDate),
      (day) => getSpotForDay(spotsPre, day, chartPeriod),
    );
  }

  int getPeriodCountByDate(ChartPeriod chartPeriod, DateTime endDate) {
    if (chartPeriod == ChartPeriod.week) {
      return 7;
    } else if (chartPeriod == ChartPeriod.month) {
      return endDate.daysInMonth;
    } else if (chartPeriod == ChartPeriod.year) {
      return 12;
    } else {
      return 0;
    }
  }

  FlSpot getSpotForDay(
      List<FlSpot> spotsPre, int day, ChartPeriod chartPeriod) {
    var spot = spotsPre.firstWhere((element) => element.x.toInt() == (day + 1),
        orElse: () => FlSpot(day + 1.0, 0));
    return spot;
  }

  LineChartData generateLineChartData(List<FlSpot> spots, bool isMonthData) {
    var maxY =
        spots.maxBy((element) => element.y.toDouble())!.y.toDouble().toInt() ==
                0
            ? 10.0
            : spots.maxBy((element) => element.y.toDouble())!.y.toDouble();
    var minY = 0.0;
    var maxX = spots.maxBy((element) => element.x.toDouble())!.x.toDouble();
    var minX = spots.minBy((element) => element.x.toDouble())!.x.toDouble();

    var bottomTitlesInterval = isMonthData ? 5.0 : 1.0;
    var tagCount = 8;
    var leftTitlesInterval = (maxY ~/ tagCount).toDouble();

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
              if (value.toInt() % (maxY ~/ tagCount) != 0) {
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
      maxY: (((maxY - (maxY ~/ tagCount) * tagCount) / (maxY ~/ tagCount))
                  .ceil() +
              tagCount) *
          (maxY ~/ tagCount).toDouble(),
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
