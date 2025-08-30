import 'package:get/get.dart';

class SplashViewMode extends GetxController{
  void loadView() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.to( () => const MainTabView());
  }
}