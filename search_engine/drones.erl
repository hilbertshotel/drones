-module(drones).
-export([main/1, drone/3, clerk/5]).


%%%%% CLERK %%%%%
wrapUp({H,M,S}) ->
    {_, {EH,EM,ES}} = calendar:local_time(),
    io:format("start time: ~B:~B:~B end time: ~B:~B:~B\n\n", [H,M,S, EH,EM,ES]),
    erlang:halt().


new_peak(Current, Peak) ->
    case Current + 1 of
        X when X > Peak -> X;
        _ -> Peak
    end.


send_metrics({Current, Peak, Total}, Socket) ->
    Package = io_lib:format("current: ~B peak: ~B total: ~B", [Current, Peak, Total]),
    gen_tcp:send(Socket, Package).


clerk(Current, Peak, Total, Time, [Socket|Sockets]) ->
    Metrics = {Current, Peak, Total},
    send_metrics(Metrics, Socket),
    receive
        on -> clerk(Current+1, new_peak(Current, Peak), Total+1, Time, Sockets ++ [Socket]);
        off ->
            case Current of
                1 -> send_metrics(Metrics, Socket), wrapUp(Time);
                _ -> clerk(Current-1, new_peak(Current, Peak), Total, Time, Sockets ++ [Socket])
            end
    end.


spawn_clerk() ->
    {ok, Socket1} = gen_tcp:connect({127,0,0,1}, 8091, []),
    {ok, Socket2} = gen_tcp:connect({127,0,0,1}, 8092, []),
    {ok, Socket3} = gen_tcp:connect({127,0,0,1}, 8093, []),
    {_, Time} = calendar:local_time(),
    spawn(drones, clerk, [0, 0, 0, Time, [Socket1, Socket2, Socket3]]).


%%%%% DRONE %%%%%
match_file(File, Pattern, F) ->
    case string:find(File, Pattern) of
        nomatch -> ok;
        _ -> io:format("~s\n", [F])
    end.


search([], _, _, _) -> ok;
search([File|Rest], Pattern, Path, Clerk) ->
    F = filename:join(Path, File),
    case filelib:is_dir(F) of
        true -> spawn_drone(Pattern, F, Clerk);
        false -> match_file(File, Pattern, F)
    end,
    search(Rest, Pattern, Path, Clerk).
    

drone(Pattern, Path, Clerk) ->
    {ok, List} = file:list_dir(Path),
    search(List, Pattern, Path, Clerk),
    Clerk ! off.


spawn_drone(Pattern, Path, Clerk) ->
    spawn(drones, drone, [Pattern, Path, Clerk]),
    Clerk ! on.


%%%%% MAIN %%%%%
main([Pattern]) ->
    Clerk = spawn_clerk(),
    spawn_drone(Pattern, "/", Clerk),
    io:format("\nsearching for \x1B[34m`~s`\x1B[0m pattern . . . \n", [Pattern]).


% erlc probe.erl; erl -noshell -run probe main discord
