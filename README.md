# Database Lab

Database Lab is a hands-on learning workspace for exploring database systems, their internal architecture, core concepts, experiments, and practical exercises.

Database systems will be added and studied one at a time. Each database will eventually have its own directory so its notes, concepts, experiments, exercises, and resources remain focused and easy to navigate.

Studies may cover:

- architecture and internal design
- storage engines and data layout
- indexing
- transactions and concurrency
- querying
- replication and distribution
- performance
- security
- experiments and practical exercises

Go will be the primary language for examples and experiments. Every experiment will be isolated as an independent Go module with its own `go.mod`, dependencies, configuration, and commands. There is intentionally no root-level Go module.

An individual experiment will generally document the concept being explored, prerequisites and setup, how to run it, expected behavior and observations, and cleanup instructions.

## Planned structure

Database directories are not included yet. As systems are introduced, the repository will grow toward a structure such as:

```text
database-lab/
├── README.md
└── <database-name>/
    ├── README.md
    ├── concepts/
    ├── experiments/
    ├── exercises/
    └── resources/
```

Within a database's `experiments` directory, each experiment will be a separate Go module:

```text
<database-name>/
└── experiments/
    ├── <experiment-one>/
    │   ├── go.mod
    │   ├── main.go
    │   └── README.md
    └── <experiment-two>/
        ├── go.mod
        ├── main.go
        └── README.md
```

The repository is intentionally minimal at the beginning. Database-specific content, application code, dependencies, modules, containers, and configuration will be introduced only through focused study.
