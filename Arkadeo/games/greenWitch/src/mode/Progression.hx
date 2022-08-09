package mode;

import api.AKApi;
import Const;
import Level;

class Progression extends Play {
	public var depth	: mt.flash.Volatile<Int>;
	public var level	: mt.flash.Volatile<Int>;
	var tutorialStep	: Int;
	var curGuide		: Null<flash.display.Bitmap>;
	var levelTimer		: Int;
	
	public function new() {
		level = api.AKApi.getLevel();
		levelTimer = 0;
		depth = 0;
		tutorialStep = level==1 ? 0 : 3;
		super();
		
		hero.loadState( AKApi.getState() );
	}
	
	function guide(msg:String) {
		var wrapper = new flash.display.Sprite();
		
		var tf = createField(msg, 0xFFFFFF);
		wrapper.addChild(tf);
		tf.multiline = tf.wordWrap = true;
		tf.width = 150;
		tf.height = 200;
		tf.width = tf.textWidth+5;
		tf.height = tf.textHeight+5;
		tf.filters = [ new flash.filters.DropShadowFilter(2,90, 0x0,0.3, 0,0,1) ];
		
		wrapper.graphics.beginFill(0x584FB0,1);
		wrapper.graphics.drawRect(-5, -3, tf.width+10, tf.height+7);
		wrapper.filters = [
			new flash.filters.GlowFilter(0x0,1, 2,2,1, 1,true),
			new flash.filters.DropShadowFilter(2,90, 0x0,0.3, 0,0,1, 1,true),
			new flash.filters.GlowFilter(0xFFFFFF,1, 2,2,8),
			new flash.filters.GlowFilter(0x0,1, 2,2,8),
		];
		wrapper.alpha = 0.85;
		
		curGuide = mt.deepnight.Lib.flatten(wrapper, 2);
		dm.add(curGuide, Const.DP_INTERF);
		curGuide.scaleX = curGuide.scaleY = 2;
		curGuide.x = -curGuide.width;
		curGuide.y = Const.HEI-curGuide.height-35;
		
		delayer.add(function() {
			if( curGuide!=null )
				tw.create(curGuide, "x", Std.int(Const.WID*0.5-curGuide.width*0.5), TEaseOut, 500);
		}, 800);
	}
	
	function hideGuide() {
		if( curGuide==null )
			return;
			
		tw.terminate(curGuide);
		var bmp = curGuide;
		curGuide = null;
		tw.create(bmp, "y", bmp.y-50, 900);
		tw.create(bmp, "alpha", 0, 1000).onEnd = function() {
			if( bmp.parent!=null )
				bmp.parent.removeChild(bmp);
			if( bmp.bitmapData!=null )
				bmp.bitmapData.dispose();
		}
	}
	
	function showTuto(step:Int, msg:String) {
		if( curGuide==null && tutorialStep==step )
			guide(msg);
	}
	
	public function endTutoStep(step:Int) {
		if( curGuide!=null && tutorialStep==step ) {
			hideGuide();
			tutorialStep++;
			if( level==1 && depth==0 && tutorialStep>=1 )
				for(d in en.Door.ALL)
					d.locked = false;
		}
	}
	
	override public function generateLevel() {
		super.generateLevel();
		
		var armor = level==1 ? 0 : rseed.irange(1,5);

		setLevel( Level.createProgressionLevel(level, depth), armor );
		currentLevel.draw();

		// Sortie
		var pt = currentLevel.getMetaOnce("exit", rseed);
		if( pt!=null )
			new en.Exit(pt.cx, pt.cy);
		
		if( level>1 || depth>0 ) {
			
			// Civils
			var a : Array<Entity> = [hero];
			var size = Math.sqrt( currentLevel.wid * currentLevel.hei );
			var n =
				if( size<=16 ) 4;
				else if( size<=32 ) 6;
				else if( size<=48 ) 12;
				else if( size<=56 ) 18;
				else 24;
			for( i in 0...n ) {
				var tries = 100;
				while(tries-->0) {
					var pt = currentLevel.getMetaOnceFarFromOthers("middle", rseed, a);
					if( pt!=null ) {
						a.push( new en.it.Civilian(pt.cx, pt.cy) );
						break;
					}
				}
			}
			
			var inf = Level.getLevelInfos(level, depth);
			
			// Distributeurs
			var a = [];
			for( d in inf.dispenser ) {
				var pt = currentLevel.getMetaOnceFarFromOthers("onWall", rseed, a);
				if( pt!=null )
					a.push(new en.Dispenser(pt.cx, pt.cy, d));
				#if debug
				else
					trace("WARNING: no room for "+d);
				#end
			}
			
			// Cartes
			var a = [];
			for(i in 0...rseed.irange(4,6)) {
				var pt = currentLevel.getMetaOnceFarFromOthers("onWall", rseed, a);
				if( pt!=null )
					a.push( new en.Map(pt.cx, pt.cy) );
			}
			
			// Soins
			var a = [];
			var n = inf.heal<0 ? rseed.irange(2,4) : inf.heal;
			for(i in 0...n) {
				var pt = currentLevel.getMetaOnceFarFromOthers("middle", rseed, a);
				if( pt!=null )
					a.push( new en.it.Heal(pt.cx, pt.cy) );
			}
			
			/***/
			// Monstres
			for(minf in inf.mobs) {
				if( minf.n<10 )
					// Monstres isolés
					for(i in 0...minf.n)
						addMobs(minf.mclass, 1);
				else {
					// Packs
					var n = minf.n;
					while( n>0 ) {
						var size = Std.int( Math.min(3,n) );
						addMobs(minf.mclass, size);
						n-=size;
					}
				}
			}
			/***/
		}
		else if( depth==0 ) {
			// Niveau 1 custom
			for(i in 0...10)
				new en.mob.Rabbit(13,11);
			for(i in 0...5)
				new en.mob.Rabbit(21,23);
			for(i in 0...8)
				new en.mob.Rabbit(26,7);
			for(d in en.Door.ALL)
				d.locked = true;
		}
		
		// Nom du niveau
		if( depth==0 && Lang.ALL.exists("Level"+level) )
			delayer.add(function() {
				placeName(Lang.ALL.get("Level"+level), 0xFFFFFF);
			}, 500);
	}
	
	
	function addMobs(c:Class<en.Mob>, ?packSize=1) {
		var a : Array<Entity> = [hero];
		var pt = currentLevel.getMetaOnceFarFromOthers("middle", rseed, a);
		if( pt==null )
			trace("WARNING : not enough room for "+c);
		else
			for(i in 0...packSize)
				Type.createInstance(c, [pt.cx, pt.cy]);
	}
	
	override function onLevelComplete() {
		super.onLevelComplete();
		if( level==1 && depth==1 )
			showTuto(4, Lang.TutorialExit);
	}
	
	override function onExit() {
		if( gameEnded )
			return;
			
		if( Level.isLastProgressionLevel(level, depth) ) {
			// Fin du niveau
			hero.heal(3);
			gameEnded = true;
			fx.fadeOut();
			delayer.add(function() {
				endGame(true);
			}, 700);
			return;
		}
		else {
			// Etage suivant
			if( currentLevel!=null )
				currentLevel.destroy();
				
			for(e in Entity.ALL)
				if( e!=hero )
					e.destroy();
			flushKillList();
			
			hero.stop();
			hero.setTurret(hero.turretType);
			hero.setWeapon(hero.weaponType);

			levelTimer = 0;
			depth++;
			generateLevel();
			fx.fadeIn(1000);
			hero.zz = 100;
			
			endTutoStep(4);
		}
	}
	
	
	
	override function update() {
		super.update();
		
		if( level>1 || depth>0 )
			if( levelTimer>30*20 )
				repopMob(15+level*5, 40, en.mob.Skeleton, 30*10, 8);
		
		if( level==1 ) {
			if( hero.cy<=19 )
				showTuto(0, Lang.Tutorial0);
			if( hero.cy<=8 )
				showTuto(1, Lang.Tutorial1);
			if( hero.turret!=null )
				endTutoStep(0);
			if( mobs.length==0 || depth!=0 )
				endTutoStep(1);
			if( depth==1 )
				showTuto(2, Lang.Tutorial2);
		}
		if( level==1 && depth==1 && hero.turretCasts==1 || level==2 && depth==0 && hero.turretCasts==0 )
			showTuto(3, Lang.TutorialTurret);
		levelTimer++;
	}
}


