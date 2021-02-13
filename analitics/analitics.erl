-module(analitics).
-export([main/0]).

-define(PORT1, 8091).
-define(PORT2, 8092).
-define(PORT3, 8093).

%% SYNCHRONIZE ANALITICS

main() -> 
    spawn(fun() -> start_server(1, ?PORT1) end),
    spawn(fun() -> start_server(2, ?PORT2) end),
    spawn(fun() -> start_server(3, ?PORT3) end).


start_server(Id, Port) ->
    {ok, Socket} = gen_tcp:listen(Port, [{active, false}, list]),
    io:format("[~B]Running analitics on port: ~B\n", [Id, Port]),
    server_loop(Socket).


server_loop(Socket) ->
    {ok, Connection} = gen_tcp:accept(Socket),
    spawn(fun() -> connection_loop(Connection) end),
    server_loop(Socket).


connection_loop(Connection) ->
    case gen_tcp:recv(Connection, 0) of
        {ok, Data} ->
            io:format("~s\n", [Data]),
            connection_loop(Connection);
        _ ->
            gen_tcp:close(Connection)
    end.
