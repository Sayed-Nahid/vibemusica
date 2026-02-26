import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:vibemusica/common_widget/gradient_mesh_background.dart';

import '../../common/color_extension.dart';
import '../../view_model/splash_view_model.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const GradientMeshBackground(),
          Column(
            children: [
              // Glass AppBar
              SafeArea(
                bottom: false,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      height: kToolbarHeight,
                      color: TColor.glassFill,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.find<SplashViewModel>().openDrawer();
                            },
                            icon: Image.asset(
                              "assets/img/menu.png",
                              width: 25,
                              height: 25,
                              fit: BoxFit.contain,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "Settings",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // balance leading icon
                        ],
                      ),
                    ),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(
                      begin: -0.05,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOut),
              // Settings list
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  children: [
                    _settingsItem(
                      title: "Display",
                      icon: "assets/img/s_display.png",
                      onTap: () {},
                      index: 0,
                    ),
                    _settingsItem(
                      title: "Audio",
                      icon: "assets/img/s_audio.png",
                      onTap: () {},
                      index: 1,
                    ),
                    _settingsItem(
                      title: "Headset",
                      icon: "assets/img/s_headset.png",
                      onTap: () {},
                      index: 2,
                    ),
                    _settingsItem(
                      title: "Lock Screen",
                      icon: "assets/img/s_lock_screen.png",
                      onTap: () {},
                      index: 3,
                    ),
                    _settingsItem(
                      title: "Advanced",
                      icon: "assets/img/s_menu.png",
                      onTap: () {},
                      index: 4,
                    ),
                    _settingsItem(
                      title: "Other",
                      icon: "assets/img/s_other.png",
                      onTap: () {},
                      index: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _settingsItem({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: TColor.glassDecoration(borderRadius: 14),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            leading: Image.asset(
              icon,
              width: 25,
              height: 25,
              fit: BoxFit.contain,
            ),
            title: Text(
              title,
              style: TextStyle(
                color: TColor.primaryText80,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: TColor.primaryText28,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: (60 * index).ms)
        .slideX(
          begin: 0.04,
          end: 0,
          duration: 300.ms,
          delay: (60 * index).ms,
          curve: Curves.easeOut,
        );
  }
}
