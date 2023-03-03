package db;
import Common;
import mt.db.Types;

class Book extends neko.db.Object {

	static var RELATIONS = function(){
		return [
			{ key : "userId",	prop : "user",	manager : User.manager, lock : false }
		];
	}
	static var PRIVATE_FIELDS = ["data"];
	static var TABLE_IDS = ["userId", "bkey"];
	static var PAGE_BREAK = "++";

	public static var manager = new BookManager();

	public var userId		: SInt;
	public var bkey			: SEncoded;
	public var date			: SDateTime;
	public var data			: BookData;
	public var user(dynamic,dynamic)	: User;

	public function new(user:db.User, bdata:BookData) {
		super();
		userId = user.id;
		data = bdata;
		date = Date.now();
		bkey = mt.db.Id.encode(data.key);
	}

	public function print() {
		return "<strong>"+data.name+"</strong>";
	}

	public function getAuthor() {
		return data.author;
	}

	public function getSummary(len:Int) {
		var ctools = new tools.TemplateTools();
		var txt = ctools.summary(data.content, len, false);
		txt = StringTools.replace(txt, PAGE_BREAK,"");
		txt = StringTools.replace(txt, "||", "");
		return txt;
	}

	public static function generateBookData(?seed:Int) {
		var max = 0;
		for( bd in XmlData.books )
			max += bd.chance;
		
		var n = if( seed == null ) Std.random(max) else new mt.Rand(seed).random(max);
		var sum = 0;
		var chosen = null;
		for( bd in XmlData.books ) {
			sum += bd.chance;
			if( n < sum ) {
				chosen = bd;
				break;
			}
		}
		return chosen; // peut être null
	}

	public static function create(u:db.User, bdata:BookData) {
		if( bdata == null ) return null;
		var b = manager.getWithKeys({ userId:u.id, bkey:mt.db.Id.encode(bdata.key) });
		if( b == null ) {
			b = new Book( u, bdata );
			b.insert();
			return {newBook:true, b:b};
		}
		return {newBook:false, b:b};
	}

	public static function format(str) {
		str = tools.Utils.replaceByTag(str,"*","<strong>","</strong>");
		str = tools.Utils.replaceByTag(str,"_","<strike>","</strike>");
		str = StringTools.replace(str,"||","<div class='hr'></div>");
		return str;
	}

	public function getContent(page:Int) {
		var pages = data.content.split(PAGE_BREAK);
		return format(pages[page]);
	}

	public function countPages() {
		return data.content.split(PAGE_BREAK).length;
	}

	public static function get(user:db.User, k:String) {
		return db.Book.manager.getWithKeys( {userId:user.id, bkey:mt.db.Id.encode(k)} );
	}
}



class BookManager extends neko.db.Manager<Book> {

	public function new() {
		super( Book );
	}

	private override function make( b : Book) {
		var k = mt.db.Id.decode(b.bkey);
		for (bdata in XmlData.books) {
			if ( bdata.key==k ) {
				b.data = bdata;
				break;
			}
		}
	}

	public function getByUser(u:User) {
		return objects( selectReadOnly("userId="+u.id), false );
	}

	public function alreadyHave(user:User, bdata:BookData) {
		var ikey = mt.db.Id.encode(bdata.key);
		return execute("SELECT count(*) FROM Book WHERE userId="+user.id+" AND bkey="+ikey).getIntResult(0) > 0;
	}

}
