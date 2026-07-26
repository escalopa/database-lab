# Milestone 1 exercises: Orientation and mental model

Complete these after reading the [lesson](../concepts/01-orientation-and-mental-model.md). Write answers below each prompt or in a separate study note linked from this file.

No KeyDB installation is required.

## 1. Explain the system

In no more than five sentences:

1. What is KeyDB?
2. Why is "Redis-compatible" more precise than "Redis"?
3. What does keeping the active dataset in memory optimize?
4. What does it not guarantee?
5. Which KeyDB design choices are especially worth testing?

## 2. Trace a request

Trace this operation from Go code to stored state and back:

```text
SET learner:42:milestone 1
```

Name each boundary crossed, the role of RESP, and the form of a successful reply. Then explain what additional facts you would need before claiming that the acknowledged value survives a power failure.

## 3. Encode RESP by hand

Encode the following command as a RESP array of bulk strings:

```text
GET learner:42:milestone
```

Then write three possible response shapes:

- the key contains the string `1`
- the key does not exist
- the command fails with an error

Do not worry about inventing a realistic error message; the RESP type and framing are the point.

## 4. Separate the mechanisms

For each scenario, choose the primary mechanism: persistence, replication, backup, clustering, or none. Explain why the other choices are insufficient.

1. Recover a value deleted yesterday but noticed today.
2. Continue serving after one process crashes.
3. Use more nodes because the dataset or workload exceeds one node.
4. Recover recent acknowledged writes after a clean restart.
5. Guarantee that two concurrent clients never overwrite each other's logical updates.

At least one answer should be `none`: name the missing application or concurrency mechanism.

## 5. Compatibility review

An application currently uses a Redis client, Lua scripts, Sentinel, RDB backups, and a few administrative commands. A teammate says migration requires only changing the hostname.

Create a validation checklist covering:

- connectivity and authentication
- command and script semantics
- configuration
- persistence compatibility
- failover behavior
- observability and administrative tooling
- rollback after adopting KeyDB-specific features

For each item, label whether documentation review, a test environment, or a failure drill provides the strongest evidence.

## 6. Property tradeoffs

For each change below, predict its most likely effect on latency, throughput, durability, availability, and consistency. Use `improves`, `worsens`, `unchanged`, or `depends`, followed by one sentence of reasoning.

1. Batch independent commands with pipelining.
2. Acknowledge writes only after stricter AOF flushing.
3. Add an asynchronous replica.
4. Partition the keyspace across a cluster.
5. Serve writes from two active replicas during a network partition.

These are predictions, not final answers. Later experiments should challenge them.

## 7. Source orientation

Visit the [KeyDB source repository](https://github.com/Snapchat/KeyDB) and record:

- the default branch and the exact commit inspected
- the primary implementation language
- where server source code appears to live
- where configuration examples or defaults appear to live
- one file or symbol you expect to revisit for multithreading or MVCC

Do not attempt a full source-code analysis yet.

## Exit ticket

Answer from memory:

1. Why can low latency and weak durability coexist?
2. Why is a replica not automatically a backup?
3. Why does protocol compatibility not prove operational compatibility?
4. Which boundary uses RESP, and which cluster communication does not?
5. What is the first claim you want to test when we install KeyDB?

When these answers are clear and the exercises are recorded, change the milestone status in [`keydb/README.md`](../README.md) from **In progress** to **Complete**.
