import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sport_connect/features/legal/views/legal_screen.dart';

part 'legal_view_model.g.dart';

class LegalScreenUiState {
  const LegalScreenUiState({this.isLoading = true});

  final bool isLoading;

  LegalScreenUiState copyWith({bool? isLoading}) {
    return LegalScreenUiState(isLoading: isLoading ?? this.isLoading);
  }
}

@riverpod
class LegalScreenUiViewModel extends _$LegalScreenUiViewModel {
  @override
  LegalScreenUiState build(LegalDocumentType arg) => const LegalScreenUiState();

  void setLoading(bool value) {
    if (state.isLoading == value) return;
    state = state.copyWith(isLoading: value);
  }
}
