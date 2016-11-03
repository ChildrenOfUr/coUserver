part of achievements;

class StatAchvManager {
	static final Map<String, Function> updaters = {
		'awesome_pot': cook,
		'beaker': stir,
		'bean_seasoner': seasonBeans,
		'blender': blend,
		'bubble_tuner': tuneBubbles,
		'cocktail_shaker': shake,
		'egg_seasoner': seasonEggs,
		'fruit_changing_machine': convertFruit,
		'frying_pan': fry,
		'gassifier': gassify,
		'famous_pugilist_grill': grill,
		'knife_and_board': chop,
		'saucepan': simmer,
		'smelter': smelt,
		'spice_mill': mill,
		'tinkertool': tinker,
        'test_tube': concoct,
	};

	static void update(String email, String toolType, String outputItemType) {
		if (updaters[toolType] != null) {
			// Call the function (below)
			updaters[toolType](email, outputItemType);
		} else {
			// The item does not have an associated
			// skill or achievement tracker (yet?).
		}
	}

	static void cook(String email, String outputItemType) {
		StatManager.add(email, Stat.awesome_pot_uses).then((int uses) {
			if (uses >= 137) {
				Achievement.find('golden_ladle_award').awardTo(email);
			} else if (uses >= 101) {
				Achievement.find('5star_cuisinartist').awardTo(email);
			} else if (uses >= 79) {
				Achievement.find('4star_cuisinartist').awardTo(email);
			} else if (uses >= 41) {
				Achievement.find('3star_cuisinartist').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('2star_cuisinartist').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('1star_cuisinartist').awardTo(email);
			}
		});
	}

	static void stir(String email, String outputItemType) {
		SkillManager.learn('alchemy', email);
		StatManager.add(email, Stat.beaker_uses).then((int uses) {
			if (uses >= 41) {
				Achievement.find('senior-admixificator').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('midlevel-admixificator').awardTo(email);
			} else if (uses >= 3) {
				Achievement.find('entrylevel-admixificator').awardTo(email);
			}
		});
    }

    static void concoct(String email, String outputItemType) {
        SkillManager.learn('alchemy', email);
        StatManager.add(email, Stat.test_tube_uses).then((int uses) {
	        if (uses >= 5011) {
		        Achievement.find('loyal-alloyer').awardTo(email);
	        } else if (uses >= 503) {
		        Achievement.find('really-unconfounded-compounder').awardTo(email);
	        } else if (uses >= 41) {
		        Achievement.find('unconfounded-compounder').awardTo(email);
	        }
        });
    }


	static void seasonBeans(String email, String outputItemType) {
		StatManager.add(email, Stat.beans_seasoned).then((int seasoned) {
            if (seasoned >= 2003) {
                Achievement.find('generalissimo_beanorator').awardTo(email);
            } else if (seasoned >= 503) {
                Achievement.find('beanorator_1st_class').awardTo(email);
            } else if (seasoned >= 53) {
				Achievement.find('beanorator_2nd_class').awardTo(email);
			}
	    });
    }

	static void blend(String email, String outputItemType) {
		StatManager.add(email, Stat.blender_uses).then((int uses) {
			if (uses >= 41) {
				Achievement.find('blendmaster').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('high_speed_commingler').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('pulse_frappe_mix_blend').awardTo(email);
			}
		});

		if (outputItemType != null && outputItemType == 'snocone_rainbo') {
			StatManager.add(email, Stat.rainbo_snocones_blended).then((int uses) {
				if (uses >= 317) {
					Achievement.find('rainbo_connection').awardTo(email);
				} else if (uses >= 73) {
					Achievement.find('rainbo_brite').awardTo(email);
				} else if (uses >= 17) {
					Achievement.find('rainbo_taster').awardTo(email);
				}
			});
		}
	}

	static void tuneBubbles(String email, String outputItemType) {
		SkillManager.learn('bubble_tuning', email);
		StatManager.add(email, Stat.bubbles_transformed).then((int transformed) {
			if (transformed >= 2003) {
				Achievement.find('bubble_transubstantiator').awardTo(email);
			} else if (transformed >= 503) {
				Achievement.find('effervescence_consultant').awardTo(email);
			} else if (transformed >= 53) {
				Achievement.find('bubble_coaxer').awardTo(email);
			}
		});
	}

	static void shake(String email, String outputItemType) {
		StatManager.add(email, Stat.cocktail_shaker_uses).then((int uses) {
			if (uses >= 41) {
				Achievement.find('superior_mixologist').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('middling_mixologist').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('mediocre_mixologist').awardTo(email);
			}
		});
	}

	static void seasonEggs(String email, String outputItemType) {
		StatManager.add(email, Stat.eggs_seasoned).then((int seasoned) {
			if (seasoned >= 2003) {
				Achievement.find('egg_transmutator_maxi_pro').awardTo(email);
			} else if (seasoned >= 503) {
				Achievement.find('egg_transmutator_pro').awardTo(email);
			} else if (seasoned >= 53) {
				Achievement.find('egg_transmutator_apprentice').awardTo(email);
			}
		});
	}

	static void convertFruit(String email, String outputItemType) {
		StatManager.add(email, Stat.fruit_converted).then((int converted) {
			if (converted >= 2003) {
				Achievement.find('fruit_metamorphosizin_tycoon').awardTo(email);
			} else if (converted >= 503) {
				Achievement.find('intermediate_fruit_metamorphosizer').awardTo(email);
			} else if (converted >= 53) {
				Achievement.find('novice_fruit_metamorphosizer').awardTo(email);
			}
		});
	}

	static void fry(String email, String outputItemType) {
		StatManager.add(email, Stat.frying_pan_uses).then((int uses) {
			if (uses >= 137) {
				Achievement.find('sizzler_supreme').awardTo(email);
			} else if (uses >= 79) {
				Achievement.find('saute_savant').awardTo(email);
			} else if (uses >= 41) {
				Achievement.find('grease_monkey').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('pretty_good_griddler').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('decent_hash_slinger').awardTo(email);
			}
		});
	}

	static void gassify(String email, String outputItemType) {
		StatManager.add(email, Stat.gas_converted).then((int converted) {
			if (converted >= 2003) {
				Achievement.find('gastronaut').awardTo(email);
			} else if (converted >= 503) {
				Achievement.find('bonafide_gas_wrangler').awardTo(email);
			} else if (converted >= 53) {
				Achievement.find('gas_dabbler').awardTo(email);
			}
		});
	}

	static void grill(String email, String outputItemType) {
		StatManager.add(email, Stat.famous_pugilist_grill_uses).then((int uses) {
			if (uses >= 137) {
				Achievement.find('broil_king').awardTo(email);
			} else if (uses >= 79) {
				Achievement.find('killer_griller').awardTo(email);
			} else if (uses >= 41) {
				Achievement.find('master_carbonifier').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('grill_jockey').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('brazier_apprentice').awardTo(email);
			}
		});
	}

	static void chop(String email, String outputItemType) {
		StatManager.add(email, Stat.knife_board_uses).then((int uses) {
			if (uses >= 137) {
				Achievement.find('master_whacker').awardTo(email);
			} else if (uses >= 79) {
				Achievement.find('silver_cleaver_award').awardTo(email);
			} else if (uses >= 41) {
				Achievement.find('nice_dicer').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('fine_mincer').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('able_chopper').awardTo(email);
			}
		});
	}

	static void simmer(String email, String outputItemType) {
		StatManager.add(email, Stat.sauce_pan_uses).then((int uses) {
			if (uses >= 137) {
				Achievement.find('a1_saucier').awardTo(email);
			} else if (uses >= 79) {
				Achievement.find('super_saucier').awardTo(email);
			} else if (uses >= 41) {
				Achievement.find('gravy_maven').awardTo(email);
			} else if (uses >= 23) {
				Achievement.find('roux_guru').awardTo(email);
			} else if (uses >= 11) {
				Achievement.find('rolling_boiler').awardTo(email);
			}
		});
	}

	static void smelt(email) {
		StatManager.add(email, Stat.smelter_uses).then((int smelted) {
			if (smelted >= 1009) {
				Achievement.find('hephaestite').awardTo(email);
			} else if (smelted >= 503) {
				Achievement.find('metalhead').awardTo(email);
			} else if (smelted >= 283) {
				Achievement.find('metal_masseuse').awardTo(email);
			} else if (smelted >= 127) {
				Achievement.find('crucible_jockey').awardTo(email);
			} else if (smelted >= 41) {
				Achievement.find('forgey_laforge').awardTo(email);
			}
		});
	}

	static void mill(email) {
		StatManager.add(email, Stat.spice_milled).then((int milled) {
			if (milled >= 2003) {
				Achievement.find('executive_in_charge_of_spice_reformatation').awardTo(email);
			} else if (milled >= 503) {
				Achievement.find('assistant_spice_manager').awardTo(email);
			} else if (milled >= 53) {
				Achievement.find('spice_intern').awardTo(email);
			}
		});
	}

	static void tinker(email) {
		SkillManager.learn('tinkering', email);
		StatManager.add(email, Stat.tinkertool_uses, increment: 50).then((int tinkered) {
			if (tinkered >= 25013) {
				Achievement.find('grand_poobah_tinkering_ops').awardTo(email);
			} else if (tinkered >= 10009) {
				Achievement.find('special_agent_tinkering_ops').awardTo(email);
			} else if (tinkered >= 2503) {
				Achievement.find('chief_of_tinkering_operations').awardTo(email);
			} else if (tinkered >= 1009) {
				Achievement.find('executive_flunky_tinkering_ops').awardTo(email);
			}
		});
	}
}
