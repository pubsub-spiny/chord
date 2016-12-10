-module(chord_SUITE).

-compile(export_all).

all() ->
	[cluster_test].

init_per_suite(_Config) ->
    %os:cmd(os:find_executable("epmd")++" -daemon"),
    %{ok, Hostname} = inet:gethostname(),
    %case net_kernel:start([list_to_atom("runner@"++Hostname), shortnames]) of
    %    {ok, _} -> ok;
    %    {error, {already_started, _}} -> ok
    %end,
    %lager:info("node name ~p", [node()]),
    _Config.

end_per_suite(_Config) ->
    application:stop(lager),
    _Config.

cluster_test(_Config) ->
    chord_sup:start_link(),
    chord_vnode_man:start_vnode(),
    A = chord_vnode_man:lookup(<<"key1">>),
    ct:log("A State:~p~n", [A]),
    ok.
    %A = start_node(cluster_test_c),
    %ct:log("A=~p~n", [A]),
    %wait_running(A),
    %timer:sleep(3000),
    %Node = node(),
    %ok = rpc:call(A, chord_app, join, [A]),
    %ct:log("A State:~p~n", [rpc:call(A, chord_app, state, [])]),
    %timer:sleep(3000),
    %N1 = rpc:call(A, chord_app, lookup, [<<"payload">>]),
    %ct:log("N1:~p~n", [N1]),
    %ct_slave:stop(A).



start_node(Name) ->
    CodePath = lists:filter(fun filelib:is_dir/1, code:get_path()),
    %% have the slave nodes monitor the runner node, so they can't outlive it
    NodeConfig = [
            {monitor_master, true},
            {startup_functions, [
                    {code, set_path, [CodePath]}
                    ]}],
    case ct_slave:start(Name, NodeConfig) of
        {ok, Node} ->
            ok = rpc:call(Node, application, load, [cowboy]),
		    rpc:call(Node, application, ensure_all_started, [chord]),
		    Node;
		{error, already_started, Node} ->
            ct_slave:stop(Name),
            start_node(Name);
		{error, Reason, Node} ->
			io:format("error ~p~n", [Reason]),
            ct_slave:stop(Name),
            start_node(Name)
	end.

wait_running(Node) ->
    wait_running(Node, 30000).

wait_running(Node, Timeout) when Timeout < 0 ->
    throw({wait_timeout, Node});

wait_running(Node, Timeout) ->
    case rpc:call(Node, chord_app, is_running, []) of
        true  -> ok;
        false -> timer:sleep(100),
                 wait_running(Node, Timeout - 100)
    end.