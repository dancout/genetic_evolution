part of 'package:genetic_evolution/genetic_evolution.dart';

/// Used for selecting parents for genetic crossover.
class SelectionService<T> extends Equatable {
  SelectionService({
    required this.numParents,
    bool? canReproduceWithSelf,
    Random? random,
  })  : canReproduceWithSelf = canReproduceWithSelf ?? true,
        random = random ?? Random();

  /// Represents the number of parents for each Entity
  final int numParents;

  /// Whether an entity can reproduce with itself.
  ///
  /// If false, then the entity will be removed from the selection pool after
  /// being selected the first time.
  final bool canReproduceWithSelf;

  /// Used as the internal random number generator.
  final Random random;

  /// Returns a List<Entity> of parents to reproduce based on the input
  /// [population].
  List<Entity<T>> selectParents({
    /// The population to select from.
    required Population<T> population,
  }) {
    final List<Entity<T>> parents = [];
    final entities = List.of(population.entities);

    for (int i = 0; i < numParents; i++) {
      // Select a parent from the pool
      final entity = selectParentFromPool(entities: entities);

      // Add this entity to the list of parents
      parents.add(entity);

      // Check if an entity can reproduce with itself
      if (!canReproduceWithSelf) {
        // Remove this entity from the selction pool.
        entities.remove(entity);
      }
    }

    return parents;
  }

  /// Returns an Entity from the input [entities] based on its probablility of
  /// being chosed.
  @visibleForTesting
  Entity<T> selectParentFromPool({
    required List<Entity<T>> entities,
  }) {
    // Calculate the total Fitness Score among all entities
    final totalFitnessScore = totalEntitiesFitnessScore(entities: entities);

    // Generate a random number to select against.
    double randNumber = random.nextDouble();

    // Cycle through each entity in the selection pool
    for (var entity in entities) {
      // Calculate the normalized probability of this entity
      final normalizedProbability = entity.fitnessScore / totalFitnessScore;
      // Subtract the probability of selecting this entity from the generated
      // random number
      randNumber -= normalizedProbability;
      // Check if we have dropped below zero, indicating this entity has been
      // selected.
      if (randNumber < 0) {
        return entity;
      }
    }

    // Theoretically, this should never be reached.
    throw Exception(
      'Cycled through all available entities and could not select a parent from'
      ' the pool. Consider adding a nonZeroBias to the FitnessService so that '
      'there are no 0 values.',
    );
  }

  /// Returns the total sum of fitness scores among the input [entities].
  @visibleForTesting
  double totalEntitiesFitnessScore({
    required List<Entity> entities,
  }) {
    final totalScores = entities
        .map((e) => e.fitnessScore)
        .reduce((value, element) => value + element);
    if (totalScores == 0.0) {
      throw Exception(
          'All fitness scores within Population were zero. Entities cannot be '
          'compared against one another unless positive fitness scores are '
          'available. Please update nonZeroBias within the FitnessService to a '
          'positive value.');
    }
    return totalScores;
  }

  @override
  List<Object?> get props => [
        numParents,
        canReproduceWithSelf,
        random,
      ];
}
