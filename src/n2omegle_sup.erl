-module(n2omegle_sup).
-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

rules() ->
    cowboy_router:compile(
      [ {'_', [
               {"/n2o/[...]", n2o_dynalo, {dir, "deps/n2o/priv", mime()}},
               {"/ws/[...]", bullet_handler, [{handler, n2o_bullet}]},
               {'_', n2o_cowboy, []}
              ]}
      ]).

mime() -> [{mimetypes,cow_mimetypes,all}].

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    io:format("starting...."),
    {ok, _} = cowboy:start_http(http, 3,
                                [{port, wf:config(n2o, port)}],
                                [{env, [{dispatch, rules()}]}]),
    {ok, { {one_for_one, 5, 10}, []} }.

