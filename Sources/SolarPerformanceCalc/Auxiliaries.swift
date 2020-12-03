import BlackBoxModel
import Foundation

/*
let dateString: String = {
  let infoPath = Bundle.main.executablePath!
  let infoAttr = try! FileManager.default.attributesOfItem(atPath: infoPath)
  let infoDate = infoAttr[FileAttributeKey.creationDate] as! Date

  let df = DateFormatter()
  df.dateStyle = .short
  df.timeStyle = .short
  return df.string(from: infoDate)
}()
*/

extension Substring.SubSequence {
  var integerValue: Int? { return Int(self) }
}

extension PerformanceLog {
  var fitness: Double { return (electric.net / layout.solarField) / 1_000 }
}

class Population {

  var individuals = [PerformanceLog]()

  var softMax: [Double] {
    let z = individuals.map { $0.fitness }
    let z_exp = z.map(exp)
    let sum_z_exp = z_exp.reduce(0, +)
    let softmax = z_exp.map { $0 / sum_z_exp }
    return softmax
  }

  init(size: Int) {
    let layouts = generateRandomLayouts(size: size)

    let recorder = PerformanceDataRecorder()

    for layout in layouts {
      Design.layout = layout
      print(layout)
      individuals.append(BlackBoxModel.runModel(with: recorder))
    }
  }

  init(logs: [PerformanceLog]) {
    self.individuals = logs
  }

  init(layouts: [Layout], cache: [PerformanceLog]) {
    let oldLayouts = cache.map { $0.layout }

    let recorder = PerformanceDataRecorder()

    for layout in layouts {
      if let idx = oldLayouts.firstIndex(of: layout) {
        individuals.append(cache[idx])
      } else {       
        Design.layout = layout
        individuals.append(BlackBoxModel.runModel(with: recorder))
      }
    }
  }

  func generateRandomLayouts(size: Int) -> [Layout] {
    var layouts = [Layout]()
    for _ in (0..<size) {
      layouts.append(Layout.random())
    }
    return layouts
  }

  func fittest() -> PerformanceLog {
    individuals.sort(by: { $0.fitness > $1.fitness })
    return individuals[0]
  }
}

class GeneticAlgorithm {

  var oldPopulations = [Population]()
  var currentPopulation: Population
  var populationSize: Int
  var mutationRate: Double
  var numberOfGenerations: Int

  init(parameters: GeneticParameters) {
    self.populationSize = parameters.populationSize
    self.mutationRate = parameters.mutationRate
    self.numberOfGenerations = parameters.numberOfGenerations

    // Generate a single population for the genetic algorithm to evolve
    self.currentPopulation = Population(size: parameters.populationSize)
  }

  // Simulate the evolution of 'n' generations
  func simulateNGenerations() -> PerformanceLog? {
    let halfSize = populationSize / 2
    let fittest = currentPopulation.fittest()

    reportNewGeneration(generation: 0)

    for gen in 1...numberOfGenerations {

      var nextGeneration = [fittest.layout]
      let parentPool = currentPopulation.individuals.prefix(halfSize)

      for _ in 1..<populationSize {

        let parentOne = parentPool.randomElement()!.layout
        let parentTwo = parentPool.randomElement()!.layout

        let layout = Layout.crossover(first: parentOne, second: parentTwo)
        let child = Layout.mutate(layout, mutationRate: mutationRate)
        print(layout)
        nextGeneration.append(child)

      }
      let oldLogs = oldPopulations.flatMap { $0.individuals }
      // Establish new population
      currentPopulation = Population(layouts: nextGeneration, cache: oldLogs)
      oldPopulations.append(currentPopulation)
      reportNewGeneration(generation: gen)
    }

    return currentPopulation.fittest()
  }

  public func scoreBest() -> Double? {
    return currentPopulation.fittest().fitness
  }

  func reportNewGeneration(generation: Int) {
    if let score = scoreBest() {
      print("Generation \(generation): \(score)")
    }
    print(currentPopulation.fittest())

    currentPopulation.individuals.forEach {
      print($0.layout, terminator: "\n")
    }
  }
}

struct GeneticParameters {
  var populationSize: Int
  var numberOfGenerations: Int
  var mutationRate: Double

  init(populationSize: Int, numberOfGenerations: Int, mutationRate: Double) {
    self.populationSize = populationSize
    self.numberOfGenerations = numberOfGenerations
    self.mutationRate = mutationRate
  }
}
