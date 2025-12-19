import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/ui/widgets/text_widget.dart';

class ListTileWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget screen;
  final bool isCompleted;
  final Function()? onBack;
  const ListTileWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.screen,
    required this.isCompleted,
    this.onBack,

  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: darkColor,
      ),
      margin: EdgeInsets.symmetric(vertical: 5),
      alignment: Alignment.center,
      child: ListTile(
        onTap: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          ).then((value) {
            if (onBack != null) {
              onBack!();
            }
          }),
        },
        title: TextWidget(text: title, color: whiteColor, textSize: 26),
        subtitle: TextWidget(text: subtitle, color: whiteColor2, textSize: 18),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
           isCompleted ?  Icon(
              Icons.check,
              color: greenColor,
              size: screenHeight / screenWidth * 100,
            ): const SizedBox.shrink(),
            SizedBox(width: screenWidth * 0.02),
            Icon(
              Icons.arrow_forward,
              color: whiteColor,
              size: screenHeight / screenWidth * 100,
            ),
          ],
        ),
      ),
    );
  }
}
