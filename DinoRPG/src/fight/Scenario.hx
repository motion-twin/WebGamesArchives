package fight;
import Fight;

using Lambda;
class Scenario {

	static inline function scenario( s : data.Scenario, value : Int ) {
		return db.Scenario.get(s,App.user) == value;
	}
	
	static inline function progress( s : data.Scenario ) {
		return db.Scenario.get(s, App.user);
	}
	
	static function next( s : data.Scenario ) {
		db.Scenario.set( s, App.user, db.Scenario.get(s,App.user) + 1 );
	}

	public static function buildMonsters( r : Result, ml : List<{ m : data.Monster, p : Int }> ) {
		if( !r.side ) return ml;
		var user = App.user;
		var P = Data.MAP.list;
		var S = Data.SCENARIOS.list;
		var M = Data.MONSTERS.list;
		var UV = Data.USERVARS.list;
		var m = r.manager;
		var message = function(txt) {
			m.onStartFight.add(function() m.text(txt));
		};
		
		switch( r.manager.getPosition() ) {
		case P.gotow:
			message(Data.TEXT.enter_tower);
			m.onEndFight.add(callback(onKillTowerGardian,m));
			return Lambda.list([{ m : M.towgrd, p : null }]);
		case P.slake:
			if( scenario(S.magnet,0) ) {
				message(Data.TEXT.fight_wteam);
				m.onEndFight.add(callback(onFightWTeam,m));
				return Lambda.list([
					{ m : M.wteam1, p : null },
					{ m : M.wteam2, p : null },
					{ m : M.wteam3, p : null },
				]);
			}
		case P.sband1:
			if( scenario(S.magnet,2) ) {
				message(Data.TEXT.fight_wteam_start);
				m.onEndFight.add(callback(onFightWTeamMember,m));
				return Lambda.list([{ m : M.wteam1, p : null }]);
			}
		case P.sband2:
			if( scenario(S.magnet,3) ) {
				message(Data.TEXT.fight_wteam_start);
				m.onEndFight.add(callback(onFightWTeamMember,m));
				return Lambda.list([{ m : M.wteam2, p : null }]);
			}
		case P.sband3:
			if( scenario(S.magnet,4) ) {
				message(Data.TEXT.fight_wteam_start);
				m.onEndFight.add(callback(onFightWTeamMember,m));
				return Lambda.list([{ m : M.wteam3, p : null }]);
			}
		case P.scampw:
			if( scenario(S.magnet,5) ) {
				message(Data.TEXT.fight_wteam_start);
				m.onEndFight.add(callback(onFightWTeamBourrin,m));
				r.manager.setTimeout(100,false);
				return Lambda.list([{ m : M.wbour1, p : null }]);
			}
		case P.gostep:
			if( scenario(S.magnet,9) ) {
				var ok = false;
				for( d in r.dinoz )
					if( d.d.hasEffect(Data.EFFECTS.list.potion) ) {
						ok = true;
						break;
					}
				if( ok ) {
					message(Data.TEXT.fight_darkdinoz);
					m.onEndFight.add(callback(onFightDarkGoup,m));
					var dg = { m : M.darkgp, p : null };
					return Lambda.list([dg,dg,dg,dg]);
				}
			}
		/* Faille : on peut refaire le combat à volonté
		case P.sking:
			if( scenario(S.magnet,11) ) {
				var dg = { m : M.darkgp, p : null };
				message(Data.TEXT.fight_sking_start);
				m.onEndFight.add(callback(onFightKingFinal,m));
				m.setTimeout(50,false,callback(onFightKindHelp,m));
				var a = [dg,{ m : M.wbour2, p : null }];
				for( i in 0...m.res.dinoz.length )
					a.push(dg);
				return Lambda.list(a);
			}
		*/
		case P.dnv:
			// only allow fight on the spot
			if( scenario(S.star,1) && m.res.end == _EBEscape ) {
				message(Data.TEXT.fight_megawolf);
				m.onEndFight.add(function() {
					if( !m.res.won )
						return;
					m.text(Data.TEXT.fight_star_found);
					db.Object.add(R_Scenario, Data.OBJECTS.list.star);
					next(S.star);
				});
				return Lambda.list([{ m : M.megawf, p : null }]);
			}
		case P.itlost:
			m.res.end = _EBEscape;
			m.res.other.end = _EBRun;
			m.onEndFight.add(function() {
				m.text(Data.TEXT.enter_ilost);
				var y = m.addMonster(M.yakuzi);
				var kb1 = m.addMonster(M.yakkb2);
				var kb2 = m.addMonster(M.yakkb3);
				m.text(Data.TEXT.yakuzi_help1,y);
				m.text(Data.TEXT.yakuzi_help2,y);
				m.text(Data.TEXT.yakuzi_help3,y);
				next(S.kabuki);
			});
			return new List();
		case P.itotem:
			if( scenario(S.kabuki,20) ) {
				var igor = null;
				var yakuzi = null;
				m.onStartFight.add(function() {
					m.text(Data.TEXT.igor_final_start);
					igor = m.addMonster(M.igor);
					m.text(Data.TEXT.igor_final_talk,igor);
					m.text(M.tigor1.name+" !",igor);
					m.addMonster(M.tigor1);
					m.text(M.tigor2.name+" !",igor);
					m.addMonster(M.tigor2);
					m.text(M.tigor3.name+" !",igor);
					m.addMonster(M.tigor3);
					m.text(Data.TEXT.igor_final_talk2,igor);
					yakuzi = m.addMonster(M.yakuzi,true);
					m.text(Data.TEXT.yakuzi_final_talk,yakuzi);
					m.addMonster(M.yakkb2,true);
					m.addMonster(M.yakkb3,true);
					m.text(Data.TEXT.yakuzi_final_talk2,yakuzi);
				});
				m.onEndFight.add(function() {
					if( !m.res.won )
						return;
					m.text(Data.TEXT.igor_lost_fight);
					App.user.addCollection(Data.COLLECTION.list.kaura);
					next(S.kabuki);
				});
				return new List();
			}
		case P.mvoutp:
			m.onStartFight.add(function() {
				if( db.Scenario.get(S.monisl, App.user) >= 17 )
					return;
				var f0 = null;
				for( i in 0...m.side(true).length ) {
					var f = m.addMonster(M.mugard);
					if( f0 == null ) f0 = f;
					var s = Data.SKILLS.list.mugard;
					f.onKill.add(function() {
						m.announce(f,s);
						m.effect(_SFAura(f.id, 0x008080, 2));
						for( f in m.side(!f.side).copy() ) {
							m.removeFromFight(f);
							m.history(_HEscape(f.id));
						}
						return false;
					});
				}
				m.text(Data.TEXT.veguard_stop,f0);
			});
		case P.mfpalc:
			if( scenario(S.monisl,7) ) {
				m.onStartFight.add(function() {
					var gt = m.addMonster(M.frking);
					m.text(Data.TEXT.grotox_begin,gt);
					for( i in 0...3 )
						m.addMonster(M.frutox);
					gt.onKill.add(function() {
						m.text(Data.TEXT.grotox_end,gt);
						for( f in m.side(true) )
							m.removeFromFight(f);
						next(S.monisl);
						return false;
					});
				});
				return new List();
			}
		case P.mcuzco:
			if( scenario(S.monisl,15) && m.res.end == _EBEscape ) {
				m.onEndFight.add(function() {
					for( i in 0...3 )
						m.addMonster(M.mugard);
					for( i in 0...3 )
						m.addMonster(M.frutox,true);
					var a = m.addMonster(M.muking);
					var g = m.addMonster(M.frking,true);
					var T = Data.TEXT;
					m.text(T.end_antrax1,a);
					m.text(T.end_grotox1,g);
					m.text(T.end_antrax2,a);
					m.text(T.end_grotox2,g);
					m.text(T.end_antrax3,a);
					m.text(T.end_grotox3,g);
					m.text(T.end_grotox4,g);
					m.text(T.end_antrax4,a);
					m.text(T.end_grotox5,g);
					m.text(T.end_antrax5,a);
					m.text(T.end_come);
					next(S.monisl);
				});
				m.res.other.end = _EBEscape;
				m.res.calculate = function() {};
				return new List();
			}
		default:
		}
		
		var pcaush = progress(S.caush);
		var enableColosse = pcaush >= 28 && pcaush <= 30 && (App.user.isAdmin ? true : Std.random(8) == 0);
		
		if( enableColosse ) {
			var v = switch( r.manager.getPosition().zone ) {
				case 1 : UV.arcadu;	// tchaud
				case 5 : UV.behemu;	// magnet
				case 9 : UV.serpe;	// caush
				default: null;
			}
			if( v != null ) {
				var p = user.getValue( v, 0 );
				if( p < 3 ) {
					var monster = Data.MONSTERS.getId(v.vid);
					var f = m.addMonster(monster , false );
					f.onKill.add( function() {
						p = user.incrVar( v );
						if( p == 3 ) {
							m.text( Text.fmt.colosse_eradicated( { colosse : monster.name } ) );
							next(S.caush);
						} else {
							m.history(_HEscape(f.id));
							m.removeFromFight(f);
							m.text( Text.fmt.colosse_victory( { colosse : monster.name } ) );
						}
						return p == 3;
					} );
					return new List();
				}
			}
		}
		return ml;
	}

	public static function dialogFight( s : data.Scenario, phase : Int, m : fight.Manager ) {
		var S = Data.SCENARIOS.list;
		var M = Data.MONSTERS.list;
		var message = function(txt) {
			m.onStartFight.add(function() m.text(txt));
		};
		// phase is the next phase of the scenario, not the current one !
		switch( s ) {
		case S.nimbao:
			if( phase == 4 ) {
				m.onEndFight.add(function() {
					m.text(Data.TEXT.lucette_heal);
					for( d in m.res.dinoz )
						if( d.f.life == 0 )
							m.regenerate(d.f, _LHeal, 1);
					m.res.won = true;
				});
			}
			if( phase == 13) {
				var f = m.res.fighters.first();
				m.res.other.end = _EBStand;
				m.res.end = _EBEscape;
				m.addMonster( M.morg, true );
				m.onStartFight.add( function() { m.history(_HEscape(f.id)); m.removeFromFight(f);} );
			}
			
		case S.nimba2:
			if( phase == 38 ) {
				m.onEndFight.add(function() {
					m.text(Data.TEXT.pistac_heal);
					for( d in m.res.dinoz )
						if( d.f.life == 0 ) {
							m.regenerate(d.f, _LHeal, 1);
						}
					m.res.won = true;
				});
			}
			if( phase == 49 ) {
				m.onEndFight.add(function() {
					m.text(Data.TEXT.mandra_heal);
					for( d in m.res.dinoz )
						if( d.f.life == 0 ) {
							m.regenerate(d.f, _LHeal, d.f.startLife);
						}
					m.res.won = true;
				});
			}
			if( phase == 50 ) {
				m.onStartFight.add( function() {
					m.addMonster( Data.MONSTERS.list.mandra, true);
					m.addMonster( Data.MONSTERS.list.lucet, true);
				});
				m.onEndFight.add(function() {
					m.text(Data.TEXT.mandra_heal);
					for( d in m.res.dinoz )
						if( d.f.life == 0 ) {
							m.regenerate(d.f, _LHeal, d.f.startLife);
						}
					m.res.won = true;
				});
			}
		case S.caush:
			if( phase == 23 ) {
				var f = m.res.fighters.first();
				m.res.other.end = _EBStand;
				m.res.end = _EBEscape;
				m.onStartFight.add( function() { m.removeFromFight(f); m.history(_HEscape(f.id));} );
			}
			
		case S.kabuki:
			if( phase == 4 ) {
				m.res.end = _EBStand;
				m.res.other.end = _EBEscape;
				m.onEndFight.add(function() {
					if( !m.res.won )
						return;
					m.text(Data.TEXT.yakuzi_run);
					for( f in m.getDeads() )
						if( !f.side )
							m.regenerate(f,_LHeal,1);
				});
			}
			if( phase == 5 ) {
				m.res.end = _EBStand;
				m.res.other.end = _EBEscape;
				var y = m.res.other.fighters.first();
				y.life = 30;
				y.onKill.add(function() {
					m.text(Data.TEXT.kabuki_defend,y);
					m.addMonster(M.yakkb1);
					m.regenerate(y,_LHeal,100);
					m.history(_HEscape(y.id));
					m.removeFromFight(y);
					return false;
				});
				m.onEndFight.add(function() {
					if( !m.res.won )
						return;
					m.text(Data.TEXT.strange_dinoz);
				});
			}
			if( phase == 19 ) {
				m.res.end = _EBStand;
				m.res.other.end = _EBEscape;
				m.onStartFight.add(function() {
					var igor = m.res.other.fighters.first();
					m.text(Data.TEXT.igor_fight,igor);
					m.text(M.tigor1.name+" !",igor);
					m.addMonster(M.tigor1);
					m.text(M.tigor2.name+" !",igor);
					m.addMonster(M.tigor2);
					m.text(M.tigor3.name+" !",igor);
					m.addMonster(M.tigor3);
				});
				m.onEndFight.add(function() {
					m.text(Data.TEXT.igor_leave);
					for( d in m.res.dinoz )
						if( d.f.life == 0 )
							m.regenerate(d.f,_LHeal,1);
					m.res.won = true;
				});
			}
			
		case S.magnet : {
			if( phase == 11 ) {
				var dg = M.darkgp;
				message(Data.TEXT.fight_sking_start);
				m.onEndFight.add(callback(onFightKingFinal,m));
				m.setTimeout(50,false,callback(onFightKindHelp,m));
				for( i in 0...m.res.dinoz.length )
					m.addMonster(dg);
			}
		}
		default:
		}
	}

	static function onKillTowerGardian( m : Manager ) {
		if( !m.res.won ) return;
		m.text(Data.TEXT.leave_tower);
		m.res.end = _EBRun;
		for( d in m.res.dinoz ) {
			d.d.addEffect(Data.EFFECTS.list.sylkey);
			d.d.moveTo(Data.MAP.list.marais,true);
			untyped d.d.moveTo = function(_,_) {}; // prevent further moves
		}
	}

	static function onFightWTeam( m : Manager ) {
		var captain = m.addMonster(Data.MONSTERS.list.wteamc);
		m.text(Data.TEXT.fight_wteam_done,captain);
		m.history(_HAnnounce(captain.id,Data.TEXT.fight_wteam_regen));
		var r = m.res;
		for( d in r.dinoz )
			m.regenerate(d.f,_LHeal,300);
		r.won = true;
		r.end = _EBRun;
		r.other.end = _EBEscape;
		db.Scenario.set(Data.SCENARIOS.list.magnet,App.user,1);
	}

	static function onFightWTeamMember( m : Manager ) {
		var captain = m.addMonster(Data.MONSTERS.list.wteamc);
		var r = m.res;
		if( !r.won ) {
			m.text(Data.TEXT.fight_wteam_lost,captain);
			return;
		}
		var s = db.Scenario.get(Data.SCENARIOS.list.magnet,App.user);
		var text = [Data.TEXT.fight_wteam_won1,Data.TEXT.fight_wteam_won2,Data.TEXT.fight_wteam_won3][s-2];
		m.text(text,captain);
		m.history(_HAnnounce(captain.id,Data.TEXT.fight_wteam_regen));
		for( f in r.other.fighters )
			if( f != captain )
				m.regenerate(f,_LHeal,300);
		db.Scenario.set(Data.SCENARIOS.list.magnet,App.user,s + 1);
		r.end = _EBRun;
		r.other.end = _EBEscape;
	}

	static function onFightWTeamBourrin( m : Manager ) {
		var captain = m.addMonster(Data.MONSTERS.list.wteamc);
		m.text(Data.TEXT.fight_wteam_end,captain);
		m.res.end = _EBStand;
		m.res.other.end = _EBStand;
		db.Scenario.set(Data.SCENARIOS.list.magnet,App.user,6);
	}

	static function onFightDarkGoup( m : Manager ) {
		m.text(Data.TEXT.fight_potion_stolen);
		m.res.end = _EBRun;
		m.res.other.end = _EBEscape;
		for( d in m.res.dinoz ) {
			if( d.f.life == 0 )
				m.regenerate(d.f,_LHeal,1);
			d.d.removeEffect(Data.EFFECTS.list.potion);
		}
		m.res.won = true;
		db.Scenario.set(Data.SCENARIOS.list.magnet,App.user,10);
	}

	static function onFightKindHelp( m : Manager ) {
		var captain = m.addMonster(Data.MONSTERS.list.wteamc,true);
		m.text(Data.TEXT.fight_captain_help,captain);
		m.history(_HAnnounce(captain.id,Data.TEXT.fight_wteam_regen));
		for( d in m.res.dinoz )
			m.regenerate(d.f,_LHeal,100);
		m.addMonster(Data.MONSTERS.list.wteam1,true);
		m.addMonster(Data.MONSTERS.list.wteam2,true);
		m.addMonster(Data.MONSTERS.list.wteam3,true);
		m.history(_HEscape(captain.id));
		m.removeFromFight(captain);
		return true;
	}

	static function onFightKingFinal( m : Manager ) {
		if( !m.res.won ) {// back
			db.Scenario.set(Data.SCENARIOS.list.magnet,App.user,10);
			return;
		}
		m.text(Data.TEXT.fight_sking_end1);
		m.text(Data.TEXT.fight_sking_end2);
		m.res.end = _EBStand;
		m.res.other.end = _EBStand;
	}

	public static function gatherContent( r : List<{ _name : String, _url : String }>, d : db.Dino ) {
	}

	public static function dig( d : db.Dino, pos : data.Map ) {
		var S = Data.SCENARIOS.list;
		var F = Data.EFFECTS.list;
		var M = Data.MISSIONS.list;
		if( scenario(S.star,4) && pos == Data.MAP.list.tunel ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.star);
			next(S.star);
			throw handler.Action.Done("/dino/" + d.id, Data.TEXT.dig_star_found);
			
		// Scenario Alzaim
		} else if( scenario( S.alzaim, 1) && pos == Data.MAP.list.spylon ){
			next(S.alzaim);
			throw handler.Action.Done("/dino/"+d.id, Text.get.alz_photo1_found, {} );
		} else if( scenario( S.alzaim, 9) && pos == Data.MAP.list.fosslv ){
			next(S.alzaim);
			throw handler.Action.Done("/dino/" + d.id, Text.get.alz_sel_lave_found, { } );
			
		// Scenario Joujou
		} else if( scenario( S.joujou, 11) && pos == Data.MAP.list.papy ){
			next(S.joujou);
			throw handler.Action.Done("/dino/" + d.id, Text.get.alz_bot_found, { } );
			
		// Scenario Nimba2
		} else if( scenario( S.nimba2, 10) && pos == Data.MAP.list.port ){
			next(S.nimba2);
			throw handler.Action.Done("/dino/" + d.id, Text.get.sable, { } );
		} else if( scenario( S.nimba2, 11) && pos == Data.MAP.list.chutes ){
			next(S.nimba2);
			throw handler.Action.Done("/dino/"+d.id, Text.get.bouh, {} );
		} else if( scenario( S.nimba2, 12) && pos == Data.MAP.list.fosslv ){
			next(S.nimba2);
			throw handler.Action.Done("/dino/"+d.id, Text.get.sellave, {} );
		} else if( scenario( S.nimba2, 13) && pos == Data.MAP.list.gorges ){
			next(S.nimba2);
			throw handler.Action.Done("/dino/"+d.id, Text.get.glac, {} );
		}
		// Scenario fmedal
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.garde ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedaa);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.baobob ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedab);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.cpyra2 ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedac);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.corail ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedad);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.chato ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedae);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.ilac ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedaf);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
		else if( scenario( S.fmedal, 8) && pos == Data.MAP.list.dktow ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.fmedag);
			throw handler.Action.Done("/dino/" + d.id, Text.get.fmedal, { } );
		}
	
		// Scenario smog
		else if( scenario( S.smog, 4) && pos == Data.MAP.list.scanyo ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.metal);
			throw handler.Action.Done("/dino/" + d.id, Text.get.metal, { } );
		}
		// Scenario smog 8+
		else if( progress(S.smog) >= 8 && pos == Data.MAP.list.iceisl) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.icepie);
			throw handler.Action.Done("/dino/" + d.id, Text.get.icepie, { } );
		}
		else if( progress(S.smog) >= 8 && pos == Data.MAP.list.iceis2) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.icepie);
			throw handler.Action.Done("/dino/" + d.id, Text.get.icepie, { } );
		}
	
	}

	public static function useObject( d : db.Dino, o : data.Object ) {
		var S = Data.SCENARIOS.list;
		if( scenario(S.star,3) && d.getCurrentView() == Data.MAP.list.marfld && o == Data.OBJECTS.list.tartev ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.star);
			next(S.star);
			throw handler.Action.Done("/dino/"+d.id,Data.TEXT.eat_star_found);
		}
	}

	public static function resurrect( d : db.Dino, pos : data.Map ) {
		var S = Data.SCENARIOS.list;
		if( scenario(S.star,7) && pos == Data.MAP.list.jungle ) {
			db.Object.add(R_Scenario, Data.OBJECTS.list.star);
			next(S.star);
			throw handler.Action.Done("/dino/"+d.id,Data.TEXT.resurrect_star_found);
		}
	}
}
