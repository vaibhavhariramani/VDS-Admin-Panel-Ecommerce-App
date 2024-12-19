import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../constants/constants.dart';
import '../../../themes/app_theme.dart';

class ReactiveDatePickerField<T> extends ReactiveFormField<T, DateTime> {
  final String controlName;
  final ValueChanged<DateTime?>? onChanged;
  final Widget? prefixIcon;
  final Function()? onEditingComplete;
  final String? hintText;
  final ValidationMessageFunction validationMessage;

  ReactiveDatePickerField({
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
          builder: (ReactiveFormFieldState<T, DateTime> field) {
            final _ReactiveDatePickerFieldState<DateTime> _state =
                field as _ReactiveDatePickerFieldState<DateTime>;
            DateTime startDate = DateTime(2000);
            DateTime endDate = DateTime(3000);

            return GestureDetector(
              onTap: () {
                Get.dialog(
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Material(
                          borderRadius: BorderRadius.circular(15.0),
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            height: 500,
                            width: 500,
                            child: SfDateRangePicker(
                              minDate: startDate,
                              maxDate: endDate,
                              showActionButtons: true,
                              showTodayButton: false,
                              view: DateRangePickerView.month,
                              viewSpacing: 5,
                              showNavigationArrow: true,
                              todayHighlightColor:
                                  Theme.of(_state.context).primaryColor,
                              selectionColor:
                                  Theme.of(_state.context).primaryColor,
                              // backgroundColor: DarkChatTheme().backgroundColor,
                              onSelectionChanged:
                                  (DateRangePickerSelectionChangedArgs args) {
                                _state._onChanged(args.value, onChanged);
                                Navigator.pop(Get.context!);
                              },
                              onCancel: () {
                                Navigator.pop(Get.context!);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  name: 'DatePicker',
                );
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
                              color: Theme.of(_state.context).colorScheme.error,
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
                                  ? hintText!
                                  : dateFortter3(
                                      _state.value ?? DateTime.now(),
                                    ),
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
                            color: Theme.of(_state.context).colorScheme.error,
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
  ReactiveFormFieldState<T, DateTime> createState() =>
      _ReactiveDatePickerFieldState<T>();
}

class _ReactiveDatePickerFieldState<T>
    extends ReactiveFormFieldState<T, DateTime> {
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

  void _onChanged(DateTime? value, ValueChanged<DateTime?>? callBack) {
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
