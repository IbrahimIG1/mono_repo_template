import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/local/shared_prefrence.dart';

part 'language_state.dart';

class LanguageCubit extends Cubit<Locale> {
  LanguageCubit()
    : super(
        Locale(
          SharedPreferencesHelper.getString(SharedPrefKeys.language) ?? "ar",
        ),
      );
  static LanguageCubit get(context) => BlocProvider.of(context);

  void langChange({required String langCode}) async {
    SharedPreferencesHelper.saveString(SharedPrefKeys.language, langCode);
    emit(Locale(langCode));
  }
}

