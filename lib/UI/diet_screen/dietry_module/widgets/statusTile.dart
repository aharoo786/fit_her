import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../widgets/app_bar_widget.dart';

class StatusTileData {
  final String name;
  final String status;
  final String time;
  final StatusType type;
  final bool isDiet;

  StatusTileData(this.name, this.status, this.time, this.type, {this.isDiet = false});
}

class StatusTile extends StatelessWidget {
  final String name;
  final String? status;
  final String time;
  final bool isDiet;

  StatusTile({required this.name, required this.status, required this.time, this.isDiet = false});
  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    // Convert the incoming string to enum
    var st = HelpingWidgets.getStatusColorAndIcon(status ?? "");
    print('StatusTile.build ${st}' );
    IconData icon = st[0];
    Color color = st[1];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name ?? "", style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500)),
                if (time.isNotEmpty) Text(time, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w400, color: Colors.grey)),
                if (time.isEmpty)
                  Text(
                    (status ?? 'N/A').capitalizeFirst ?? "",
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      color: color,
                    ),
                  ),
              ],
            ),
          ),
          Icon(icon, color: color),
        ],
      ),
    );
  }
}
