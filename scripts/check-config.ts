import { readConfig } from "../src/config.js";

try {
  const config = readConfig();
  const url = new URL(config.databaseUrl);
  const target = url.hostname.includes("oovoswegjrisiqhumkya") || decodeURIComponent(url.username).endsWith(".oovoswegjrisiqhumkya");
  console.log(`Destino: ${url.hostname}:${url.port || "5432"}; esquema: grupo_2; proyecto Supabase esperado: ${target ? "sí" : "no"}`);
  const { checkDatabase, prisma } = await import("../src/prisma.js");
  try {
    await checkDatabase();
    console.log("OK: conexión y columnas de grupo_2.usuarios verificadas");
  } finally {
    await prisma.$disconnect();
  }
} catch {
  console.error("Configuración fallida: revise DATABASE_URL, disponibilidad, credenciales y acceso a grupo_2.usuarios");
  process.exitCode = 1;
}
