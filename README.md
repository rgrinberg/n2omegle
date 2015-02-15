# n2omegle

Tiny omegle clone in N2O

## Running

After cloning and cd'ing into this repository:

If you're using rebar:

```
$ rebar get-deps
$ rebar compile
$ erl -name "web@$(hostname)" -pa deps/*/ebin -pa ebin -boot start_sasl -s n2omegle_app start -config sys.config
```

If you're using mad:

```
$ mad deps compile plan repl
```

Then open your browser in: `http://localhost:9002`
