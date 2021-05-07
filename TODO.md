# Users

# Lobby

    * Add loading state when creating/joining game or all buttons

    * Loading state on accepting player, adding word

# Game play

    * Run game by first player, not the owner. It'll remove dependency on owner!!!

    * Improve join game logic

    * Explain when to click on let's play and start the game

    * Organise css

# Code style

    * Add tests for Encoding/Decoding (especially for missing/empty states)

    * Rethink if creating a game shuold be on Elm side at all, atm empty game model is being created on Elm side and the "patched" in the cloud function, might make sense to have it all in the function but could introduce bugs when changing the model as the compiler wouldn't catch it

    * There is "isPlayer" chek on addWord msg, it's better to remove it from the UI completely if a user is not a player
