struct WantedDataset: Equatable, Sendable {
    let language: LanguageCode
    let domain: DatasetDomain
}

struct SynchronizeDatasetsInput: Equatable, Sendable {
    let wanted: [WantedDataset]
}

struct SynchronizeDatasetsUseCase: Sendable {
    private let catalogRepository: any DatasetCatalogRepository
    private let installedRepository: any InstalledDatasetRepository
    private let planner: DatasetSyncPlanner

    init(
        catalogRepository: any DatasetCatalogRepository,
        installedRepository: any InstalledDatasetRepository,
        planner: DatasetSyncPlanner = DatasetSyncPlanner()
    ) {
        self.catalogRepository = catalogRepository
        self.installedRepository = installedRepository
        self.planner = planner
    }

    func callAsFunction(
        _ input: SynchronizeDatasetsInput
    ) async throws -> DatasetSyncPlan {
        let installed = try await installedRepository.datasets()
        let catalog = try await catalogRepository.catalog()
        let availability = try await catalogRepository.availability(
            installed: installed,
            wanted: input.wanted
        )

        let plan = planner.makePlan(
            catalog: catalog,
            installed: installed,
            wanted: input.wanted,
            availability: availability
        )

        try await installedRepository.apply(plan)
        return plan
    }
}
