import 'package:flutter/material.dart';

import '../../../core/constants/pokemon_type_colors.dart';
import '../../../core/utils/string_extensions.dart';

/// Compact badge using the color assigned to a Pokémon type.
class TypeChip extends StatelessWidget {
  const TypeChip({required this.type, super.key});

  final String type;

  @override
  Widget build(BuildContext context) {
    final color = PokemonTypeColors.forType(type);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        child: Text(
          type.titleWords,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
