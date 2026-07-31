# Data

Data owns concrete implementations of Domain repository protocols and mapping
between infrastructure representations and Domain values.

Stage 2 contains only unavailable adapters so the production composition root
can be assembled without prematurely introducing URLSession, Keychain, or
SQLite. Later stages replace those adapters with real implementations.
