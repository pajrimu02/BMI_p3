enum Gender {
  male('Laki-laki', 25.0),
  female('Perempuan', 24.0);

  final String label;

  final double normalMax;

  const Gender(this.label, this.normalMax);
}

enum BmiCategory {
  kurus('Kurus', 'Berat badan di bawah rentang sehat.'),
  normal('Normal', 'Berat badan berada pada rentang ideal.'),
  gemuk('Gemuk', 'Berat badan sedikit di atas rentang ideal.'),
  obesitas('Obesitas', 'Disarankan berkonsultasi dengan tenaga kesehatan.');

  final String label;
  final String note;

  const BmiCategory(this.label, this.note);
}

class BmiRange {
  final BmiCategory category;
  final double from;
  final double to;

  const BmiRange(this.category, this.from, this.to);

  String get rangeText {
    if (from == 0) return '< ${to.toStringAsFixed(1)}';
    if (to == double.infinity) return '≥ ${from.toStringAsFixed(1)}';
    return '${from.toStringAsFixed(1)} – ${(to - 0.1).toStringAsFixed(1)}';
  }
}

class BmiResult {
  final double bmi;
  final double tinggiM;

  const BmiResult(this.bmi, this.tinggiM);

  BmiCategory categoryFor(Gender gender) => BmiCalculator.classify(bmi, gender);

  double get idealMinKg => BmiCalculator.normalMin * tinggiM * tinggiM;

  double idealMaxKg(Gender gender) => gender.normalMax * tinggiM * tinggiM;
}

class BmiCalculator {
  BmiCalculator._();

  static const double normalMin = 18.5;
  static const double obesityStart = 27.0;

  static const double minBeratKg = 10;
  static const double maxBeratKg = 500;
  static const double minTinggiCm = 50;
  static const double maxTinggiCm = 250;

  static const double scaleMin = 15.0;
  static const double scaleMax = 35.0;

  static double? parseNumber(String text) =>
      double.tryParse(text.trim().replaceAll(',', '.'));

  static String? validate(double? beratKg, double? tinggiCm) {
    final valid =
        beratKg != null &&
        tinggiCm != null &&
        beratKg >= minBeratKg &&
        beratKg <= maxBeratKg &&
        tinggiCm >= minTinggiCm &&
        tinggiCm <= maxTinggiCm;

    return valid
        ? null
        : 'Masukkan berat (${minBeratKg.toInt()}–${maxBeratKg.toInt()} kg) '
              'dan tinggi (${minTinggiCm.toInt()}–${maxTinggiCm.toInt()} cm) '
              'yang valid.';
  }

  static BmiResult calculate({
    required double beratKg,
    required double tinggiCm,
  }) {
    final tinggiM = tinggiCm / 100;
    return BmiResult(beratKg / (tinggiM * tinggiM), tinggiM);
  }

  static List<BmiRange> ranges(Gender gender) => [
    const BmiRange(BmiCategory.kurus, 0, normalMin),
    BmiRange(BmiCategory.normal, normalMin, gender.normalMax),
    BmiRange(BmiCategory.gemuk, gender.normalMax, obesityStart),
    const BmiRange(BmiCategory.obesitas, obesityStart, double.infinity),
  ];

  static BmiCategory classify(double bmi, Gender gender) =>
      ranges(gender).firstWhere((r) => bmi < r.to).category;

  static List<double> scaleBounds(Gender gender) => [
    scaleMin,
    normalMin,
    gender.normalMax,
    obesityStart,
    scaleMax,
  ];
}
