import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final Widget textfield;
  final bool isRequired;

  const LabeledTextField({
    Key? key,
    required this.label,
    required this.textfield,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 5,
          ),
          child: RichText(
            textScaleFactor: Get.textScaleFactor,
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: DefaultTextStyle.of(context).style.copyWith(
                        color: DefaultTextStyle.of(context)
                            .style
                            .color
                            ?.withOpacity(0.6),
                        fontSize: 16,
                      ),
                ),
                TextSpan(
                  text: isRequired ? " *" : "",
                  style: DefaultTextStyle.of(context).style.copyWith(
                        color: Theme.of(context).errorColor,
                        fontSize: 16,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        textfield,
      ],
    );
  }
}
