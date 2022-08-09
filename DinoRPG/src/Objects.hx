import Fight;
import data.Event;

class Objects {

	static var O = Data.OBJECTS.list;

	static function addDinoz( d : db.Dino, fam : data.Family, palette : Int = 0, special1 : Int = 0, special2 : Int = 0 ) {
		var u = d.owner;
		if ( u.countActiveDinoz() >= Skills.calculateMaxDinoz(u) ) {
			return false;
		}
		var d = new db.Dino(fam);
		d.gfx = UID.CHARS.charAt(fam.gfx) + UID.CHARS.charAt(0) + UID.make(11, Std.random) + UID.CHARS.charAt(palette) + UID.CHARS.charAt(special1) + UID.CHARS.charAt(special2);
		d.setOwner(u, true);
		d.insert();
		App.session.setSelected(d);
		return true;
	}

	public static function isSphere( o : data.Object ) {
		switch( o ) {
			case O.spher1, O.spher2, O.spher3, O.spher4, O.spher5: return true;
			default : return false;
		}
	}
	
	public static function sphereElement( o : data.Object ) {
		if( !isSphere(o) ) return null;
		return switch( o ) {
			case O.spher1: Data.FIRE;
			case O.spher2: Data.WOOD;
			case O.spher3: Data.WATER;
			case O.spher4: Data.THUNDER;
			default: Data.AIR;
		};
	}
	
	static var PAQUES = null;
	public static function openSurpriseEgg(): data.Object {
		if( PAQUES == null ) {
			var r = Data.REWARDS.list.urma.reward;
			var rand = new mt.deepnight.RandList<data.Object>();
			rand.setFastDraw();
			for( o in r.objects )
				rand.add( o.o, o.count );
			PAQUES = rand;
		}
		return PAQUES.draw();
	}
	
	public static function isEgg( o : data.Object ) {
		return switch( o ) {
			case O.xmase1, O.smegg3, O.fereg3, O.smegg4, O.stzegg, O.feregg, O.kabegg, O.mamegg, O.tufufu, O.rocky2, O.nuago2, O.casti2, O.winks2, O.fereg2, O.stzeg2, O.pigm, O.sirain, O.soufle, O.kabeg2, O.tufeg2, O.quetzu, O.smegg, O.smegg2, O.mameg2, O.mouef2, O.wan2, O.plan2, O.triceg :
				true;
			default: false;
		}
	}
	
	public static function use( o : data.Object, d : db.Dino ) {
		var fx : Dynamic = {};
		var life = function(n) {
			if( !d.canHeal() ) {
				fx = null;
				return false;
			}
			var l = Std.int(n * Skills.calculateObjectLifeBonus(d));
			if( d.life + l > d.maxLife )
				l = d.maxLife - d.life;
			d.life += l;
			if( d.owner != null ) {
				d.owner.incrVar( Data.USERVARS.list.healpv, l);
			}
			fx.pv = l;
			return true;
		};
		
		fx.name = d.name;
		if( d.life == 0 && o != O.angel )
			return null;
		
		switch( o ) {
		case O.irma, O.irma2:
			if( d.action && (d.gather || !handler.PlaceActions.canGather(d)) )
				return null;
			d.action = true;
			d.gather = true;
		case O.angel:
			if( d.life > 0 || d.status != null )
				return null;
			d.life = 1;
			d.status = Data.STATUS.list.heal.sid;
			d.timer = Date.now();
		case O.burger:
			if( d.life >= d.maxLife )
				return null;
			life(10);
		case O.hotpan:
			if( d.life >= d.maxLife )
				return null;
			life(100);
		case O.tartev:
			if( d.life >= d.maxLife )
				return null;
			life(30);
		case O.remed2:
			if( d.life >= d.maxLife )
				return null;
			life(200);
		case O.fruit:
			if( d.life >= d.maxLife )
				return null;
			if( life(15) )
				db.Object.add(R_Misc, Data.OBJECTS.list.noyau,1,d.owner);
		case O.riz:
			if( d.name == null )
				return null;
			d.name = null;
			d.xp = 0;
		case O.stzegg:
			if( !addDinoz(d,Data.DINOZ.list.santaz) )
				return null;
		case O.feregg:
			if( !addDinoz(d,Data.DINOZ.list.feross) )
				return null;
		case O.tix:
			var u = db.User.manager.get(d.uid);
			u.winMoney(1000,"tixuse");
			u.update();
		case O.kabegg:
			if( !addDinoz(d,Data.DINOZ.list.kabuki) )
				return null;
		case O.spher1, O.spher2, O.spher3, O.spher4, O.spher5:
			var elt = switch( o ) {
				case O.spher1: Data.FIRE;
				case O.spher2: Data.WOOD;
				case O.spher3: Data.WATER;
				case O.spher4: Data.THUNDER;
				default: Data.AIR;
			}
			var sph = Data.SKILLS.list.sphere;
			var stmp = new db.Skill();
			stmp.dino = d;
			stmp.sid = sph.sid;
			stmp.unlocked = true;
			stmp.insert();
			var skills = Skills.getLevelupInfos(d, elt);
			stmp.delete();
			var sklist = new Array();
			for( s in skills.learn )
				if( Lambda.has(s.require, sph.sid) )
					sklist.push(s);
			if( sklist.length == 0 )
				return null;
			var sk = sklist[Std.random(sklist.length)];
			Skills.learn(d, sk);
			var sdata = new db.Skill();
			sdata.dino = d;
			sdata.sid = sk.sid;
			sdata.unlocked = true;
			sdata.active = true;
			sdata.insert();
			fx.skill = sk.name;
			db.UserLog.insert(d.owner, db.UserLogKind.KAdminNote, Text.fmt.user_use_sphere( { elt:Data.ELEMENTS[elt], name:d.name } ));
		case O.odemon:
			if( !d.removeEffect(Data.EFFECTS.list.maudit) )
				return null;
		case O.mamegg:
			if( !addDinoz(d,Data.DINOZ.list.mahamu) )
				return null;
		case O.tufufu:
			if( !addDinoz(d,Data.DINOZ.list.toufu) )
				return null;
		case O.paques :
			var surprise = openSurpriseEgg();
			db.Object.add( R_Misc, surprise, 1, d.owner, true );
			App.session.important( Text.get.paques_egg, {icon:surprise.icon, name:surprise.name} );
			fx.cancelNotification = true;
		case O.rocky2:
			if( !addDinoz(d,Data.DINOZ.list.rocky, 1) )
				return null;
		case O.nuago2:
			if( !addDinoz(d,Data.DINOZ.list.nuagoz, 1) )
				return null;
		case O.winks2:
			if( !addDinoz(d,Data.DINOZ.list.winks, 1, 1) )
				return null;
		case O.fereg2:
			if( !addDinoz(d,Data.DINOZ.list.feross, 1, 1) )
				return null;
		case O.stzeg2:
			if( !addDinoz(d,Data.DINOZ.list.santaz, 1, 1) )
				return null;
		case O.pigm:
			if( !addDinoz(d,Data.DINOZ.list.pigmou, Std.random(5)==0 ? 1:0, 1) )
				return null;
		case O.sirain:
			if( !addDinoz(d,Data.DINOZ.list.sirain, Std.random(5)==0 ? 1:0, 1) )
				return null;
		case O.soufle:
			if( !addDinoz(d, Data.DINOZ.list.soufle) )
				return null;
		case O.casti2:
			if( !addDinoz(d, Data.DINOZ.list.casti, 1, 1+Std.random(2)) )
				return null;
		case O.kabeg2:
			if( !addDinoz(d, Data.DINOZ.list.kabuki, 1, 1+Std.random(2)) )
				return null;
		case O.tufeg2:
			if( !addDinoz(d, Data.DINOZ.list.toufu, 0, 1) )
				return null;
		case O.quetzu:
			if( !addDinoz(d, Data.DINOZ.list.quetzu, 1, 1) )
				return null;
		case O.smegg:
			if( !addDinoz(d, Data.DINOZ.list.smog, 1, 1) )
				return null;
		case O.smegg2:
			if( !addDinoz(d, Data.DINOZ.list.smog, Std.random(2)==0 ? 2:0 ) )
				return null;
		case O.mameg2:
			if( !addDinoz(d, Data.DINOZ.list.mahamu, 1, 1) )
				return null;	
		case O.mouef2:
			if( !addDinoz(d, Data.DINOZ.list.mouef, 1, 1) )
				return null;
		case O.wan2:
			if( !addDinoz(d, Data.DINOZ.list.wanwan, 2, 1) )
				return null;
		case O.plan2:
			if( !addDinoz(d, Data.DINOZ.list.plan, 1, 1) )
				return null;
		case O.triceg:
			if( !addDinoz(d, Data.DINOZ.list.trice, 0, 0) )
				return null;
		case O.fereg3:
			if( !addDinoz(d, Data.DINOZ.list.feross, 2, 2) )
				return null;
		case O.smegg3:
			if( !addDinoz(d, Data.DINOZ.list.smog, 0, 2) )
				return null;
		case O.smegg4:
			if( !addDinoz(d, Data.DINOZ.list.smog, 1, 3) )
				return null;
		case O.xmase1:
			if ( Std.random(3) == 0 ) {
				if( !addDinoz(d, Data.DINOZ.list.trice, 0, 0) )
					return null;
			} else {
				if ( !addDinoz(d, Data.DINOZ.list.santaz, 0, Std.random(2) ) ) {
					return null;
				}
			}
		case O.goegg1:
			if( !addDinoz(d, Data.DINOZ.list.gorill, 1, 1) )
				return null;
			
		default:
			return null;
		}
		return fx;
	}

}
