module Views.Lobby exposing (..)

import Dict exposing (Dict)
import Game.Participants exposing (Participants)
import Html exposing (Html, button, div, h1, h3, span, text)
import Html.Attributes exposing (class, classList, disabled)
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


lobbyView : PlayingGameModel -> Html Msg
lobbyView model =
    let
        cantStartGame =
            Dict.size model.game.participants.players <= 1

        titleCopy =
            if model.isOwner then
                "Waiting for players to join"

            else
                "Waiting for game to start"
    in
    div [ class "lobby-container" ]
        [ div [ class "invite-to-game" ]
            [ h1 []
                [ text titleCopy ]
            , button [ onClick CopyInviteLink, class "secondary" ] [ text "Copy invite link 🔗" ]
            , div [ class "join-requests-container" ]
                [ h3 []
                    [ text "Players" ]
                , playersList
                    model.game.participants.players
                    model.isOwner
                    model.localUser
                ]
            ]
        , if model.isOwner then
            button [ onClick StartGame, class "start-game", disabled cantStartGame ] [ text "start game" ]

          else
            text ""
        ]
