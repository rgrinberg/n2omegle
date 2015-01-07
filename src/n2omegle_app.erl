-module(n2omegle_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    application:ensure_all_started(n2omegle),
    application:set_env(n2o, route, routes),
    application:start(n2omegle).

start(_StartType, _StartArgs) ->
    n2omegle_sup:start_link().

stop(_State) ->
    ok.
