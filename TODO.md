# Users

# Lobby

    * Add loading state when creating/joining game or all buttons

    * Loading state on accepting player, adding word

    * Change help dialog font

# Game play

    * Run game by first player, not the owner. It'll remove dependency on owner!!!

    * Improve join game logic

    * Explain when to click on let's play and start the game

    * Organize css

    * Save game and username to local state so you can recover. You need to be able to differentiate games that are done or finished a while ago from ones that are "active"

    * Save if visited before or use the above to auto open how to play on the first play

    * Finish game on disconnect

    * Request with the same username exists is not handled by UI

# Code style

    * Add tests for Encoding/Decoding (especially for missing/empty states)

    * Rethink if creating a game should be on Elm side at all, atm empty game model is being created on Elm side and the "patched" in the cloud function, might make sense to have it all in the function but could introduce bugs when changing the model as the compiler wouldn't catch it

    * There is "isPlayer" check on addWord msg, it's better to remove it from the UI completely if a user is not a player
