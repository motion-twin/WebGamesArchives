import Fight;
import fight.Fighter;

class Effects {

	static var E = Data.EFFECTS.list;

	public static function apply( f : fight.Fighter, m : fight.Manager, e : db.Effect ) {
		var proba = null;
		switch( Data.EFFECTS.getId(e.eid) ) {
		case E.fcharm:
			f.assaultsBonus[Data.FIRE] += 3;
			proba = 10;
		case E.wcharm:
			f.modDefense(Data.WATER,3);
			proba = 10;
		case E.cuzmal:
			m.setSkin(f,Data.MONSTERS.list.frutox);
			f.armor -= 3;
		case E.mcapt:
			enableCapture(f,m,e);
		}
		if( proba != null && Std.random(proba) == 0 )
			e.delete();
	}

	static function enableCapture( f : fight.Fighter, m : fight.Manager, e : db.Effect ) {
		if(  m.canUseCapture == false ) return;
		var f = f, m = m, side = f.side;
		for( t in m.side(!f.side) )
			if( t.isBoss() )
				return;
		var captures = db.Capture.manager.search({ did : f.dino.id },true);
		var count = 0;
		for( c in captures )
			count += c.count;
		var invoc = new Array();
		if( count < 3 )
			f.addAttack(1,[5,3,1,1,1][count],cast { name : Data.EFFECTS.getId(e.eid).name, energy:10, level: 0 },function() {
				var ml = new Array();
				for( f in m.side(!f.side) )
					if( f.monster != null && !f.isBoss() )
						ml.push(f);
				var t = ml[Std.random(ml.length)];
				if( t == null )
					m.cancel();
				if( m.attackTarget(f,t,_GNormal,_LNormal,null,f.attack(0,0),true).lost == 0 || !t.monster.capture )
					return;
				m.setSide(t,f.side);
				m.effect(_SFHypnose(f.id,t.id));
				invoc.push(t);
				db.Capture.get(f.dino,t.monster).total++;
			});
		m.onStartFight.add(function() {
			var cl = new Array();
			for( c in captures )
				for( i in 0...c.count )
					cl.push(c);
			for( i in 0...3 ) {
				var c = cl[Std.random(cl.length)];
				if( c == null ) break;
				cl.remove(c);
				var t = m.addMonster(Data.MONSTERS.getId(c.mid),f.side);
				t.castleAttacks = 0;
				t.startLife = t.life = c.lifes.pop();
				invoc.push(t);
				m.invocated(f,t);
			}
		});
		m.onEndFight.add(function() {
			for( i in invoc ) {
				if( i.life <= 0 || i.side != side ) continue;
				var c = db.Capture.get(f.dino,i.monster);
				c.lifes.push(i.life);
				c.update();
			}
			for( c in captures )
				c.update();
		});
		f.onKill.add(function() {
			for( i in invoc ) {
				if( i.life <= 0 ) continue;
				if( Lambda.has(m.escaped, i) ) continue;
				m.history(_HEscape(i.id));
				m.removeFromFight(i);
			}
			return true;
		});
	}

}