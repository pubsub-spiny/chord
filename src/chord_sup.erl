%%%-------------------------------------------------------------------
%% @doc spiny_erl top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(chord_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    Restart = permanent,
    Shutdown = 2000,
    Type = worker,
    VnodeServer = {chord_vnode_sup, {chord_vnode_sup, start_link, []},
              Restart, Shutdown, supervisor, [chord_vnode_sup]},
    VnodeManServer = {chord_vnode_man, {chord_vnode_man, start_link, []},
              Restart, Shutdown, Type, [chord_vnode_man]},
    {ok, {SupFlags, [VnodeServer, VnodeManServer]}}.

%%====================================================================
%% Internal functions
%%====================================================================
