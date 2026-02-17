import 'package:core/network/error/error_model.dart';

abstract class OtpState {}

class OtpInitialState extends OtpState {}

class OtpLoadingState extends OtpState {}

class OtpSuccessState extends OtpState {
  final String message;
  OtpSuccessState({required this.message});
}

class OtpErrorState extends OtpState {
  final ErrorModel errorModel;
  OtpErrorState(this.errorModel);
}

class OtpLoadedState extends OtpState {
  final String message;
  final Duration timeLeft;

  OtpLoadedState({required this.message, required this.timeLeft});
}

class OtpTimerState extends OtpState {
  final int remainingSeconds;
  final bool canResend;

  OtpTimerState(this.remainingSeconds, this.canResend);
}

class OtpTimerExpiredState extends OtpState {}

