import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reactive_forms/reactive_forms.dart';

class FormTextInputField<T> extends ReactiveFormField<T, String> {
  final String controlName;
  final String hintText;
  final bool obscureText;
  final String? prefixText;
  final Widget? prefixIcon;
  final bool showErrorIcon;
  final VoidCallback? onPasswordToggle;
  final Function() onEditingComplete;
  final VoidCallback? onSubmitted;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final ValidationMessageFunction validationMessage;
  final FocusNode? focusNode;
  final bool readOnly;
  final int maxLines;
  final bool expands;

  FormTextInputField({
    Key? key,
    required this.controlName,
    required this.hintText,
    this.prefixText,
    this.prefixIcon,
    this.showErrorIcon = false,
    this.obscureText = false,
    this.onPasswordToggle,
    required this.onEditingComplete,
    this.onSubmitted,
    required this.textInputAction,
    required this.keyboardType,
    required this.validationMessage,
    this.onChanged,
    this.focusNode,
    this.readOnly = false,
    this.maxLines = 1,
    this.expands = false,
  }) : super(
          key: key,
          formControlName: controlName,
          validationMessages:
              validationMessage as Map<String, String Function(Object)>,
          builder: (ReactiveFormFieldState<T, String> field) {
            final _state = field as _ReactiveFormInputFieldState<T>;

            _state._setFocusNode(focusNode);

            return Column(
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
                    child: TextField(
                      cursorColor: Theme.of(_state.context).indicatorColor,
                      controller: _state._textController,
                      enabled: _state.control.enabled,
                      focusNode: _state.focusNode,
                      keyboardType: keyboardType,
                      textInputAction: textInputAction,
                      obscureText: obscureText,
                      maxLines: maxLines,
                      expands: expands,
                      decoration: InputDecoration(
                        hintText: hintText,
                        prefixIcon: prefixIcon,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      smartDashesType: obscureText
                          ? SmartDashesType.disabled
                          : SmartDashesType.enabled,
                      smartQuotesType: obscureText
                          ? SmartQuotesType.disabled
                          : SmartQuotesType.enabled,
                      onSubmitted:
                          onSubmitted != null ? (_) => onSubmitted() : null,
                      onEditingComplete: onEditingComplete,
                      onChanged: field.didChange,
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
            );
          },
        );

  @override
  ReactiveFormFieldState<T, String> createState() =>
      _ReactiveFormInputFieldState<T>();
}

class _ReactiveFormInputFieldState<T>
    extends ReactiveFormFieldState<T, String> {
  late TextEditingController _textController;
  late FocusController _focusController;
  FocusNode? _focusNode;

  FocusNode get focusNode => _focusNode ?? _focusController.focusNode;

  @override
  void initState() {
    super.initState();
    _initializeTextController();
  }

  @override
  void subscribeControl() {
    _registerFocusController(FocusController());
    super.subscribeControl();
  }

  @override
  void unsubscribeControl() {
    _unregisterFocusController();
    super.unsubscribeControl();
  }

  @override
  void onControlValueChanged(dynamic value) {
    final effectiveValue = (value == null) ? '' : value.toString();
    _textController.value = _textController.value.copyWith(
      text: effectiveValue,
      selection: TextSelection.collapsed(offset: effectiveValue.length),
      composing: TextRange.empty,
    );

    super.onControlValueChanged(value);
  }

  @override
  ControlValueAccessor<T, String> selectValueAccessor() {
    if (control is FormControl<int>) {
      return IntValueAccessor() as ControlValueAccessor<T, String>;
    } else if (control is FormControl<double>) {
      return DoubleValueAccessor() as ControlValueAccessor<T, String>;
    } else if (control is FormControl<DateTime>) {
      return DateTimeValueAccessor() as ControlValueAccessor<T, String>;
    } else if (control is FormControl<TimeOfDay>) {
      return TimeOfDayValueAccessor() as ControlValueAccessor<T, String>;
    }

    return super.selectValueAccessor();
  }

  void _registerFocusController(FocusController focusController) {
    _focusController = focusController;
    control.registerFocusController(focusController);
  }

  void _unregisterFocusController() {
    control.unregisterFocusController(_focusController);
    _focusController.dispose();
  }

  void _setFocusNode(FocusNode? focusNode) {
    if (_focusNode != focusNode) {
      _focusNode = focusNode;
      _unregisterFocusController();
      _registerFocusController(FocusController(focusNode: _focusNode));
    }
  }

  void _initializeTextController() {
    final initialValue = value;
    _textController = TextEditingController();
    _textController.text = initialValue == null ? '' : initialValue.toString();
  }
}
