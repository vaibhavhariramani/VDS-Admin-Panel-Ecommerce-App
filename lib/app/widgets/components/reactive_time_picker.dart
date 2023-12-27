import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../themes/app_theme.dart';

class ReactiveTimePickerField<T> extends ReactiveFormField<T, TimeOfDay> {
  final String controlName;
  final ValueChanged<TimeOfDay?>? onChanged;
  final Widget? prefixIcon;
  final Function()? onEditingComplete;
  final String? hintText;
  final ValidationMessageFunction validationMessage;

  ReactiveTimePickerField({
    Key? key,
    required this.controlName,
    this.onChanged,
    this.prefixIcon,
    required this.onEditingComplete,
    required this.validationMessage,
    this.hintText,
  }) : super(
          key: key,
          formControlName: controlName,
          builder: (ReactiveFormFieldState<T, TimeOfDay> field) {
            final _ReactiveDatePickerFieldState<TimeOfDay> _state =
                field as _ReactiveDatePickerFieldState<TimeOfDay>;
            // DateTime startDate = DateTime(2000);
            // DateTime endDate = DateTime(3000);

            return GestureDetector(
              onTap: () {
                showTimePicker(
                    context: _state.context,
                    initialTime: TimeOfDay.now(),
                    initialEntryMode: TimePickerEntryMode.dial,
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          primaryColor: Theme.of(_state.context).primaryColor,
                          colorScheme: ColorScheme.light(
                              primary: Theme.of(_state.context).primaryColor),
                          textButtonTheme: TextButtonThemeData(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateColor.resolveWith(
                                  (states) => Colors.white),
                              backgroundColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      Theme.of(_state.context).primaryColor),
                              overlayColor: MaterialStateColor.resolveWith(
                                  (states) =>
                                      Theme.of(_state.context).primaryColor),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    }).then((value) => _state._onChanged(value, onChanged));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: _state.errorText != null
                          ? BorderSide(
                              color: Theme.of(_state.context).errorColor,
                            )
                          : BorderSide.none,
                    ),
                    clipBehavior: Clip.hardEdge,
                    color:
                        Theme.of(_state.context).inputDecorationTheme.fillColor,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 10,
                      ),
                      child: SizedBox(
                        height: 46,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            prefixIcon ?? const SizedBox.shrink(),
                            Text(
                              // (_state.value ?? "DD/MM/YY").toString(),
                              _state.value == null
                                  ? hintText ?? "hh:mm"
                                  : _state.value!
                                      .format(Get.context!)
                                      .toString(),
                              textScaleFactor: Get.textScaleFactor,
                              style: DefaultTextStyle.of(_state.context)
                                  .style
                                  .copyWith(
                                    color: AppColors.grey,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // if (_state.errorText != null)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      top: 10,
                    ),
                    child: Text(
                      _state.errorText ?? "",
                      textScaleFactor: Get.textScaleFactor,
                      style: DefaultTextStyle.of(_state.context).style.copyWith(
                            color: Theme.of(_state.context).errorColor,
                            fontSize: 12,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

  @override
  ReactiveFormFieldState<T, TimeOfDay> createState() =>
      _ReactiveDatePickerFieldState<T>();
}

class _ReactiveDatePickerFieldState<T>
    extends ReactiveFormFieldState<T, TimeOfDay> {
  late FocusController _focusController;
  FocusNode? _focusNode;

  FocusNode get focusNode => _focusNode ?? _focusController.focusNode;

  @override
  void subscribeControl() {
    _registerFocusController(FocusController());
    super.subscribeControl();
  }

  @override
  void dispose() {
    _unregisterFocusController();
    super.dispose();
  }

  void _onChanged(TimeOfDay? value, ValueChanged<TimeOfDay?>? callBack) {
    didChange(value);
    if (callBack != null) {
      callBack(value);
    }
  }

  void _registerFocusController(FocusController focusController) {
    _focusController = focusController;
    control.registerFocusController(focusController);
  }

  void _unregisterFocusController() {
    control.unregisterFocusController(_focusController);
    _focusController.dispose();
  }
}
