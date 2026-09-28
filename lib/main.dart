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
