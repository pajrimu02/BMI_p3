import 'package:flutter/material.dart';

import 'bmi_logic.dart';

 
class _Palette {
  static const background = Color(0xFFF5F4F0);
  static const surface = Colors.white;
  static const ink = Color(0xFF2E3A3F);
  static const muted = Color(0xFF8A9499);
  static const line = Color(0xFFE6E4DD);
  static const primary = Color(0xFF4F7C78);
  static const danger = Color(0xFFC27468);
}

const Map<BmiCategory, Color> _categoryColors = {
  BmiCategory.kurus: Color(0xFF6E9BBF),
  BmiCategory.normal: Color(0xFF5E9A7E),
  BmiCategory.gemuk: Color(0xFFD1A04F),
  BmiCategory.obesitas: Color(0xFFC27468),
};

class _GenderStyle {
  final IconData icon;
  final Color accent;
  const _GenderStyle(this.icon, this.accent);
}

const Map<Gender, _GenderStyle> _genderStyles = {
  Gender.male: _GenderStyle(Icons.male_rounded, Color(0xFF5B7FA3)),
  Gender.female: _GenderStyle(Icons.female_rounded, Color(0xFFB07C8C)),
};

class BMIScreen extends StatefulWidget {
  const BMIScreen({super.key});

  @override
  State<BMIScreen> createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();

  Gender _gender = Gender.male;
  BmiResult? _result;
  String? _error;

  void _hitungBMI() {
    FocusScope.of(context).unfocus();

    final bb = BmiCalculator.parseNumber(_bbController.text);
    final tb = BmiCalculator.parseNumber(_tbController.text);
    final error = BmiCalculator.validate(bb, tb);

    setState(() {
      if (error != null) {
        _result = null;
        _error = error;
      } else {
        _error = null;
        _result = BmiCalculator.calculate(beratKg: bb!, tinggiCm: tb!);
      }
    });
  }

  void _resetForm() {
    FocusScope.of(context).unfocus();
    setState(() {
      _bbController.clear();
      _tbController.clear();
      _result = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    _bbController.dispose();
    _tbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _Palette.background,
      appBar: AppBar(
        title: const Text(
          'Kalkulator BMI',
          style: TextStyle(
            color: _Palette.ink,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: _Palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Indeks Massa Tubuh',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _Palette.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih jenis kelamin, lalu isi berat dan tinggi badan.',
                  style: TextStyle(fontSize: 14, color: _Palette.muted),
                ),
                const SizedBox(height: 20),
                _buildGenderToggle(),
                const SizedBox(height: 16),
                _buildInputCard(),
                const SizedBox(height: 16),
                _buildActions(),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  _buildError(_error!),
                ],
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _result == null
                      ? const SizedBox.shrink()
                      : Padding(
                          key: ValueKey('${_result!.bmi}-$_gender'),
                          padding: const EdgeInsets.only(top: 24),
                          child: _buildResult(_result!),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

 

  Widget _buildGenderToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAE8E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: Gender.values.map((g) {
          final style = _genderStyles[g]!;
          final selected = g == _gender;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _gender = g),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? _Palette.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: selected
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(style.icon,
                        size: 20,
                        color: selected ? style.accent : _Palette.muted),
                    const SizedBox(width: 8),
                    Text(
                      g.label,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                        color: selected ? _Palette.ink : _Palette.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

 

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _buildField(
            controller: _bbController,
            label: 'Berat badan',
            suffix: 'kg',
            icon: Icons.monitor_weight_outlined,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _tbController,
            label: 'Tinggi badan',
            suffix: 'cm',
            icon: Icons.height_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: _Palette.ink, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _Palette.muted),
        floatingLabelStyle: const TextStyle(color: _Palette.primary),
        prefixIcon: Icon(icon, color: _Palette.primary, size: 22),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: _Palette.muted),
        filled: true,
        fillColor: const Color(0xFFFAF9F6),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        enabledBorder: border(_Palette.line),
        focusedBorder: border(_Palette.primary, 1.5),
      ),
    );
  }

 

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _hitungBMI,
            style: ElevatedButton.styleFrom(
              backgroundColor: _Palette.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Hitung BMI',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: _resetForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: _Palette.ink,
              side: const BorderSide(color: _Palette.line, width: 1.5),
              backgroundColor: _Palette.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _Palette.danger.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _Palette.danger.withAlpha(90)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              size: 20, color: _Palette.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _Palette.ink, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildResult(BmiResult r) {
    final gender = _gender;
    final style = _genderStyles[gender]!;
    final category = r.categoryFor(gender);
    final catColor = _categoryColors[category]!;
    final ranges = BmiCalculator.ranges(gender);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: style.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(style.icon, size: 15, color: style.accent),
                    const SizedBox(width: 4),
                    Text(
                      gender.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: style.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'HASIL BMI',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: _Palette.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                r.bmi.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 56,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  color: _Palette.ink,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: catColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            category.note,
            style: const TextStyle(fontSize: 13.5, color: _Palette.muted),
          ),
          const SizedBox(height: 22),
          _buildScale(r.bmi, gender, category),
          const SizedBox(height: 22),
          _divider(),
          _infoRow(
            'Berat ideal untuk tinggi Anda',
            '${r.idealMinKg.toStringAsFixed(1)} – '
                '${r.idealMaxKg(gender).toStringAsFixed(1)} kg',
          ),
          _divider(),
          const SizedBox(height: 14),
          Text(
            'Kategori ${gender.label}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _Palette.ink,
            ),
          ),
          const SizedBox(height: 8),
          ...ranges.map((range) => _categoryRow(range, range.category == category)),
          const SizedBox(height: 14),
          const Text(
            'BMI adalah indikator umum, bukan diagnosis. Untuk penilaian '
            'yang lebih tepat, konsultasikan dengan tenaga kesehatan.',
            style: TextStyle(fontSize: 11.5, height: 1.45, color: _Palette.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildScale(double bmi, Gender gender, BmiCategory active) {
    const minV = BmiCalculator.scaleMin;
    const maxV = BmiCalculator.scaleMax;
    final ranges = BmiCalculator.ranges(gender);
    final bounds = BmiCalculator.scaleBounds(gender);
    final pos = (bmi.clamp(minV, maxV) - minV) / (maxV - minV);
    final activeIndex = ranges.indexWhere((r) => r.category == active);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        return SizedBox(
          height: 22,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        flex: ((bounds[i + 1] - bounds[i]) * 100).round(),
                        child: Container(
                          height: 6,
                          color: _categoryColors[ranges[i].category]!
                              .withAlpha(i == activeIndex ? 255 : 100),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Positioned(
                left: (w * pos - 7).clamp(0.0, w - 14).toDouble(),
                top: 4,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: _Palette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: _Palette.ink, width: 2.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13.5, color: _Palette.muted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _Palette.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryRow(BmiRange range, bool isActive) {
    final color = _categoryColors[range.category]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isActive ? color.withAlpha(28) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              range.category.label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: _Palette.ink,
              ),
            ),
          ),
          Text(
            range.rangeText,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? _Palette.ink : _Palette.muted,
            ),
          ),
        ],
      ),
    );
  }

 

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: _Palette.line);

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: _Palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _Palette.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      );
}