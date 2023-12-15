import 'dart:math';
import 'package:dartx/dartx.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../model/billing.dart';
import '../provider/billing_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _LineChartState();
}

class _LineChartState extends State<ChartPage> {
  var billingType = BillingType.expense;
  var currentDate = DateTime.now();
  var chartPeriod = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    var colorSchema = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          height: 48,
          color: colorSchema.onSurfaceVariant,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    setState(() {
                      billingType == BillingType.expense
                          ? billingType = BillingType.income
                          : billingType = BillingType.expense;
                      BillingProvider billingProvider = Provider.of<BillingProvider>(context, listen: false);
                      billingProvider.chartBillingType = billingType;
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: colorSchema.onSurfaceVariant,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    fixedSize: const Size(96, 16),
                    padding: const EdgeInsets.all(0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    billingType == BillingType.income
                        ? AppLocalizations.of(context)!.income
                        : AppLocalizations.of(context)!.expense,
                    style: TextStyle(color: billingType == BillingType.income ? Colors.green : Colors.red),
                  )),
            ],
          ),
        ),
        Expanded(child: Consumer<BillingProvider>(
          builder: (context, billingProvider, child) {
            billingType = billingProvider.chartBillingType;
            currentDate = billingProvider.chartCurrentDate;
            chartPeriod = billingProvider.chartPeriod;

            var billings = billingProvider.billings;

            var allPeriodKindData = billings
                .where((element) => element.type == billingType && isInDateRange(element))
                .groupBy((element) => element.kind)
                .map((kind, values) {
              var total = values.fold(Decimal.zero, (sum, value) => sum + value.amount);
              return MapEntry(kind, total);
            }).toList();

            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 64, right: 64),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4, bottom: 0),
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorSchema.onSurfaceVariant,
                          borderRadius: const BorderRadius.all(Radius.circular(16)),
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: colorSchema.onSurfaceVariant,
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  chartPeriod = ChartPeriod.week;
                                  billingProvider.chartPeriod = chartPeriod;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    chartPeriod == ChartPeriod.week ? Colors.white : colorSchema.onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                fixedSize: const Size(96, 16),
                                padding: const EdgeInsets.all(0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.week,
                                style: TextStyle(
                                    color:
                                        chartPeriod == ChartPeriod.week ? colorSchema.onSurfaceVariant : Colors.white,
                                    fontSize: 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  chartPeriod = ChartPeriod.month;
                                  billingProvider.chartPeriod = chartPeriod;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    chartPeriod == ChartPeriod.month ? Colors.white : colorSchema.onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                fixedSize: const Size(96, 16),
                                padding: const EdgeInsets.all(0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.month,
                                style: TextStyle(
                                    color:
                                        chartPeriod == ChartPeriod.month ? colorSchema.onSurfaceVariant : Colors.white,
                                    fontSize: 14),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  chartPeriod = ChartPeriod.year;
                                  billingProvider.chartPeriod = chartPeriod;
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    chartPeriod == ChartPeriod.year ? Colors.white : colorSchema.onSurfaceVariant,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                fixedSize: const Size(96, 16),
                                padding: const EdgeInsets.all(0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.year,
                                style: TextStyle(
                                    color:
                                        chartPeriod == ChartPeriod.year ? colorSchema.onSurfaceVariant : Colors.white,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          chartPeriod == ChartPeriod.week
                              ? currentDate = currentDate.subtract(const Duration(days: 7))
                              : chartPeriod == ChartPeriod.month
                                  ? currentDate = DateTime(currentDate.year, currentDate.month - 1, currentDate.day)
                                  : currentDate = DateTime(currentDate.year - 1, currentDate.month, currentDate.day);
                          billingProvider.chartCurrentDate = currentDate;
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
                            billingProvider.chartCurrentDate = currentDate;
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
                              ? currentDate = currentDate.add(const Duration(days: 7))
                              : chartPeriod == ChartPeriod.month
                                  ? currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day)
                                  : currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
                          billingProvider.chartCurrentDate = currentDate;
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
                  ],
                ),
                Column(
                  children: allPeriodKindData.map((e) {
                    return Padding(
                        padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
                        child: Card(
                          color: Color.fromRGBO(Random().nextInt(255), Random().nextInt(255), Random().nextInt(255), 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: ListTile(
                            title: Text(e.first.name),
                            trailing: Text(e.second.toString()),
                            leading: Icon(BillingIconMapper.getIcon(billingType, e.first)),
                          ),
                        ));
                  }).toList(),
                ),
              ],
            );
          },
        ))
      ],
    );
  }

  bool isInDateRange(Billing billing) {
    if (chartPeriod == ChartPeriod.week) {
      return billing.date.isAfter(currentDate.subtract(Duration(days: currentDate.weekday - 1))) &&
          billing.date.isBefore(currentDate.add(Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1)));
    } else if (chartPeriod == ChartPeriod.month) {
      return billing.date.isAfter(DateTime(currentDate.year, currentDate.month, 1)) &&
          billing.date.isBefore(DateTime(currentDate.year, currentDate.month + 1, 1));
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
          currentDate.add(Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1)),
          chartPeriod);
      return LineChart(generateLineChartData(weekSpots, false));
    } else if (chartPeriod == ChartPeriod.month) {
      var monthSpots = generateSpots(billings, billingType, DateTime(currentDate.year, currentDate.month, 1),
          DateTime(currentDate.year, currentDate.month + 1, 1), chartPeriod);
      return LineChart(generateLineChartData(monthSpots, true));
    } else if (chartPeriod == ChartPeriod.year) {
      var yearSpots = generateSpots(
          billings, billingType, DateTime(currentDate.year, 1, 1), DateTime(currentDate.year + 1, 1, 1), chartPeriod);
      return LineChart(generateLineChartData(yearSpots, false));
    }
    var weekSpots = generateSpots(billings, billingType, currentDate.subtract(Duration(days: currentDate.weekday - 1)),
        currentDate.add(Duration(days: DateTime.daysPerWeek - currentDate.weekday + 1)), chartPeriod);
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
            element.type == billingType && element.date.isAfter(startDate) && element.date.isBefore(endDate))
        .sortedBy((element) => element.date)
        .groupBy((element) => getDayByPeriod(chartPeriod, element.date))
        .map((day, values) {
          var total = values.fold(Decimal.zero, (sum, value) => sum + value.amount);
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

  FlSpot getSpotForDay(List<FlSpot> spotsPre, int day, ChartPeriod chartPeriod) {
    var spot = spotsPre.firstWhere((element) => element.x.toInt() == (day + 1), orElse: () => FlSpot(day + 1.0, 0));
    return spot;
  }

  LineChartData generateLineChartData(List<FlSpot> spots, bool isMonthData) {
    var maxY = spots.maxBy((element) => element.y.toDouble())!.y.toDouble().toInt() == 0
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
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.onTertiary,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Theme.of(context).colorScheme.onTertiary,
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
        border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      minX: minX,
      maxX: maxX,
      minY: minY,
      maxY: (((maxY - (maxY ~/ tagCount) * tagCount) / (maxY ~/ tagCount)).ceil() + tagCount) *
          (maxY ~/ tagCount).toDouble(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: false,
          gradient: LinearGradient(
            colors: gradientColors(context),
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                strokeWidth: 1,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors(context).map((color) => color.withOpacity(0.3)).toList(),
            ),
          ),
        ),
      ],
    );
  }

  List<Color> gradientColors(BuildContext context) {
    return billingType == BillingType.expense
        ? [Theme.of(context).colorScheme.onSurfaceVariant, Theme.of(context).colorScheme.onSurface]
        : [Theme.of(context).colorScheme.tertiaryContainer, Theme.of(context).colorScheme.tertiary];
  }
}

enum ChartPeriod { week, month, year }
