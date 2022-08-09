package data;

class Tools {

	#if neko
	public static inline function hash( dialog : String ) : Int untyped {
		return __dollar__fasthash(dialog.__s);
	}
	#end
	
	public static function cleanTextFromTemplo(pText:String) {
		pText = StringTools.trim(pText);
		var lines:Array<String> = pText.split("\r\n");
		if ( lines.length == 1 )
			lines = pText.split("\r");
		if ( lines.length == 1 )
			lines = pText.split("\n");
		
		var emptyCount = 0;
		var isList = false;
		var isStarted = false;
		var linesToRemove = [];
		for ( i in 0...lines.length ) {
			var l = lines[i];
			var trimed = StringTools.trim(l);			
			if ( trimed.length == 0 ) {
				var limit = isList ? 0 : 1;
				if ( isStarted ) emptyCount ++;
				if ( emptyCount > limit )
					linesToRemove.unshift(i);
			} else {
				//for gérer correctement la sortie des listes
				var wasList = isList;
				isList = StringTools.startsWith(trimed, "* ");
				if ( wasList && !isList && linesToRemove.length > 0 )
					linesToRemove.shift();
				//
				emptyCount = 0;
				isStarted = true;
				if (!isList ) lines[i] = trimed;
			}
		}
		
		for ( index in linesToRemove ) {
			lines.splice(index, 1);
		}
		return lines.join("\n");
	}
	
	public static function format( text, ?trim ) {
		if( trim == null || trim == true )
			text = StringTools.trim(text);
		text = ~/\[([^}]+?)\]/g.replace(text,'<p>$1</p>');
		text = ~/\*([^*]+?)\*/g.replace(text, '<strong>$1</strong>');
		text = ~/_([^*]+?)_/g.replace(text,'<em>$1</em>');
		text = ~/@([^*]+?)@/g.replace(text,'<img src="$1" alt="" />');
		return text;
	}
	
	//check if not present anywhere else
	public static function format2(text, params:{}, ?trim ) {
		if( trim == null || trim == true )
			text = StringTools.trim(text);
		var a = ~/::([^}]+)::/g.split(text);
		return Lambda.map( a, function( elt ) return Reflect.field(params,elt) ).join('');
	}
	
	public static function intArray( str : String ) {
		return Lambda.array(Lambda.map(str.split(":"),Std.parseInt));
	}

	public static function makeId( id : String ) {
		return mt.db.Id.encode(id);
	}

	public static function makeName( id : Int ) {
		return mt.db.Id.decode(id);
	}

	public static function element( str : String ) {
		for( i in 0...Data.ELEMENTS.length )
			if( Data.ELEMENTS[i].name == str )
				return i;
		throw "Invalid element "+str;
	}

	public static function parseTime( s : String ) : Float {
		var id = s.indexOf("(");
		if( id == -1 ) return Std.parseFloat(s);
		var m = s.substring(0, id);
		var id2 = s.indexOf(")");
		if( id2 == -1 ) throw "Invalid xml attribute time format : " + s + ", missing parenthesis";
		var t = Std.parseFloat( StringTools.trim(s.substring(id + 1, id2)) );
		return Reflect.callMethod( DateTools, Reflect.field(DateTools, m), [t] );
	}
	
/*
	public static function getInquisitionMultis( u: db.User ) {
		var inq = new mt.net.Inquisition( Std.parseInt(Config.get('mt_cash_id')) );
		inq.userId = u.id;
		return
			if(Config.BETA)
				inq.query();
			else
				inq.query("http://dev.inquisition.com/query");
	}
*/	
	public static function generateSurvey( pid : Int, ?popup ) {
		var pop = popup ? "1" : "0";
		var output = "<div id='poll'></div><script type='text/javascript'>_.loadJS('http://trax.motion-twin.com/tools/poll?"+getSurveyParams(pid)+";popup="+pop+";v="+DefaultContext.version('js')+"', 'poll');</script>";
		return output;
	}
	
	public static function getSurveyParams(pid) {
		var params = {
				sid : tools.BankImpl.CASH_ID,
				uid : (App.user == null) ? null : App.user.id,
				admin : (App.user == null) ? false : App.user.isAdmin,
				lang : Config.LANG,
				pid	: pid,
		};
		var u = App.user;
		if(  u != null ) {
			if( u.clanUser != null ) {
				Reflect.setField(params, "hasClan", true);
				Reflect.setField(params, "clan", u.clanUser.cid );
			} else {
				Reflect.setField(params, "hasClan", false);
			}
			Reflect.setField(params, "points", u.points );
			Reflect.setField(params, "dinos", u.ndinoz );
			Reflect.setField(params, "payed", Db.execute("SELECT * FROM BankLog WHERE uid=" + u.id + " LIMIT 1").length );
			var d = DateTools.delta( Date.now(), - u.createDate.getTime() );
			Reflect.setField(params, "month", ((d.getFullYear() - 1970) * 12 + d.getMonth()) );
			#if !twinoid
			Reflect.setField(params, "refid", u.refid );
			Reflect.setField(params, "ref", ( u.refUser == null ) ? null : u.refUser.id );
			#end
			Reflect.setField(params, "forum", DateTools.delta( Date.now(), -DateTools.days(7) ).getTime() > u.forumDate.getTime() );
			
			for( v in Data.USERVARS )
				Reflect.setField( params, v.id, db.UserVar.getValue(u, v ) );
			for( s in Data.SCENARIOS )
				Reflect.setField(params, s.id, db.Scenario.get(s, u) );
		}
		var sparams = haxe.Serializer.run(params);
		var cid = tools.BankImpl.CASH_SIGN;
		if( cid == "" ) cid = "null";
		return "data=" + StringTools.urlEncode(sparams) + ";chk=" + haxe.Md5.encode(sparams + cid + sparams.length);
	}
	
	public static function generateCode() {
		var character_set_array = [];
		character_set_array.push({count:7, characters: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' });
		character_set_array.push({count:1, characters: '0123456789' });
		var temp_array = [];
		var r = new neko.Random();
		for ( character_set in character_set_array ) {
			for ( i in 0...character_set.count ) {
				temp_array.push( character_set.characters.charAt( r.int( character_set.characters.length - 1 ) ) );
			}
		}
		temp_array = shuffle( temp_array );
		return temp_array.join('');
	}
	
	public static function shuffle<T>( a : Array<T>, ?rand : neko.Random ) : Array<T> {
		var output = [];
		var rnd = (rand != null) ? rand.int : Std.random;
		while ( a.length > 0 ) {
			var e = a[rnd(a.length)];
			output.push(e);
			a.remove( e );
		}
		return output;
	}
	
	public static function random<T>( a : Array<T>, f : T -> Int, r : neko.Random ) : Int {
		var p = new Array();
		var tot = 0;
		for( x in a ) {
			if( x == null ) {
				p.push(0);
				continue;
			}
			var n = f(x);
			tot += n;
			p.push(n);
		}
		if( tot == 0 )
			return null;
		var n = r.int(tot);
		for( i in 0...p.length ) {
			n -= p[i];
			if( n < 0 )
				return i;
		}
		return null;
	}
	
	public static function getUserMissionProgress( u : db.User ) {
		var total = Lambda.count(Data.MISSIONS);
		var uprogress = Lambda.count(db.Mission.manager.getMissionsDoneByUser(u));
		return DefaultContext.percent(uprogress, total);
	}
	
	public static function getUserScenarioProgress( u : db.User ) {
		var total = 0, uprogress = 0;
		Lambda.iter( Data.DIALOGS, function(d) total += Lambda.count(d.phases) );
		Lambda.iter( Data.SCENARIOS, function(s) uprogress += db.Scenario.get(s, u) );
		return DefaultContext.percent(uprogress, total);
	}
	/*
	public static function getUserTitlesProgress( u : db.User )  {
		var total = Lambda.count( Data.TITLES );
		var uprogress = u.getTitles(true).length;
		return DefaultContext.percent(uprogress, total);
	}
	*/
	
	public static function validateObjective( ?noReward = false ) {
		if( App.user != null ) {
			var p = App.user.getTutorial();
			if( !noReward ) {
				// On attribue les récompenses
				if( p.reward.objects != null )
					for( obj in p.reward.objects ) {
						switch( obj.o ) {
						case Data.OBJECTS.list.gold : App.user.winMoney( obj.count, "tuto" );
						default : db.Object.add( R_ToolsValidateObjective, obj.o, obj.count, App.user );
						}
					}
				if( p.reward.ingredients != null )
					for( obj in p.reward.ingredients )
						db.Ingredient.add( obj.i, obj.count, App.user, true );
				if( p.reward.collections != null )
					for( obj in p.reward.collections )
						App.user.addCollection(obj);
				// On notifie le joueur
				App.session.objectiveSuccess( p );
			}
			//
			var next = null;
			if( p.next != null ) {
				next = Data.TUTORIAL.getId( p.next );
				while( next != null && next.valid != null && Script.eval(App.session.getSelected(), next.valid) )
					next = Data.TUTORIAL.getId( next.next );
			}
			if( next != null ) 	App.user.setValue(Data.USERVARS.list.ptuto, next.tid);
			else				App.user.setValue(Data.USERVARS.list.tuto, 2); // on le flag comme terminé

		}
	}
}