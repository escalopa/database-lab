# KeyDB

This directory is the study home for [KeyDB](https://docs.keydb.dev/), a multithreaded, Redis-compatible, in-memory database. The course approaches KeyDB as a database system rather than only as a cache or command-line tool: each stage connects observable behavior to architecture, data structures, durability, concurrency, replication, distribution, security, and performance.

## Learning goals

By the end of the course, we should be able to:

- explain where KeyDB fits among in-memory database systems
- use its Redis-compatible protocol and choose appropriate data types
- reason about atomicity, transactions, pipelining, Pub/Sub, streams, and expiration
- compare RDB and AOF persistence and their failure tradeoffs
- explain KeyDB's multithreaded execution and MVCC behavior
- design conventional replication, active-replica, and clustered deployments
- identify consistency, conflict-resolution, failover, and partitioning tradeoffs
- configure authentication, ACLs, TLS, and safer network exposure
- measure throughput, latency, memory use, and tail behavior responsibly
- operate KeyDB from isolated Go experiments without coupling their dependencies

## Course roadmap

The course is sequential. Each milestone should leave behind concise concept notes, one or more exercises, and—when code is useful—an independent Go experiment.

### 1. Orientation and mental model

- What KeyDB is and how it relates to Redis
- In-memory systems, latency, throughput, and durability boundaries
- Server, client, command, keyspace, database, and configuration vocabulary
- RESP and client compatibility

**Outcome:** describe KeyDB's role, major guarantees, and important non-goals.

### 2. Keys, values, and data structures

- Strings, hashes, lists, sets, and sorted sets
- Bitmaps, HyperLogLog, geospatial indexes, and streams
- Key naming, expiration, eviction, and memory-aware modeling
- Choosing structures by access pattern and complexity

**Outcome:** model a small domain with deliberate data-structure choices.

### 3. Commands and client behavior

- Command semantics and error handling
- Connections, timeouts, cancellation, and retry boundaries
- Pipelining versus sequential requests
- Pub/Sub and streams as different messaging models
- Keyspace notifications

**Outcome:** build a Go client experiment that makes protocol and batching behavior visible.

### 4. Atomicity, transactions, and concurrency

- Single-command atomicity
- `MULTI`, `EXEC`, `WATCH`, and optimistic concurrency
- Lua scripting and server-side execution
- Race conditions, idempotency, and retry-safe design
- Limits of transaction semantics

**Outcome:** reproduce and then prevent a lost-update style anomaly.

### 5. Persistence and recovery

- RDB snapshots
- AOF logging and rewrite behavior
- Combined persistence strategies
- Durability windows and performance costs
- Backup, restore, restart, and corruption-aware recovery drills

**Outcome:** explain exactly what data may be lost under chosen persistence settings.

### 6. Caching, expiration, and memory

- Cache-aside and related application patterns
- TTL design and expiration behavior
- Eviction policies and working-set pressure
- Hot keys, large keys, fragmentation, and memory inspection
- KeyDB-specific subkey expiration

**Outcome:** design and observe a bounded cache under pressure.

### 7. Internals: multithreading and MVCC

- KeyDB's multithreaded architecture
- Contention, scheduling, and scaling limits
- MVCC and non-blocking keyspace iteration
- Comparing `KEYS`, `SCAN`, and snapshot-style behavior
- Reading selected source paths to connect documentation to implementation

**Outcome:** form and test a hypothesis about concurrency or scan behavior.

### 8. Replication and high availability

- Conventional primary-replica replication
- Replication lag and asynchronous failure modes
- Active replicas and writable replicas
- Split brain and last-write-wins conflict resolution
- Sentinel and proxy-based failover considerations

**Outcome:** run a failure-and-recovery experiment and document consistency observations.

### 9. Partitioning and cluster mode

- Hash slots and key distribution
- Multi-key operation constraints and hash tags
- Resharding, rebalancing, and failure handling
- Replication inside a sharded topology
- Client behavior during redirection and topology changes

**Outcome:** trace a key from client request to shard and reason about degraded states.

### 10. Security and safe operation

- Network exposure and protected operation
- Authentication and ACL design
- TLS, certificates, and client verification
- Secret handling and configuration hygiene
- Administrative commands, observability, and incident-ready practices

**Outcome:** produce a minimum secure configuration and verify rejected access paths.

### 11. Migration and compatibility

- Redis protocol and client compatibility
- Snapshot-based migration
- Replica-assisted live migration
- KeyDB-specific features that affect rollback
- Validation, cutover, and rollback planning

**Outcome:** write and rehearse a migration checklist with explicit acceptance criteria.

### 12. Performance methodology and capstone

- Workload design and representative datasets
- Throughput, average latency, percentiles, and coordinated omission
- Warm-up, saturation, client bottlenecks, and repeatability
- Comparing configuration changes without misleading conclusions
- Capstone: design, secure, test, and explain a small production-like KeyDB system

**Outcome:** publish a reproducible performance report and an architecture decision record.

## Study loop

For every milestone:

1. Read the linked official material in [`resources/`](resources/README.md).
2. Record the mental model and open questions in [`concepts/`](concepts/README.md).
3. Complete the checks in [`exercises/`](exercises/README.md).
4. Add an isolated Go module under [`experiments/`](experiments/README.md) only when implementation begins.
5. Capture observed behavior, surprises, cleanup, and follow-up questions.

## Progress

| Milestone | Status |
| --- | --- |
| 1. Orientation and mental model | Ready |
| 2. Keys, values, and data structures | Planned |
| 3. Commands and client behavior | Planned |
| 4. Atomicity, transactions, and concurrency | Planned |
| 5. Persistence and recovery | Planned |
| 6. Caching, expiration, and memory | Planned |
| 7. Internals: multithreading and MVCC | Planned |
| 8. Replication and high availability | Planned |
| 9. Partitioning and cluster mode | Planned |
| 10. Security and safe operation | Planned |
| 11. Migration and compatibility | Planned |
| 12. Performance methodology and capstone | Planned |

No KeyDB server, container, Go code, dependency, or Go module is included yet.
