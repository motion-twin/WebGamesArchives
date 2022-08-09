package game;
import game.Resolver;
import game.Event;

class GamePrinter implements GameListener {

	public var resolver : game.Resolver;

	public function new(r:game.Resolver){
		resolver = r;
		resolver.addEventListener(this);
	}

	public function onEvent( e:game.Event ){
		switch (e){
			case DefStart:
				neko.Lib.println("** Init");
			case NextAttempt(round,team,bat,attempt):
				neko.Lib.println("** "+Std.string(e)
				+" ---------------------------------------- ROUND="+round
				+" TEAM="+team+" BAT="+bat+" ATTEMPT="+attempt);
			default:
				neko.Lib.println("- ["+resolver.time+"] "+Std.string(e));
		}
	}

	public function printBoard( b:ScoreBoard ){
		neko.Lib.println("** GameOver");
		for (i in 0...2){
			var team = b[i];
			neko.Lib.print("|");
			neko.Lib.print(i);
			neko.Lib.print("|");
			neko.Lib.print(team.join("|"));
			neko.Lib.println("|");
		}
		neko.Lib.println(resolver.teamA.name+" ("+resolver.teamA.score+") -- "+resolver.teamB.name+" ("+resolver.teamB.score+")");
	}
}
