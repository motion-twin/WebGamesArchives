import mt.bumdum.Lib;
import Data;

class InterGlad{//}


	var shake:Float;
	var wait:Int;
	var loaded:Int;
	var prc:Float;
	public var root:{ >flash.MovieClip, bar:flash.MovieClip, red:flash.MovieClip, pic:{>flash.MovieClip,_init:String->Int->Void}, field:flash.TextField };
	var fighter:Fighter;
	var mcCross:flash.MovieClip;
	var dm:mt.DepthManager;

	public function new(mc) {

		root = cast mc;
		prc = 100;
		Filt.glow(root,2,4,0);
		dm = new mt.DepthManager(root);




	}


	public function update() {

		if(wait--<0)root.red._xscale += (prc - root.red._xscale)*0.15;
		root.red._alpha-=1.5;
		var bx = 15;
		//trace(root.pic._x);
		root.pic.filters = [];
		if(shake!=null){

			root.pic._x = bx+shake;
			shake *= -0.75;
			var c = Math.abs(shake/10);
			if(c<0.1){
				shake = null;
				root.pic._x = bx;
				c = 0;
			}


			var m = [
				0.6,	0.33,	0.33,	0,	0,
				0,	0,	0,	0,	0,
				0,	0,	0,	0,	0,
				0,	0,	0,	1,	0,
			];

			Filt.grey(root.pic,c,null,null,m);
		}



	}

	public function setLife(nprc){
		if(nprc<prc)shake = 10;
		root.red._alpha=100;

		wait = 8;

		prc = nprc;
		if(prc<=0){
			//Filt.grey(root.pic,1);
			prc = 0;
			if(mcCross == null ){
				mcCross = dm.attach("mcDeathCross",20);
				mcCross._x = 25;
				mcCross._y = 51;
			}
		}

		root.bar._xscale = prc;

	}

	public function displayWeapon(){
		dm.clear(0);
		var i = 0;
		//trace(fighter.gladiator.weapons.length);
		var max = 11;
		for( wid in fighter.gladiator.weapons ){
			var mc = dm.attach("mcWeaponIco",0);
			mc.gotoAndStop(Type.enumIndex(wid)+1);
			mc._x = 63 + (i%max)*16;
			mc._y = 43 + Math.floor(i/max)*16;
			i++;
		}
	}


	public function setFighter(f){
		fighter = f;

		loaded = 0;

		var mcl = new flash.MovieClipLoader();
		mcl.onLoadComplete = skinLoaded;
		mcl.onLoadInit = skinLoaded;
		mcl.onLoadError = function(mc,str) haxe.Log.trace("File not found",null);
		mcl.loadClip( Game.me.data._mini, root.pic );


		// NAME
		var scx = 1.5;
		root.field.text = f.gladiator.name.toUpperCase();
		root.field._xscale = -f.side*100*scx;
		if(f.side==1)root.field._x += root.field.textWidth*scx;

		// ROLLOVER
		var str = "";
		str += getStrong( "("+(f.gladiator.lvl+1)+")"+StringTools.htmlEscape(f.gladiator.name) )+"<br/>";
		str += Lang.CARACS[0]+" : "+getStrong( ""+f.gladiator.force )+"<br/>";
		str += Lang.CARACS[1]+" : "+getStrong( ""+f.gladiator.agility )+"<br/>";
		str += Lang.CARACS[2]+" : "+getStrong( ""+f.gladiator.speed )+"<br/>";
		str += Lang.MISC[5]+" : "+getStrong( ""+f.gladiator.getLife() )+"<br/>";

		str += getStrong(Lang.MISC[6]+" : ");
		var flFirst = true;
		for( o in f.gladiator.supers ){
			if(!flFirst)str+=", ";
			str += Lang.SUPERS[Type.enumIndex(o)];
			flFirst = false;
		}
		str += "<br/>";

		str += getStrong(Lang.MISC[7]+" : ");
		var flFirst = true;
		for( b in f.gladiator.bonus){
			switch(b){
				case Permanent(p):
					if(!flFirst)str+=", ";
					str += Lang.PERMANENTS[Type.enumIndex(p)];
					flFirst = false;
				default:
			}

		}

		//str+="\nseed:"+f.id;

		Game.me.setHint(cast(root).cadre,str,160);


	}
	function getStrong(str){
		return "<b>"+str+"</b>";
	}

	public function skinLoaded(mc){
		loaded++;
		if(loaded<2)return;

		var inf = fighter.getInfos();
		root.pic.gotoAndStop(inf.frame);
		root.pic.smc.gotoAndStop("slot");
		root.pic._init( fighter.skin, inf.chk );
		root.pic._x = 15;
		root.pic._y = 80;
		root.pic._xscale = root.pic._yscale = 120;
		root.pic.smc.smc.stop();

		//root.pic._visible = false;

		//root.pic.cacheAsBitmap = true;
		// NAME


		// charles ingalls VS akenathon
		// Zidane VS Materazzi
		// Jeanne VS Serge

		// thuram

	}

//{
}
