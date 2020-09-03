module Game.Gameplay exposing (..)

import Game.Game exposing (Game)
import User


isRoundEnd : Game -> Bool
isRoundEnd game =
    case game.state.words.current of
        Just _ ->
            Basics.True

        Nothing ->
            List.isEmpty game.state.words.next


canSwitchTimer : Game -> User.User -> Bool
canSwitchTimer game user =
    let
        teamOnTurn =
            game.state.teams.current

        isLocalPlayersTurn =
            case teamOnTurn of
                Just currentTeam ->
                    List.member user currentTeam.players

                Nothing ->
                    False

        isOwner =
            game.creator == user.name
    in
    isOwner || isLocalPlayersTurn


isExplaining : Game -> User.User -> Basics.Bool
isExplaining game user =
    let
        teamOnTurn =
            game.state.teams.current
    in
    case teamOnTurn of
        Just currentTeam ->
            case List.head currentTeam.players of
                Just explainingUser ->
                    explainingUser.id == user.id

                Nothing ->
                    False

        Nothing ->
            False
