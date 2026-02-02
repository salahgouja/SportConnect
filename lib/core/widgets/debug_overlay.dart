import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:sport_connect/core/services/talker_service.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
enum _DebugScreen { none, logs, theme }

/// Debug overlay that provides quick access to developer tools
/// Shows a floating action button in debug mode for:
/// - Talker logs screen
/// - Theme playground (flex_color_scheme)
/// - Device info
class DebugOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const DebugOverlay({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  _DebugScreen _currentScreen = _DebugScreen.none;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _openTalkerScreen() {
    setState(() {
      _isExpanded = false;
      _animationController.reverse();
      _currentScreen = _DebugScreen.logs;
    });
  }

  void _openThemePlayground() {
    setState(() {
      _isExpanded = false;
      _animationController.reverse();
      _currentScreen = _DebugScreen.theme;
    });
  }

  void _closeDebugScreen() {
    setState(() {
      _currentScreen = _DebugScreen.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        // Only show FAB when no debug screen is open
        if (_currentScreen == _DebugScreen.none)
          Positioned(
            right: 16.w,
            bottom: 100.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Expandable menu items
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Talker Logs Button
                        _buildMenuButton(
                          icon: Icons.bug_report_rounded,
                          label: 'Logs',
                          color: AppColors.error,
                          onTap: _openTalkerScreen,
                          delay: 0.0,
                        ),
                        SizedBox(height: 8.h),
                        // Theme Playground Button
                        _buildMenuButton(
                          icon: Icons.palette_rounded,
                          label: 'Theme',
                          color: AppColors.secondary,
                          onTap: _openThemePlayground,
                          delay: 0.1,
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: 8.h),
                // Main FAB
                _buildMainFab(),
              ],
            ),
          ),
        // Full-screen debug screens (shown on top of everything)
        if (_currentScreen != _DebugScreen.none)
          Positioned.fill(child: _buildDebugScreen()),
      ],
    );
  }

  Widget _buildDebugScreen() {
    switch (_currentScreen) {
      case _DebugScreen.logs:
        return _FullScreenDebugView(
          title: 'Debug Logs',
          onClose: _closeDebugScreen,
          child: TalkerScreen(talker: TalkerService.instance),
        );
      case _DebugScreen.theme:
        return _FullScreenDebugView(
          title: 'Theme Playground',
          onClose: _closeDebugScreen,
          child: ThemePlaygroundScreen(onClose: _closeDebugScreen),
        );
      case _DebugScreen.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = Curves.easeOutBack.transform(
          (_animation.value - delay).clamp(0.0, 1.0 - delay) / (1.0 - delay),
        );
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: _animation.value, child: child),
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainFab() {
    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _isExpanded
                ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                : [AppColors.primary, AppColors.primaryDark],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: (_isExpanded ? AppColors.error : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedRotation(
          turns: _isExpanded ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            _isExpanded ? Icons.close_rounded : Icons.developer_mode_rounded,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}

/// Full screen view wrapper for debug screens - uses state-based navigation
/// instead of Navigator to avoid context issues with MaterialApp.router
/// Wraps content in a MaterialApp to provide Overlay and other required ancestors
class _FullScreenDebugView extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  final Widget child;

  const _FullScreenDebugView({
    required this.title,
    required this.onClose,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Get the current theme to pass to the nested MaterialApp
    final currentTheme = Theme.of(context);

    // Wrap in MaterialApp to provide Overlay, Navigator, and other required ancestors
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: currentTheme,
      home: Material(
        color: currentTheme.scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              // Custom app bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color:
                      currentTheme.appBarTheme.backgroundColor ??
                      AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: onClose,
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme Playground Screen for testing flex_color_scheme themes
class ThemePlaygroundScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const ThemePlaygroundScreen({super.key, this.onClose});

  @override
  State<ThemePlaygroundScreen> createState() => _ThemePlaygroundScreenState();
}

class _ThemePlaygroundScreenState extends State<ThemePlaygroundScreen> {
  int _selectedColorIndex = 0;
  bool _isDarkMode = false;
  double _surfaceBlend = 0.0;
  bool _useMaterial3 = true;

  // Popular flex_color_scheme color options
  static const List<Map<String, dynamic>> _colorSchemes = [
    {
      'name': 'Default Blue',
      'primary': Color(0xFF2196F3),
      'secondary': Color(0xFF03DAC6),
    },
    {
      'name': 'Deep Purple',
      'primary': Color(0xFF673AB7),
      'secondary': Color(0xFFFF4081),
    },
    {
      'name': 'Teal',
      'primary': Color(0xFF009688),
      'secondary': Color(0xFFFFC107),
    },
    {
      'name': 'Amber',
      'primary': Color(0xFFFFC107),
      'secondary': Color(0xFF795548),
    },
    {
      'name': 'Red Orange',
      'primary': Color(0xFFFF5722),
      'secondary': Color(0xFF607D8B),
    },
    {
      'name': 'Indigo',
      'primary': Color(0xFF3F51B5),
      'secondary': Color(0xFFE91E63),
    },
    {
      'name': 'Green',
      'primary': Color(0xFF4CAF50),
      'secondary': Color(0xFF8BC34A),
    },
    {
      'name': 'Pink',
      'primary': Color(0xFFE91E63),
      'secondary': Color(0xFF9C27B0),
    },
    {
      'name': 'Cyan',
      'primary': Color(0xFF00BCD4),
      'secondary': Color(0xFF00ACC1),
    },
    {
      'name': 'Brown',
      'primary': Color(0xFF795548),
      'secondary': Color(0xFFBCAAA4),
    },
    {
      'name': 'Grey',
      'primary': Color(0xFF9E9E9E),
      'secondary': Color(0xFF757575),
    },
    {
      'name': 'Blue Grey',
      'primary': Color(0xFF607D8B),
      'secondary': Color(0xFF455A64),
    },
    {
      'name': 'Sport Connect',
      'primary': AppColors.primary,
      'secondary': AppColors.secondary,
    },
  ];

  Color get _currentPrimary =>
      _colorSchemes[_selectedColorIndex]['primary'] as Color;
  Color get _currentSecondary =>
      _colorSchemes[_selectedColorIndex]['secondary'] as Color;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Theme Playground'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color scheme selector
              _buildSection(
                title: 'Color Scheme',
                child: SizedBox(
                  height: 80.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _colorSchemes.length,
                    itemBuilder: (context, index) {
                      final scheme = _colorSchemes[index];
                      final isSelected = index == _selectedColorIndex;
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedColorIndex = index),
                        child: Container(
                          width: 60.w,
                          margin: EdgeInsets.only(right: 12.w),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: isSelected
                                ? Border.all(color: _currentPrimary, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: _currentPrimary.withValues(
                                        alpha: 0.4,
                                      ),
                                      blurRadius: 8,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: scheme['primary'] as Color,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                        isSelected ? 9.r : 12.r,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: scheme['secondary'] as Color,
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(
                                        isSelected ? 9.r : 12.r,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Current scheme name
              Center(
                child: Chip(
                  label: Text(
                    _colorSchemes[_selectedColorIndex]['name'] as String,
                  ),
                  backgroundColor: _currentPrimary.withValues(alpha: 0.2),
                ),
              ),
              SizedBox(height: 16.h),

              // Surface blend slider
              _buildSection(
                title: 'Surface Blend: ${(_surfaceBlend * 100).toInt()}%',
                child: Slider(
                  value: _surfaceBlend,
                  onChanged: (value) => setState(() => _surfaceBlend = value),
                  activeColor: _currentPrimary,
                ),
              ),

              // Material 3 toggle
              _buildSection(
                title: 'Settings',
                child: SwitchListTile(
                  title: const Text('Use Material 3'),
                  value: _useMaterial3,
                  onChanged: (value) => setState(() => _useMaterial3 = value),
                  activeColor: _currentPrimary,
                ),
              ),

              // Preview Components
              _buildSection(
                title: 'Component Preview',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Buttons
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Elevated'),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: const Text('Filled'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Outlined'),
                        ),
                        TextButton(onPressed: () {}, child: const Text('Text')),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Text fields
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Text Field',
                        hintText: 'Enter text...',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Cards
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _currentPrimary,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        title: const Text('Card Title'),
                        subtitle: const Text('Card subtitle with description'),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {},
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Chips
                    Wrap(
                      spacing: 8.w,
                      children: [
                        Chip(label: const Text('Chip 1')),
                        FilterChip(
                          label: const Text('Filter'),
                          selected: true,
                          onSelected: (_) {},
                        ),
                        ActionChip(
                          label: const Text('Action'),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Progress indicators
                    Row(
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: 0.7,
                            backgroundColor: _currentPrimary.withValues(
                              alpha: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Slider
                    Slider(value: 0.5, onChanged: (_) {}),
                    SizedBox(height: 16.h),

                    // Switch and Checkbox
                    Row(
                      children: [
                        Switch(value: true, onChanged: (_) {}),
                        SizedBox(width: 16.w),
                        Checkbox(value: true, onChanged: (_) {}),
                        SizedBox(width: 16.w),
                        Radio(value: true, groupValue: true, onChanged: (_) {}),
                      ],
                    ),
                  ],
                ),
              ),

              // Color palette display
              _buildSection(
                title: 'Color Palette',
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildColorChip(
                      'Primary',
                      _buildTheme().colorScheme.primary,
                    ),
                    _buildColorChip(
                      'Secondary',
                      _buildTheme().colorScheme.secondary,
                    ),
                    _buildColorChip(
                      'Surface',
                      _buildTheme().colorScheme.surface,
                    ),
                    _buildColorChip(
                      'Background',
                      _buildTheme().scaffoldBackgroundColor,
                    ),
                    _buildColorChip('Error', _buildTheme().colorScheme.error),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              // Copy theme code button
              Center(
                child: ElevatedButton.icon(
                  onPressed: _copyThemeCode,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Theme Code'),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _applyTheme,
          icon: const Icon(Icons.check),
          label: const Text('Apply Theme'),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 12.h),
        child,
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  ThemeData _buildTheme() {
    final brightness = _isDarkMode ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: _useMaterial3,
      brightness: brightness,
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: _currentPrimary,
            secondary: _currentSecondary,
            brightness: brightness,
          ).copyWith(
            surface: Color.lerp(
              _isDarkMode ? Colors.grey[900] : Colors.white,
              _currentPrimary,
              _surfaceBlend * 0.1,
            ),
          ),
    );
  }

  void _copyThemeCode() {
    final code =
        '''
// Generated theme code
// Primary: ${_currentPrimary.value.toRadixString(16).padLeft(8, '0').toUpperCase()}
// Secondary: ${_currentSecondary.value.toRadixString(16).padLeft(8, '0').toUpperCase()}
// Mode: ${_isDarkMode ? 'Dark' : 'Light'}
// Material 3: $_useMaterial3
// Surface Blend: ${(_surfaceBlend * 100).toInt()}%

ThemeData(
  useMaterial3: $_useMaterial3,
  brightness: ${_isDarkMode ? 'Brightness.dark' : 'Brightness.light'},
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0x${_currentPrimary.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),
    secondary: Color(0x${_currentSecondary.value.toRadixString(16).padLeft(8, '0').toUpperCase()}),
    brightness: ${_isDarkMode ? 'Brightness.dark' : 'Brightness.light'},
  ),
)
''';

    TalkerService.info('Theme code copied:\n$code');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Theme code copied to logs!')));
  }

  void _applyTheme() {
    TalkerService.info(
      'Theme applied: ${_colorSchemes[_selectedColorIndex]['name']}',
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Theme "${_colorSchemes[_selectedColorIndex]['name']}" applied!',
        ),
        action: SnackBarAction(label: 'OK', onPressed: () {}),
      ),
    );
  }
}
