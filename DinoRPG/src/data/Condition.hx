package data;

enum CMissionStatus {
	CMDone;
	CMCurrent( ?state : Int );
}

enum RandBase {
	CRDay;
	CRHour;
	CRDialog;
	CRDino;
	CRUser;
}

enum Condition {
	CTrue;
	CFalse;
	CLevel( l : Int );
	CEffect( e : Effect );
	CCollection( c : Collection );
	CTime( t : Int, user : Bool );
	CMission( m : Mission, status : CMissionStatus );
	CSkill( s : Skill );
	CCanFight( m : Monster );
	CPosition( m : Map );
	CNo( c : Condition );
	COr( c1 : Condition, c2 : Condition );
	CAnd( c1 : Condition, c2 : Condition );
	CHasObject( o : Object );
	CHasIngredient( i : Ingredient, qty:Int, min_max:Null<Bool> );
	CRandom( n : Int, t : Int, seed : Bool, basis : RandBase, min_max : Null<Bool> );
	CAdmin;
	CScenario( s : Scenario, phase : Int, min_max : Null<Bool> );
	CLife( l : Int, min_max : Null<Bool> );
	CDinoz( n : Int );
	CEquip( o : Object );
	CHour( n : Int, min_max : Null<Bool> );
	CScenarioWait( s : Scenario, t : Int );
	CDungeon( d : Dungeon );
	CClanAction( c : ClanAction );
	CStatus( s : Status );
	CFriend( f : Monster );
	CTag( name:String );
	CUVar( v : UserVar, value : Int, min_max : Null<Bool> );
	CGVar( v : GameVar, value : Int, min_max : Null<Bool> );
	CEvent( name : String );
	CRace( f : Family );
	CTab( name : String );
	CCaushRock( dir:Int );
	CPromo( name : String );
	CConfig( name : String );
	CWar( name : String );
	CDate( date:Date, min_max : Null<Bool> ); 
}
