The following changes have been made to the dev database and will need to be added to the live database upon release.

- Populate the `api_access` table by including the `uuid` package and uncommenting the bit from `declarations.dart`
- `ALTER TABLE streets ALTER COLUMN id TYPE character(25);`
- `ALTER TABLE streets ADD COLUMN is_home boolean NOT NULL DEFAULT false;`