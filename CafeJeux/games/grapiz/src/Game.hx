import Common;

class Game implements MMGame<Msg> {

	public var dmanager : mt.DepthManager;
	public var dmanagerBoard : mt.DepthManager;
	public var dmanagerToken : mt.DepthManager;
	public var freeAnim : List<Anim>;
	public var anim : List<Anim>;
	public var grid : Array<Array<Cell>>;
	public var team : Bool;
	public var flyingToken : Token;
	var victorySent : Bool;

	function new( mc : flash.MovieClip ) {
		anim = new List();
		freeAnim = new List();

		mc.attachMovie("bg","bg",0);
		var mcGame = mc.createEmptyMovieClip("g",5);
		mcGame._xscale = mcGame._yscale = 75;

		var mcBoard = mcGame.createEmptyMovieClip("e",5);
		dmanagerBoard = new mt.DepthManager(mcBoard);
		mcBoard.cacheAsBitmap = true;

		var mcToken = mcGame.createEmptyMovieClip("f",10);
		dmanagerToken = new mt.DepthManager(mcToken);

		var mcInterface = mc.createEmptyMovieClip("h",10);
		dmanager = new mt.DepthManager(mcInterface);

		victorySent = false;

		// when ready
		MMApi.lockMessages(false);
	}

	public function initialize() {
		return Init(Std.random(2)==0);
	}

	public function main() {
		if( flyingToken != null ){
			flyingToken.updateFly();
		}

		if( freeAnim.length > 0 ){
			for( a in freeAnim ){
				if( a.play() ){
					freeAnim.remove( a );
				}
			}
		}

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					anim.remove( a );
				}
			}
			if( anim.length == 0 )
				onEndAnim();
		}
	}

	public function onEndAnim(){
		checkVictory();
		MMApi.lockMessages(false);
	}

	function checkVictory(){
		var a = checkTeamVictory(true);
		var b = checkTeamVictory(false);

		if( a && b ) victory(null);
		else if( a ) victory(team);
		else if( b ) victory(!team);
	}

	// return true is this team win, false if this team loose or null
	function checkTeamVictory( team : Bool ) : Bool {
		var firstFound = null;
		var nb = 0;

		// clean chained
		for( a in grid ){
			for( c in a ){
				if( c.token != null ){
					if( c.token.team == team ){
						c.token.chained = false;
						nb++;
						if( firstFound == null ) firstFound = c.token;
					}
				}
			}
		}

		if( firstFound.chain() == nb ) return true;
		return false;
	}

	public function onTurnDone() {
		if( victorySent ) return;
		if( MMApi.isMyTurn() && MMApi.hasControl() && !MMApi.isReconnecting() ){
			for( a in grid ){
				for( c in a ){
					if( c.token != null && c.token.team == team ) c.token.initActions();
				}
			}
		}
	}

	public function move( from : Cell, to : Cell ){
		for( a in grid ){
			for( c in a ){
				if( c.token != null && c.token.team == team ) c.token.stopActions();
			}
		}
		MMApi.endTurn(Move(from.x,from.y,to.x,to.y));
	}

	function victory( mine : Bool ){
		victorySent = true;
		MMApi.victory( mine );
	}

	public function onVictory( mine : Bool ){
		var t = if( mine ) team else !team;

		for( a in grid ){
			for( c in a ){
				if( c.token != null && c.token.team == t ) c.token.startVictoryGlow();
			}
		}
		haxe.Timer.delay(MMApi.gameOver,3000);
	}

	public function onReconnectDone(){
		for( r in grid ) for( c in r ) if( c.token != null ) c.token.display();
		onTurnDone();
	}

	public function onMessage( mine : Bool, msg : Msg ) {
		switch( msg ) {
		case Init(c):
			team = (mine || c) && !(mine && c);
			if( team )
				MMApi.setColors( Const.COLOR_BLUE, Const.COLOR_RED );
			else
				MMApi.setColors( Const.COLOR_RED, Const.COLOR_BLUE );
			grid = new Array();
			for( i in 0...(Const.RADIUS * 2 - 1) ){
				grid[i] = new Array();
				var start = if( i < Const.RADIUS ) 0 else i - Const.RADIUS + 1;
				var nb = Const.RADIUS + i;
				if( i >= Const.RADIUS ) nb -= (i - Const.RADIUS + 1) * 2;
				for( j in start...(start+nb) ){
					grid[i][j] = new Cell(this,i,j);
				}
			}
			for( a in Const.START_BLUE ){
				grid[a[0]][a[1]].addToken( false );
			}
			for( a in Const.START_RED ){
				grid[a[0]][a[1]].addToken( true );
			}
			onTurnDone();
		case Move(fx,fy,tx,ty):
			if( !MMApi.isReconnecting() )
				MMApi.lockMessages(true);
			var from = grid[fy][fx];
			var to = grid[ty][tx];
			from.token.moveTo( to );

		}
	}

}
