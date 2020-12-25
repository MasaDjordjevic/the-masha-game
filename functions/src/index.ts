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
    response
      .status(201)
      .send({ status: "OK", game: writeResult.game, user: writeResult.user });
  } else {
    response.status(500).send(`Cannot add game.`);
  }
});

export const joinGame = functions.https.onRequest(async (request, response) => {
  const { username, gameId } = request.body;
  if (!username || !gameId) {
    response.status(400).send("Params should be username and gameId");
  }

  const game: Game = await findGameById(gameId);
  const existingRequest = Object.values(
    game.participants?.joinRequests ?? {}
  ).find((request) => request.name === username);

  if (existingRequest) {
    response.status(409).send({
      status: "Request with the same username already exists",
      user: existingRequest,
    });
    return;
  }

  const user = await createJoinRequest(username, gameId);

  if (user) {
    response.status(201).send({
      status: `Game request added.`,
      user: user,
    });
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

    games
      .acceptRequest(gameId, user)
      .then(() => {
        response.send(`Game request accepted.`);
      })
      .catch(() => {
        response.status(500).send(`Cannot accept join request.`);
      });
  }
);

export const updateGame = functions.https.onRequest(
  async (request, response) => {
    const { game } = request.body;
    if (!game) {
      response.status(400).send("game parameter expected");
    }

    games
      .update(game)
      .then(() => {
        response.send(`Game updated.`);
      })
      .catch(() => {
        response.status(500).send(`Cannot update game.`);
      });
  }
);

export const addWord = functions.https.onRequest(async (request, response) => {
  const { gameId, word } = request.body;
  if (!gameId || !word) {
    response.status(400).send("gameId and word parameters expected");
  }

  words
    .addWord(gameId, word)
    .then(() => {
      response.status(201).send(`Word added.`);
    })
    .catch(() => {
      response.status(500).send(`Cannot add word.`);
    });
});

export const deleteWord = functions.https.onRequest(
  async (request, response) => {
    const { gameId, wordId } = request.body;
    if (!gameId || !wordId) {
      response.status(400).send("gameId and wordId parameters expected");
    }

    words
      .deleteWord(gameId, wordId)
      .then((res) => {
        console.log("delete res", res);
        response.send(`Word deleted.`);
      })
      .catch(() => {
        response.status(500).send(`Cannot add word.`);
      });
  }
);
