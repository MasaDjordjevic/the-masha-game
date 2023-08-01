module Views.Lobby exposing (..)

import Dict exposing (Dict)
import Game.Participants exposing (Participants)
import Html exposing (Html, button, div, h1, h3, span, text)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Player exposing (Player)
import State exposing (LocalUser(..), Msg(..), PlayingGameModel)


isPlayerLocalUser : Player -> LocalUser -> Bool
isPlayerLocalUser player localUser =
    case localUser of
        LocalPlayer localPlayer ->
            localPlayer.id == player.id

        LocalWatcher _ ->
            False


playersList : Dict String Player -> Bool -> LocalUser -> Html Msg
playersList users isOwner localUser =
    users
        |> Dict.toList
        |> List.map
            (\( _, user ) ->
                let
                    canBeKicked =
                        isOwner && not (isPlayerLocalUser user localUser)
                in
                div
                    [ classList
                        [ ( "space-between", canBeKicked )
                        , ( "request", True )
                        ]
                    ]
                    [ span [] [ text user.name ]
                    , if canBeKicked then
                        button [ class "icon-button", onClick (KickPlayer user.id) ] [ text "🚫" ]

                      else
                        text ""
                    ]
            )
        |> div [ class "participants" ]


playersView : Participants -> Bool -> LocalUser -> Html Msg
playersView participants isOwner localUser =
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
                isOwner
                localUser
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
            [ playersView model.game.participants model.isOwner model.localUser
            ]
        ]
