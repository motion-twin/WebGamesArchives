import Protocole;


class Main
{//}
	//public static var mode = FRUIT_EDITOR;
	//public static var mode = GAME;
	//public static var mode = BROWSER;
	
	public static var root:flash.display.MovieClip;
	public static var dm :mt.DepthManager;
	public static var game:Game;
	
	public static var dt:Float;
	
	public static var domain : String ;
	public static var subscribe : String ;
	public static var slogan : String ;
	public static var lang : String ;
	public static var bdata:_DataBrowser;
	
	public static var rec = haxe.Resource.getBytes("replay");
	
	
	static function main() {
	
		//
		haxe.Serializer.USE_ENUM_INDEX = true;
		Codec.VERSION = Data.CODEC_VERSION ;
		
		//
		root = flash.Lib.current;
		dm = new mt.DepthManager(root);
		
		//
		var par = flash.Lib.current.loaderInfo.parameters;
		domain = 	Reflect.field(par, "dom") ;
		subscribe = Reflect.field(par, "sub") ;
		slogan = 	Reflect.field(par, "slogan") ;
		lang = 		Reflect.field(par, "lang") ;
		
		// TIME
		dt = Std.parseFloat( Reflect.field(par, "time") ) - Date.now().getTime();
	
		//
		Fruit.init();
		Gfx.init();
		Lang.init();
		
		
		var mode = 	Reflect.field(par, "mode") ;
		switch(mode) {

			case "browser",null : // BROWSER
				bdata = Codec.getData("data");
				#if dev
				domain = "file:///F:/mesdocs/projets/muxxu/games/snake/clients/arene/bin/index.html";
				bdata = { _cards:[], _plays:0, _age:8, _draft:null, _me:getFalseMe() };
				for( i in 0...200 ) {
					var o:_DataCard = { _type: Cs.getEnum(_CardType, i % Data.CARDS.length), _available:Std.random(2)>0 };
					o._type = Cs.getEnum(_CardType, Std.random(Data.CARDS.length));
					bdata._cards.push(o);
				}
				
				var draftPlayers:Array<_DraftPlayer> = [];
				for( i in 0...Data.DRAFT_PLAYER_MAX ) {
					var data = { _name:["bumdum", "Irvie", "Warp", "Deepnight", "Yota", "Hiko"][i], _avatar:"hale.gif", _id:i, _rank:10 + Std.random(50) };
					var cards  = [];
					for( i in 0...10 ) cards.push({ _type: Cs.getEnum(_CardType, Std.random(Data.CARDS.length)), _available:Std.random(2)>0 });
					draftPlayers.push({_data:data,_cards:0,_packs:0,_score:Std.random(400000),_cardDetails:cards, _per:null});

				}
				var draft = {
					_tid:0,
					_step:DST_WAIT,
					//_step:DST_SUBSCRIBE,
					//_step:DST_DRAFT,
					//_step:DST_PLAY(draftPlayers),
					_players:[],
					_serverUrl:"http://www.frutiparc.com",
					_pKey : "",
					_timeLimit:now()+Std.random(100000000),
				}
				for( i in 0...Data.DRAFT_PLAYER_MAX-Std.random(3) ) draft._players.push({_name:["bumdum","Irvie","Warp","Deepnight","Yota","Hiko"][i],_avatar:"hale.gif",_id:i,_rank:10+Std.random(50)});

				bdata._draft = draft;
				//bdata._cards = [];
				//data._cards = data._cards.splice(0, 10);
				
				#end
				
				if( bdata._draft == null )	new browser.Build(bdata);
				else						new browser.Draft(bdata);
			
			case "demo" :
				launchDemo();
				
			case "replay" :
				var data:_DataReplay = Codec.getData("data");
				launchGame(data._id, data._hand, data._sid, data._rec );
				game.showPlayer(data._player, data._score, data._dateString);
				

		#if dev
			case "demo_record" :
				var cards = [];
				var sum = 0;
				while( cards.length < 3 ) {
					var id = Std.random(60);
					var type = Cs.getEnum(_CardType, id);
					var add  = true;
					for( t in cards ) if( t == type ) add = false;
					if( add ) cards.push(type);
				}
				launchGame( 0, cards, Std.random(9999), null, true );
				
			case "game" :
				var o = flash.net.SharedObject.getLocal("snake_replay");
				if( o.data.str != null ) {
					var data:_DataReplay = haxe.Unserializer.run(o.data.str);
					if(rec!=null && false ){
						data._rec = rec;
						data._sid = 32160;
						var a = [14, 14, 67, 22];
						
						data._hand = [];
						var cons = Type.getEnumConstructs(_CardType);
						while( a.length > 0 ) data._hand.push( Type.createEnum(_CardType,cons[a.shift()]));
					}
					launchGame(data._id, data._hand, data._sid, data._rec );
					game.showPlayer(data._player,data._score, data._dateString);
				}else{
					var a = Cs.START_CARDS;
					if( a.length == 0 ) for( n in 0...6 ) a.push(Cs.getEnum(_CardType, Std.random(75)));
					launchGame(0, a, Std.random(999));
				}
				
			case "fruit_editor" :
				var editor = new utils.FruitEditor();
				root.addEventListener(flash.events.Event.ENTER_FRAME, editor.update);
				
			case "fruit_export" :
				new utils.FruitExport();
		#end
		
		}
		
		//
		//garbageCollectorCheat() ;
	}
	
	static public function launchGame( id, cards, sid, ?rec, ?demo ) {
		if ( game != null ) {
			root.removeEventListener(flash.events.Event.ENTER_FRAME, game.updateAll) ;
			game.kill();
		}
		game = new Game(id,cards,sid,rec,demo);
		root.addEventListener(flash.events.Event.ENTER_FRAME, game.updateAll) ;
	}

	//
	static public function garbageCollectorCheat() {
		mt.flash.Gc.init();
	}
	
	/*
	static public function initTexts() {
		
		var c:Dynamic = null;
		#if fr
		return;
		#elseif en
		c = LangEn;
		#elseif de
		c = LangDe;
		#end
		
		for( f in Type.getClassFields(c) ) {
			var v : Dynamic = Reflect.field(c, f);
			if( Reflect.isFunction(v) ) continue;
			Reflect.setField(Lang, f, v );
		}
	}
	*/
	
	// TOOLS
	
	static public function refresh() {
		var url = new flash.net.URLRequest(Main.domain);
		Codec.displayError = function(e) {} ;
		flash.Lib.getURL(url,"_self");
		//while( flash.Lib.current.numChildren > 0 ) flash.Lib.current.removeChildAt(0);
	}
	
	static public function now() {
		return Date.now().getTime() + dt;
	}
	
	// DEMO
	static public var demoId:Null<Int>;
	static public function launchDemo() {
		if( demoId == null ) demoId = Std.random(DEMO.length);
		demoId = (demoId + 1) % DEMO.length;
		var data:_DataReplay = haxe.Unserializer.run(DEMO[demoId]);
		launchGame(data._id, data._hand, data._sid, data._rec, true );
	}
	
	
	
	// POOLS
	static public function emptyPools() {
		Part.POOL = [];
		Bonus.POOL = [];
		Fruit.POOL = [];
		part.BloodDrop.POOL = [];
		part.Line.POOL = [];
		part.Globule.POOL = [];

	}
	
	
	#if dev
	public static var REPLAY_DATA = "";
	
	public static function getFalseMe() {
		return { _name:"bumdum", _avatar:"hale.gif", _rank:11, _id:0 };
	}
	
	#end
	
	public static var DEMO = [
		"oy4:_sidi7402y3:_idzy4:_recs166:eNrFVUEOwCAIK:L:Py9uh2UoFR1u7c1gqw0i4EJEb0KLQwRo9pxQzr7ApFFQn63t4uUijAZNAZZILZ06phJVHp9ZPuAf:khuGqRq2fvv048%Ltv%3VeRnX9oKEVHybvRtOLfjotnRMXDMJf6EVDM6dEM8zqsJnIAhUoN7gy5:_handajy9:_CardType:12:0jR4:18:0jR4:46:0hg",
	"oy4:_sidi3425y3:_idzy4:_recs251:eNqtVFEWwyAIA2zvf%W9usnAAiJt8mXrA0yiAAs0aMi8VlTiKReQKgQOeRykP5JjyDqZbrs19wRCi5fopDHaKFeo3HaScWLvgx0yB9ZI9EifQ:%OjKDXadfX38IdrIjQZivGuXNBhrNBZWtmnouRyUjFDTjQYvIhnPq69cglV7d8qKi%2pfy8z4wJK4dmYKGz5ZxrxWsonF9cEbN5bD0QmSi2EX92v0b6P1HARMEM%OO2SqgEr4jHyZ7Ds8y5:_handajy9:_CardType:30:0jR4:14:0jR4:53:0hg",
		"oy4:_sidi8092y3:_idzy4:_recs219:eNqlVEkSwCAIC:r:P9facSmyqeHSsQokLIAGIsqUUS2ZhsXEex3OYwSCYsvYqwqWx4dB:UX7bPcVBn528h:%qsj9Q94xk7qLERSRgssslbSYdL56cgzS:fcq:eRj7SzyDkXXzu2CxGU36nkglc8Yrqo8FWuY4:O8M9:pqAPdOOk278lPMKsbLmuvq610uB%Ptef7cpo%eUQxb9Q2ocXFAzLaDDcy5:_handajy9:_CardType:19:0jR4:33:0jR4:56:0hg",
		"oy4:_sidi9863y3:_idzy4:_recs196:eNq1VFsOgCAM20q4:5UVRRFwHZDQ:hFgj3YTIVDV8MMaaBB8ygTZGyzRizT%x1J8QKLsRtbie5QyTpqeCtJut1K6V5caj3Xx6hK9RJ3g1L1K2BdR5zVhwPHhKMENa:mCeF%:vIqJxFxANOKNzdfjSIH1fsYYRKe8yhK%q62gE5Y3KQ%S6v45ttZyKeaW4AB0qglBy5:_handajy9:_CardType:40:0jR4:36:0jR4:46:0hg",
		"oy4:_sidi896y3:_idzy4:_recs214:eNqtU0kOwCAIBEz6:ye3aWWRRW3a4WIUWYYBYAJsauCMvtqFOwfajMRABT94v35yX0OSgN4AvrSkyApM0sAlNyNP7B1op4oz4T77VQ4xx46rbbeMH5RREMjwmoIpF1X5rgmrk:aXRWH6OdlbPmptVM6w1tCsz0xpPWRal9S2DLNTg2LI7nM9q9pShYybDxRWdoK1GKTHltlGjuME3m8G1Qy5:_handajy9:_CardType:21:0jR4:22:0jR4:10:0hg",
		"oy4:_sidi4222y3:_idzy4:_recs342:eNqtVlsSwyAIXGjH%x%5mcb4QFAMwkc6DSgLCwSQ8nmUhEIoC4VpYft41L4VkzurpvyjlWXwPWjhzbYfO9JyLhnzEvFrhSvqCKq9COGM6CxSz:medrB8UzS4YqkxerdN:K2HF6jhauP92mnne4bVWYbEeSiVFjoSYEGCFooP5iZ5zNn63ypEiYqg2ParJ%Unz:BUt3ogtdbKG0duZDa%GnCtChFWzerL49ZRNhCWJ52L%f1Ezv8nGBJOpF6szS%WQr1jAYybOQLPc%s4T29gHlA3dmvBcNe0ubs0hg2CKYPF%YUTl58mqY6IUq92ZvTWfdhkSqzop9roSeEP%aYXEAy5:_handajy9:_CardType:13:0jR4:41:0jR4:23:0hg",
		"oy4:_sidi3780y3:_idzy4:_recs211:eNq1VNESgCAMYuv::7k6zWbFpM7gpbx1MtgCCJZIr4RIS6nUfGGv9R:yHvvTVrfBCl51McEPgzf87EU87TU0CEmdnpmxLxXvQJSdtxCNw1vx3KWqrcWBrsVPg%5kTOQ1NIT5yAaFm5nZ7CQGyNyqR7M7Tluiv0miwB8hSs2boG5M5%zf75FYjjD5qMuww8Pz9T3sTcU9sLoSK8cdDRoy5:_handajy9:_CardType:25:0jR4:7:0jR4:46:0hg",
		"oy4:_sidi5927y3:_idzy4:_recs235:eNq1VVkWgCAIZHnd:8rtpbFbzfzxRGAQBAiAiCwJTB0n4gohIJXp%45EKOejAFuwQwQ4fdyLG:Pq1cJ0:0BdeYdeB9jnfCnspLBEGGCTIteZl7UTYiDKO2VQbdvkCRe9glfTIqY23gRPu9XI0TcebqgN3oNeztyzuh:XxtIp0wUmQPRD7VmFDvv%b3R:SHYRlmfYvCX:mckd1a9mff:KvmSm8JJFbZ0RSS10BiD6Dpoy5:_handajy9:_CardType:7:0jR4:14:0jR4:25:0hg",
		"oy4:_sidi5927y3:_idzy4:_recs235:eNq1VVkWgCAIZHnd:8rtpbFbzfzxRGAQBAiAiCwJTB0n4gohIJXp%45EKOejAFuwQwQ4fdyLG:Pq1cJ0:0BdeYdeB9jnfCnspLBEGGCTIteZl7UTYiDKO2VQbdvkCRe9glfTIqY23gRPu9XI0TcebqgN3oNeztyzuh:XxtIp0wUmQPRD7VmFDvv%b3R:SHYRlmfYvCX:mckd1a9mff:KvmSm8JJFbZ0RSS10BiD6Dpoy5:_handajy9:_CardType:7:0jR4:14:0jR4:25:0hg",

	];

	// DATA
	/*
	var o = new flash.utils.ByteArray();
	o.writeByte(9);
	o.compress();
	var b = haxe.io.Bytes.ofData(o);
	*/
	
	
//{
}












