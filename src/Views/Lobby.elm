module Views.Lobby exposing (..)

import Dict exposing (Dict, isEmpty)
import Game.Participants exposing (Participants, joinRequestsDecoder)
import Html exposing (Html, button, div, h1, h2, h3, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import State exposing (Model, Msg(..))
import User exposing (User)
import State exposing (PlayingGameModel)


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
                        [ ( "space-between", isOwner )
                        , ( "request", True )
                        ]
                    ]
                    [ span [] [ text user.name ]
                    , if isOwner then
                        button [ class "icon-button", onClick (AcceptUser user) ] [ text "✔️" ]

                      else
                        text ""
                    ]
            )
        |> div [ class "participants" ]


requestsView : Participants -> Bool -> Html Msg
requestsView participants isOwner =
    let
        hasNoParticipants =
            Dict.isEmpty participants.joinRequests && Dict.isEmpty participants.players

        cantStartGame =
            Dict.isEmpty participants.players
    in
    if hasNoParticipants then
        h2 [] [ text "Waiting for players to join" ]

    else
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
            , button [ onClick StartGame, classList [ ( "disabled", cantStartGame ), ( "start-game", True ) ] ] [ text "start game" ]
            ]


lobbyView : PlayingGameModel -> Html Msg
lobbyView model =
    let
        titleCopy =
            if model.isOwner then
                "ACCEPT PLAYERS"

            else
                "Waiting for game to start"

        instructions =
            if model.isOwner then
                h3 [] [ text ("Game code: " ++ model.game.gameId) ]
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

        
