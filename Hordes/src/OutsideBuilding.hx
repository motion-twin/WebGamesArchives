class OutsideBuilding {

	public var id : Int;
	public var tools : List<{t:String,p:Int}>;
	public var name : String;
	public var probaEmpty : Int;
	public var probaMap : Int;
	public var level : Int;
	public var description : String;
	public var banner : String;
//	public var defense : Int;
	public var baseDefense : Int;
	public var isExplorable : Bool;

	public function new() {
		description ="";
		tools = new List();
		level = 0;
		probaEmpty = 10;
		probaMap = 50;
		banner = "oldRuins";
//		defense = 0;
		baseDefense = 10;
		isExplorable = false;
	}

	public function addTool( key : String, p : Int ) {
		tools.add( { t: key, p : p} ) ;
	}

	public function print() {
		return "<strong>"+name+"</strong>";
	}

}
