import 'package:core/di/di.dart';
import 'package:core/helper/spacer.dart';
import 'package:sandwich_app/core/routing/screens_names.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:shared/widgets/text_field/phone_number_widget.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:sandwich_app/features/register_screen/logic/cubit/register_cubit.dart';
import 'package:sandwich_app/features/register_screen/logic/cubit/register_state.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/build_register_button.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/register_confirm_password_field.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/register_gender_selection.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/register_password_field.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/register_password_requirements.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/register_terms_and_conditions_checkbox.dart';
import 'package:sandwich_app/features/register_screen/ui/widgets/register_user_name_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<RegisterCubit>(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 1.h),
              child: SingleChildScrollView(
                child: BlocConsumer<RegisterCubit, RegisterState>(
                  listener: (context, state) {
                    if (state is RegisterSuccessState) {
                      showToast(
                        msg: "تم التسجيل بنجاح",
                        state: ToastStates.SUCCESS,
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        ScreensNames.login,
                      );
                    }
                    if (state is RegisterErrorState) {
                      showToast(
                        msg: state.error.message,
                        state: ToastStates.ERROR,
                      );
                    }
                  },
                  builder: (context, state) {
                    RegisterCubit cubit = RegisterCubit.get(context);
                    return Form(
                      key: cubit.formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          verticalSpace(38),
                          registerGenderSelection(cubit),
                          verticalSpace(16),
                          registerUserNameField(cubit),
                          verticalSpace(16),
                          phoneNumberField(
                            controller: cubit.phoneNumberController,
                            getPhoneNumber: (phoneNumber) {
                              cubit.phoneNumber = phoneNumber;
                            },
                            phoneNumber: cubit.phoneNumber,
                          ),
                          verticalSpace(16),
                          registerPasswordField(cubit),
                          verticalSpace(8),
                          registerPasswordRequirements(),
                          verticalSpace(16),
                          registerConfirmPasswordField(cubit),
                          verticalSpace(24),
                          // _buildDataConfirmationCheckbox(),
                          registerCommitmentCheckbox(cubit),
                          verticalSpace(15),
                          registerTermsAndConditionsCheckbox(cubit, context),
                          verticalSpace(30),
                          buildRegisterButton(
                            context: context,
                            cubit: cubit,
                            state: state,
                          ),
                          verticalSpace(30),

                          // already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "لديك حساب؟ ",
                                style: AppTextStyles().fontGrey14Regular,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    ScreensNames.login,
                                  );
                                },
                                child: Text(
                                  "تسجيل دخول",
                                  style: AppTextStyles().fontGold14Meduim,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text("إنشاء حساب", style: AppTextStyles().fontGoldDark20Bold);
  }
}

