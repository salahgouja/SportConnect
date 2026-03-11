import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'driver_requests_view_model.g.dart';

class DeclineReasonSheetState {
  const DeclineReasonSheetState({this.selectedReason, this.otherText = ''});

  final String? selectedReason;
  final String otherText;

  DeclineReasonSheetState copyWith({
    String? selectedReason,
    bool clearSelectedReason = false,
    String? otherText,
  }) {
    return DeclineReasonSheetState(
      selectedReason: clearSelectedReason
          ? null
          : (selectedReason ?? this.selectedReason),
      otherText: otherText ?? this.otherText,
    );
  }

  bool get canSubmit =>
      selectedReason != null &&
      (selectedReason != 'Other' || otherText.trim().isNotEmpty);

  String get resolvedReason =>
      selectedReason == 'Other' ? otherText.trim() : selectedReason!;
}

@riverpod
class DeclineReasonSheetViewModel extends _$DeclineReasonSheetViewModel {
  @override
  DeclineReasonSheetState build(String arg) => const DeclineReasonSheetState();

  void selectReason(String reason) {
    state = state.copyWith(
      selectedReason: reason,
      otherText: reason == 'Other' ? state.otherText : '',
    );
  }

  void setOtherText(String value) {
    state = state.copyWith(otherText: value);
  }
}
