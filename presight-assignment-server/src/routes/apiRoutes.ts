import { Router } from "express";
import { facetsController } from "../controllers/usersController.js";
import { usersController } from "../controllers/usersController.js";
import { validate } from "../middleware/validate.js";
import { facetsQuerySchema, usersListQuerySchema } from "../schemas/usersQuery.js";

export const apiRoutes = Router();

apiRoutes.get("/users", validate({ query: usersListQuerySchema }), usersController.list);
apiRoutes.get("/facets", validate({ query: facetsQuerySchema }), facetsController.list);
