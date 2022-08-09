import Datas;
class Activity{//}

	public var type:ActivityType;

	public var freq:Int;			// Frequence a laquelle l'action est produite
	public var crewCoef:Float;		// Coef de reduction de la frequence appliqué pour chaque homme au delà du premier.
	public var crewMax:Int;			// population maximum pour cette activité
	public var crew:Array<Man>;		// liste de la population présente sur cette activité.
	public var cost:Array<Cost>;		// cout de l'activité

	public var structure:Structure;		// Structure contenant l'activité

	public function new( st ){

		structure = st;

		freq = 60;
		crewCoef = 0.75;
		crewMax = 4;
		crew = [];
		st.act.push(this);
	}


//{
}