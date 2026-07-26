# KeyDB experiments

Experiments will be added one at a time. This directory intentionally contains no implementation yet.

Every experiment must:

- live in its own directory
- be an independent Go module with its own `go.mod`
- avoid shared dependencies or configuration with other experiments
- include `main.go` and a dedicated `README.md`
- document the concept, prerequisites, setup, run command, expected behavior, observations, and cleanup
- use deterministic inputs where practical
- avoid committing credentials, generated data, or local database state

## Planned experiments

| Experiment | Question |
| --- | --- |
| `01-protocol-basics` | What does a simple KeyDB request/response exchange look like from Go? |
| `02-data-structures` | How do structure choice and command complexity affect a domain model? |
| `03-pipelining` | How does pipelining change round trips, throughput, and error handling? |
| `04-optimistic-locking` | How do `WATCH` and retries prevent conflicting updates? |
| `05-streams-consumers` | How do streams, consumer groups, acknowledgements, and recovery behave? |
| `06-persistence-recovery` | What survives controlled crashes under different persistence settings? |
| `07-ttl-eviction` | How do expiration and eviction behave under memory pressure? |
| `08-scan-concurrency` | How does keyspace iteration interact with concurrent workload? |
| `09-active-replica-conflicts` | What happens during partition, conflicting writes, and reconnection? |
| `10-cluster-routing` | How does a client handle slots, redirection, and topology change? |
| `11-acl-tls` | Which access paths succeed or fail under ACL and TLS policies? |
| `12-benchmark-methodology` | Which client or server bottleneck explains observed latency and throughput? |

The exact server setup for an experiment belongs in that experiment's README and must be removable without affecting any other experiment.
