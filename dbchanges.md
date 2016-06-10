The following changes have been made to the dev database and will need to be added to the live database upon release.

alter table stats add column crops_harvested integer not null default 0;
alter table stats add column crops_hoed integer not null default 0;
alter table stats add column crops_planted integer not null default 0;
alter table stats add column crops_watered integer not null default 0;