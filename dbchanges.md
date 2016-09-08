The following changes have been made to the dev database and will need to be added to the live database upon release.

alter table street_entities add column h_flip boolean default false;
alter table street_entities add column rotation int default 0;
alter table stats add column rainbo_snocones_blended int not null default 0;