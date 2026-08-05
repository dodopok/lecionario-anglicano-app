import 'package:flutter_test/flutter_test.dart';

import 'package:lecionario_anglicano/core/theme/app_colors.dart';
import 'package:lecionario_anglicano/presentation/widgets/design_primitives.dart';

void main() {
  test('maps known liturgical colors without guessing unknown API values', () {
    expect(AppColors.liturgical('verde'), AppColors.liturgicalGreen);
    expect(AppColors.liturgical('WHITE'), AppColors.liturgicalWhite);
    expect(AppColors.liturgical('preto'), AppColors.liturgicalBlack);
    expect(AppColors.liturgical('new-api-color'), AppColors.mutedLight);
  });

  test('uses a neutral visual when the API omits a color', () {
    expect(liturgicalColor(null), AppColors.mutedLight);
    expect(liturgicalColor(''), AppColors.mutedLight);
  });
}
