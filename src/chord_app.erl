%%%-------------------------------------------------------------------
%% @doc spiny_erl public API
%% @end
%%%-------------------------------------------------------------------

-module(chord_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, join/1, state/0, lookup/1, is_running/0]).

-define(APP, ?MODULE).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
	io:format("Hello~n"),
    SupResult = chord_sup:start_link(),
    io:format("~p~n", [SupResult]),
    io:format("A~n", []),
    wait_for_application(chord_vnode_sup),
    io:format("B~n", []),
    A = chord_vnode_man:start_vnode(),
    B = chord_vnode_man:start_vnode(),
    %C = spiny_erl_vnode_man:start_vnode(),
    io:format("A,B= ~p~p~n", [A,B]),
    SupResult.

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

join(Node) ->
	chord_vnode_man:join(Node).

state() ->
	chord_vnode_man:call_vnode(state).

lookup(Key) ->
	chord_vnode_man:lookup(chord_lib:hash(Key)).


wait_for_application(App) ->
    case is_running(App) of
        true ->
            ok;
        false ->
            timer:sleep(500),
            wait_for_application(App)
    end.

%% @doc Is running?
is_running() ->
	is_running(chord_sup).

is_running(App) ->
	io:format("~p~p~n", [node(), erlang:whereis(App)]),
	case erlang:whereis(App) of
		undefined ->
			false;
		P when is_pid(P) ->
			true
	end.

%%====================================================================
%% Internal functions
%%====================================================================
