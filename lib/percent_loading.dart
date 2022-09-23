import 'package:flutter/material.dart';

class PercentLoadingDialog extends StatefulWidget {
  PercentLoadingDialog(this.percent);
  final ValueNotifier<int> percent;
  @override
  State<StatefulWidget> createState() => _PercentLoadingDialogState();
}

class _PercentLoadingDialogState extends State<PercentLoadingDialog> {
  @override
  void initState() {
    super.initState();
    widget.percent.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              color: Colors.red,
            ),
          ),
          Text(
            "${widget.percent.value}%",
            style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.none),
          ),
        ],
      ),
      height: 200,
      width: 200,
    );
  }
}
