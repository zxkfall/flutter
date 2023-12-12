import 'package:flutter/material.dart';

import '../model/billing.dart';

class KindSelectionView extends StatefulWidget {
  final List<BillingKind> allKinds; // 所有可选的kind
  final BillingKind selectedKind; // 当前选择的kind
  final Function(BillingKind) onKindSelected; // 回调函数，当kind被选择时调用
  final BillingType type; // 收入或支出

  const KindSelectionView({
    super.key,
    required this.allKinds,
    required this.selectedKind,
    required this.onKindSelected,
    required this.type,
  });

  @override
  State<KindSelectionView> createState() => _KindSelectionViewState();
}

class _KindSelectionViewState extends State<KindSelectionView> {
  Map<BillingType, BillingKind> selectedKinds = {};

  @override
  void initState() {
    super.initState();
    selectedKinds[widget.type] = widget.selectedKind;
  }

  @override
  void didUpdateWidget(covariant KindSelectionView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.allKinds.contains(selectedKinds[widget.type])) {
      // 如果当前选中的kind不在新的列表中，则选择默认值
      setState(() {
        selectedKinds[widget.type] = widget.type == BillingType.expense ? getExpenseValues()[0] : getIncomeValues()[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // 子元素之间的水平间距
      runSpacing: 8.0, // 每行之间的垂直间距
      children: widget.allKinds.map((kind) {
        return InkWell(
          onTap: () {
            widget.onKindSelected(kind);
            setState(() {
              selectedKinds[widget.type] = kind; // 更新选中的kind
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: kind == selectedKinds[widget.type]
                    ? Colors.blue // 选中时的边框颜色
                    : Colors.grey, // 未选中时的边框颜色
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  BillingIconMapper.getIcon(widget.type, kind), // 根据kind获取图标
                  color: kind == selectedKinds[widget.type]
                      ? Colors.blue // 选中时的图标颜色
                      : Colors.black, // 未选中时的图标颜色
                ),
                const SizedBox(width: 4.0),
                Text(
                  kind.name,
                  style: TextStyle(
                    color: kind == selectedKinds[widget.type]
                        ? Colors.blue // 选中时的文字颜色
                        : Colors.black, // 未选中时的文字颜色
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
