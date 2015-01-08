-module(omegle).
-compile(export_all).
-include_lib("n2o/include/wf.hrl").

%% The main function is the entrance point to your n2o handler
main() -> #dtl{ file="index", app=nitroshell, bindings=[{body, body()}] }.

body() ->
    %% spawn a background process responsible for pairing users
    {ok, Pid} = wf:async("matcher", fun () -> matcher() end),
    [ #span{ id=status, body="Welcome"}, #br{},
      #span{ id=ui, body=ui(seek, Pid) } ].

%% helper functions for constructing the dom
ui(seek, Pid) ->
    [ #button{ id=seekButton, body="Seek", postback={seek, Pid}} ];
ui(chat, Pid) ->
    [ #textbox{ id=message },
      #button{ id=sendButton, body="Send", postback={chat, Pid}, source=[message]},
      #span{ id=history } ].
message_ui(From, Msg) -> #pre{ body=(From ++ ": " ++ Msg) }.
set_status(S)         -> wf:update(status, #span{ id=status, body=S}).
append_history(Msg)   -> wf:insert_bottom(history, Msg).

%% Event handler function called on dom/chat events
event({seek, Pid}) -> %% user starts to seek
    Pid ! {seek, self()},
    set_status("Seeking..."),
    wf:update(ui, #span{ id=ui });

event({chat, Pid}) -> %% user sends chat message
    Message = wf:q(message),
    append_history(message_ui("You", Message)),
    Pid ! {direct, {inbox, Message}};

%% incoming message from user
event({inbox, Message}) -> append_history(message_ui("Anonymous", Message));

%% signal a user that he's been paired up
event({connected, To}) ->
    wf:update(ui, ui(chat, To)),
    set_status("Connected. Say Hi.").

%% Pairing up users has 2 responsibilities, hence another process is needed
matcher() ->
    {ok, Q} = ebqueue:start_link(),
    _Pid = spawn_link(fun () -> matcherQ(Q) end),
    matcherRcv(Q).

%% first responsibility is to add willing users to the queue
matcherRcv(Q) ->
    receive {seek, Pid} -> ebqueue:in(Pid, Q) end,
    matcherRcv(Q).

%% second is to consume the queue 2 items a time and pair up the users
matcherQ(Q) ->
    {ok, Pid1} = ebqueue:out(Q),
    {ok, Pid2} = ebqueue:out(Q),
    Pid1 ! {direct, {connected, Pid2}},
    Pid2 ! {direct, {connected, Pid1}},
    matcherQ(Q).
