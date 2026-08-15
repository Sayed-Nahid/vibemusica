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
  bool _isSearching = false;
  final TextEditingController _txtSearch = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<Map<String, String>> _allSettings = [
    {
      "title": "Display",
      "icon": "assets/img/s_display.png",
    },
    {
      "title": "Audio",
      "icon": "assets/img/s_audio.png",
    },
    {
      "title": "Headset",
      "icon": "assets/img/s_headset.png",
    },
    {
      "title": "Lock Screen",
      "icon": "assets/img/s_lock_screen.png",
    },
    {
      "title": "Advanced",
      "icon": "assets/img/s_menu.png",
    },
    {
      "title": "Other",
      "icon": "assets/img/s_other.png",
    },
  ];

  @override
  void dispose() {
    _txtSearch.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
                          _isSearching
                              ? IconButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _isSearching = false;
                                      _txtSearch.clear();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: TColor.primaryText,
                                    size: 20,
                                  ),
                                )
                              : IconButton(
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
                            child: _isSearching
                                ? _buildActiveSearchBar()
                                : Center(
                                    child: _buildTitle(),
                                  ),
                          ),
                          if (!_isSearching)
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isSearching = true;
                                });
                                _searchFocusNode.requestFocus();
                              },
                              icon: Icon(
                                Icons.search_rounded,
                                color: TColor.primaryText80,
                                size: 24,
                              ),
                            ),
                          if (_isSearching && _txtSearch.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _txtSearch.clear();
                                });
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: TColor.primaryText60,
                                size: 20,
                              ),
                            ),
                          const SizedBox(width: 4),
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
                child: Builder(
                  builder: (context) {
                    final query = _txtSearch.text.trim().toLowerCase();
                    final filteredList = query.isEmpty
                        ? _allSettings
                        : _allSettings
                            .where((item) =>
                                item["title"]!.toLowerCase().contains(query))
                            .toList();

                    if (filteredList.isEmpty) {
                      return Center(
                        child: Text(
                          "No settings found",
                          style: TextStyle(
                            color: TColor.primaryText60,
                            fontSize: 15,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return _settingsItem(
                          title: item["title"]!,
                          icon: item["icon"]!,
                          onTap: () {},
                          index: index,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Centered title "Settings"
  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: TColor.primaryG,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds),
      child: Text(
        "Settings",
        style: TextStyle(
          fontFamily: "Circular Std",
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: TColor.primaryText,
          letterSpacing: 0.8,
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  /// Frosted-glass search bar when search is active
  Widget _buildActiveSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 38,
          decoration: TColor.glassDecoration(borderRadius: 20),
          child: TextField(
            controller: _txtSearch,
            focusNode: _searchFocusNode,
            autofocus: true,
            onChanged: (val) {
              setState(() {});
            },
            style: TextStyle(
              color: TColor.primaryText,
              fontSize: 13,
            ),
            decoration: InputDecoration(
              isDense: true,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 16,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.only(left: 12, right: 8),
                alignment: Alignment.centerLeft,
                width: 20,
                child: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: TColor.focus,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 20,
              ),
              hintText: "Search Settings...",
              hintStyle: TextStyle(
                color: TColor.primaryText28,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.05, end: 0, duration: 250.ms, curve: Curves.easeOut);
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
