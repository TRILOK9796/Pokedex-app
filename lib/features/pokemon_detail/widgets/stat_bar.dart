import 'package:flutter/material.dart';

import '../../../core/constants/pokemon_type_colors.dart';
import '../../../data/models/pokemon_detail.dart';

/// Labeled base-stat value and proportional progress bar.
class StatBar extends StatelessWidget {
  const StatBar({required this.stat, required this.color, super.key});

  final PokemonStat stat;
  final Color color;

  static const _labels = {
    'hp': 'HP',
    'attack': 'Attack',
    'defense': 'Defense',
    'special-attack': 'Sp. Atk',
    'special-defense': 'Sp. Def',
    'speed': 'Speed',
  };

  @override
  Widget build(BuildContext context) {
    final fraction = (stat.value / 255).clamp(0.0, 1.0);
    final label = _labels[stat.name] ?? stat.name;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          SizedBox(
            width: 34,
            child: Text(
              '${stat.value}',
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 8,
                backgroundColor: PokemonTypeColors.forType('normal')
                    .withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
