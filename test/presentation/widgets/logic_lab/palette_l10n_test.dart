import 'package:flutter_test/flutter_test.dart';
import 'package:soilscope/presentation/widgets/logic_lab/function_palette.dart';
import 'package:soilscope/presentation/widgets/logic_lab/input_palette.dart';

/// The palettes keep Finnish as the source copy and switch to English through
/// lookup maps. A function added without an English entry would silently show
/// Finnish to English users, so every definition is checked here.
void main() {
  test('every Logic Lab function has English copy', () {
    for (final category in functionCategories.entries) {
      expect(
        functionCategoryLabel(category.key, false),
        isNot(category.key),
        reason: 'category ${category.key} has no English label',
      );

      for (final function in category.value) {
        expect(
          function.hasEnglishCopy,
          isTrue,
          reason: '${function.operation} has no English copy',
        );
        expect(function.labelFor(false), isNotEmpty);
        expect(function.descriptionFor(false), isNotEmpty);
        expect(
          function.inputsFor(false),
          hasLength(function.inputsFor(true).length),
          reason: '${function.operation} input labels drifted',
        );
      }
    }
  });

  test('every Logic Lab input has English copy', () {
    for (final category in inputCategories.entries) {
      expect(
        inputCategoryLabel(category.key, false),
        isNot(category.key),
        reason: 'category ${category.key} has no English label',
      );

      for (final input in category.value) {
        expect(
          input.hasEnglishCopy,
          isTrue,
          reason: '${input.operation} has no English copy',
        );
        expect(input.labelFor(false), isNotEmpty);
        expect(input.descriptionFor(false), isNotEmpty);
      }
    }
  });

  test('the Finnish locale keeps the source copy', () {
    final function = functionCategories.values.first.first;
    expect(function.labelFor(true), function.label);
    expect(function.descriptionFor(true), function.description);

    final input = inputCategories.values.first.first;
    expect(input.labelFor(true), input.label);
    expect(input.descriptionFor(true), input.description);
  });
}
