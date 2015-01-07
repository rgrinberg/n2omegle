-module(omegle).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").

main() -> #dtl{ file="index", app=nitroshell, bindings=[{body, body()}] }.

body() ->
    {ok, Pid} = wf:async("matcher", fun () -> matcher() end),
    [ #span{ id=status, body="Welcome"}, #br{},
      #span{ id=ui, body=ui(seek, Pid) } ].

ui(seek, Pid) ->
    [ #button{ id=seekButton, body="Seek", postback={seek, Pid}} ];
ui(chat, Pid) ->
    [ #textbox{ id=message },
      #button{ id=sendButton, body="Send", postback={chat, Pid}, source=[message]},
      #span{ id=history }
    ].

message_ui(From, Msg) -> #pre{ body=(From ++ ": " ++ Msg) }.
set_status(S) -> wf:update(status, #span{ id=status, body=S}).
append_history(Msg) -> wf:insert_bottom(history, Msg).

event({seek, Pid}) ->
    Pid ! {seek, self()},
    set_status("Seeking..."),
    wf:update(ui, #span{ id=ui });

event({chat, Pid}) ->
    Message = wf:q(message),
    append_history(message_ui("You", Message)),
    Pid ! {direct, {inbox, Message}};

event({inbox, Message}) -> append_history(message_ui("Anonymous", Message));

event({connected, To}) ->
    wf:update(ui, ui(chat, To)),
    set_status("Connected. Say Hi.").

matcher() ->
    {ok, Q} = ebqueue:start_link(),
    _Pid = spawn_link(fun () -> matcherQ(Q) end),
    matcherRcv(Q).

matcherRcv(Q) ->
    receive {seek, Pid} -> ebqueue:in(Pid, Q) end,
    matcherRcv(Q).

matcherQ(Q) ->
    {ok, Pid1} = ebqueue:out(Q),
    {ok, Pid2} = ebqueue:out(Q),
    Pid1 ! {direct, {connected, Pid2}},
    Pid2 ! {direct, {connected, Pid1}},
    matcherQ(Q).
