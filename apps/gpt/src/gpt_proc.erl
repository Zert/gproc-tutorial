-module(gpt_proc).

-include("log.hrl").

-behaviour(gen_server).

-export([start_link/1]).

-export([
         init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3
        ]).

-record(state, {
          id      :: any()
         }).

%%% API
start_link(Args) ->
    gen_server:start_link(?MODULE, Args, []).

%%% gen_server callbacks

init(Id) ->
    ?DBG("Start process: ~p", [Id]),
    true = gproc:add_local_name(Id),
    {ok, #state{
       id = Id
      }}.

handle_call(Request, _From, State) ->
    Error = {unknown_call, Request},
    {stop, Error, {error, Error}, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({await, Id},
            #state{id = MyId} = State) ->
    gproc:await({n, l, Id}),
    ?DBG("MyId: ~p.~nNewId: ~p.", [MyId, Id]),
    {noreply, State};
handle_info(stop, State) ->
    {stop, normal, State};
handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%% Internal functions
