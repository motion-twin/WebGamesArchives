import Protocol;

enum _QGoal {
	G_AddClient;
	G_BuyStaff;
	G_StaffLobby;
	G_InstallItem;
	G_BuildRoom;
	G_ClientPop;
	G_Midnight;
	G_Rename;
	G_ExtendAny;
	G_EndConstruction;
	G_ChangeDeco;
	G_Level;
	G_Satisfy(min:Int);
	G_PickItem;
	G_DropResearch;
	G_UseResearch;
	G_RoomLevel(min:Int); // ATTENTION : ce level est +1
	G_PlaceDeco;
	G_Service;
	G_SatisfyMax;
}


#if neko

enum _QReward {
	R_Money(sum:Int);
	R_Item(item:_Item);
	R_Client;
	R_Research;
	R_Fame;
}


class _Quest implements haxe.Public {
	var _id			: Int;
	var _repeatable	: Bool;
	var _desc		: String;
	var _goals		: List<{_ok:Bool, _g:_QGoal}>;
	var _rewards	: List<_QReward>;
	public function new() {
		_repeatable = false;
		_desc = "";
		_goals = new List();
		_rewards = new List();
	}
	
	public function copy() : _Quest {
		return haxe.Unserializer.run( haxe.Serializer.run(this) );
	}
}

// ***** MANAGER
class QuestManager {
	var quest	: _Quest;
	var fl_done	: Bool;
	var solver	: Solver;
	
	public function new(s:Solver, q:_Quest) {
		solver = s;
		quest = q;
		fl_done = quest._goals.length>0;
	}
	
	public function getObjectivesInfos() {
		var hash = new Hash();
		var hashDone = new Hash();
		for (g in quest._goals) {
			var key = Std.string(g._g);
			if (hash.exists(key))
				hash.set(key, hash.get(key)+1);
			else
				hash.set(key, 1);
			if(g._ok)
				if (hashDone.exists(key))
					hashDone.set(key, hashDone.get(key)+1);
				else
					hashDone.set(key, 1);
		}
		
		var olist = new Array();
		for (key in hash.keys()) {
			var done = if (hashDone.exists(key)) hashDone.get(key) else 0;
			var total = hash.get(key);
			var data = {
				_n	: if (key.indexOf("(")>=0) StringTools.replace(key.substr(key.indexOf("(")+1), ")", ""),
			}
			var nameKey = if ( key.indexOf("(")>=0 ) key = key.substr(0,key.indexOf("(")) else key;
			olist.push( {
				name		: T.formatByKey(nameKey, data),
				complete	: done>=total,
				done		: Std.int(done),
				total		: Std.int(total),
			} );
		}
		
		olist.sort(function(a,b) {
			return Reflect.compare(a.done, b.done);
		});
		return olist;
	}
	
	public function getRewardText(hotel:_Hotel) {
		if (quest._rewards.length<=0)
			return "";
		else {
			var list = new List();
			for (r in quest._rewards)
				list.add(
					switch(r) {
						case R_Money(n)		: T.format.R_Money({_money:n, _currency:T.get.Currency});
						case R_Item(i)		: T.format.R_Item({_item:T.getItemText(i)._name});
						case R_Client		: T.get.R_Client;
						case R_Research		:
							if (hotel.treeMaxed())
								T.format.R_Fame({_fame:Const.FAME_RESEARCH})
							else
								T.get.R_Research;
						case R_Fame			: T.format.R_Fame({_fame:Const.FAME_QUEST});
					}
				);
			return " . "+list.join("\n . ");
		}
	}
	
	public function validateGoal(done:_QGoal) {
		for (g in quest._goals)
			if ( Type.enumIndex(g._g)==Type.enumIndex(done) && !g._ok ) {
				var fl_done =
					switch(g._g) {
						case G_Satisfy(target)		: switch(done) { case G_Satisfy(n) : (n>=target); default:false; }
						case G_RoomLevel(target)	: switch(done) { case G_RoomLevel(n) : (n>=target); default:false; }
						default						: true;
					}
				if ( fl_done ) {
					g._ok = true;
					return true;
				}
			}
		return false;
	}
	
	public function isDone() {
		for (g in quest._goals)
			if (!g._ok)
				return false;
		return true;
	}
	
}


// ***** XML

class QuestXml {
	public static var steps : Hash<Int> = new Hash();
	public static var ALL : IntHash<_Quest> = init();
	
	public static function init() {
		var raw = neko.io.File.getContent(Config.TPL+"../../xml/"+Config.LANG+"/quests.xml");
		if ( raw==null || raw=="" )
			throw "no quest data";
			
		var h = new IntHash();
		var xml = Xml.parse(raw);
		var fast = new haxe.xml.Fast(xml.firstChild());
		
		var id = 0;
		for (qnode in fast.nodes.q) {
			var quest = new _Quest();
			if ( qnode.nodes.d.length!=1 )
				throw "invalid description in quest "+id;
			quest._id = id;
			quest._desc = qnode.nodes.d.first().innerHTML;
			quest._repeatable = qnode.has.repeatable && qnode.att.repeatable=="1";
			if ( qnode.has.step )
				steps.set(qnode.att.step, id);
			// objectifs
			for (gnode in qnode.nodes.g) {
				var raw = StringTools.replace(gnode.att.id, ")", "");
				var key = raw.split("(")[0];
				var data = if (raw.indexOf("(")>=0) raw.split("(")[1].split(",") else [];
				var idata = Lambda.array( Lambda.map( data, function(d) { return Std.parseInt(d); } ) ); // cast en INT
				var goal = Type.createEnum(_QGoal, "G_"+key, idata);
				quest._goals.add({_ok:false, _g:goal});
			}
			// récompenses
			for (rnode in qnode.nodes.r) {
				var raw = StringTools.replace(rnode.att.id, ")", "");
				var key = raw.split("(")[0].toLowerCase();
				var data = if(raw.indexOf("(")>=0) raw.split("(")[1].split(",") else [];
				var reward = switch(key) { // en minuscules !
					case "money"	: R_Money(Std.parseInt(data[0]));
					case "item"		: R_Item( Type.createEnum(_Item, "_"+data[0].toUpperCase()) );
					case "client"	: R_Client;
					case "research"	: R_Research;
					case "fame"		: R_Fame;
					default			: throw "invalid reward : "+raw;
				}
				quest._rewards.add(reward);
			}
			h.set(id, quest);
			id++;
		}

		return h;
	}
	
	public static function get(id) {
		if (ALL.exists(id))
			return ALL.get(id).copy(); // pour éviter les effets de bords
		else
			return null;
	}
	
		
	public static function getRepeatables() {
		return Lambda.filter(ALL, function(q) { return q._repeatable; });
	}

}

#end
