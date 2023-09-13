import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  final DNA mockDNA = MockDNA();
  const fitnessScore = 100.0;
  const crossoverFitnessScore = 200.0;
  const trackParents = false;
  const wave = 1;

  // A list meant to represent a random selection of the index corresponding to
  // 1 of 4 parents.
  const List<int> parentIndices = [
    1,
    3,
    0,
    2,
    1,
    3,
    1,
    0,
    2,
    3,
  ];
  final numGenes = parentIndices.length;

  late DNAService mockDnaService;
  late FitnessService mockFitnessService;
  late GeneMutationService mockGeneMutationService;
  late CrossoverService mockCrossoverService;

  late EntityService testObject;

  final parent0 = Entity(
    dna: DNA(
        genes: List.generate(
      numGenes,
      (index) => Gene(value: index),
    )),
    fitnessScore: fitnessScore,
  );

  final parent1 = Entity(
    dna: DNA(
        genes: List.generate(
      numGenes,
      (index) => Gene(value: 10 + index),
    )),
    fitnessScore: fitnessScore,
  );

  final parent2 = Entity(
    dna: DNA(
        genes: List.generate(
      numGenes,
      (index) => Gene(value: 20 + index),
    )),
    fitnessScore: fitnessScore,
  );

  final parent3 = Entity(
    dna: DNA(
        genes: List.generate(
      numGenes,
      (index) => Gene(value: 30 + index),
    )),
    fitnessScore: fitnessScore,
  );
  final List<Entity> parents = [
    parent0,
    parent1,
    parent2,
    parent3,
  ];

  // Generate the list of genes based on the index of the parent
  final List<Gene> crossoverGenes = List.generate(
    numGenes,
    (index) {
      final parentIndex = parentIndices[index];
      return parents[parentIndex].dna.genes[index];
    },
  );

  final crossoverDna = DNA(genes: crossoverGenes);

  setUp(() async {
    mockDnaService = MockDNAService();
    mockFitnessService = MockFitnessService();

    mockCrossoverService = MockCrossoverService();
    testObject = EntityService(
      trackParents: trackParents,
      dnaService: mockDnaService,
      fitnessService: mockFitnessService,
      geneMutationService: MockGeneMutationService(),
      crossoverService: mockCrossoverService,
    );

    when(() => mockCrossoverService.crossover(parents: parents, wave: wave))
        .thenAnswer((invocation) async => crossoverGenes);

    when(() => mockFitnessService.calculateScore(dna: crossoverDna))
        .thenAnswer((_) async => crossoverFitnessScore);
  });

  group('randomEntity', () {
    test(
        'calls proper services to create a random DNA object and score its fitness',
        () async {
      when(() => mockDnaService.randomDNA()).thenReturn(mockDNA);
      when(() => mockFitnessService.calculateScore(dna: mockDNA))
          .thenAnswer((_) async => fitnessScore);
      final expected = Entity(dna: mockDNA, fitnessScore: fitnessScore);
      final actual = await testObject.randomEntity();

      expect(actual, expected);

      verify(() => mockDnaService.randomDNA());
      verify(() => mockFitnessService.calculateScore(dna: mockDNA));
    });
  });

  group('crossOver', () {
    test(
        'will create an Entity with randomly crossed over genes from the parents'
        'without tracking parents when trackParents is false', () async {
      final expected = Entity(
        dna: crossoverDna,
        fitnessScore: crossoverFitnessScore,
        parents: null,
      );

      final actual = await testObject.crossOver(
        parents: parents,
        wave: wave,
      );
      expect(actual, expected);

      verify(() => mockFitnessService.calculateScore(dna: crossoverDna));
      verify(
          () => mockCrossoverService.crossover(parents: parents, wave: wave));
    });

    test(
        'will create an Entity with randomly crossed over genes from the parents'
        'while tracking parents when trackParents is true', () async {
      final expected = Entity(
        dna: crossoverDna,
        fitnessScore: crossoverFitnessScore,
        parents: parents,
      );

      testObject = EntityService(
        trackParents: true,
        dnaService: mockDnaService,
        fitnessService: mockFitnessService,
        geneMutationService: MockGeneMutationService(),
        crossoverService: mockCrossoverService,
      );

      final actual = await testObject.crossOver(
        parents: parents,
        wave: wave,
      );
      expect(actual, expected);

      verify(() => mockFitnessService.calculateScore(dna: crossoverDna));
      verify(
          () => mockCrossoverService.crossover(parents: parents, wave: wave));
    });
  });
}
