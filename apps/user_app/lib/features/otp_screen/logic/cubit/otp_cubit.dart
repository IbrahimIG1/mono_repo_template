import 'dart:async';
import 'package:monorepo_template/features/otp_screen/logic/repo/otp_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepo otpRepo;

  OtpCubit(this.otpRepo) : super(OtpInitialState()) {
    startTimer();
  }
  static OtpCubit get(context) => BlocProvider.of(context);
  Timer? timer;
  Duration duration = const Duration(minutes: 4);
  //* Form key
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //* Text Controller
  TextEditingController otpController = TextEditingController();
  Future<void> sendVerificationCode(String phone) async {
    emit(OtpLoadingState());

    final response = await otpRepo.requestOtpCode(phone.trim());
    response.fold(
      (error) {
        if (!isClosed) {
          emit(OtpErrorState(error));
        }
      },
      (success) {
        if (!isClosed) {
          emit(OtpSuccessState(message: success));
        }
      },
    );
  }

  // ignore: unused_field
  Timer? _timer;
  int _remainingSeconds = 180; // 3 minutes in seconds
  bool _canResend = false; // Add this flag

  void startTimer() {
    _remainingSeconds = 180;
    _canResend = false;
    if (!isClosed) {
      emit(OtpTimerState(_remainingSeconds, _canResend));
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        if (!isClosed) {
          emit(OtpTimerState(_remainingSeconds, _canResend));
        }
      } else {
        _canResend = true; // Enable resend when timer reaches 0
        if (!isClosed) {
          emit(OtpTimerState(0, _canResend));
        }
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }
}
