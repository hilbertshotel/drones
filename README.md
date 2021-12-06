```
Drones is a small asynchronous search engine for the terminal.

I wanted something to replace the horrendous Windows search.

Initially it was built in Erlang, but BEAM and Windows Firewall don't get along very well.

The Erlang script takes around 1 minute for a 50GB SDD.

Then I rewrote it in Go. Now it takes around 16 seconds.
```
