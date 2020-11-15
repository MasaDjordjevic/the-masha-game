import * as functions from "firebase-functions";
import * as url from "url";

import { createGame, createJoinRequest, findGameById } from "./registration";
import { games, words } from "./db";
// import { database } from "firebase-admin";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

export const addGame = functions.https.onRequest(async (request, response) => {
  console.log("Body", request.body);
  const { username, game } = request.body;
  console.log("username", request.body.username);
  console.log("game", request.body.game);

  if (!username) {
    response.status(400).send("username expected but not found");
  }

  const writeResult = await createGame(username, game);
  console.log(writeResult);
  if (writeResult) {
    response.send({ status: "OK", game: writeResult });
  } else {
    response.status(500).send(`Cannot add game.`);
  }
});

export const joinGame = functions.https.onRequest(async (request, response) => {
  const { username, gameId } = request.body;
  if (!username || !gameId) {
    response.status(400).send("Params should be username and gameId");
  }
  const writeResult = await createJoinRequest(username, gameId);
  if (writeResult) {
    response.send(`Game request added: ${writeResult.key}`);
  } else {
    response.status(500).send(`Cannot add join request.`);
  }
});

export const findGame = functions.https.onRequest(async (request, response) => {
  const { gameId } = url.parse(request.url, true).query;
  if (!gameId) {
    response.status(400).send("gameId parameter expected");
  }

  const writeResult = await findGameById(gameId as string);
  if (writeResult) {
    response.send(writeResult);
  } else {
    response.status(500).send(`Cannot find game.`);
  }
});

export const acceptRequest = functions.https.onRequest(
  async (request, response) => {
    const { user, gameId } = request.body;
    if (!user || !gameId) {
      response.status(400).send("Params should be user and gameId");
    }
    const writeResult = await games.acceptRequest(user, gameId);
    if (writeResult) {
      response.send(`Game request accepted: ${writeResult.key}`);
    } else {
      response.status(500).send(`Cannot accept join request.`);
    }
  }
);

export const updateGame = functions.https.onRequest(
  async (request, response) => {
    const { game } = request.body;
    if (!game) {
      response.status(400).send("game parameter expected");
    }

    const writeResult = await games.update(game);
    if (writeResult) {
      response.send(`Game updated: ${writeResult.key}`);
    } else {
      response.status(500).send(`Cannot update game.`);
    }
  }
);

export const addWord = functions.https.onRequest(async (request, response) => {
  const { gameId, word } = request.body;
  if (!gameId || !word) {
    response.status(400).send("gameId and word parameters expected");
  }

  const writeResult = await words.addWord(gameId, word);
  if (writeResult) {
    response.send(`Word added: ${writeResult.key}`);
  } else {
    response.status(500).send(`Cannot add word.`);
  }
});

export const deleteWord = functions.https.onRequest(
  async (request, response) => {
    const { gameId, wordId } = request.body;
    if (!gameId || !wordId) {
      response.status(400).send("gameId and wordId parameters expected");
    }

    const writeResult = await words.deleteWord(gameId, wordId);
    if (writeResult) {
      response.send(`Word added: ${writeResult.key}`);
    } else {
      response.status(500).send(`Cannot add word.`);
    }
  }
);
