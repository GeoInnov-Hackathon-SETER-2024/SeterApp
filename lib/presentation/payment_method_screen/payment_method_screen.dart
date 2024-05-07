import 'package:flutter/material.dart';
import 'package:ibrahima_s_application_seter/core/app_export.dart';
import 'package:ibrahima_s_application_seter/presentation/payment_method_screen/widgets/paymentmethod_item_widget.dart';

import 'models/paymentmethod_item_model.dart';
import 'notifier/payment_method_notifier.dart';

class PaymentMethodScreen extends ConsumerStatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  PaymentMethodScreenState createState() => PaymentMethodScreenState();
}

class PaymentMethodScreenState extends ConsumerState<PaymentMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 23.v),
              _buildHeader(context),
              SizedBox(height: 34.v),
              Padding(
                padding: EdgeInsets.only(left: 43.h),
                child: Text("lbl_banque".tr, style: CustomTextStyles.titleLargePoppinsGray90005),
              ),
              SizedBox(height: 56.v),
              _buildPaymentMethod(context),
              SizedBox(height: 42.v),
              Padding(
                padding: EdgeInsets.only(left: 41.h),
                child: Text("msg_portefeuille_mobile".tr, style: CustomTextStyles.titleLargePoppinsGray90005),
              ),
              SizedBox(height: 53.v),
              _buildMobileWalletPaymentMethod(context),
              SizedBox(height: 230.v),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 256.h,
                  child: Divider(color: appTheme.black90002.withOpacity(0.6), endIndent: 121.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(
            imagePath: ImageConstant.imgArrowLeft,
            height: 17.v,
            width: 10.h,
            margin: EdgeInsets.only(top: 4.v, bottom: 6.v),
            onTap: () {
              onTapImgArrowLeft(context);
            },
          ),
          Text("msg_choisissez_votre2".tr, style: CustomTextStyles.titleLargeBold),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.only(left: 26.h, right: 23.h),
        child: Consumer(
          builder: (context, ref, _) {
            return GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                mainAxisExtent: 68.v,
                crossAxisCount: 3,
                mainAxisSpacing: 25.h,
                crossAxisSpacing: 25.h,
              ),
              physics: NeverScrollableScrollPhysics(),
              itemCount: ref.watch(paymentMethodNotifier).paymentMethodModelObj?.paymentmethodItemList.length ?? 0,
              itemBuilder: (context, index) {
                PaymentmethodItemModel model = ref.watch(paymentMethodNotifier).paymentMethodModelObj?.paymentmethodItemList[index] ?? PaymentmethodItemModel();
                return PaymentmethodItemWidget(model, onTapVisa: () {
                  onTapVisa(context);
                });
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileWalletPaymentMethod(BuildContext context) {
    List<String> walletImages = [
      ImageConstant.imgRectangle310,
      ImageConstant.imgRectangle367x102,
      ImageConstant.imgRectangle31,
      ImageConstant.imgRectangle38,
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26.h),
      child: Column(
        children: [
          Row(
            children: [
              _buildMobileWalletItem(context, walletImages[0], onTap: () => onTapImgImage(context)),
            ],
          ),
          SizedBox(height: 25.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMobileWalletItem(context, walletImages[1], onTap: () => onTapImgImage1(context)),
              _buildMobileWalletItem(context, walletImages[2], onTap: () => onTapImgImage2(context)),
              _buildMobileWalletItem(context, walletImages[3], onTap: () => onTapImgImage3(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileWalletItem(BuildContext context, String imagePath, {bool hasCheckmark = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 67.v,
        width: 102.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            CustomImageView(
              imagePath: imagePath,
              height: 67.v,
              width: 102.h,
              radius: BorderRadius.circular(8.h),
              alignment: Alignment.center,
            ),
            if (hasCheckmark)
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  height: 7.v,
                  width: 6.h,
                  margin: EdgeInsets.only(top: 4.v, right: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3.h),
                  ),
                  child: CustomImageView(
                    imagePath: ImageConstant.imgCheckmarkIndigo900,
                    height: 7.v,
                    width: 6.h,
                    alignment: Alignment.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Navigates to the lightVersionSixScreen when the action is triggered.
  onTapVisa(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.lightVersionSixScreen);
  }

  /// Navigates back to the previous screen.
  onTapImgArrowLeft(BuildContext context) {
    NavigatorService.goBack();
  }

  /// Navigates to the lightVersionSixScreen when the action is triggered.
  onTapImgImage(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.lightVersionSixScreen);
  }

  /// Navigates to the lightVersionSixScreen when the action is triggered.
  onTapImgImage1(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.lightVersionSixScreen);
  }

  /// Navigates to the lightVersionSixScreen when the action is triggered.
  onTapImgImage2(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.lightVersionSixScreen);
  }

  /// Navigates to the lightVersionSixScreen when the action is triggered.
  onTapImgImage3(BuildContext context) {
    NavigatorService.pushNamed(AppRoutes.lightVersionSixScreen);
  }
}
