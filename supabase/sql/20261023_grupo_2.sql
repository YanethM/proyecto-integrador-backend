BEGIN;

CREATE SCHEMA IF NOT EXISTS saga_up;

CREATE OR REPLACE FUNCTION saga_up.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS saga_up.document_types (
  document_type_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.sexes (
  sex_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.child_statuses (
  child_status_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.legal_statuses (
  legal_status_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.guardianship_types (
  guardianship_type_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.contract_types (
  contract_type_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.staff_statuses (
  staff_status_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.staff_roles (
  staff_role_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.payment_methods (
  payment_method_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.tuition_statuses (
  tuition_status_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.staff (
  staff_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name text NOT NULL,
  document_type_id bigint REFERENCES saga_up.document_types(document_type_id) ON DELETE SET NULL,
  document_number text,
  staff_role_id bigint REFERENCES saga_up.staff_roles(staff_role_id) ON DELETE SET NULL,
  hire_date date,
  exit_date date,
  contract_type_id bigint REFERENCES saga_up.contract_types(contract_type_id) ON DELETE SET NULL,
  staff_status_id bigint REFERENCES saga_up.staff_statuses(staff_status_id) ON DELETE SET NULL,
  phone text,
  email text,
  hours_worked numeric(7,2) CHECK (hours_worked >= 0),
  hours_payed numeric(7,2) CHECK (hours_payed >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint,
  CONSTRAINT staff_document_uniq UNIQUE (document_type_id, document_number)
);

CREATE TABLE IF NOT EXISTS saga_up.guardians (
  guardian_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name text NOT NULL,
  document_type_id bigint REFERENCES saga_up.document_types(document_type_id) ON DELETE SET NULL,
  document_number text,
  phone text,
  address text,
  legal_status_id bigint REFERENCES saga_up.legal_statuses(legal_status_id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint,
  CONSTRAINT guardians_document_uniq UNIQUE (document_type_id, document_number)
);

CREATE TABLE IF NOT EXISTS saga_up.children (
  child_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  first_name text NOT NULL,
  last_name text NOT NULL,
  birth_date date,
  sex_id bigint REFERENCES saga_up.sexes(sex_id) ON DELETE SET NULL,
  document_type_id bigint REFERENCES saga_up.document_types(document_type_id) ON DELETE SET NULL,
  document_number text,
  admission_date date,
  exit_date date,
  child_status_id bigint REFERENCES saga_up.child_statuses(child_status_id) ON DELETE SET NULL,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.children_guardians (
  child_guardian_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  child_id bigint REFERENCES saga_up.children(child_id) ON DELETE SET NULL,
  guardian_id bigint REFERENCES saga_up.guardians(guardian_id) ON DELETE SET NULL,
  guardianship_type_id bigint REFERENCES saga_up.guardianship_types(guardianship_type_id) ON DELETE SET NULL,
  start_date date,
  end_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint,
  CONSTRAINT children_guardians_dates_chk CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS saga_up.child_records (
  record_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  child_id bigint REFERENCES saga_up.children(child_id) ON DELETE SET NULL,
  recorded_by bigint REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL,
  eps text,
  state text,
  ips_assigned text,
  allergies text,
  meal_restrictions text,
  medicines text,
  special_conditions text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.child_internal_description (
  child_internal_description_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  child_id bigint REFERENCES saga_up.children(child_id) ON DELETE SET NULL,
  communication_ways text,
  daily_routine_help text,
  likings text,
  crisis_management text,
  previous_institution text,
  grade text,
  therapies text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.staff_assistance (
  staff_assistance_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  staff_id bigint REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL,
  date_working date,
  time_in numeric(5,2),
  time_out numeric(5,2),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.professionals (
  professional_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  staff_id bigint REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL,
  titles text,
  institutions text,
  observations text,
  time_donor boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.interns (
  intern_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  staff_id bigint REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL,
  university text,
  career text,
  foundation_role text,
  duration_months smallint CHECK (duration_months > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.audit_logs (
  log_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  staff_id bigint REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL,
  table_name text NOT NULL,
  record_id bigint,
  action text NOT NULL,
  logged_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.workshops (
  workshop_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name text NOT NULL,
  duration_minutes integer CHECK (duration_minutes > 0),
  description text,
  workshop_supplies text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

CREATE TABLE IF NOT EXISTS saga_up.professionals_workshops (
  professional_workshop_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  professional_id bigint REFERENCES saga_up.professionals(professional_id) ON DELETE SET NULL,
  workshop_id bigint REFERENCES saga_up.workshops(workshop_id) ON DELETE SET NULL,
  day_week text CHECK (day_week IN ('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado','Domingo')),
  ends_on date,
  time_starts time,
  time_ends time,
  observations text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint,
  CONSTRAINT professionals_workshops_time_chk CHECK (time_ends IS NULL OR time_starts IS NULL OR time_ends > time_starts)
);

CREATE TABLE IF NOT EXISTS saga_up.children_assistance (
  children_assistance_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  child_id bigint REFERENCES saga_up.children(child_id) ON DELETE SET NULL,
  professional_workshop_id bigint REFERENCES saga_up.professionals_workshops(professional_workshop_id) ON DELETE SET NULL,
  will_assist boolean,
  attended boolean,
  complete_workshop boolean,
  behavior text,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint,
  CONSTRAINT children_assistance_uniq UNIQUE (child_id, professional_workshop_id)
);

CREATE TABLE IF NOT EXISTS saga_up.tuition (
  tuition_fee_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  child_id bigint REFERENCES saga_up.children(child_id) ON DELETE SET NULL,
  amount bigint CHECK (amount >= 0),
  paid_date date,
  payment_method_id bigint REFERENCES saga_up.payment_methods(payment_method_id) ON DELETE SET NULL,
  tuition_status_id bigint REFERENCES saga_up.tuition_statuses(tuition_status_id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  created_by bigint,
  updated_at timestamptz NOT NULL DEFAULT now(),
  updated_by bigint
);

DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'document_types','sexes','child_statuses','legal_statuses','guardianship_types',
    'contract_types','staff_statuses','staff_roles','payment_methods','tuition_statuses',
    'staff','guardians','children','children_guardians','child_records',
    'child_internal_description','staff_assistance','professionals','interns',
    'audit_logs','workshops','professionals_workshops','children_assistance','tuition'
  ]
  LOOP
    BEGIN
      EXECUTE format(
        'ALTER TABLE saga_up.%I ADD CONSTRAINT %I FOREIGN KEY (created_by) REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL',
        t, t || '_created_by_fkey');
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
    BEGIN
      EXECUTE format(
        'ALTER TABLE saga_up.%I ADD CONSTRAINT %I FOREIGN KEY (updated_by) REFERENCES saga_up.staff(staff_id) ON DELETE SET NULL',
        t, t || '_updated_by_fkey');
    EXCEPTION WHEN duplicate_object THEN NULL;
    END;
  END LOOP;
END $$;

DO $$
DECLARE
  t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'document_types','sexes','child_statuses','legal_statuses','guardianship_types',
    'contract_types','staff_statuses','staff_roles','payment_methods','tuition_statuses',
    'staff','guardians','children','children_guardians','child_records',
    'child_internal_description','staff_assistance','professionals','interns',
    'audit_logs','workshops','professionals_workshops','children_assistance','tuition'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%s_updated_at ON saga_up.%I', t, t);
    EXECUTE format(
      'CREATE TRIGGER trg_%s_updated_at BEFORE UPDATE ON saga_up.%I FOR EACH ROW EXECUTE FUNCTION saga_up.set_updated_at()',
      t, t);
    EXECUTE format('ALTER TABLE saga_up.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;
INSERT INTO saga_up.sexes (code, name) VALUES
  ('M', 'Masculino'),
  ('F', 'Femenino')
ON CONFLICT (code) DO NOTHING;
INSERT INTO saga_up.document_types (code, name) VALUES
  ('CC', 'Cédula de ciudadanía'),
  ('TI', 'Tarjeta de identidad'),
  ('RC', 'Registro civil'),
  ('CE', 'Cédula de extranjería'),
  ('PA', 'Pasaporte')
ON CONFLICT (code) DO NOTHING;
CREATE SCHEMA IF NOT EXISTS grupo_2;
CREATE TABLE IF NOT EXISTS grupo_2.usuarios (
  id integer GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  nombre text NOT NULL CHECK (length(trim(nombre)) > 0),
  correo text NOT NULL UNIQUE CHECK (correo = lower(trim(correo)) AND length(correo) > 0),
  clave text NOT NULL,
  equipo integer CHECK (equipo BETWEEN 1 AND 5),
  "creadoEn" timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP
);
ALTER TABLE grupo_2.usuarios ENABLE ROW LEVEL SECURITY;
ALTER FUNCTION saga_up.set_updated_at() SET search_path = pg_catalog;
REVOKE ALL ON SCHEMA saga_up, grupo_2 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL TABLES IN SCHEMA saga_up, grupo_2 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA saga_up, grupo_2 FROM PUBLIC, anon, authenticated;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA saga_up, grupo_2 FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA saga_up, grupo_2 REVOKE ALL ON TABLES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA saga_up, grupo_2 REVOKE ALL ON SEQUENCES FROM PUBLIC, anon, authenticated;
ALTER DEFAULT PRIVILEGES IN SCHEMA saga_up, grupo_2 REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC, anon, authenticated;
COMMIT;
