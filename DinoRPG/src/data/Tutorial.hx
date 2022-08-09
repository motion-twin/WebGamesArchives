package data;

typedef TutorialReward = {
	var collections : List<Collection>;
	var objects 	: List<{o:Object, count:Int}>;
	var ingredients : List<{i:Ingredient, count:Int}>;
}

typedef TutorialHelper = {
	var selector:String;
	var text:String;
	var url:Null<String>;
	var cond:Null<Condition>;
}

typedef TutorialText = {
	var text : String;
	var url : Null<String>;
	var fast : Bool;
	var visible : Bool;
}

typedef Tutorial = {
	var cond 	: Null<Condition>;
	var valid	: Null<Condition>;
	var id 		: String;
	var tid		: Int;
	var helpers : List<TutorialHelper>;
	var title	: String;
	var begin 	: TutorialText;
	var end		: TutorialText;
	var reward 	: TutorialReward;
	var next	: Null<Int>;
}

class TutorialXML extends haxe.xml.Proxy<"tutorial.xml", Tutorial> {

	public static function parse() {
		return new data.Container<Tutorial, TutorialXML>(false, false).parse("tutorial.xml", function(id, tid, o) {
			return {
				cond 	: o.has.cond ? Script.parse( o.att.cond ) : null,
				valid 	: o.has.valid ? Script.parse( o.att.valid ) : null,
				id 		: id,
				tid  	: tid,
				title 	: o.att.title,
				begin 	: parseTextBlock(o.node.begin),
				end		: parseTextBlock(o.node.end),
				reward 	: parseReward( o.node.rewards ),
				helpers : parseHelpers( o ),
				next	: o.has.next ? Tools.makeId(o.att.next) : null,
			}
		});
	}
	
	public static function check() {
		//check if next are existing !
	}
	
	static function parseTextBlock( x : haxe.xml.Fast ) {
		return {
			text : x.innerHTML,
			url	 : x.has.url ? x.att.url : null,
			fast : x.has.fast ? x.att.fast == "1" : true,
			visible : x.has.visible ? x.att.visible == "1" : true,
		};
	}
	
	static function parseHelpers( x : haxe.xml.Fast ) {
		var helpers = new List();
		if( x.hasNode.helpers )
			for( helper in x.node.helpers.nodes.helper ) {
				var url = null;
				if( helper.has.url ) url = helper.att.url;
				helpers.add({ 	selector: helper.att.selector,
								text 	: helper.innerData,
								url 	: url,
								cond 	: helper.has.cond ? Script.parse( helper.att.cond ) : null,
							} );
			}
		return helpers;
	}
	
	static function parseReward( x : haxe.xml.Fast ) : TutorialReward {
		var ingredients = new List();
		var objects = new List();
		var collections = new List();
		//
		for( node in x.nodes.object )
			objects.add( { o: Data.OBJECTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );

		for( node in x.nodes.ingredient )
			ingredients.add( { i: Data.INGREDIENTS.getName(node.att.name), count: node.has.count ? Std.parseInt(node.att.count) : 1 } );
	
		for( node in x.nodes.collection )
			collections.add( Data.COLLECTION.getName(node.att.name) );
	
		return  {
			ingredients : ingredients,
			objects : objects,
			collections : collections,
		}
	}
}
