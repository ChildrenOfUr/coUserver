The following changes have been made to the dev database and will need to be added to the live database upon release.

```
CREATE TABLE street_entities (
    id varchar(30) PRIMARY KEY UNIQUE NOT NULL,
    type varchar(30) NOT NULL,
    tsid varchar(20),
    x integer NOT NULL DEFAULT 0,
    y integer NOT NULL DEFAULT 0
);
```