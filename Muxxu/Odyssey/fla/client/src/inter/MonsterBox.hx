package inter;
import Protocole;
import mt.bumdum9.Lib;
import mt.bumdum9.Rush;
using mt.bumdum9.MBut;


class MonsterBox extends SP {//}

	public static var WIDTH = 244;//60;//120;//92;
	public static var HEIGHT = 25;
	
	var title:TF;
	
	var mon:Monster;
	var life:Counter;
	var armor:Counter;
	var atk:Counter;
	
	public var counters:Array<Counter>;
	
	var icons:Array<MC>;
	
	public function new(monster:Monster) {
		super();
		mon = monster;
		x = (Game.me.fgs[0]._infoBox.x) - 120;
		y = Scene.HEIGHT;
		
		
		icons = [];
		var cx = 0;
		
		title = Cs.getField(0xFFFFFF,16,"diogenes");
		title.x = cx;
		title.y = -2;
		title.text = mon.data.name;
		title.width = WIDTH;
		title.height = 32;
		addChild(title);

		cx += 60;
		
		var a = [];
		for ( i in 0...3) {
			var shieldFrame = [1, 8, 6][mon.getArmorType()];
			var counter = new Counter([0,shieldFrame,5][i]);
			counter.x = WIDTH - (i + 1) * 40;//cx + i * 40;
			counter.y = 4;
			counter.setDigits(2);
			
			addChild(counter);
			a.push(counter);
			
			var name = "name";
			var desc = "desc";
			switch(counter.gid) {
				case 0 :
					name = "Points de vie";
					desc = "Réduisez les points de vie du monstre à zéro pour le détruire !";
					
				case 1 :
					name = "Bouclier";
					desc = "Pour chaque dégât physiques reçu le monstre protège un point par bouclier";
					
				case 8 :
					name = "Evasion";
					desc = "Tous les dégâts superieur à cette somme sont ignorés, innéficace contre les projectiles";
					
				case 6 :
					name = "Bouclier magique";
					desc = "Pour chaque dégât magiques reçu le monstre protège un point par bouclier";
					
				case 5 :
					name = "Attaque";
					desc = "Dégâts physiques reçus par le premier joueur en cas d'attaque";

			}
			var hint = "<div class='monster_counter'><h1>" + name + "</h1><p>" + desc + "</p></div>";
			Game.me.makeHint(counter, hint);
			
		}
		
		life = a[0];
		armor = a[1];
		atk = a[2];
		
		counters = a;
		
		graphics.beginFill(0xFF0000,0);
		graphics.drawRect(0, 0, WIDTH, HEIGHT);
		
	}
	
	public function maj() {
		
		//title.text = "("+mon.data.lvl+")" + mon.data.name;
		title.text =  mon.data.name;
		
		// CARACS
		life.set(mon.life);
		armor.set(mon.getArmor());
		atk.set(mon.getAttack());
		
		
		// STATUS
		displayStatus(atk.x-20,atk.y);
		
		
		
		
	}
	
	public function displayStatus(bx:Float,by:Float) {
		for ( el in icons ){
			removeChild(el);
			el.removeEvents();
		}
		icons = [];
		
		var bx = title.x + title.textWidth + 10;
		
		
		// STATUS + SKILLS
		var a = [];
		var skills = mon.getSkills();
		var allStatus = [];
		for ( sk in skills ) {
			var data = Data.SKILLS[Type.enumIndex(sk)];
			if ( !data.visible ) continue;
			
			var hint = "<div class='skill_desc'><h1>" + data.name + "</h1><p>" + data.desc + "</p></div>";
			a.push( { lib:"skills", fr:Type.enumIndex(sk) - Type.enumIndex(VENOM), hint:hint, num:0 } );
			
		}
		for ( o in mon.status ) {
			var sid = Type.enumIndex(o.sta);
			var data = Data.STATUS[sid];
			var hint = "<div class='status_desc'><h1><img src='"+Main.path+"/img/status/status_"+sid+".png' alt='"+data.name+"' /> " + data.name + "</h1><p>" + data.desc + "</p></div>";

			if ( allStatus[sid] == null ) {
				var obj = { lib:"status", fr:sid, hint:hint, num:0 };
				allStatus[sid] = obj;
				a.push( obj );
			}
			allStatus[sid].num++;
		}
				

		for ( o in a ) {
		
			var el:MC = new StatusIcons();
			if (o.lib == "skills") el = new SkillIcons();
			el.x = bx;
			el.y = by;
			el.gotoAndStop(o.fr+1);
			el.filters = [new flash.filters.DropShadowFilter(1, 45, 0, 1, 0, 0, 100)];
			addChild(el);
			icons.push(el);
			//mt.bumdum9.Hint.me.addItem(el, o.hint);

			if ( o.num > 1 ) {
				var tf = TField.get(0xFFFFFF);
				Filt.glow(tf, 2, 4, 0);
				el.addChild(tf);
				tf.text = "x" + o.num;
				tf.x = 4;
				tf.y = 4;
			}
			
			Game.me.makeHint(el, o.hint);
			bx += 18;
			
		}
		
		bx += 6;
		// COUNTER
		for ( co in counters ) {
			co.x = bx;
			bx += 40;
		}
		
		// RESIZE BAR
		var size = bx;
		
		for( i in 0...2 ){
			var box = Game.me.fgs[i]._infoBox;
			box._b.width = size;
			box._a.x = -size*0.5;
			box._c.x = size * 0.5;
			x = box.x+box._a.x;
		}
		
		
		
		
		
	}
	
	public function fxArmor() {
		// TODO
		new mt.fx.Flash(counters[1]);
	}
	
	
	
//{
}








