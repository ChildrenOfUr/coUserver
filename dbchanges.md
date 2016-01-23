The following changes have been made to the dev database and will need to be added to the live database upon release.

- metabolics table
    - Added skills_json text column with default '{}' and NOT NULL constraint

- users table
    - Added chat_disabled boolean column with default false and NOT NULL constraint
      (this allows us to disable sending messages to global chat for spammers)
    - Added achievements text column with default '[]' and NOT NULL constraint
      (stores a list of ids in JSON format)

- stats table (created)
    - id - integer, not null, default nextval('users_id_seq'::regclass)
    - user_id - integer
    - integer, not null, default 0 (the actual trackers)
        - steps_taken
        - butterflies_massaged
        - chickens_squeezed
        - piggies_nibbled
        - awesome_pot_uses
        - cocktail_shaker_uses
        - blender_uses
        - grill_uses
        - frying_pan_uses
        - knife_board_uses
        - sauce_pan_uses
        - shrine_donations
        - emblems_collected
        - barnacles_scraped
        - dirt_dug
        - ice_scraped
        - jellisac_harvested
        - paper_harvested
        - peat_harvested
        - rocks_mined
        - jumps
        - bean_trees_petted
        - bean_trees_watered
        - beans_harvested
        - beans_seasoned
        - bubble_trees_petted
        - bubble_trees_watered
        - bubbles_harvested
        - bubbles_transformed
        - egg_plants_petted
        - egg_plants_watered
        - eggs_harveted
        - eggs_seasoned
        - fruit_trees_petted
        - fruit_trees_watered
        - cherries_harvested
        - fruit_converted
        - gas_plants_petted
        - gas_plants_watered
        - gas_harvested
        - gas_converted
        - spice_plants_petted
        - spice_plants_watered
        - spice_harvested
        - spice_milled
        - wood_trees_petted
        - wood_trees_watered
        - planks_harvested
        
    ```SQL
    CREATE TABLE stats (
    	id integer NOT NULL DEFAULT nextval('stats_id_seq'::regclass),
    	user_id integer NOT NULL DEFAULT -1,
    	steps_taken integer NOT NULL DEFAULT 0,
    	butterflies_massaged integer NOT NULL DEFAULT 0,
    	chickens_squeezed integer NOT NULL DEFAULT 0,
    	piggies_nibbled integer NOT NULL DEFAULT 0,
    	awesome_pot_uses integer NOT NULL DEFAULT 0,
    	cocktail_shaker_uses integer NOT NULL DEFAULT 0,
    	blender_uses integer NOT NULL DEFAULT 0,
    	grill_uses integer NOT NULL DEFAULT 0,
    	frying_pan_uses integer NOT NULL DEFAULT 0,
    	knife_board_uses integer NOT NULL DEFAULT 0,
    	sauce_pan_uses integer NOT NULL DEFAULT 0,
    	shrine_donations integer NOT NULL DEFAULT 0,
    	emblems_collected integer NOT NULL DEFAULT 0,
    	barnacles_scraped integer NOT NULL DEFAULT 0,
    	dirt_dug integer NOT NULL DEFAULT 0,
    	ice_scraped integer NOT NULL DEFAULT 0,
    	jellisac_harvested integer NOT NULL DEFAULT 0,
    	paper_harvested integer NOT NULL DEFAULT 0,
    	peat_harvested integer NOT NULL DEFAULT 0,
    	rocks_mined integer NOT NULL DEFAULT 0,
    	jumps integer NOT NULL DEFAULT 0,
    	bean_trees_petted integer NOT NULL DEFAULT 0,
    	bean_trees_watered integer NOT NULL DEFAULT 0,
    	beans_harvested integer NOT NULL DEFAULT 0,
    	beans_seasoned integer NOT NULL DEFAULT 0,
    	bubble_trees_petted integer NOT NULL DEFAULT 0,
    	bubble_trees_watered integer NOT NULL DEFAULT 0,
    	bubbles_harvested integer NOT NULL DEFAULT 0,
    	bubbles_transformed integer NOT NULL DEFAULT 0,
    	egg_plants_petted integer NOT NULL DEFAULT 0,
    	egg_plants_watered integer NOT NULL DEFAULT 0,
    	eggs_harveted integer NOT NULL DEFAULT 0,
    	eggs_seasoned integer NOT NULL DEFAULT 0,
    	fruit_trees_petted integer NOT NULL DEFAULT 0,
    	fruit_trees_watered integer NOT NULL DEFAULT 0,
    	cherries_harvested integer NOT NULL DEFAULT 0,
    	fruit_converted integer NOT NULL DEFAULT 0,
    	gas_plants_petted integer NOT NULL DEFAULT 0,
    	gas_plants_watered integer NOT NULL DEFAULT 0,
    	gas_harvested integer NOT NULL DEFAULT 0,
    	gas_converted integer NOT NULL DEFAULT 0,
    	spice_plants_petted integer NOT NULL DEFAULT 0,
    	spice_plants_watered integer NOT NULL DEFAULT 0,
    	spice_harvested integer NOT NULL DEFAULT 0,
    	spice_milled integer NOT NULL DEFAULT 0,
    	wood_trees_petted integer NOT NULL DEFAULT 0,
    	wood_trees_watered integer NOT NULL DEFAULT 0,
    	planks_harvested integer NOT NULL DEFAULT 0,
    	PRIMARY KEY(id)
    );
    ```