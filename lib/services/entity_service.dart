import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetic_evolution/models/dna.dart';
import 'package:genetic_evolution/models/entity.dart';
import 'package:genetic_evolution/models/gene.dart';
import 'package:genetic_evolution/services/dna_service.dart';
import 'package:genetic_evolution/services/fitness_service.dart';

/// Used to manipulate Entity objects.
class EntityService<T> extends Equatable {
  EntityService({
    required this.dnaService,
    required this.fitnessService,
    required this.geneMutationService,
    required this.trackParents,
    Random? random,
  }) : random = random ?? Random();

  /// Represents the DNAService used internally.
  final DNAService<T> dnaService;

  /// Represents the service used to calculate this entity's fitness core.
  final FitnessService fitnessService;

  /// Represents the service used when mutating genes.
  final GeneMutationService<T> geneMutationService;

  /// Used as the internal random number generator.
  final Random random;

  /// Whether or not to keep track of an Entity's parents from the previous
  /// generation.
  final bool trackParents;

  Future<Entity<T>> randomEntity() async {
    final randomDNA = dnaService.randomDNA();
    return Entity<T>(
      dna: randomDNA,
      fitnessScore: await fitnessService.calculateScore(dna: randomDNA),
    );
  }

  /// Returns an Entity created by randomly crossing over the genes present
  /// within the input [parents].
  Future<Entity<T>> crossOver({
    required List<Entity<T>> parents,
    required int wave,
  }) async {
    // Initialize your list of Genes
    final List<Gene<T>> crossedOverGenes = [];
    // Declare the number of parents
    final numParents = parents.length;

    // Generate a list of random indices between 0 and the number of parents
    final List<int> randIndices = List.generate(
      dnaService.numGenes,
      (_) => random.nextInt(numParents),
    );

    // Populate the crossedOverGenes list with genes from the input parents
    for (int i = 0; i < dnaService.numGenes; i++) {
      final parentalGene = parents[randIndices[i]].dna.genes[i];

      // Potentially mutate this gene
      final potentiallyMutatedGene = geneMutationService.mutateGene(
        gene: parentalGene,
        wave: wave,
      );

      // Add this gene into the list of Crossed Over Genes
      crossedOverGenes.add(
        potentiallyMutatedGene,
      );
    }

    // Declare the new DNA
    final dna = DNA<T>(genes: crossedOverGenes);
    // Declare the fitness score of this new DNA
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    // Return the newly created Entity
    return Entity(
      dna: dna,
      fitnessScore: fitnessScore,
      parents: trackParents ? parents : null,
    );
  }

  @override
  List<Object?> get props => [
        dnaService,
        fitnessService,
        geneMutationService,
        random,
        trackParents,
      ];
}
