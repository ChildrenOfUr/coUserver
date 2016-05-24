The following changes have been made to the dev database and will need to be added to the live database upon release.

```
CREATE TABLE street_entities (
    tsid varchar(20) PRIMARY KEY UNIQUE NOT NULL,
    json text NOT NULL DEFAULT '{"entities": []}'
);
```