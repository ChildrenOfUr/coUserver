part of achievements;

class StatAchvManager {
	static final Map<String, Function> updaters = {
		"awesome_pot": cook,
		"beaker": stir,
		"bean_seasoner": seasonBeans,
		"blender": blend,
		"bubble_tuner": tuneBubbles,
		"cocktail_shaker": shake,
		"egg_seasoner": seasonEggs,
		"fruit_changing_machine": convertFruit,
		"frying_pan": fry,
		"gassifier": gassify,
		"grill": grill,
		"knife_and_board": chop,
		"saucepan": simmer,
		"spice_mill": mill
	};

	static void update(String email, String toolType) {
		if (updaters[toolType] != null) {
			// Call the function (below)
			updaters[toolType](email);
		} else {
			// The item does not have an associated
			// skill or achievement tracker (yet?).
		}
	}

	static void cook(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.awesome_pot_uses++;
			if (stats.awesome_pot_uses >= 11) {
				Achievement.find("1star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 23) {
				Achievement.find("2star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 41) {
				Achievement.find("3star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 79) {
				Achievement.find("4star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 101) {
				Achievement.find("5star_cuisinartist").awardTo(email);
			} else if (stats.awesome_pot_uses >= 137) {
				Achievement.find("golden_ladle_award").awardTo(email);
			}
		});
	}

	static void stir(String email) {
		SkillManager.learn("alchemy", email);
	}

	static void seasonBeans(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.beans_seasoned++;
			if (stats.beans_seasoned >= 53) {
				Achievement.find("beanorator_2nd_class").awardTo(email);
			} else if (stats.beans_seasoned >= 503) {
				Achievement.find("beanorator_1st_class").awardTo(email);
			} else if (stats.beans_seasoned >= 2003) {
				Achievement.find("generalissimo_beanorator").awardTo(email);
			}
		});
	}

	static void blend(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.blender_uses++;
			if (stats.blender_uses >= 11) {
				Achievement.find("pulse_frappe_mix_blend").awardTo(email);
			} else if (stats.blender_uses >= 23) {
				Achievement.find("high_speed_commingler").awardTo(email);
			} else if (stats.blender_uses >= 41) {
				Achievement.find("blendmaster").awardTo(email);
			}
		});
	}

	static void tuneBubbles(String email) {
		SkillManager.learn("bubble_tuning", email);
		StatCollection.find(email).then((StatCollection stats) {
			stats.bubbles_transformed++;
			if (stats.bubbles_transformed >= 53) {
				Achievement.find("bubble_coaxer").awardTo(email);
			} else if (stats.bubbles_transformed >= 503) {
				Achievement.find("effervescence_consultant").awardTo(email);
			} else if (stats.bubbles_transformed >= 2003) {
				Achievement.find("bubble_transubstantiator").awardTo(email);
			}
		});
	}

	static void shake(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.cocktail_shaker_uses++;
			if (stats.cocktail_shaker_uses >= 11) {
				Achievement.find("mediocre_mixologist").awardTo(email);
			} else if (stats.cocktail_shaker_uses >= 23) {
				Achievement.find("middling_mixologist").awardTo(email);
			} else if (stats.cocktail_shaker_uses >= 41) {
				Achievement.find("superior_mixologist").awardTo(email);
			}
		});
	}

	static void seasonEggs(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.eggs_seasoned++;
			if (stats.eggs_seasoned >= 53) {
				Achievement.find("egg_transmutator_apprentice").awardTo(email);
			} else if (stats.eggs_seasoned >= 503) {
				Achievement.find("egg_transmutator_pro").awardTo(email);
			} else if (stats.eggs_seasoned >= 2003) {
				Achievement.find("egg_transmutator_maxi_pro").awardTo(email);
			}
		});
	}

	static void convertFruit(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.fruit_converted++;
			if (stats.fruit_converted >= 53) {
				Achievement.find("novice_fruit_metamorphosizer").awardTo(email);
			} else if (stats.fruit_converted >= 503) {
				Achievement.find("intermediate_fruit_metamorphosizer").awardTo(email);
			} else if (stats.fruit_converted >= 2003) {
				Achievement.find("fruit_metamorphosizin_tycoon").awardTo(email);
			}
		});
	}

	static void fry(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.frying_pan_uses++;
			if (stats.frying_pan_uses >= 11) {
				Achievement.find("decent_hash_slinger").awardTo(email);
			} else if (stats.frying_pan_uses >= 23) {
				Achievement.find("pretty_good_griddler").awardTo(email);
			} else if (stats.frying_pan_uses >= 41) {
				Achievement.find("grease_monkey").awardTo(email);
			} else if (stats.frying_pan_uses >= 79) {
				Achievement.find("saute_savant").awardTo(email);
			} else if (stats.frying_pan_uses >= 137) {
				Achievement.find("sizzler_supreme").awardTo(email);
			}
		});
	}

	static void gassify(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.gas_converted++;
			if (stats.gas_converted >= 53) {
				Achievement.find("gas_dabbler").awardTo(email);
			} else if (stats.gas_converted >= 503) {
				Achievement.find("bonafide_gas_wrangler").awardTo(email);
			} else if (stats.gas_converted >= 2003) {
				Achievement.find("gastronaut").awardTo(email);
			}
		});
	}

	static void grill(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.grill_uses++;
			if (stats.grill_uses >= 11) {
				Achievement.find("brazier_apprentice").awardTo(email);
			} else if (stats.grill_uses >= 23) {
				Achievement.find("grill_jockey").awardTo(email);
			} else if (stats.grill_uses >= 41) {
				Achievement.find("master_carbonifier").awardTo(email);
			} else if (stats.grill_uses >= 79) {
				Achievement.find("killer_griller").awardTo(email);
			} else if (stats.grill_uses >= 137) {
				Achievement.find("broil_king").awardTo(email);
			}
		});
	}

	static void chop(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.knife_board_uses++;
			if (stats.knife_board_uses >= 11) {
				Achievement.find("able_chopper").awardTo(email);
			} else if (stats.knife_board_uses >= 23) {
				Achievement.find("fine_mincer").awardTo(email);
			} else if (stats.knife_board_uses >= 41) {
				Achievement.find("nice_dicer").awardTo(email);
			} else if (stats.knife_board_uses >= 79) {
				Achievement.find("silver_cleaver_award").awardTo(email);
			} else if (stats.knife_board_uses >= 137) {
				Achievement.find("master_whacker").awardTo(email);
			}
		});
	}

	static void simmer(String email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.sauce_pan_uses++;
			if (stats.sauce_pan_uses >= 11) {
				Achievement.find("rolling_boiler").awardTo(email);
			} else if (stats.sauce_pan_uses >= 23) {
				Achievement.find("roux_guru").awardTo(email);
			} else if (stats.sauce_pan_uses >= 41) {
				Achievement.find("gravy_maven").awardTo(email);
			} else if (stats.sauce_pan_uses >= 79) {
				Achievement.find("super_saucier").awardTo(email);
			} else if (stats.sauce_pan_uses >= 137) {
				Achievement.find("a1_saucier").awardTo(email);
			}
		});
	}

	static void mill(email) {
		StatCollection.find(email).then((StatCollection stats) {
			stats.spice_milled++;
			if (stats.spice_milled >= 53) {
				Achievement.find("spice_intern").awardTo(email);
			} else if (stats.spice_milled >= 503) {
				Achievement.find("assistant_spice_manager").awardTo(email);
			} else if (stats.spice_milled >= 2003) {
				Achievement.find("executive_in_charge_of_spice_reformatation").awardTo(email);
			}
		});
	}
}