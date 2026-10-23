import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../generated/prisma/client.js";
import { readConfig } from "./config.js";

const adapter = new PrismaPg({
  connectionString: readConfig().databaseUrl,
  connectionTimeoutMillis: 5000,
  query_timeout: 5000,
  max: 5,
});
export const prisma = new PrismaClient({ adapter });

export async function checkDatabase() {
  await prisma.$queryRaw`SELECT id, nombre, correo, clave, equipo, "creadoEn" FROM grupo_2.usuarios LIMIT 0`;
}
