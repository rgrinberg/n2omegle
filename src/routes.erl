-module(routes).
-include_lib("n2o/include/wf.hrl").
-export([init/2, finish/2]).

finish(State, Ctx) -> {ok, State, Ctx}.
init(State, Ctx) ->
    Path = wf:path(Ctx#cx.req),
    {ok, State, Ctx#cx{path=Path,module=route_prefix(Path)}}.

route_prefix(P) -> route(P).

route(_) -> omegle.     % always return `index` handler for any url.
