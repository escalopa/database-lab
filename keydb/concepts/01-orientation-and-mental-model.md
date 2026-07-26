# Milestone 1: Orientation and mental model

This lesson builds the vocabulary and system model needed for every later KeyDB experiment. It deliberately avoids installation: first understand what the system claims to be, where its boundaries are, and which questions require evidence.

## Learning objectives

After this lesson, you should be able to:

- describe KeyDB without calling it merely "Redis but faster"
- trace a normal command from a client to a reply
- separate client/server protocol, in-memory state, persistence, replication, and clustering
- explain compatibility as a useful claim with explicit limits
- distinguish latency, throughput, durability, availability, and consistency
- identify which KeyDB-specific mechanisms deserve later experiments

## 1. What KeyDB is

KeyDB is an open-source, in-memory database derived from Redis. Its public interface is intentionally compatible with the Redis API and RESP protocol, while its implementation and feature set diverge in important places.

The shortest useful description is:

> KeyDB is a Redis-compatible, primarily in-memory database that emphasizes vertical scaling through multithreading and adds mechanisms such as MVCC, active replicas, and subkey expiration.

Each part matters:

- **Redis-compatible** describes an interoperability goal, not identical internals or permanent feature parity.
- **Primarily in-memory** explains the low-latency access path, but does not mean disk is irrelevant.
- **Database** means the system owns data structures, command semantics, concurrency rules, persistence, replication, and operational state.
- **Multithreading** is an architectural choice intended to use more CPU cores per server process.
- **MVCC and active replicas** introduce behavior that must be studied on its own terms rather than inferred from Redis.

KeyDB began as a multithreaded fork of Redis in 2019 and is maintained as an open-source project under Snap. That history explains both its familiar surface and its different architectural priorities.

## 2. A first system map

```text
Go application
    |
    | Redis-compatible client API
    v
client library
    |
    | RESP over TCP or a Unix socket
    v
KeyDB server process
    |
    +-- command parsing and execution
    +-- in-memory keyspace and data structures
    +-- expiration and eviction
    +-- persistence: RDB and/or AOF
    +-- replication and failover roles
    +-- cluster membership and shard routing
```

This is a boundary map, not a complete internal architecture. It prevents several early mistakes:

- a client library is not the database
- RESP is not a storage format
- persistence is not replication
- replication is not a backup
- clustering is not required for a single KeyDB node to use multiple cores
- an in-memory primary access path does not imply guaranteed durability

## 3. The normal command path

For a regular request:

1. A client opens a TCP connection, conventionally to port `6379`, or uses a Unix socket.
2. The client encodes a command as a RESP array of bulk strings.
3. KeyDB parses and executes the command against its keyspace.
4. KeyDB returns a command-specific RESP value.
5. The client library maps that value into Go values or an error.

For example, the conceptual request:

```text
SET course:keydb started
```

is represented as three bulk-string arguments inside a RESP array:

```text
*3\r\n
$3\r\nSET\r\n
$12\r\ncourse:keydb\r\n
$7\r\nstarted\r\n
```

A successful response is the RESP simple string:

```text
+OK\r\n
```

RESP is binary-safe because bulk strings carry an explicit byte length. Replies may be simple strings, errors, integers, bulk strings, arrays, or null representations.

Two important variations appear later:

- **Pipelining:** the client sends multiple commands before waiting for their replies.
- **Pub/Sub:** after subscribing, the server can push messages without a matching request for every message.

KeyDB Cluster uses a separate node-to-node binary protocol. Client/server RESP and cluster-internal communication are different boundaries.

## 4. Where the data lives

The active dataset is normally served from memory. This makes memory capacity, allocation overhead, eviction, and key design central concerns.

Disk persistence is optional and configurable:

- **RDB** records point-in-time snapshots.
- **AOF** records operations in an append-only log.

Neither mechanism means every acknowledged write is automatically durable. The exact loss window depends on configuration, operating-system behavior, and the failure being considered. We will test these claims in the persistence milestone.

Replication maintains copies on other running nodes. It improves availability and can support read or write topologies, but it can also copy mistakes and is generally asynchronous. Backups serve a different recovery purpose.

## 5. Compatibility: what it does and does not mean

The official documentation describes KeyDB as compatible with the Redis API and protocol, allowing Redis client libraries to communicate with it.

Treat that as a hypothesis with four layers:

1. **Wire compatibility:** the client and server can exchange RESP messages.
2. **Command compatibility:** expected commands exist with compatible syntax.
3. **Semantic compatibility:** edge cases, errors, atomicity, and timing behave as expected.
4. **Operational compatibility:** configuration, persistence files, failover tooling, monitoring, and upgrades behave acceptably.

A "drop-in replacement" claim is strongest at the first layer and must be validated for the exact application at the later layers.

KeyDB-specific capabilities also create a return-path constraint. A workload that uses active replicas, subkey expiration, FLASH storage, or KeyDB-only commands cannot assume a symmetric move back to Redis.

## 6. Five properties that must not be conflated

### Latency

Time taken for one operation, ideally studied as a distribution rather than an average.

### Throughput

Operations completed per unit of time. Higher throughput can coexist with worse tail latency.

### Durability

Whether an acknowledged write survives a specified failure.

### Availability

Whether the system can serve acceptable requests during failures or maintenance.

### Consistency

What values clients are allowed to observe, especially across concurrent operations, replicas, partitions, and failover.

Architecture choices trade among these properties. "Fast" alone says almost nothing about durability, availability, or consistency.

## 7. KeyDB-specific questions for later milestones

The course will not accept marketing claims as experimental conclusions. It will test:

- how throughput changes with worker-thread count and client concurrency
- whether long-running scans interfere with concurrent operations and how MVCC changes that behavior
- which writes can be lost under each persistence policy
- how replication lag appears to clients
- how active replicas resolve conflicting writes after a partition
- what cluster redirection and topology changes look like to a Go client
- where client-side bottlenecks distort server benchmarks

## 8. Vocabulary checkpoint

| Term | Working definition |
| --- | --- |
| keyspace | The logical collection of keys and their values in a database |
| command | A named operation with arguments and a defined reply |
| RESP | The client/server serialization and request-response protocol |
| client library | Code that manages connections, RESP, errors, and higher-level APIs |
| expiration | Removal of data after a configured lifetime |
| eviction | Removal chosen under a memory policy, usually because of pressure |
| RDB | Point-in-time snapshot persistence |
| AOF | Append-only operation-log persistence |
| replica | A node receiving changes from another node |
| active replica | A KeyDB replica configuration that can accept writes |
| cluster | A topology that partitions a keyspace across nodes |
| MVCC | Versioning used to let operations observe suitable data versions without all readers blocking writers |

These definitions are intentionally provisional. Later lessons will replace short definitions with mechanisms, guarantees, and observed behavior.

## Required reading

1. [About KeyDB](https://docs.keydb.dev/docs/about/)
2. [Compatibility](https://docs.keydb.dev/docs/compatibility/)
3. [Protocol specification](https://docs.keydb.dev/docs/protocol/)
4. [KeyDB source repository](https://github.com/Snapchat/KeyDB)

## Milestone completion criteria

Milestone 1 is complete when you can:

- draw the system map from memory
- explain the normal command path
- explain why persistence, replication, and backup are different
- give one limit of the "drop-in replacement" description
- predict which of latency, throughput, durability, availability, or consistency a proposed change may affect
- complete the linked exercises without copying sentences from this note

Continue with [the milestone exercises](../exercises/01-orientation-and-mental-model.md).
