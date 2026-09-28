import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() => runApp(const WindowCalcApp());

class WindowCalcApp extends StatelessWidget {
  const WindowCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Расчёт окон',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// ЦЕНЫ
// ============================================================
class Prices {
  static Map<String, double> windows = {
    'Глухое': 4500,
    'Одностворчатое': 6500,
    'Двустворчатое': 7000,
    'Балконный блок малый': 7500,
    'Балконный блок большой': 8500,
    'Лоджия': 7500,
  };

  static double sillPrice = 800;
  static double dripPrice = 600;
  static double slopePrice250 = 500;
  static double slopePrice600 = 1500;
  static double slopePrice1000 = 2500;
  static double installWindow = 1500;
  static double installSlope = 400;

  static double windowPrice(String type, double width) {
    if (type == 'Балконный блок') {
      return width <= 1600
          ? (windows['Балконный блок малый'] ?? 7500)
          : (windows['Балконный блок большой'] ?? 8500);
    }
    return windows[type] ?? 0;
  }

  static String windowTypeLabel(String type, double width) {
    if (type == 'Балконный блок') {
      return width <= 1600
          ? 'Балконный блок (малый, до 1600 мм)'
          : 'Балконный блок (большой, > 1600 мм)';
    }
    return type;
  }

  static double slopePriceByDepth(double depth) {
    if (depth <= 250) return slopePrice250;
    if (depth <= 600) return slopePrice600;
    return slopePrice1000;
  }
}

// ============================================================
// ГЛАВНЫЙ ЭКРАН
// ============================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расчёт окон'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _button(context, Icons.calculate, 'Новый расчёт',
              'Рассчитать окно', const OrderScreen()),
          const SizedBox(height: 12),
          _button(context, Icons.settings, 'Настройки цен',
              'Окна, доп. элементы, монтаж', const PriceSettingsScreen()),
        ],
      ),
    );
  }

  Widget _button(BuildContext ctx, IconData icon, String title,
      String subtitle, Widget page) {
    return Card(
      elevation: 3,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, size: 40, color: Colors.blue),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
            ctx, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

// ============================================================
// НАСТРНАСТРОЙКИОЙКИ ЦЕЦЕНН
// ============================================================
class PriceSettingsScreen extends StatefulWidget {
  const PriceSettingsScreen({super.key});
  @override
  State<PriceSettingsScreen> createState() => _PriceSettingsScreenState();
}

class _PriceSettingsScreenState extends State<PriceSettingsScreen> {
  final Map<String, TextEditingController> _windowCtrls = {};
  final _sillCtrl = TextEditingController();
  final _dripCtrl = TextEditingController();
  final _slope250Ctrl = TextEditingController();
  final _slope600Ctrl = TextEditingController();
  final _slope1000Ctrl = TextEditingController();
  final _instWCtrl = TextEditingController();
  final _instSCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final k in Prices.windows.keys) {
      _windowCtrls[k] =
          TextEditingController(text: Prices.windows[k]!.toStringAsFixed(0));
    }
    _sillCtrl.text = Prices.sillPrice.toStringAsFixed(0);
    _dripCtrl.text = Prices.dripPrice.toStringAsFixed(0);
    _slope250Ctrl.text = Prices.slopePrice250.toStringAsFixed(0);
    _slope600Ctrl.text = Prices.slopePrice600.toStringAsFixed(0);
    _slope1000Ctrl.text = Prices.slopePrice1000.toStringAsFixed(0);
    _instWCtrl.text = Prices.installWindow.toStringAsFixed(0);
    _instSCtrl.text = Prices.installSlope.toStringAsFixed(0);
  }

  void _saveAndExit() {
    for (final k in Prices.windows.keys) {
      Prices.windows[k] = double.tryParse(_windowCtrls[k]?.text ?? '') ?? 0;
    }
    Prices.sillPrice = double.tryParse(_sillCtrl.text) ?? 0;
    Prices.dripPrice = double.tryParse(_dripCtrl.text) ?? 0;
    Prices.slopePrice250 = double.tryParse(_slope250Ctrl.text) ?? 0;
    Prices.slopePrice600 = double.tryParse(_slope600Ctrl.text) ?? 0;
    Prices.slopePrice1000 = double.tryParse(_slope1000Ctrl.text) ?? 0;
    Prices.installWindow = double.tryParse(_instWCtrl.text) ?? 0;
    Prices.installSlope = double.tryParse(_instSCtrl.text) ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Цены сохранены ✅')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки цен'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveAndExit),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('ОКНА (₽/м²)'),
          ...Prices.windows.keys.map((k) => _priceField(
                label: k,
                ctrl: _windowCtrls[k]!,
                unit: '₽/м²',
              )),
          const Divider(height: 32),
          _sectionTitle('ДОПОЛНИТЕЛЬНО'),
          _priceField(label: 'Подоконник (Ш×Д)', ctrl: _sillCtrl, unit: '₽/м²'),
          _priceField(label: 'Отлив (Ш×Д)', ctrl: _dripCtrl, unit: '₽/м²'),
          const SizedBox(height: 8),
          const Text('Откосы ПВХ — цена за м.п. по глубине:',
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: Colors.grey)),
          _priceField(
              label: 'Откос до 250 мм', ctrl: _slope250Ctrl, unit: '₽/м.п.'),
          _priceField(
              label: 'Откос 251–600 мм', ctrl: _slope600Ctrl, unit: '₽/м.п.'),
          _priceField(
              label: 'Откос 601–1000 мм', ctrl: _slope1000Ctrl, unit: '₽/м.п.'),
          const Divider(height: 32),
          _sectionTitle('МОНТАЖ'),
          _priceField(label: 'Монтаж окна', ctrl: _instWCtrl, unit: '₽/м²'),
          _priceField(
              label: 'Монтаж откосов', ctrl: _instSCtrl, unit: '₽/м.п.'),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('СОХРАНИТЬ ВСЁ'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            onPressed: _saveAndExit,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(t,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _priceField({
    required String label,
    required TextEditingController ctrl,
    required String unit,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
// ============================================================
// ЭКРАН РАСЧЁТА
// ============================================================
class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});
  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _type = 'Одностворчатое';
  final _widthCtrl = TextEditingController(text: '1300');
  final _heightCtrl = TextEditingController(text: '1400');
  bool _hasSash = true;
  String _hinge = 'Слева';
  bool _tiltTurn = false;
  bool _addSill = false;
  bool _addDrip = false;
  bool _addSlopes = false;
  bool _install = false;
  final _sillW = TextEditingController(text: '300');
  final _sillL = TextEditingController(text: '1500');
  final _dripW = TextEditingController(text: '150');
  final _dripL = TextEditingController(text: '1500');
  final _slopeCount = TextEditingController(text: '3');
  final _slopeDepth = TextEditingController(text: '200');
  final _slopeLen = TextEditingController(text: '1500');

  final types = const [
    'Глухое',
    'Одностворчатое',
    'Двустворчатое',
    'Балконный блок',
    'Лоджия',
  ];

  double get _w => double.tryParse(_widthCtrl.text) ?? 0;
  double get _h => double.tryParse(_heightCtrl.text) ?? 0;
  double get _area => (_w / 1000) * (_h / 1000);

  double get windowCost => _area * Prices.windowPrice(_type, _w);

  double get sillCost {
    if (!_addSill) return 0;
    final w = double.tryParse(_sillW.text) ?? 0;
    final l = double.tryParse(_sillL.text) ?? 0;
    return (w / 1000) * (l / 1000) * Prices.sillPrice;
  }

  double get dripCost {
    if (!_addDrip) return 0;
    final w = double.tryParse(_dripW.text) ?? 0;
    final l = double.tryParse(_dripL.text) ?? 0;
    return (w / 1000) * (l / 1000) * Prices.dripPrice;
  }

  double get slopeCost {
    if (!_addSlopes) return 0;
    final cnt = int.tryParse(_slopeCount.text) ?? 0;
    final depth = double.tryParse(_slopeDepth.text) ?? 0;
    final len = double.tryParse(_slopeLen.text) ?? 0;
    return (len / 1000) * cnt * Prices.slopePriceByDepth(depth);
  }

  double get materialsCost => windowCost + sillCost + dripCost + slopeCost;

  double get installCost {
    if (!_install) return 0;
    double w = _area * Prices.installWindow;
    if (_addSlopes) {
      final cnt = int.tryParse(_slopeCount.text) ?? 0;
      final len = double.tryParse(_slopeLen.text) ?? 0;
      w += (len / 1000) * cnt * Prices.installSlope;
    }
    return w;
  }

  double get totalCost => materialsCost + installCost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый расчёт')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _title('Тип изделия'),
          DropdownButtonFormField<String>(
            value: _type,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: types
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => _type = v!),
          ),
          if (_type == 'Балконный блок')
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _w <= 1600
                    ? '→ Малый ББ (ширина ≤ 1600 мм)'
                    : '→ Большой ББ (ширина > 1600 мм)',
                style: TextStyle(
                    color:
                        _w <= 1600 ? Colors.green[700] : Colors.orange[800],
                    fontWeight: FontWeight.bold),
              ),
            ),
          _title('Размеры окна (мм)'),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _widthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Ширина', border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Высота', border: OutlineInputBorder()),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Площадь: ${_area.toStringAsFixed(2)} м²',
                style: const TextStyle(color: Colors.grey)),
          ),
          if (_type != 'Глухое') ...[
            _title('Створка'),
            CheckboxListTile(
              title: const Text('Есть створка'),
              value: _hasSash,
              onChanged: (v) => setState(() => _hasSash = v!),
            ),
            if (_hasSash) ...[
              DropdownButtonFormField<String>(
                value: _hinge,
                decoration:
                    const InputDecoration(border: OutlineInputBorder()),
                items: ['Слева', 'Справа']
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text('Открывание: $s')))
                    .toList(),
                onChanged: (v) => setState(() => _hinge = v!),
              ),
              CheckboxListTile(
                title: const Text('Поворотно-откидная'),
                value: _tiltTurn,
                onChanged: (v) => setState(() => _tiltTurn = v!),
              ),
            ],
          ],
          _title('Визуализация'),
Padding(
  padding: const EdgeInsets.symmetric(vertical: 8),
  child: Column(
    children: [
      Text('${_w.toStringAsFixed(0)} мм',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 14)),
      const SizedBox(height: 4),
      SizedBox(
        height: 160,
        child: Row(
          children: [
            RotatedBox(
              quarterTurns: 3,
              child: Text(
                '${_h.toStringAsFixed(0)} мм',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: WindowDrawing(
                type: _type,
                hinge: _hinge,
                tiltTurn: _tiltTurn,
                hasSash: _hasSash,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),_title('Подоконник'),
          CheckboxListTile(
            title: Text(
                'Добавить (${Prices.sillPrice.toStringAsFixed(0)} ₽/м²)'),
            value: _addSill,
            onChanged: (v) => setState(() => _addSill = v!),
          ),
          if (_addSill)
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _sillW,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Ширина (мм)',
                      border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _sillL,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Длина (мм)',
                      border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
          _title('Отлив'),
          CheckboxListTile(
            title: Text(
                'Добавить (${Prices.dripPrice.toStringAsFixed(0)} ₽/м²)'),
                      value: _addDrip,
            onChanged: (v) => setState(() => _addDrip = v!),
          ),
          if (_addDrip)
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _dripW,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Ширина (мм)',
                      border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dripL,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Длина (мм)',
                      border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
          _title('Откосы ПВХ'),
          CheckboxListTile(
            title: const Text('Добавить откосы'),
            subtitle: Text(
                'до 250 мм — ${Prices.slopePrice250.toStringAsFixed(0)} ₽/м.п.\n'
                '251–600 — ${Prices.slopePrice600.toStringAsFixed(0)} ₽/м.п.\n'
                '601–1000 — ${Prices.slopePrice1000.toStringAsFixed(0)} ₽/м.п.'),
            value: _addSlopes,
            onChanged: (v) => setState(() => _addSlopes = v!),
          ),
          if (_addSlopes)
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _slopeCount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Кол-во', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _slopeDepth,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Глубина', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _slopeLen,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Длина', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ]),
          const Divider(height: 32),
          CheckboxListTile(
            title: const Text('Включить монтаж'),
            subtitle: Text(
                'Окно: ${Prices.installWindow.toStringAsFixed(0)} ₽/м²\n'
                'Откосы: ${Prices.installSlope.toStringAsFixed(0)} ₽/м.п.'),
            value: _install,
            onChanged: (v) => setState(() => _install = v!),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              const Text('Итого'),
              Text('${totalCost.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.receipt_long),
            label: const Text('ДЕТАЛЬНЫЙ РАСЧЁТ'),
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50)),
            onPressed: _showDetails,
          ),OutlinedButton.icon(
  icon: const Icon(Icons.copy),
  label: const Text('СКОПИРОВАТЬ РАСЧЁТ'),
  style: OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(50)),
  onPressed: _copyToClipboard,
),
const SizedBox(height: 8),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 6),
        child: Text(t,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  void _showDetails() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.8,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          children: [
            const Text('ДЕТАЛЬНЫЙ РАСЧЁТ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              '${Prices.windowTypeLabel(_type, _w)} '
              '${_w.toStringAsFixed(0)}×${_h.toStringAsFixed(0)} мм, '
              'площадь ${_area.toStringAsFixed(2)} м²',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 24),
            _row('${Prices.windowTypeLabel(_type, _w)}',
                '${_area.toStringAsFixed(2)} м² × ${Prices.windowPrice(_type, _w).toStringAsFixed(0)} ₽/м²',
                windowCost),
            if (_addSill)
              _row('Подоконник ${_sillW.text}×${_sillL.text} мм', '', sillCost),
            if (_addDrip)
              _row('Отлив ${_dripW.text}×${_dripL.text} мм', '', dripCost),
            if (_addSlopes)
              _row(
                  'Откосы ПВХ ×${_slopeCount.text}',
                  'глубина ${_slopeDepth.text} мм → ${Prices.slopePriceByDepth(double.tryParse(_slopeDepth.text) ?? 0).toStringAsFixed(0)} ₽/м.п.',
                  slopeCost),
            const Divider(),
            _totalRow('ЗАКУПКА МАТЕРИАЛОВ', materialsCost),
            const Divider(),
            if (_install) ...[
              _row('Монтаж окна', '${_area.toStringAsFixed(2)} м²',
                  _area * Prices.installWindow),
              if (_addSlopes)
                _row('Монтаж откосов', '',
                    installCost - _area * Prices.installWindow),
              _totalRow('МОНТАЖ', installCost),
              const Divider(),
            ],
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ИТОГО',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${totalCost.toStringAsFixed(0)} ₽',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

Future<void> _copyToClipboard() async {
  final buf = StringBuffer();
  buf.writeln('📋 РАСЧЁТ ОКНА');
  buf.writeln('━━━━━━━━━━━━━━━━━━━━');
  buf.writeln();
  buf.writeln('${Prices.windowTypeLabel(_type, _w)}');
  buf.writeln('Размер: ${_w.toStringAsFixed(0)}×${_h.toStringAsFixed(0)} мм');
  buf.writeln('Площадь: ${_area.toStringAsFixed(2)} м²');
  buf.writeln();
  buf.writeln('МАТЕРИАЛЫ:');
  buf.writeln('• Окно: ${windowCost.toStringAsFixed(0)} ₽');
  if (_addSill) {
    buf.writeln('• Подоконник: ${sillCost.toStringAsFixed(0)} ₽');
              }
  if (_addDrip) {
    buf.writeln('• Отлив: ${dripCost.toStringAsFixed(0)} ₽');
  }
  if (_addSlopes) {
    buf.writeln('• Откосы ПВХ: ${slopeCost.toStringAsFixed(0)} ₽');
  }
  buf.writeln('──────────');
  buf.writeln('Закупка: ${materialsCost.toStringAsFixed(0)} ₽');
  buf.writeln();
  if (_install) {
    buf.writeln('МОНТАЖ:');
    buf.writeln(
        '• Окно: ${(_area * Prices.installWindow).toStringAsFixed(0)} ₽');
    if (_addSlopes) {
      final mountSlope = installCost - _area * Prices.installWindow;
      buf.writeln('• Откосы: ${mountSlope.toStringAsFixed(0)} ₽');
    }
    buf.writeln('──────────');
    buf.writeln('Монтаж: ${installCost.toStringAsFixed(0)} ₽');
    buf.writeln();
  }
  buf.writeln('━━━━━━━━━━━━━━━━━━━━');
  buf.writeln('ИТОГО: ${totalCost.toStringAsFixed(0)} ₽');

  await Clipboard.setData(ClipboardData(text: buf.toString()));

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Расчёт скопирован ✅'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
  Widget _row(String name, String sub, double price) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  if (sub.isNotEmpty)
                    Text(sub,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Text('${price.toStringAsFixed(0)} ₽',
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _totalRow(String name, double price) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text('${price.toStringAsFixed(0)} ₽',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      );
}
// ============================================================
// ЧЕРТЁЖ ОКНА
// ============================================================
class WindowDrawing extends StatelessWidget {
  final String type;
  final String hinge;
  final bool tiltTurn;
  final bool hasSash;

  const WindowDrawing({
    super.key,
    required this.type,
    required this.hinge,
    required this.tiltTurn,
    required this.hasSash,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> sections = [];
    if (type == 'Глухое') {
      sections.add(Expanded(child: _pane(fixed: true)));
    } else if (type == 'Одностворчатое') {
      sections.add(Expanded(
          child: _pane(fixed: !hasSash, hinge: hinge, tilt: tiltTurn)));
    } else if (type == 'Двустворчатое') {
      sections.add(Expanded(child: _pane(fixed: true)));
      sections.add(_dividerVertical());
      sections.add(Expanded(
          child: _pane(fixed: !hasSash, hinge: hinge, tilt: tiltTurn)));
    } else if (type == 'Балконный блок') {
      sections.add(Expanded(
          flex: 2,
          child: _pane(
              fixed: !hasSash, hinge: hinge, tilt: false, isDoor: true)));
      sections.add(_dividerVertical());
      sections.add(Expanded(child: _pane(fixed: true)));
    } else {
      sections.add(Expanded(child: _pane(fixed: true)));
      sections.add(_dividerVertical());
      sections.add(Expanded(
          child: _pane(fixed: !hasSash, hinge: hinge, tilt: tiltTurn)));
      sections.add(_dividerVertical());
      sections.add(Expanded(child: _pane(fixed: true)));
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black87, width: 3),
      ),
      child: Row(children: sections),
    );
  }

  Widget _dividerVertical() => Container(width: 2, color: Colors.black87);

  Widget _pane({
    bool fixed = false,
    String? hinge,
    bool tilt = false,
    bool isDoor = false,
  }) {
    return Stack(
      children: [
        Container(
          color: fixed ? Colors.grey[350] : Colors.lightBlue[100],
        ),
        if (!fixed)
          Align(
            alignment: hinge == 'Слева'
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: Container(
              width: 5,
              height: double.infinity,
              color: Colors.blue[700],
            ),
          ),
        if (tilt)
          Positioned(
            bottom: 2,
            left: 0,
            right: 0,
            child: Center(
              child: Icon(Icons.keyboard_arrow_up,
                  color: Colors.blue[700], size: 18),
            ),
          ),
        if (isDoor)
          Center(
            child:
                Icon(Icons.door_front_door, size: 36, color: Colors.blue[800]),
          ),
      ],
    );
  }
}
