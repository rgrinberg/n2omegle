# n2omegle

Tiny omegle clone in N2O

## Running

After cloning and cd'ing into this repository:

```
$ rebar get-deps
$ rebar compile
$ erl -name "web@$(hostname)" -pa deps/*/ebin -pa ebin -boot start_sasl -s n2omegle_app start -config sys.config
```

Then open your browser in: `http://localhost:9002`
