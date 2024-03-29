import * as admin from "firebase-admin";
import { GAMES_PATH, USERS_PATH } from "./constants";

admin.initializeApp();

const database = admin.database();

export const users = {
  add: (username: string) =>
    database
      .ref(USERS_PATH)
      .push({ name: username })
      .once("value")
      .then((snapshot) => {
        return { ...snapshot.val(), id: snapshot.key };
      }),
  get: (username: string) =>
    database
      .ref(USERS_PATH)
      .orderByChild("name")
      .equalTo(username)
      .once("value"),
  ref: database.ref(USERS_PATH),
};

export const words = {
  addWord: (id: string, word: Word) =>
    database.ref(`${GAMES_PATH}/${id}/state/words/next/${word.id}`).set(word),
  deleteWord: (id: string, wordId: string) =>
    database.ref(`${GAMES_PATH}/${id}/state/words/next/${wordId}`).remove(),
};

export const games = {
  add: (game: any) =>
    database
      .ref(GAMES_PATH)
      .push(game)
      .once("value")
      .then((snapshot) => {
        return { ...snapshot.val(), id: snapshot.key };
      }),
  getById: (gameId: string) =>
    database.ref(`${GAMES_PATH}/${gameId}`).once("value"),
  getByGameId: (gameId: string) =>
    database
      .ref(GAMES_PATH)
      .orderByChild("gameId")
      .equalTo(gameId)
      .once("value"),
  addPlayer: (id: string, player: Player) =>
    database
      .ref(`${GAMES_PATH}/${id}/participants/players/${player.id}`)
      .set(player),
  kickPlayer: (gameId: string, userId: string) =>
    database
      .ref(`${GAMES_PATH}/${gameId}/participants/players/${userId}`)
      .remove(),
  update: (game: any) => database.ref(`${GAMES_PATH}/${game.id}`).set(game),
  ref: database.ref(GAMES_PATH),
  gameRef: (id: string) => database.ref(`${GAMES_PATH}/${id}`),
};
