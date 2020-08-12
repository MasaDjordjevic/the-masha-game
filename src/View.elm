module View exposing (view)

import Game exposing (Game)
import Html exposing (Html, button, div, h1, h3, img, input, li, span, text, ul)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Player
import State exposing (..)


localUserView : Model -> Html Msg
localUserView model =
    case model.localUser of
        Just user ->
            div []
                [ h3 [] [ text ("Welcome " ++ user.name) ]
                ]

        Maybe.Nothing ->
            div []
                [ input [ type_ "text", placeholder "Enter your name here", value model.nameInput, onInput UpdateNameInput ] []
                , button [ onClick RegisterLocalUser ] [ text "Register" ]
                ]


openGameView : Game -> Html Msg
openGameView game =
    let
        noPlayers =
            game.players
                |> List.filter Player.isOnline
                |> List.length
                |> String.fromInt
    in
    div []
        [ span []
            [ text game.creator
            ]
        , span []
            [ text noPlayers
            ]
        ]


openGamesView : Model -> Html Msg
openGamesView model =
    case model.localUser of
        Just localUser ->
            let
                gamesList =
                    model.openGames
                        |> List.map (\game -> li [] [ text ("Created by: " ++ game.creator) ])
                        |> ul []

                localUserHasGame =
                    model.openGames
                        |> List.any (\game -> game.creator == localUser.name)
            in
            div []
                [ gamesList
                , if localUserHasGame then
                    text ""

                  else
                    button [ onClick AddGame ] [ text "Add Game" ]
                ]

        Nothing ->
            text ""


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "The Masha Game" ]
        , localUserView model
        , openGamesView model
        ]
