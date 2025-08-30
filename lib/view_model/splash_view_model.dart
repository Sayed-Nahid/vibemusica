import 'package:get/get.dart';
import 'package:vibemusica/view/main_tabview/main_tabview.dart';

class SplashViewModel extends GetxController{
  void loadView() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.to( () => const MainTabView());
  }
}