The following changes have been made to the dev database and will need to be added to the live database upon release.

alter table auctions alter column start_time set default now();
alter table auctions alter column end_time set default now() + '2 days'::interval;
create table api_access(id serial primary key, user_id integer not null references users(id), api_token text not null, access_count integer not null default 0);
//populate that table by including the uuid package and uncommenting the bit from declarations.dart