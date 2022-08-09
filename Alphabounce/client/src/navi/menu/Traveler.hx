package navi.menu;
import mt.bumdum.Lib;
import mt.bumdum.Bouille;
import lander.House;
import Protocol;


class Traveler extends navi.menu.People{//}


	var mission:_Travel;
	var rewardMin:mt.flash.VarSecure;
	var rewardCaps:mt.flash.VarSecure;

	override function init(){
		super.init();


		// DESTINATION
		var szid = lander.Game.me.level.zid;
		var ezid:Int = null;
		var ex:Int = 0;
		var ey:Int = 0;


		// END POS
		if(bs.random(3)==0){	// POINT
			ex = bs.random(300)-150;
			ey = bs.random(300)-150;
		}else{	// PLANETE

			while(true){
				//ezid = bs.random( ZoneInfo.list.length );
				ezid = bs.random( 19 );
				if( lander.Game.isAlive(ezid) && ezid!=szid ){
					var epl = ZoneInfo.list[ezid];
					ex = epl.pos[0];
					ey = epl.pos[1];
					break;
				}
			}
		}


		// REWARD

		var dx = ex-Cs.pi.x;
		var dy = ey-Cs.pi.y;
		var dist = Math.max( Math.abs(dx), Math.abs(dy) );

		// MINERAI
		if( bs.random(10) > 0 )	rewardMin =  new mt.flash.VarSecure( Std.int( dist*( 5+bs.random(15) ) ) );

		// CAPS
		if( bs.random(3) == 0 ) rewardCaps = new mt.flash.VarSecure( Std.int( dist*bs.rand()*0.15 ) );


		mission = {
			_name:null,
			_sx : Cs.pi.x,
			_sy : Cs.pi.y,
			_ex : ex,
			_ey : ey,
			_start: szid,
			_dest : ezid,
		}

		var info = getInfo(mission);
		setText( getIntroText(info) );
		mission._name = info.name ;

		// BUT
		if( Cs.pi.getLife() > 0 ){
			addBut(0,accept);
			addBut(1,quit);
		}else{
			addBut(2,quit);
		}


	}

	public function accept(){
		var h = lander.Game.me.hero.currentHouse;
		//Cs.pi.travel.push(mission);

		h.mark();

		h.alienBehaviour = 0;
		lander.Game.me.travel = mission;
		if( rewardMin != null )		lander.Game.me.incMinerai( rewardMin );
		if( rewardCaps != null )	lander.Game.me.incCaps( rewardCaps );

		quit();
	}


	static public function getInfo(mission){

		var seed = new mt.OldRandom(mission._ex*10000+mission._ey);
		//var seed = new mt.OldRandom(Std.random(10000));

		// NAME
		var a  = Text.get.TRAVELER_NAMES;
		var name = a[seed.random(a.length)];

		// PROFESSION
		var a  = Text.get.TRAVELER_JOBS;
		var profession = a[seed.random(a.length)];

		// USER
		var a = Text.get.TRAVELER_USER;
		var user = a[seed.random(a.length)];

		// STUFF CONSONNE
		var a = Text.get.TRAVELER_STUFF_0;
		var stuff0 = a[seed.random(a.length)];

		// STUFF VOYELLE
		var a = Text.get.TRAVELER_STUFF_1;
		var stuff1 = a[seed.random(a.length)];

		// MISS
		var a = Text.get.TRAVELER_MISS;
		var miss = a[seed.random(a.length)];

		// SINGER
		var a = Text.get.TRAVELER_SINGER;
		var singer = a[seed.random(a.length)];

		return { name:name, seed:seed, profession:profession, miss:miss, user:user, stuff0:stuff0, stuff1:stuff1, singer:singer };

	}

	public function getIntroText(info){



		var str = "";

		// INTRO
		var a  = Text.get.TRAVELER_INTRO;
		str += a[info.seed.random(a.length)];

		// PRESENTATION
		var a  = Text.get.TRAVELER_WHO;
		str += a[info.seed.random(a.length)];

		// LEAVE
		var a0 = Text.get.TRAVELER_LEAVE;
		var a1 = Text.get.TRAVELER_LEAVE_PLANET[mission._start];
		var a = [];
		for( str in a0 )a.push(str);
		for( str in a1 )a.push(str);


		str += " "+a[info.seed.random(a.length)];




		// GOTO
		if( mission._dest !=null ){
			var a  = Text.get.TRAVELER_DEST;
			str += " "+a[info.seed.random(a.length)];


			if( info.seed.random(2)==0 ){
				var a = Text.get.TRAVELER_DEST_PLANET[mission._dest];
				str += " "+a[info.seed.random(a.length)];
			}


		}else{

			var a = Text.get.TRAVELER_DEST_COORD;
			str += " "+a[info.seed.random(a.length)];

		}



		// ASK
		if( Cs.pi.getLife() > 0 ){
			var a = Text.get.TRAVELER_ASK_0;
			str+="\n"+a[info.seed.random(a.length)];

			// PRECISION
			var a = Text.get.TRAVELER_ASK_1;
			str+=" "+a[info.seed.random(a.length)];

			// PAIEMENT GEM
			if( rewardMin !=null ){
				var a = Text.get.TRAVELER_REWARD_MIN_0;
				str+=" "+a[info.seed.random(a.length)];
				if(info.seed.random(3)==0){
					var a = Text.get.TRAVELER_REWARD_MIN_1;
					str+=" "+a[info.seed.random(a.length)];
				}
			}else{
				var a = Text.get.TRAVELER_REWARD_KEUD;
				str+=" "+a[info.seed.random(a.length)];
			}

			// PAIEMENT CAPSULE
			if( rewardCaps !=null ){
				var a = Text.get.TRAVELER_REWARD_CAPS;
				str+=" "+a[info.seed.random(a.length)];
			}
		}else{
			str+=Text.get.TRAVELER_NO_SLOT;
		}



		str = Str.searchAndReplace( str, "::name::", info.name );
		str = Str.searchAndReplace( str, "::profession::", info.profession );
		str = Str.searchAndReplace( str, "::miss::", info.miss );
		str = Str.searchAndReplace( str, "::user::", info.user );
		str = Str.searchAndReplace( str, "::start::", ZoneInfo.list[mission._start].name );
		str = Str.searchAndReplace( str, "::end::", ZoneInfo.list[mission._dest].name );
		str = Str.searchAndReplace( str, "::pos::", "["+mission._ex+"]["+mission._ey+"]" );

		str = Str.searchAndReplace( str, "::stuff0::", info.stuff0 );
		str = Str.searchAndReplace( str, "::stuff1::", info.stuff1 );
		str = Str.searchAndReplace( str, "::singer::", info.singer );

		str = Str.searchAndReplace( str, "::rmin::", Std.string(rewardMin.get()) );
		str = Str.searchAndReplace( str, "::rcap::", Std.string(rewardCaps.get()) );







		return str;

	}





//{
}








