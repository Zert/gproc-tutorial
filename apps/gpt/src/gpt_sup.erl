-module(gpt_sup).

-include("log.hrl").

-behaviour(supervisor).

%% API
-export([
         start_link/0,
         start_worker/1
        ]).

%% Supervisor callbacks
-export([init/1]).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

-define(WORKER_SUP, gpt_worker_sup).
-define(WORKER_MOD, gpt_proc).

start_worker(Args) ->
    supervisor:start_child(?WORKER_SUP, [Args]).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([gpt_worker_start]) ->
    ?DBG("Start supervisor for workers", []),
    Restart = temporary,
    Shutdown = 2000,
    Type = worker,

    Children =
        [
         {gpt_worker, {?WORKER_MOD, start_link, []},
          Restart, Shutdown, Type, [?WORKER_MOD]}
        ],

    Strategy = simple_one_for_one,
    MaxR = 10, MaxT = 10,
    {ok, {{Strategy, MaxR, MaxT}, Children}};

init([]) ->
    ?DBG("Start main supervisor", []),
    Restart = permanent,
    Shutdown = brutal_kill,
    Children =
        [
         {?WORKER_SUP,
          {supervisor, start_link, [{local, ?WORKER_SUP}, ?MODULE, [gpt_worker_start]]},
          Restart, Shutdown, supervisor, [?MODULE]}
        ],
    Strategy = one_for_one,
    MaxR = 5, MaxT = 10,
    {ok, {{Strategy, MaxR, MaxT}, Children}}.

