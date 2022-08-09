package data;

import data.Event;

typedef GameRewards = {
	var id : String;
	var rid : Int;
	var reward : Reward;
	var cond : Condition;
}

class GameRewardsXML extends haxe.xml.Proxy<"rewards.xml",GameRewards> {

	public static function parse() {
		return new data.Container<GameRewards,GameRewardsXML>().parse("rewards.xml", function(id,rid,r) {
			var found = new List();
			var gReward:GameRewards = {
				id : id,
				rid : rid,
				reward : { ingredients : new List(), objects : new List(), collections : new List() },
				cond : if(  r.has.cond ) Script.parse(r.att.cond ) else Condition.CTrue,
			};
			for( node in r.nodes.object )
				gReward.reward.objects.add( { o: Data.OBJECTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
	
			for( node in r.nodes.ingredient )
				gReward.reward.ingredients.add( { i: Data.INGREDIENTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
			/*
			for( node in r.nodes.collection )
				gReward.collections.add( Data.COLLECTION.getName(node.att.name) );
			*/
			return gReward;
		});
	}

}
