import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart' hide isSameDay;
import 'data/task.dart';
import 'data/task_database.dart';
import 'smart_input.dart';

const _ink = Color(0xff14251f);
const _green = Color(0xff14785d);
const _mint = Color(0xffe3f2eb);
const Map<String, Map<String, String>> _words = {
  'en': {
    'home': 'Home',
    'tasks': 'Tasks',
    'calendar': 'Calendar',
    'focus': 'Focus',
    'insights': 'Insights',
    'settings': 'Settings',
    'version': 'Version',
    'rights': 'All rights reserved.',
    'font': 'Font family',
    'fontSize': 'Text size',
    'small': 'Small',
    'normal': 'Medium',
    'large': 'Large',
    'cairo': 'Cairo',
    'amiri': 'Amiri',
    'lists': 'Lists',
    'newList': 'New list',
    'addItem': 'Add item',
    'listItemHint': 'Add a new item',
    'shoppingList': 'Shopping',
    'groceriesList': 'Groceries',
    'travelList': 'Travel',
    'umrahList': 'Umrah',
    'hajjList': 'Hajj',
    'ramadanList': 'Ramadan',
    'movingList': 'Moving',
    'booksList': 'Books to read',
    'backupRestore': 'Backup and restore',
    'backup': 'Create backup',
    'backupDesc': 'Save tasks, focus history, and lists to a file.',
    'restore': 'Restore backup',
    'restoreDesc': 'Replace app data from a Smart-ToDo backup file.',
    'backupSaved': 'Backup file created.',
    'restoreDone': 'Backup restored successfully.',
    'restoreConfirm': 'Restore this backup?',
    'restoreWarning':
        'This replaces all current tasks, focus history, and lists.',
    'backupInvalid': 'The selected backup is invalid or unsupported.',
    'customList': 'Custom list',
    'noLists': 'Create a list for shopping, travel, or anything you need.',
    'reminders': 'Reminders',
    'remindersDisabled': 'Local reminders are not enabled in this build.',
    'linkTask': 'Link to a task',
    'noneOption': 'None',
    'today': 'Today',
    'upcoming': 'Upcoming',
    'overdue': 'Overdue',
    'completed': 'Completed',
    'all': 'All tasks',
    'hello': 'Good day',
    'progress': 'Daily progress',
    'todayTasks': 'Today\'s tasks',
    'quick': 'Quick capture',
    'add': 'Add task',
    'save': 'Save task',
    'title': 'What needs to get done?',
    'description': 'Notes or details',
    'priority': 'Priority',
    'low': 'Low',
    'medium': 'Medium',
    'high': 'High',
    'date': 'Due date',
    'time': 'Time',
    'duration': 'Duration (minutes)',
    'category': 'Category',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'empty': 'A little space to breathe. You\'re all caught up.',
    'work': 'Work',
    'personal': 'Personal',
    'study': 'Study',
    'shopping': 'Shopping',
    'search': 'Search tasks',
    'total': 'Total tasks',
    'done': 'Completed',
    'pending': 'Pending',
    'completionRate': 'Completion rate',
    'focusTime': 'Focus time',
    'week': 'This week',
    'start': 'Start focus',
    'pause': 'Pause',
    'resume': 'Resume',
    'reset': 'Reset',
    'workSession': 'Focus session',
    'shortBreak': 'Short break',
    'longBreak': 'Long break',
    'language': 'Language',
    'theme': 'Appearance',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'noDate': 'No date',
    'smartHint': 'Try: Call Sam tomorrow at 5 PM for 30 minutes',
    'minutes': 'min',
    'newTask': 'New task',
    'calendarEmpty': 'No tasks scheduled',
    'recurrence': 'Repeat',
    'none': 'Never',
    'daily': 'Daily',
    'weekly': 'Weekly',
    'subtasks': 'Subtasks',
    'project': 'Project',
  },
  'ar': {
    'home': 'الرئيسية',
    'tasks': 'المهام',
    'calendar': 'التقويم',
    'focus': 'التركيز',
    'insights': 'الإحصاءات',
    'settings': 'الإعدادات',
    'version': 'الإصدار',
    'rights': 'جميع الحقوق محفوظة.',
    'font': 'نوع الخط',
    'fontSize': 'حجم الخط',
    'small': 'صغير',
    'normal': 'متوسط',
    'large': 'كبير',
    'cairo': 'كايرو',
    'amiri': 'أميري',
    'lists': 'القوائم',
    'newList': 'قائمة جديدة',
    'addItem': 'إضافة عنصر',
    'listItemHint': 'أضف عنصراً جديداً',
    'shoppingList': 'المشتريات',
    'groceriesList': 'مشتريات البقالة',
    'travelList': 'السفر',
    'umrahList': 'العمرة',
    'hajjList': 'الحج',
    'ramadanList': 'رمضان',
    'movingList': 'الانتقال إلى منزل جديد',
    'booksList': 'كتب للقراءة',
    'backupRestore': 'النسخ الاحتياطي والاستعادة',
    'backup': 'إنشاء نسخة احتياطية',
    'backupDesc': 'احفظ المهام وسجل التركيز والقوائم في ملف.',
    'restore': 'استعادة نسخة احتياطية',
    'restoreDesc': 'استبدل بيانات التطبيق من ملف نسخة Smart-ToDo.',
    'backupSaved': 'تم إنشاء ملف النسخة الاحتياطية.',
    'restoreDone': 'تمت استعادة النسخة الاحتياطية بنجاح.',
    'restoreConfirm': 'هل تريد استعادة هذه النسخة؟',
    'restoreWarning':
        'سيؤدي ذلك إلى استبدال كل المهام وسجل التركيز والقوائم الحالية.',
    'backupInvalid': 'ملف النسخة الاحتياطية غير صالح أو غير مدعوم.',
    'customList': 'قائمة مخصصة',
    'noLists': 'أنشئ قائمة للتسوق أو السفر أو لأي شيء تحتاجه.',
    'reminders': 'التذكيرات',
    'remindersDisabled': 'التذكيرات المحلية غير مفعلة في هذا الإصدار.',
    'linkTask': 'اربط الجلسة بمهمة',
    'noneOption': 'بدون',
    'today': 'اليوم',
    'upcoming': 'القادمة',
    'overdue': 'المتأخرة',
    'completed': 'المكتملة',
    'all': 'كل المهام',
    'hello': 'نهارك سعيد',
    'progress': 'إنجاز اليوم',
    'todayTasks': 'مهام اليوم',
    'quick': 'إضافة سريعة',
    'add': 'إضافة مهمة',
    'save': 'حفظ المهمة',
    'title': 'ما الذي تريد إنجازه؟',
    'description': 'ملاحظات أو تفاصيل',
    'priority': 'الأولوية',
    'low': 'منخفضة',
    'medium': 'متوسطة',
    'high': 'عالية',
    'date': 'تاريخ الاستحقاق',
    'time': 'الوقت',
    'duration': 'المدة (بالدقائق)',
    'category': 'التصنيف',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'empty': 'أحسنت! لا توجد مهام متبقية.',
    'work': 'العمل',
    'personal': 'شخصي',
    'study': 'دراسة',
    'shopping': 'تسوق',
    'search': 'ابحث في المهام',
    'total': 'إجمالي المهام',
    'done': 'مكتملة',
    'pending': 'قيد الانتظار',
    'completionRate': 'نسبة الإنجاز',
    'focusTime': 'وقت التركيز',
    'week': 'هذا الأسبوع',
    'start': 'ابدأ التركيز',
    'pause': 'إيقاف مؤقت',
    'resume': 'متابعة',
    'reset': 'إعادة',
    'workSession': 'جلسة تركيز',
    'shortBreak': 'استراحة قصيرة',
    'longBreak': 'استراحة طويلة',
    'language': 'اللغة',
    'theme': 'المظهر',
    'light': 'فاتح',
    'dark': 'داكن',
    'system': 'تلقائي',
    'noDate': 'بدون تاريخ',
    'minutes': 'دقيقة',
    'newTask': 'مهمة جديدة',
    'calendarEmpty': 'لا توجد مهام مجدولة',
    'recurrence': 'التكرار',
    'none': 'أبداً',
    'daily': 'يومياً',
    'weekly': 'أسبوعياً',
    'subtasks': 'مهام فرعية',
    'project': 'المشروع',
  },
};

class SmartTodoApp extends StatefulWidget {
  const SmartTodoApp({super.key});
  @override
  State<SmartTodoApp> createState() => _SmartTodoAppState();
}

class _SmartTodoAppState extends State<SmartTodoApp> {
  String _lang = 'en', _theme = 'light';
  String _fontFamily = 'Cairo', _fontSize = 'normal';
  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (mounted) {
        setState(() {
          _lang = p.getString('language') ?? 'en';
          _theme = p.getString('theme') ?? 'light';
          _fontFamily = p.getString('font_family') ?? 'Cairo';
          _fontSize = p.getString('font_size') ?? 'normal';
        });
      }
    });
  }

  Future<void> setLanguage(String v) async {
    setState(() => _lang = v);
    (await SharedPreferences.getInstance()).setString('language', v);
  }

  Future<void> setTheme(String v) async {
    setState(() => _theme = v);
    (await SharedPreferences.getInstance()).setString('theme', v);
  }

  Future<void> setFontFamily(String v) async {
    setState(() => _fontFamily = v);
    (await SharedPreferences.getInstance()).setString('font_family', v);
  }

  Future<void> setFontSize(String v) async {
    setState(() => _fontSize = v);
    (await SharedPreferences.getInstance()).setString('font_size', v);
  }

  double get _fontScale => switch (_fontSize) {
    'small' => .9,
    'large' => 1.2,
    _ => 1,
  };

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart-ToDo',
    debugShowCheckedModeBanner: false,
    locale: Locale(_lang),
    supportedLocales: const [Locale('en'), Locale('ar')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) {
      final media = MediaQuery.maybeOf(context);
      final platformScale = media?.textScaler.scale(16) ?? 16;
      return MediaQuery(
        data: (media ?? const MediaQueryData()).copyWith(
          textScaler: TextScaler.linear(platformScale / 16 * _fontScale),
        ),
        child: child ?? const SizedBox.shrink(),
      );
    },
    themeMode: _theme == 'system'
        ? ThemeMode.system
        : _theme == 'dark'
        ? ThemeMode.dark
        : ThemeMode.light,
    theme: _buildTheme(Brightness.light),
    darkTheme: _buildTheme(Brightness.dark),
    home: TodoShell(
      lang: _lang,
      onLanguage: setLanguage,
      themeMode: _theme,
      onTheme: setTheme,
      fontFamily: _fontFamily,
      fontSize: _fontSize,
      onFontFamily: setFontFamily,
      onFontSize: setFontSize,
    ),
  );
  ThemeData _buildTheme(Brightness b) {
    final dark = b == Brightness.dark;
    final colors = ColorScheme.fromSeed(
      seedColor: _green,
      brightness: b,
      primary: _green,
      surface: dark ? const Color(0xff14201c) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colors,
      scaffoldBackgroundColor: dark
          ? const Color(0xff0e1714)
          : const Color(0xfff5f7f4),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _ink,
      ),
      cardTheme: CardThemeData(
        color: dark ? const Color(0xff192722) : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      fontFamily: _fontFamily,
      textTheme: ThemeData(
        brightness: b,
        useMaterial3: true,
      ).textTheme.apply(fontFamily: _fontFamily),
    );
  }
}

class TodoShell extends StatefulWidget {
  const TodoShell({
    super.key,
    required this.lang,
    required this.onLanguage,
    required this.themeMode,
    required this.onTheme,
    required this.fontFamily,
    required this.fontSize,
    required this.onFontFamily,
    required this.onFontSize,
  });
  final String lang, themeMode, fontFamily, fontSize;
  final ValueChanged<String> onLanguage, onTheme, onFontFamily, onFontSize;
  @override
  State<TodoShell> createState() => _TodoShellState();
}

class _TodoShellState extends State<TodoShell> {
  final db = TaskDatabase.instance;
  String appVersion = '1.0.1+2';
  List<TodoTask> tasks = [];
  int tab = 0;
  bool loading = true;
  String filter = 'all';
  String search = '';
  final quickController = TextEditingController();
  DateTime selected = DateTime.now();
  String t(String key) => _words[widget.lang]?[key] ?? key;
  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => appVersion = '${info.version}+${info.buildNumber}');
      }
    });
    reload();
  }

  Future<void> reload() async {
    try {
      final values = await Future.wait([db.allTasks(), db.focusMinutes()]);
      final v = values.first as List<TodoTask>;
      if (mounted) {
        setState(() {
          tasks = v;
          _focusTotal = values[1] as int;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> save(TodoTask value) async {
    await db.save(value);
    await reload();
  }

  Future<void> toggle(TodoTask task) async {
    final completing = !task.completed;
    await save(
      task.copyWith(
        completed: completing,
        completedAt: completing ? DateTime.now() : null,
      ),
    );
    if (completing) {
      final next = nextOccurrence(task);
      if (next != null) await save(next);
    }
  }

  Future<void> delete(TodoTask task) async {
    if (task.id == null) return;
    await db.delete(task.id!);
    await reload();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(task.title),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => save(task.copyWith(id: null)),
        ),
      ),
    );
  }

  Future<void> _exportBackup() async {
    try {
      final data = await db.exportBackup();
      final stamp = DateFormat('yyyyMMdd-HHmm').format(DateTime.now());
      final result = await FilePicker.saveFile(
        dialogTitle: t('backup'),
        fileName: 'smart-todo-backup-$stamp.json',
        bytes: Uint8List.fromList(utf8.encode(jsonEncode(data))),
        mimeType: 'application/json',
      );
      if (result != null && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t('backupSaved'))));
      }
    } catch (_) {
      if (mounted) _showBackupError();
    }
  }

  Future<void> _importBackup() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (file == null) return;
      final decoded = jsonDecode(utf8.decode(await file.readAsBytes()));
      if (!mounted) return;
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Invalid backup root.');
      }
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(t('restoreConfirm')),
          content: Text(t('restoreWarning')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(t('restore')),
            ),
          ],
        ),
      );
      if (accepted != true) return;
      await db.restoreBackup(decoded);
      await reload();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t('restoreDone'))));
      }
    } catch (_) {
      if (mounted) _showBackupError();
    }
  }

  void _showBackupError() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t('backupInvalid'))));
  }

  Future<void> editor([TodoTask? task]) async {
    final result = await showModalBottomSheet<TodoTask>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskEditor(task: task, lang: widget.lang),
    );
    if (result != null) await save(result);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _dashboard(),
      _tasksView(),
      _listsView(),
      _calendarView(),
      _focusView(),
      _insightsView(),
      _settingsView(),
    ];
    final wide = MediaQuery.sizeOf(context).width >= 720;
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            if (wide)
              NavigationRail(
                selectedIndex: tab,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (i) => setState(() => tab = i),
                destinations: [
                  _rail(Icons.grid_view_rounded, 'home'),
                  _rail(Icons.checklist_rounded, 'tasks'),
                  _rail(Icons.shopping_bag_outlined, 'lists'),
                  _rail(Icons.calendar_month_rounded, 'calendar'),
                  _rail(Icons.timer_outlined, 'focus'),
                  _rail(Icons.insights_rounded, 'insights'),
                  _rail(Icons.tune_rounded, 'settings'),
                ],
              ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : IndexedStack(index: tab, children: tabs),
            ),
          ],
        ),
      ),
      floatingActionButton: tab < 2
          ? FloatingActionButton.extended(
              onPressed: () => editor(),
              icon: const Icon(Icons.add_rounded),
              label: Text(t('add')),
              backgroundColor: _green,
              foregroundColor: Colors.white,
            )
          : null,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (i) => setState(() => tab = i),
              height: 68,
              destinations: [
                _nav(Icons.grid_view_rounded, 'home'),
                _nav(Icons.checklist_rounded, 'tasks'),
                _nav(Icons.shopping_bag_outlined, 'lists'),
                _nav(Icons.calendar_month_rounded, 'calendar'),
                _nav(Icons.timer_outlined, 'focus'),
                _nav(Icons.insights_rounded, 'insights'),
                _nav(Icons.tune_rounded, 'settings'),
              ],
            ),
    );
  }

  NavigationDestination _nav(IconData icon, String key) =>
      NavigationDestination(icon: Icon(icon), label: t(key));
  NavigationRailDestination _rail(IconData icon, String key) =>
      NavigationRailDestination(icon: Icon(icon), label: Text(t(key)));
  List<TodoTask> get todayTasks => tasks
      .where(
        (x) =>
            !x.completed &&
            x.dueAt != null &&
            isSameDay(x.dueAt!, DateTime.now()),
      )
      .toList();
  List<TodoTask> get visibleTasks {
    var v = tasks;
    if (search.isNotEmpty) {
      v = v
          .where(
            (x) => ('${x.title} ${x.description} ${x.category}')
                .toLowerCase()
                .contains(search.toLowerCase()),
          )
          .toList();
    }
    if (filter == 'today') {
      v = v
          .where((x) => x.dueAt != null && isSameDay(x.dueAt!, DateTime.now()))
          .toList();
    }
    if (filter == 'upcoming') {
      v = v
          .where(
            (x) =>
                x.dueAt != null &&
                x.dueAt!.isAfter(DateTime.now()) &&
                !isSameDay(x.dueAt!, DateTime.now()),
          )
          .toList();
    }
    if (filter == 'overdue') v = v.where(isOverdue).toList();
    if (filter == 'completed') v = v.where((x) => x.completed).toList();
    return v;
  }

  Widget _dashboard() => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 8),
        sliver: SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xff145e4b), Color(0xff23856a)],
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/branding/smart_todo_icon.png',
                        width: 52,
                        height: 52,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${t('hello')},',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            widget.lang == 'ar'
                                ? 'مبدع اليوم'
                                : 'Make today count.',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat.yMMMMEEEEd(
                              widget.lang,
                            ).format(DateTime.now()),
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.wb_sunny_rounded,
                      color: Color(0xffffd27a),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _progressCard(),
              const SizedBox(height: 16),
              _quickCapture(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _metric(
                      t('today'),
                      todayTasks.length,
                      Icons.today_rounded,
                      const Color(0xff3978d4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      t('overdue'),
                      tasks.where(isOverdue).length,
                      Icons.warning_amber_rounded,
                      const Color(0xffdb654e),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _metric(
                      t('completed'),
                      tasks.where((x) => x.completed).length,
                      Icons.check_circle_outline_rounded,
                      _green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t('todayTasks'),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => tab = 1),
                    child: Text(t('all')),
                  ),
                ],
              ),
              if (todayTasks.isEmpty) _empty(),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
        sliver: SliverList.builder(
          itemCount: todayTasks.length,
          itemBuilder: (c, i) => _taskCard(todayTasks[i]),
        ),
      ),
    ],
  );
  Widget _progressCard() {
    final total = todayTasks.length,
        done = todayTasks.where((x) => x.completed).length;
    final ratio = total == 0 ? 0.0 : done / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff145e4b), Color(0xff269473)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('progress'),
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '$done / $total',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: ratio,
                    minHeight: 7,
                    backgroundColor: Colors.white24,
                    color: const Color(0xffb6f2cf),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 6,
                  backgroundColor: Colors.white24,
                  color: Colors.white,
                ),
                Text(
                  '${(ratio * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCapture() => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: TextField(
        controller: quickController,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _captureQuickTask(),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: widget.lang == 'ar'
              ? 'أضف مهمة… (مثال: غداً الساعة 5 مساءً)'
              : 'Quick capture · e.g. Review notes tomorrow at 5 PM',
          prefixIcon: const Icon(Icons.bolt_rounded, color: _green),
          suffixIcon: IconButton(
            tooltip: t('add'),
            onPressed: _captureQuickTask,
            icon: const Icon(Icons.arrow_upward_rounded, color: _green),
          ),
        ),
      ),
    ),
  );

  Future<void> _captureQuickTask() async {
    final input = quickController.text.trim();
    if (input.isEmpty) return;
    final draft = SmartInputParser.parse(input);
    if (draft.needsReview && mounted) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.lang == 'ar' ? 'مراجعة المهمة' : 'Review task'),
          content: Text(draft.task.title),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(t('save')),
            ),
          ],
        ),
      );
      if (accepted != true) return;
    }
    quickController.clear();
    await save(draft.task);
  }

  Widget _metric(String title, int count, IconData icon, Color color) => Card(
    color: color.withValues(alpha: .09),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 9),
          Text(
            '$count',
            style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    ),
  );
  Widget _tasksView() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('tasks'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t('search'),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['all', 'today', 'upcoming', 'overdue', 'completed']
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          label: Text(t(f)),
                          selected: filter == f,
                          onSelected: (_) => setState(() => filter = f),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
      Expanded(
        child: visibleTasks.isEmpty
            ? Center(child: _empty())
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 90),
                itemCount: visibleTasks.length,
                itemBuilder: (c, i) => _taskCard(visibleTasks[i], full: true),
              ),
      ),
    ],
  );
  Widget _taskCard(TodoTask task, {bool full = false}) {
    final color = switch (task.priority) {
      TaskPriority.high => const Color(0xffdb654e),
      TaskPriority.medium => const Color(0xffdba73b),
      TaskPriority.low => _green,
    };
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        leading: Checkbox(
          value: task.completed,
          shape: const CircleBorder(),
          activeColor: _green,
          onChanged: (_) => toggle(task),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 9,
              children: [
                if (task.dueAt != null)
                  Text(
                    task.hasDueTime
                        ? DateFormat.MMMd(
                            widget.lang,
                          ).add_Hm().format(task.dueAt!)
                        : DateFormat.yMMMd(widget.lang).format(task.dueAt!),
                    style: TextStyle(
                      fontSize: 12,
                      color: isOverdue(task) ? Colors.red : Colors.grey[600],
                    ),
                  ),
                Text(
                  t(task.category.toLowerCase()),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: full
            ? PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'edit') {
                    editor(task);
                  } else if (v == 'delete') {
                    delete(task);
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'edit', child: Text(t('newTask'))),
                  PopupMenuItem(value: 'delete', child: Text(t('delete'))),
                ],
              )
            : null,
        onTap: full ? () => editor(task) : null,
      ),
    );
  }

  Widget _empty() => Container(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(color: _mint, shape: BoxShape.circle),
          child: const Icon(Icons.spa_rounded, color: _green, size: 34),
        ),
        const SizedBox(height: 14),
        Text(
          t('empty'),
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    ),
  );
  Widget _calendarView() => Column(
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            t('calendar'),
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      Card(
        margin: const EdgeInsets.all(12),
        child: TableCalendar<TodoTask>(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2035),
          focusedDay: selected,
          selectedDayPredicate: (d) => isSameDay(d, selected),
          eventLoader: (d) => tasks
              .where((x) => x.dueAt != null && isSameDay(x.dueAt!, d))
              .toList(),
          onDaySelected: (d, f) => setState(() => selected = d),
          calendarStyle: CalendarStyle(
            markerDecoration: const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: _green.withValues(alpha: .25),
              shape: BoxShape.circle,
            ),
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            DateFormat.yMMMMd(widget.lang).format(selected),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      Expanded(
        child: ListView(
          children:
              tasks
                  .where(
                    (x) => x.dueAt != null && isSameDay(x.dueAt!, selected),
                  )
                  .map((x) => _taskCard(x, full: true))
                  .toList()
                  .isEmpty
              ? [_empty()]
              : tasks
                    .where(
                      (x) => x.dueAt != null && isSameDay(x.dueAt!, selected),
                    )
                    .map((x) => _taskCard(x, full: true))
                    .toList(),
        ),
      ),
    ],
  );
  Widget _focusView() => FocusScreen(lang: widget.lang, tasks: tasks);

  Widget _listsView() => SavedListsScreen(lang: widget.lang);
  Widget _insightsView() {
    final completed = tasks.where((x) => x.completed).length;
    final overdue = tasks.where(isOverdue).length;
    final pending = tasks.length - completed - overdue;
    final completionPercent = tasks.isEmpty
        ? 0
        : (completed * 100 / tasks.length).round();
    final pieSections = tasks.isEmpty
        ? [PieChartSectionData(value: 1, color: Colors.black12, title: '')]
        : [
            if (completed > 0)
              PieChartSectionData(
                value: completed.toDouble(),
                color: _green,
                title: '$completed',
              ),
            if (pending > 0)
              PieChartSectionData(
                value: pending.toDouble(),
                color: const Color(0xff73a9d8),
                title: '$pending',
              ),
            if (overdue > 0)
              PieChartSectionData(
                value: overdue.toDouble(),
                color: const Color(0xffdf9378),
                title: '$overdue',
              ),
          ];
    final days = List.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );
    final bars = days.map((d) {
      final n = tasks
          .where((x) => x.completedAt != null && isSameDay(x.completedAt!, d))
          .length;
      return BarChartGroupData(
        x: days.indexOf(d),
        barRods: [
          BarChartRodData(
            toY: n.toDouble(),
            color: _green,
            width: 17,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      );
    }).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
      children: [
        Text(
          t('insights'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _metric(t('total'), tasks.length, Icons.checklist, _green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(t('done'), completed, Icons.task_alt, _green),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metric(
                t('pending'),
                tasks.where((x) => !x.completed).length,
                Icons.hourglass_bottom,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                SizedBox(
                  width: 136,
                  height: 136,
                  child: PieChart(
                    PieChartData(
                      sections: pieSections,
                      centerSpaceRadius: 42,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$completionPercent%',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: _green,
                            ),
                      ),
                      Text(t('completionRate')),
                      const SizedBox(height: 10),
                      _chartLegend(_green, t('completed'), completed),
                      _chartLegend(
                        const Color(0xff73a9d8),
                        t('pending'),
                        pending,
                      ),
                      _chartLegend(
                        const Color(0xffdf9378),
                        t('overdue'),
                        overdue,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('week'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 210,
                  child: BarChart(
                    BarChartData(
                      barGroups: bars,
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, m) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                DateFormat.E(widget.lang)
                                    .format(days[v.toInt().clamp(0, 6)])
                                    .substring(0, 1),
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer_rounded, color: _green),
            title: Text(t('focusTime')),
            trailing: Text(
              '$_focusTotal ${t('minutes')}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chartLegend(Color color, String label, int amount) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        Text('$amount', style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );

  int _focusTotal = 0;
  Widget _settingsView() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
    children: [
      Text(
        t('settings'),
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 16),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.translate_rounded, color: _green),
              title: Text(t('language')),
              trailing: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'en', label: Text('EN')),
                  ButtonSegment(value: 'ar', label: Text('عربي')),
                ],
                selected: {widget.lang},
                onSelectionChanged: (v) => widget.onLanguage(v.first),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.palette_outlined, color: _green),
              title: Text(t('theme')),
              trailing: DropdownButton<String>(
                value: widget.themeMode,
                items: ['light', 'dark', 'system']
                    .map((x) => DropdownMenuItem(value: x, child: Text(t(x))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) widget.onTheme(v);
                },
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Card(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('font'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final name in const [
                    'Cairo',
                    'Amiri',
                    'NotoSansArabic',
                    'NotoNaskhArabic',
                    'Tajawal',
                  ])
                    ChoiceChip(
                      label: Text(switch (name) {
                        'Cairo' => t('cairo'),
                        'Amiri' => t('amiri'),
                        'NotoSansArabic' => 'Noto Sans Arabic',
                        'NotoNaskhArabic' => 'Noto Naskh Arabic',
                        _ => name,
                      }),
                      selected: widget.fontFamily == name,
                      onSelected: (_) => widget.onFontFamily(name),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                t('fontSize'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'small', label: Text(t('small'))),
                    ButtonSegment(value: 'normal', label: Text(t('normal'))),
                    ButtonSegment(value: 'large', label: Text(t('large'))),
                  ],
                  selected: {widget.fontSize},
                  onSelectionChanged: (v) => widget.onFontSize(v.first),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 14),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.backup_outlined, color: _green),
              title: Text(t('backupRestore')),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt_rounded),
              title: Text(t('backup')),
              subtitle: Text(t('backupDesc')),
              onTap: _exportBackup,
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_backup_restore_rounded),
              title: Text(t('restore')),
              subtitle: Text(t('restoreDesc')),
              onTap: _importBackup,
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: ListTile(
          leading: const Icon(Icons.notifications_off_outlined),
          title: Text(t('reminders')),
          subtitle: Text(t('remindersDisabled')),
        ),
      ),
      const SizedBox(height: 12),
      Center(
        child: Column(
          children: [
            Text(
              '${t('version')} $appVersion',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              '© ${DateTime.now().year} Anubisland. ${t('rights')}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    ],
  );
}

class SavedListsScreen extends StatefulWidget {
  const SavedListsScreen({super.key, required this.lang});
  final String lang;
  @override
  State<SavedListsScreen> createState() => _SavedListsScreenState();
}

class _SavedListsScreenState extends State<SavedListsScreen> {
  final db = TaskDatabase.instance;
  List<Map<String, Object?>> lists = [];
  final Map<int, List<Map<String, Object?>>> items = {};
  final Set<int> expanded = {};
  String t(String key) => _words[widget.lang]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final value = await db.allLists();
    if (mounted) setState(() => lists = value);
  }

  Future<void> _newList({String? kind}) async {
    final templates = <String, (String, List<String>)>{
      'shopping': (
        t('groceriesList'),
        widget.lang == 'ar'
            ? [
                'خضروات وفاكهة',
                'خبز ومخبوزات',
                'حليب وألبان',
                'لحوم أو بدائل',
                'مستلزمات المنزل',
              ]
            : [
                'Fruit and vegetables',
                'Bread and bakery',
                'Milk and dairy',
                'Meat or alternatives',
                'Household supplies',
              ],
      ),
      'travel': (
        t('travelList'),
        widget.lang == 'ar'
            ? [
                'حجز السفر والإقامة',
                'جواز السفر والهوية',
                'التذاكر والحجوزات',
                'الأدوية الضرورية',
                'شاحن الهاتف',
                'ملابس السفر',
              ]
            : [
                'Book travel and stay',
                'Passport and ID',
                'Tickets and reservations',
                'Essential medication',
                'Phone charger',
                'Travel clothes',
              ],
      ),
      'umrah': (
        t('umrahList'),
        widget.lang == 'ar'
            ? [
                'جواز السفر والهوية',
                'ملابس الإحرام',
                'حجز السكن والمواصلات',
                'أدوية ومستلزمات شخصية',
                'شاحن الهاتف',
                'التأكد من التصاريح',
              ]
            : [
                'Passport and ID',
                'Ihram clothing',
                'Accommodation and transport',
                'Medication and personal care',
                'Phone charger',
                'Check permits',
              ],
      ),
      'hajj': (
        t('hajjList'),
        widget.lang == 'ar'
            ? [
                'جواز السفر والهوية',
                'وثائق الحملة والتصاريح',
                'ملابس الإحرام',
                'أدوية ومستلزمات صحية',
                'حذاء مريح ومظلة',
                'شاحن متنقل',
              ]
            : [
                'Passport and ID',
                'Hajj group documents and permits',
                'Ihram clothing',
                'Medication and health supplies',
                'Comfortable shoes and umbrella',
                'Power bank',
              ],
      ),
      'ramadan': (
        t('ramadanList'),
        widget.lang == 'ar'
            ? [
                'خطة وجبات الأسبوع',
                'مستلزمات السحور',
                'مستلزمات الإفطار',
                'مواعيد العبادات',
                'صدقة أو عمل تطوعي',
              ]
            : [
                'Plan weekly meals',
                'Suhoor groceries',
                'Iftar groceries',
                'Worship schedule',
                'Charity or volunteering',
              ],
      ),
      'moving': (
        t('movingList'),
        widget.lang == 'ar'
            ? [
                'حجز شركة النقل',
                'كراتين ومواد تغليف',
                'فرز الأغراض والتبرع',
                'تحديث العنوان والخدمات',
                'تجهيز حقيبة اليوم الأول',
              ]
            : [
                'Book movers',
                'Boxes and packing supplies',
                'Sort and donate items',
                'Update address and utilities',
                'Pack a first-day bag',
              ],
      ),
      'books': (
        t('booksList'),
        widget.lang == 'ar'
            ? ['أضف كتاباً للقراءة', 'حدّد هدف القراءة', 'سجّل ملاحظاتك']
            : ['Add a book to read', 'Set a reading goal', 'Record your notes'],
      ),
    };
    final preset = kind == null || kind == 'custom' ? null : templates[kind];
    final controller = TextEditingController(text: preset?.$1 ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('newList')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: t('title')),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(t('save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final id = await db.createList(name, kind ?? 'custom');
    if (preset != null) {
      for (final item in preset.$2) {
        await db.createListItem(id, item);
      }
    }
    await _load();
    if (mounted) setState(() => expanded.add(id));
  }

  Future<void> _addItem(int listId) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('addItem')),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(hintText: t('listItemHint')),
          onSubmitted: (v) => Navigator.pop(context, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(t('addItem')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    await db.createListItem(listId, title);
    await _loadItems(listId);
  }

  Future<void> _loadItems(int listId) async {
    final value = await db.listItems(listId);
    if (mounted) setState(() => items[listId] = value);
  }

  Future<void> _toggleItem(Map<String, Object?> item, int listId) async {
    await db.checkListItem(item['id'] as int, item['checked'] != 1);
    await _loadItems(listId);
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              t('lists'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton.filledTonal(
            onPressed: () => _newList(),
            icon: const Icon(Icons.add_rounded),
            tooltip: t('newList'),
          ),
        ],
      ),
      Text(
        t('noLists'),
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in [
            ('shopping', 'groceriesList', Icons.shopping_cart_outlined),
            ('travel', 'travelList', Icons.flight_takeoff_rounded),
            ('umrah', 'umrahList', Icons.mosque_rounded),
            ('hajj', 'hajjList', Icons.mosque_rounded),
            ('ramadan', 'ramadanList', Icons.nights_stay_rounded),
            ('moving', 'movingList', Icons.local_shipping_outlined),
            ('books', 'booksList', Icons.menu_book_rounded),
          ])
            ActionChip(
              avatar: Icon(option.$3, size: 18),
              label: Text(t(option.$2)),
              onPressed: () => _newList(kind: option.$1),
            ),
          ActionChip(
            avatar: const Icon(Icons.playlist_add_rounded, size: 18),
            label: Text(t('customList')),
            onPressed: () => _newList(kind: 'custom'),
          ),
        ],
      ),
      const SizedBox(height: 14),
      if (lists.isEmpty)
        Card(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Text(t('noLists'), textAlign: TextAlign.center),
          ),
        )
      else
        for (final list in lists) _listCard(list),
    ],
  );

  Widget _listCard(Map<String, Object?> list) {
    final id = list['id'] as int;
    final kind = list['kind'] as String;
    final rows = items[id] ?? const <Map<String, Object?>>[];
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _green.withValues(alpha: .12),
              foregroundColor: _green,
              child: Icon(
                kind == 'travel'
                    ? Icons.flight_takeoff_rounded
                    : kind == 'shopping'
                    ? Icons.shopping_cart_outlined
                    : Icons.list_alt_rounded,
              ),
            ),
            title: Text(
              list['name'] as String,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${rows.where((x) => x['checked'] == 1).length}/${rows.length}',
            ),
            trailing: IconButton(
              onPressed: () => _addItem(id),
              icon: const Icon(Icons.add_circle_outline_rounded),
              tooltip: t('addItem'),
            ),
            onTap: () async {
              setState(
                () => expanded.contains(id)
                    ? expanded.remove(id)
                    : expanded.add(id),
              );
              if (expanded.contains(id)) await _loadItems(id);
            },
          ),
          if (expanded.contains(id)) ...[
            const Divider(height: 1),
            for (final item in rows)
              Dismissible(
                key: ValueKey('list-item-${item['id']}'),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await db.deleteListItem(item['id'] as int);
                  await _loadItems(id);
                },
                background: Container(
                  color: Colors.red.shade100,
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsetsDirectional.only(end: 20),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                child: CheckboxListTile(
                  value: item['checked'] == 1,
                  title: Text(
                    item['title'] as String,
                    style: TextStyle(
                      decoration: item['checked'] == 1
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (_) => _toggleItem(item, id),
                ),
              ),
            TextButton.icon(
              onPressed: () => _addItem(id),
              icon: const Icon(Icons.add),
              label: Text(t('addItem')),
            ),
          ],
        ],
      ),
    );
  }
}

class TaskEditor extends StatefulWidget {
  const TaskEditor({super.key, this.task, required this.lang});
  final TodoTask? task;
  final String lang;
  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  late final title = TextEditingController(text: widget.task?.title ?? '');
  late final description = TextEditingController(
    text: widget.task?.description ?? '',
  );
  late final project = TextEditingController(text: widget.task?.project ?? '');
  late final subtasks = TextEditingController(
    text: widget.task?.subtasks.join('\n') ?? '',
  );
  late final duration = TextEditingController(
    text: '${widget.task?.durationMinutes ?? 25}',
  );
  DateTime? date;
  TimeOfDay time = const TimeOfDay(hour: 9, minute: 0);
  bool hasDueTime = false;
  TaskPriority priority = TaskPriority.medium;
  String category = 'Personal', recurrence = 'none';
  Map<String, String> get s => _words[widget.lang] ?? _words['en']!;

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    project.dispose();
    subtasks.dispose();
    duration.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    date = widget.task?.dueAt;
    hasDueTime = widget.task?.hasDueTime ?? false;
    priority = widget.task?.priority ?? TaskPriority.medium;
    category = widget.task?.category ?? 'Personal';
    recurrence = widget.task?.recurrence ?? 'none';
    if (date != null) time = TimeOfDay.fromDateTime(date!);
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: DraggableScrollableSheet(
      initialChildSize: .88,
      maxChildSize: .95,
      minChildSize: .55,
      builder: (c, sc) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s['newTask']!,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: title,
              autofocus: true,
              decoration: InputDecoration(
                hintText: s['title'],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: description,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: s['description'],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: project,
              decoration: InputDecoration(
                labelText: s['project'],
                prefixIcon: const Icon(Icons.folder_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              s['date']!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                      );
                      if (d != null) {
                        setState(
                          () => date = DateTime(
                            d.year,
                            d.month,
                            d.day,
                            time.hour,
                            time.minute,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.event),
                    label: Text(
                      date == null
                          ? s['noDate']!
                          : DateFormat.yMMMd(widget.lang).format(date!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final v = await showTimePicker(
                        context: context,
                        initialTime: time,
                      );
                      if (v != null) {
                        setState(() {
                          time = v;
                          hasDueTime = true;
                          if (date != null) {
                            date = DateTime(
                              date!.year,
                              date!.month,
                              date!.day,
                              v.hour,
                              v.minute,
                            );
                          }
                        });
                      }
                    },
                    icon: const Icon(Icons.schedule),
                    label: Text(time.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              s['priority']!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 8,
              children: TaskPriority.values
                  .map(
                    (p) => ChoiceChip(
                      label: Text(s[p.name]!),
                      selected: priority == p,
                      onSelected: (_) => setState(() => priority = p),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 14),
            Text(
              s['category']!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Wrap(
              spacing: 8,
              children: ['Personal', 'Work', 'Study', 'Shopping']
                  .map(
                    (v) => ChoiceChip(
                      label: Text(s[v.toLowerCase()] ?? v),
                      selected: category == v,
                      onSelected: (_) => setState(() => category = v),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: duration,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: s['duration'],
                prefixIcon: const Icon(Icons.timelapse),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              s['recurrence']!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            DropdownButtonFormField<String>(
              initialValue: recurrence,
              items: ['none', 'daily', 'weekly']
                  .map((v) => DropdownMenuItem(value: v, child: Text(s[v]!)))
                  .toList(),
              onChanged: (v) => setState(() => recurrence = v ?? 'none'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: subtasks,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: s['subtasks'],
                hintText: widget.lang == 'ar'
                    ? 'مهمة فرعية في كل سطر'
                    : 'One subtask per line',
                prefixIcon: const Icon(Icons.format_list_bulleted_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {
                if (title.text.trim().isEmpty) return;
                final due = date == null
                    ? null
                    : DateTime(
                        date!.year,
                        date!.month,
                        date!.day,
                        time.hour,
                        time.minute,
                      );
                Navigator.pop(
                  context,
                  TodoTask(
                    id: widget.task?.id,
                    title: title.text.trim(),
                    description: description.text.trim(),
                    dueAt: due,
                    hasDueTime: hasDueTime,
                    durationMinutes: int.tryParse(duration.text) ?? 25,
                    priority: priority,
                    category: category,
                    project: project.text.trim(),
                    recurrence: recurrence,
                    subtasks: subtasks.text
                        .split('\n')
                        .map((item) => item.trim())
                        .where((item) => item.isNotEmpty)
                        .toList(),
                    completed: widget.task?.completed ?? false,
                    completedAt: widget.task?.completedAt,
                    createdAt: widget.task?.createdAt,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.all(15),
              ),
              child: Text(s['save']!),
            ),
          ],
        ),
      ),
    ),
  );
}

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.lang, required this.tasks});
  final String lang;
  final List<TodoTask> tasks;
  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> with WidgetsBindingObserver {
  int minutes = 25, remaining = 1500;
  bool running = false;
  DateTime? deadline;
  Timer? ticker;
  int? taskId;
  String phase = 'workSession';
  String text(String key) => _words[widget.lang]?[key] ?? key;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restore();
  }

  Future<void> _restore() async {
    final p = await SharedPreferences.getInstance();
    final end = p.getInt('focus_end');
    final m = p.getInt('focus_minutes') ?? 25;
    phase = p.getString('focus_phase') ?? 'workSession';
    taskId = p.getInt('focus_task');
    remaining = p.getInt('focus_remaining') ?? m * 60;
    if (end != null && end > DateTime.now().millisecondsSinceEpoch) {
      deadline = DateTime.fromMillisecondsSinceEpoch(end);
      remaining = deadline!.difference(DateTime.now()).inSeconds;
      running = true;
    } else if (end != null) {
      remaining = 0;
      await TaskDatabase.instance.saveFocus(
        taskId,
        DateTime.now().subtract(Duration(minutes: m)),
        m,
      );
      await p.remove('focus_end');
    }
    minutes = m;
    if (mounted) setState(() {});
    if (running) _startTick();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    if (s == AppLifecycleState.resumed && running) _tick();
  }

  void _startTick() {
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (deadline == null) return;
    final r = deadline!.difference(DateTime.now()).inSeconds;
    if (r <= 0) {
      ticker?.cancel();
      setState(() {
        remaining = 0;
        running = false;
      });
      SharedPreferences.getInstance().then((p) => p.remove('focus_end'));
      TaskDatabase.instance.saveFocus(
        taskId,
        DateTime.now().subtract(Duration(minutes: minutes)),
        minutes,
      );
      return;
    }
    if (mounted) setState(() => remaining = r);
  }

  Future<void> _start() {
    deadline = DateTime.now().add(Duration(seconds: remaining));
    running = true;
    SharedPreferences.getInstance().then((p) {
      p.setInt('focus_end', deadline!.millisecondsSinceEpoch);
      p.setInt('focus_minutes', minutes);
      p.setString('focus_phase', phase);
      p.setInt('focus_remaining', remaining);
      if (taskId == null) {
        p.remove('focus_task');
      } else {
        p.setInt('focus_task', taskId!);
      }
    });
    setState(() {});
    _startTick();
    return Future.value();
  }

  void _pause() {
    ticker?.cancel();
    remaining = deadline?.difference(DateTime.now()).inSeconds ?? remaining;
    running = false;
    deadline = null;
    SharedPreferences.getInstance().then((p) {
      p.remove('focus_end');
      p.setInt('focus_remaining', remaining);
    });
    setState(() {});
  }

  void _reset() {
    ticker?.cancel();
    running = false;
    remaining = minutes * 60;
    deadline = null;
    SharedPreferences.getInstance().then((p) {
      p.remove('focus_end');
      p.setInt('focus_remaining', remaining);
    });
    setState(() {});
  }

  @override
  void dispose() {
    ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio = 1 - remaining / (minutes * 60);
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
      children: [
        Text(
          text('focus'),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 260,
            height: 260,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: ratio,
                    strokeWidth: 12,
                    backgroundColor: _mint,
                    color: _green,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(remaining ~/ 60).toString().padLeft(2, '0')}:${(remaining % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      text(phase),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.restart_alt_rounded),
            ),
            const SizedBox(width: 15),
            FilledButton.icon(
              onPressed: running ? _pause : _start,
              icon: Icon(
                running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              ),
              label: Text(text(running ? 'pause' : 'start')),
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(width: 15),
            IconButton(onPressed: _reset, icon: const Icon(Icons.stop_rounded)),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: const Icon(Icons.task_alt, color: _green),
            title: Text(text('linkTask')),
            trailing: DropdownButton<int?>(
              value: taskId,
              hint: Text(text('noneOption')),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(text('noneOption')),
                ),
                ...widget.tasks
                    .where((x) => !x.completed)
                    .map(
                      (x) => DropdownMenuItem<int?>(
                        value: x.id,
                        child: SizedBox(
                          width: 170,
                          child: Text(x.title, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ),
              ],
              onChanged: (v) {
                setState(() => taskId = v);
                SharedPreferences.getInstance().then((p) {
                  if (v == null) {
                    p.remove('focus_task');
                  } else {
                    p.setInt('focus_task', v);
                  }
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Wrap(
            spacing: 8,
            children: [
              for (final option in const {
                'workSession': 25,
                'shortBreak': 5,
                'longBreak': 15,
              }.entries)
                ChoiceChip(
                  label: Text(text(option.key)),
                  selected: phase == option.key,
                  onSelected: running
                      ? null
                      : (_) {
                          setState(() {
                            phase = option.key;
                            minutes = option.value;
                            remaining = minutes * 60;
                          });
                          SharedPreferences.getInstance().then((p) {
                            p.setString('focus_phase', phase);
                            p.setInt('focus_minutes', minutes);
                            p.setInt('focus_remaining', remaining);
                          });
                        },
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Wrap(
            spacing: 8,
            children: [
              for (final m in [25, 45, 60])
                ChoiceChip(
                  label: Text('$m ${text('minutes')}'),
                  selected: minutes == m && !running,
                  onSelected: running
                      ? null
                      : (_) {
                          setState(() {
                            phase = 'workSession';
                            minutes = m;
                            remaining = m * 60;
                          });
                          SharedPreferences.getInstance().then((p) {
                            p.setString('focus_phase', 'workSession');
                            p.setInt('focus_minutes', m);
                            p.setInt('focus_remaining', m * 60);
                          });
                        },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
