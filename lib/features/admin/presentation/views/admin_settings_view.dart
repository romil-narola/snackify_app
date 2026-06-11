import '../../../../core/common_imports.dart';
import '../../../../core/mock/mock_database.dart';

class AdminSettingsView extends StatefulWidget {
  const AdminSettingsView({super.key});

  @override
  State<AdminSettingsView> createState() => _AdminSettingsViewState();
}

class _AdminSettingsViewState extends State<AdminSettingsView> {
  late bool _isCombineOption;
  late TimeOfDay _startTime;
  late TimeOfDay _cutoffTime;

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  void _loadCurrentSettings() {
    final db = MockDatabase();
    _isCombineOption = db.isCombineOption;

    _startTime = _parseTimeString(
      db.orderStartTime,
      const TimeOfDay(hour: 9, minute: 0),
    );
    _cutoffTime = _parseTimeString(
      db.orderCutoffTime,
      const TimeOfDay(hour: 17, minute: 0),
    );
  }

  TimeOfDay _parseTimeString(String timeStr, TimeOfDay fallback) {
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (_) {}
    return fallback;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  String _formatTimeDisplay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? "AM" : "PM";
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = isStart ? _startTime : _cutoffTime;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: context.theme.copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primary,
              primary: AppTheme.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _cutoffTime = picked;
        }
      });
    }
  }

  void _saveSettings() {
    final startStr = _formatTimeOfDay(_startTime);
    final cutoffStr = _formatTimeOfDay(_cutoffTime);

    context.read<AdminBloc>().add(
      AdminUpdateSettings(
        isCombineOption: _isCombineOption,
        startTime: startStr,
        cutoffTime: cutoffStr,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Ordering configurations saved successfully!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          top: 16,
          left: 20,
          right: 20,
          bottom: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Settings Header
            Text(
              'Pantry Settings ⚙️',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Set order confirmation times & scheduling rules',
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),

            // Mode Selection Section
            Text(
              'Ordering Mode',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildModeTile(
                    title: 'Single Ordering Mode',
                    description:
                        'Employees request individually. Orders processed instantly upon arrival.',
                    icon: Icons.electric_bolt_rounded,
                    color: AppTheme.success,
                    isSelected: !_isCombineOption,
                    onTap: () => setState(() => _isCombineOption = false),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildModeTile(
                    title: 'Combined Ordering Mode',
                    description:
                        'Aggregate orders from all employees. Combined list processed at the cutoff time.',
                    icon: Icons.group_work_rounded,
                    color: AppTheme.primary,
                    isSelected: _isCombineOption,
                    onTap: () => setState(() => _isCombineOption = true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Time Windows Section
            Text(
              'Time Schedule Configuration',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTimeSettingRow(
                    label: 'Pantry Opens (Start Time)',
                    timeDisplay: _formatTimeDisplay(_startTime),
                    icon: Icons.wb_sunny_outlined,
                    onTap: () => _selectTime(context, true),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildTimeSettingRow(
                    label: 'Pantry Closes (Cutoff Time)',
                    timeDisplay: _formatTimeDisplay(_cutoffTime),
                    icon: Icons.nightlight_round_outlined,
                    onTap: () => _selectTime(context, false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),

            // Action Button
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeTile({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : (isDark ? Colors.white12 : Colors.grey.shade200),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? color
                    : (isDark ? Colors.white70 : Colors.black54),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.5,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettingRow({
    required String label,
    required String timeDisplay,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = context.isDarkMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              timeDisplay,
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
