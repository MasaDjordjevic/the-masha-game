import * as functions from "firebase-functions";
import * as url from "url";

import {
  createGame,
  createJoinRequest,
  findGameByGameId,
} from "./registration";
import { games, words } from "./db";
import * as cors from "cors";
// import { database } from "firebase-admin";

// // Start writing Firebase Functions
// // https://firebase.google.com/docs/functions/typescript
//

// const cors = require("cors")({ origin: true });
const corsHandler = cors({ origin: true });

export const helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", { structuredData: true });
  response.send("Hello from Firebase!");
});

const onCorsRequest = (
  handler: (
    req: functions.https.Request,
    resp: functions.Response<any>
  ) => void | Promise<void>
) =>
  functions.https.onRequest(async (request, response) => {
    corsHandler(request, response, async () => {
      return handler(request, response);
    });
  });

export const addGame = onCorsRequest(async (request, response) => {
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

export const joinGame = onCorsRequest(async (request, response) => {
  const { username, gameId } = request.body;
  if (!username || !gameId) {
    response.status(400).send("Params should be username and gameId");
    return;
  }

  const game: Game | null = await findGameByGameId(gameId);
  console.log("joinGame findGame", game);
  if (!game) {
    response.status(404).send("Game not found.");
    return;
  }

  const existingRequest = Object.values(
    game.participants?.joinRequests ?? {}
  ).find((req) => {
    console.log(`req ${req.name}, username: ${username}`);
    return req.name === username;
  });

  if (existingRequest) {
    response.status(201).send({
      status: "Request with the same username already exists",
      user: existingRequest,
    });
    return;
  }

  const existingPlayer = Object.values(game.participants?.players ?? {}).find(
    (player) => {
      console.log(`playername ${player.name}, username: ${username}`);
      return player.name === username;
    }
  );

  if (existingPlayer) {
    response.status(201).send({
      status: "User is already in the game",
      user: existingPlayer,
    });
    return;
  }

  const user = await createJoinRequest(username, game.id);

  if (user) {
    response.status(201).send({
      status: `Game request added.`,
      user: user,
    });
  } else {
    response.status(500).send(`Cannot add join request.`);
  }
});

export const findGame = onCorsRequest(async (request, response) => {
  const { gameId } = url.parse(request.url, true).query;
  if (!gameId) {
    response.status(400).send("gameId parameter expected");
  }

  const writeResult = await findGameByGameId(gameId as string);
  if (writeResult) {
    response.send(writeResult);
  } else {
    response.status(500).send(`Cannot find game.`);
  }
});

export const acceptRequest = onCorsRequest(async (request, response) => {
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
});

export const updateGame = onCorsRequest(async (request, response) => {
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
});

export const addWord = onCorsRequest(async (request, response) => {
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

export const deleteWord = onCorsRequest(async (request, response) => {
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
});
