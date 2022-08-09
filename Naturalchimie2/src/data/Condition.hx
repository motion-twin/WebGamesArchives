package data;

import GameData._ArtefactId ;


enum CQuestStatus {
	CQDone ;
	CQCurrent(?state : Int) ;
}

enum Condition {
	CDemo ;
	CFirstPlay ;
	CTrue ;
	CFalse ;
	CEffect( e : Effect );
	CGrade(s : String, g : Int) ;
	CReput(s : String, r : Int) ;
	CSchool( s : String) ;
	CFullSchool( s : String, g : Int, r : Int) ;
	CTime(t : Int ) ;
	CQuest( q : Quest, status : CQuestStatus ) ;
	CPosition( m : Map ) ;
	CNo( c : Condition ) ;
	COr( c1 : Condition, c2 : Condition ) ;
	CAnd( c1 : Condition, c2 : Condition ) ;
	CHasObject( o : _ArtefactId, qty : Int) ;
	CHasQuestObject( o : _ArtefactId, qty : Int) ;
	CHasCollection( c : data.Collection ) ;
	
	CHasAvatar(index : Int, value : Int) ;
	CHasRecipe(r : Recipe) ;
	
	CRecipeRank(t : String, r : Int) ;
	
	CHasGold(g : Int) ;
	CRandom( n : Int ) ;
	CVisit(m : String, v : Int ) ;
	CAdmin ;
	CBeta ;
	CNumName;
	CWeekDay(t : Int) ;
	CVersion(n : String, v : String) ;
	CWorldMod(v : String) ;
	CNewXmasFace ;
	CHasToken(p : Int) ;
	
}
