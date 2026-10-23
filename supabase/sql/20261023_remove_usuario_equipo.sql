BEGIN;
LOCK TABLE grupo_2.usuarios IN ACCESS EXCLUSIVE MODE;
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'grupo_2' AND table_name = 'usuarios' AND column_name = 'equipo'
  ) THEN
    IF EXISTS (SELECT 1 FROM grupo_2.usuarios WHERE equipo IS NOT NULL) THEN
      RAISE EXCEPTION 'La columna equipo contiene datos; revise antes de eliminarla';
    END IF;
    ALTER TABLE grupo_2.usuarios DROP COLUMN equipo;
  END IF;
END $$;
COMMIT;
