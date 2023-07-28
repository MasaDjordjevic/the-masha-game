module Views.Lobby exposing (..)

import Dict exposing (Dict, isEmpty)
import Game.Participants exposing (Participants, joinRequestsDecoder)
import Html exposing (Html, button, div, h1, h2, h3, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..), PlayingGameModel)
import User exposing (User)


playersList : Dict String User -> Html Msg
playersList users =
    users
        |> Dict.toList
        |> List.map
            (\( _, user ) ->
                div
                    [ class "request" ]
                    [ span [] [ text user.name ]
                    ]
            )
        |> div [ class "participants" ]


requestsList : Dict String User -> Bool -> Html Msg
requestsList users isOwner =
    users
        |> Dict.toList
        |> List.map
            (\( _, user ) ->
                div
                    [ classList
                        [ ( "space-between", True )
                        , ( "request", True )
                        ]
                    ]
                    [ span [] [ text user.name ]
                    , if isOwner then
                        button [ class "icon-button", onClick (AcceptUser user) ] [ text "✔️" ]

                      else
                        text "⏳"
                    ]
            )
        |> div [ class "participants" ]


requestsView : Participants -> Bool -> Html Msg
requestsView participants isOwner =
    let
        cantStartGame =
            Dict.size participants.players <= 1
    in
    div []
        [ div [ class "join-requests-container" ]
            [ h3 []
                [ text "Players" ]
            , playersList
                participants.players
            , requestsList
                participants.joinRequests
                isOwner
            ]
        , if isOwner then
            div []
                [ button [ onClick StartGame, classList [ ( "disabled", cantStartGame ), ( "start-game", True ) ] ] [ text "start game" ]
                ]

          else
            text ""
        ]


lobbyView : PlayingGameModel -> Html Msg
lobbyView model =
    let
        hasNoParticipants =
            Dict.isEmpty model.game.participants.joinRequests && Dict.size model.game.participants.players <= 1

        titleCopy =
            if model.isOwner then
                if hasNoParticipants then
                    "Waiting for players to join"

                else
                    "ACCEPT PLAYERS"

            else
                "Waiting for game to start"

        instructions =
            if model.isOwner then
                div [ class "invite-to-game" ]
                    [ h3 [ class "game-code" ] [ text ("Game code: " ++ model.game.gameId) ]
                    , button [ onClick CopyInviteLink ] [ text "Invite 🔗" ]
                    ]

            else
                text ""
    in
    div [ class "lobby-container" ]
        [ instructions
        , h1 []
            [ text titleCopy ]
        , div []
            [ requestsView model.game.participants model.isOwner
            ]
        ]
