import Grid;
import Common;
import Anim;
import flash.Mouse;

class Game implements MMGame<Msg> {
	public var dm : mt.DepthManager;
	public var grid : Array<Array<Cell>>;
	public var anim : List<Anim>;
	public var tinyAnims : Array<flash.MovieClip>;
	public var conquered : List<Anim>;
	public var scale : Float;
	public var lock : Bool;
	public var team : Bool;
	public var mcSelector:flash.MovieClip; // géré à partir de Cell
	public var mcSelectedOption : flash.MovieClip; // option sélectionnée par le joueur
	public var zombieTurn : Int;
	public var optionAnim : Bool;

	var hasConquered : Bool;
	var wasTrap : Bool;
	var invasionDone : Bool; // Invasion des zombies
	var root : flash.MovieClip;
	var mcBg : flash.MovieClip;
	var mcTitle : flash.MovieClip;
	var hCell : PlayerDock; // Choix du joueur humain
	var zCell : PlayerDock; // Choix du joueur zombie
	var oppTurnAnim : OppTurnAnim;
	var mcPlayedOption : flash.MovieClip; // option jouée par l'adversaire
	var mcOptionsBg : flash.MovieClip;
	var helpTip : HelpTip; // Affichage de l'aide
	var myCount : Int;
	var oppCount : Int;
	var myOptions : Array<Int>;		// options intra jeu
	var oppOptions : Array<Int>;	// options intra jeu
	var backgroundOption : Int;
	var currentTurnOption : Int; // option jouée avant la fin du tour
	var myMoves : Array<Int>; // coups à jouer
	var oppMoves : Array<Int>; // coups à jouer
	var zombieMoves : Array<{x:Int,y:Int,n:Int}>; // coups des zombies en cas d'invasion
	var options : Array<Option>;
	var currentTurn : Int;
	var doorClosed : Bool;
	var messageFromMe : Bool;
	var currentMessage : Msg;
	var shakeCpt : Float;
	var shakeSpeed : Float;


	/*----------------------------------- LOGIQUE ------------------------------------------*/
	/*--------------------------------------------------------------------------------------*/


	public function playOption( option : Int ) {
		hideHelp();

		if ( !MMApi.hasControl() ) return;

		if( lock )
			return;

		switch( option ) {

			case Type.enumIndex( MegaShield ):
				currentTurnOption = option;
				activateOption( option );
				enableMyCells(); // Permet de sélectionner uniquement ses cases

			case Type.enumIndex( Shield ):
				currentTurnOption = option;
				activateOption( option );

			case Type.enumIndex( Gun ):
				currentTurnOption = option;
				activateOption( option );
				enableOppCells(); // Permet de sélectionner uniquement les cases de l'adversaire

			case Type.enumIndex( Cat ):
				currentTurnOption = option;
				activateOption( option );
				enableOppCells(); // Permet de sélectionner uniquement les cases de l'adversaire

			case Type.enumIndex( MachineGun ):
				currentTurnOption = option;
				activateOption( option );
				enableOppCells(); // Inverse les cases qu'il est possible de sélectionner

			case Type.enumIndex( Armageddon ):
				currentTurnOption = option;
				activateOption( option );
				enableAllCells(); // Permet de sélectionner n'import quelle case

			case Type.enumIndex( SportElec ):
				currentTurnOption = option;
				activateOption( option );
				enableMyCells(); // Permet de sélectionner uniquement ses cases

			case Type.enumIndex( Water ):
				if( isLastCell() ) return;

				currentTurnOption = option;
				activateOption( option );

			case Type.enumIndex( Bed ):
				lock = true;
				MMApi.sendMessage( BedEvent(option) );

			case Type.enumIndex( Trap ):
				currentTurnOption = option;
				activateOption( option );
				enableEmptyCells();

			case Type.enumIndex( Shield ):
				currentTurnOption = option;
				activateOption( option );

		}
	}

	// Retour de l'opération sur la case sélectionnée
	public function onActionDone(x : Int, y : Int ) {
		hideHelp();

		if( lock )
			return;

		mcSelector._visible = false;
		lock = true;

		// y-a-t''il une option de jeu en cours ?
		if( currentTurnOption >= 0 ) {
			hideOptionSelector(false);
			switch( currentTurnOption ) {

				case Type.enumIndex( Shield ):
					MMApi.sendMessage( ShieldEvent( x, y, currentTurnOption, team ) );
					return;

				case Type.enumIndex( Cat ):
					MMApi.endTurn( CatEvent( x, y, currentTurnOption, team, Std.random( Const.MAX_CAT_ATTACK ) + 2 ) );
					return;

				case Type.enumIndex( Gun ):
					MMApi.sendMessage( GunEvent( x, y, currentTurnOption, team ) );
					return;

				case Type.enumIndex( MachineGun ):
					var med = Math.floor( Const.MACHINE_GUN / 2 );
					var onTarget = med + Std.random( med + 1 );
					var offTarget = Const.MACHINE_GUN - onTarget;
					var touchedCells = null;

					// localisation des balles perdues
					if( offTarget > 0 ) {
						var o = offTarget;
						touchedCells = new Array();
						var t : Array<{x:Int,y:Int}>= new Array();
						var touched = false;
						var directions = if( y % 2 == 0 ) Const.DIRECTIONS_2 else Const.DIRECTIONS_1;
						while( o > 0 ){
							touched = false;
							var d = directions[Std.random( directions.length) ];
							for( tt in t ) {
								if( tt.x == d.x && tt.y == d.y ) {
									touched = true;
								}
							}
							if( !touched ) {
								touchedCells.push( d );
							}
							o--;
						}
					}

					MMApi.endTurn( MachineGunEvent( x, y, currentTurnOption, team, onTarget, offTarget, touchedCells ) );
					return;

				case Type.enumIndex( Armageddon ):
					MMApi.endTurn( ArmageddonEvent( x, y, currentTurnOption, team ) );
					return;

				case Type.enumIndex( SportElec ):
					MMApi.sendMessage( SportElecEvent( x, y, currentTurnOption, team ) );
					return;

				case Type.enumIndex( Water ):
					if( isLastCell() ) return;
					MMApi.sendMessage( ChooseCell( x, y, myMoves[0], team, currentTurnOption ) );
					return;

				case Type.enumIndex( MegaShield ):
					MMApi.endTurn( MegaShieldEvent( x, y, currentTurnOption, team ) );
					return;

				case Type.enumIndex( Trap ):
//					MMApi.endTurn( TrapEvent( x, y, currentTurnOption, team ) );
					MMApi.sendMessage( TrapEvent( x, y, currentTurnOption, team ) );
					return;

				case Type.enumIndex( Bed ):
					return;
			}
		}

		MMApi.endTurn( ChooseCell( x, y, myMoves[0], team, -1 ) );
	}

	public function onMessage( messageFromMe : Bool, msg : Msg ) {

		// Résolution de l'invasion des zombies
		if( Type.enumIndex( msg ) != Type.enumIndex( WaterEvent )
			) {
			if( !invasionDone && currentTurn > zombieTurn ) {
				invasionDone = true;
			}
		}

		var option = -1;
		switch( msg ) {

			case Init(g, mm, om, options, oOptions, isUnits, zTurn, zMoves):
				team = !messageFromMe;

				if( isUnits )
					Const.MODE_VICTORY = Units;
				else
					Const.MODE_VICTORY = Land;

				zombieTurn = zTurn;
				zombieMoves = zMoves;

				if( team ) {
					MMApi.setColors(Const.COLOR1,Const.COLOR2);
					myMoves = mm;
					oppMoves = om;
					myOptions = options;
					oppOptions = oOptions;
				}
				else {
					MMApi.setColors(Const.COLOR2,Const.COLOR1);
					myMoves = om;
					oppMoves = mm;
					myOptions = oOptions;
					oppOptions = options;
				}

				defineConst();
				initGrid(g);
				initInterface(messageFromMe);
				updateScore();
				currentTurn = 1;
				playFirstTurnAnim(messageFromMe);
				return;

			case ChooseCell( x, y, points, z, o ) : option = o;
			case BedEvent( o ) : option = o; currentTurn--;
			case MachineGunEvent( x,y, o, z, onTarget, offTarget, touchedCells ) : option = o;
			case ArmageddonEvent( x,y, o, z ) : option = o;
			case GunEvent( x,y, o, z ) : option = o; currentTurn--;
			case WaterEvent : return;// Géré dans ChooseCell
			case SportElecEvent( x,y, o, z ) : option = o; currentTurn--;
			case ShieldEvent( x,y, o, z ) : option = o;
			case CatEvent( x,y, o, z, killed ) : option = o;
			case MegaShieldEvent( x,y, o, z ) : option = o;
			case TrapEvent( x,y, o, z ) : option = o;
			case ZombieAttack( o, info, playedCell ) : currentTurn--;
			case NewTurn :
		}

		MMApi.lockMessages(true);
		this.messageFromMe = messageFromMe;
		currentMessage = msg;
		currentTurn++;
		playMessage(option);
	}


	/*------------------------------------ ANIMS -------------------------------------------*/
	/*--------------------------------------------------------------------------------------*/

	function playFirstTurnAnim(messageFromMe) {

		MMApi.lockMessages( true );
		lock = true;
		var me = this;

		lockControls();
		if( messageFromMe ) {
			anim.push( new TurnGradient(this) );

			var b = new TurnInfo( this, 1 );
			b.onEnd = function() { me.unlockControls(); me.lock = false; MMApi.lockMessages(false); }
			anim.push( b );
		}
		else {
			oppTurnAnim.startRoll();
			oppTurnAnim.onEnd = function() { me.lock = false; MMApi.lockMessages(false); }
			anim.push( oppTurnAnim );
		}
	}

	function playMessage( o = -1, info : String = null ) {
		if( currentMessage == null ) return;

		// On supprime l'option de l'arsenal
		if( o > 0 ) {
			if( !messageFromMe ) {
				for( i in 0...oppOptions.length ) {
					var oo = oppOptions[i];
					if( oo == o +1 ) {
						oppOptions.splice( i, 1 );
						break;
					}
				}
			} else {
				for( i in 0...myOptions.length ) {
					var oo = myOptions[i];
					if( oo == o +1 ) {
						myOptions.splice( i, 1 );
						break;
					}
				}
			}
		}

		// On joue une animation d'option s'il y a besoin
		if( !optionAnim && o >= 0 ) {
			var me = this;
			var a = new OptionAnim( this, o );
			a.onEnd = function() { me.optionAnim = true; me.playMessage(o); };
			anim.push( a );
			return;
		}
		optionAnim = false;

		switch( currentMessage ) {
			case Init(g, mm, om, options, oOptions, isUnits, zTurn, zMoves): // Non implémenté dans cette partie
			case ChooseCell( x, y, points, z, o ) :

				var playedCell = grid[x][y];
				playedCell.setPoints( points );

				if( playedCell.trap ) {
					playedCell.setTeam( z );
					var me = this;
					playedCell.conquered(function() { playedCell.refresh(); } );
					playedCell.untrap();
					var a = new OptionAnim( this, Type.enumIndex( Trap ) );
					if( o != Type.enumIndex( Water ) ) {
						a.onEnd = function() {
							playedCell.conquered(  function() { 
								me.attachScore(playedCell,-Const.TRAP_DAMAGE); 
								if( playedCell.points >= Const.TRAP_DAMAGE ) {
									playedCell.setPoints( playedCell.points - Const.TRAP_DAMAGE );
									playedCell.refresh(); 
								} else {
									playedCell.reset(); 
								}
							} );
							me.playTurnAnim(o, info );
						};
					} else {
						a.onEnd = function() {
							playedCell.conquered(  function() { 
								me.attachScore(playedCell,-Const.TRAP_DAMAGE); 

								if( playedCell.points >= Const.TRAP_DAMAGE ) {
									playedCell.setPoints( playedCell.points - Const.TRAP_DAMAGE );
									playedCell.refresh(); 
								} else {
									playedCell.reset(); 
								}
								
								me.currentTurnOption = -1;
								me.updateScore();
								me.currentMessage = null;
								if( me.messageFromMe ) {
									me.disableOption( o );
									me.messageFromMe = false;
									me.unlockControls();
								}
								me.lock = false;
								MMApi.lockMessages( false );
									
							} );								
						};
					}
					anim.push( a );
					return;
				}

				var me = this;
				if( playedCell.points <= 0 ) {
					playedCell.conquered(function() { playedCell.reset(); } );
				} else {
					playedCell.setTeam( z );
					playedCell.conquered(function() { playedCell.refresh(); } );
				}

				updateNeighbourCells( playedCell );

				// on met à jour les mouvements disponibles
				if( messageFromMe )
					myMoves.splice(0,1)
				else
					oppMoves.splice(0,1);

				if( team ) {
					zCell.setPoints( myMoves[0], myMoves[1] );
				} else {
					hCell.setPoints( myMoves[0], myMoves[1] );
				}

				// Si un option a été utilisée pendant ce tour
				if( o > 0 ) {
					// WaterEvent
					if( o == Type.enumIndex( Water ) ) {
						currentTurnOption = -1;
						updateScore();
						currentMessage = null;
						if( messageFromMe ) {
							disableOption( o );
							messageFromMe = false;
							unlockControls();
						}
						lock = false;
						MMApi.lockMessages( false );
						return;
					}
					currentTurnOption = -1;
					disableOption( o );
				}

				hasConquered = true;
				currentMessage = ZombieAttack( o, info , {x:playedCell.x, y:playedCell.y} );
				return;

			case BedEvent( o ) :

				if( messageFromMe ) {
					myMoves.splice(0,1);
				}
				else
					oppMoves.splice(0,1);

				if( team ) {
					zCell.setPoints( myMoves[0], myMoves[1] );
				} else {
					hCell.setPoints( myMoves[0], myMoves[1] );
				}

				currentMessage = null;
				if( messageFromMe ) {
					disableOption( o );
					if( !canPlayFurther() ) {
						lock = false;
						MMApi.lockMessages( false );
						MMApi.endTurn( NewTurn );
						return;
					}

					currentTurnOption =  -1;
					messageFromMe = false;
					unlockControls();
				}
				lock = false;
				MMApi.lockMessages( false );
				return;

			case MachineGunEvent( x,y, o, z, onTarget, offTarget, touchedCells ) :

				var playedCell = grid[x][y];

				// coût sur la cible
				var zone=0;
				var p = Std.int( Math.min( onTarget, playedCell.points ) );

				var me = this;
				playedCell.changePoints( playedCell.points - p );
				if( playedCell.points <= 0 ) {
					playedCell.conquered(function(){me.attachScore(playedCell,-p); playedCell.reset(); me.shake(2); });
					zone =1;
				} else {
					playedCell.conquered(function(){me.attachScore(playedCell,-p); playedCell.refresh(); me.shake(2); });
				}

				// Coût des balles perdues
				if( offTarget > 0 ) {
					var m = 0;
					var p = 0;
					for( t in touchedCells ) {
						var tx = playedCell.x + t.x;
						var ty = playedCell.y + t.y;
						var c = grid[tx][ty];

						if( c == null ) continue;
						if( c.points <= 0 ) continue;
						if( c.void ) continue;
						if( c.armageddon ) continue;
						if( c.megaShield ) continue;
						c.changePoints(c.points-1);

						var me = this;
						if( c.zombie ) {
							if( c.points <= 0 )
								c.conquered(function(){me.attachScore(c,-1); c.reset(); c.refresh(); me.shake(1); });
							else
								c.conquered(function(){me.attachScore(c,-1); c.refresh(); me.shake(1); });
							continue;
						}

						if( c.points <= 0 ) {
							c.conquered(function(){me.attachScore(c,-1); c.reset(); c.refresh(); me.shake(1); });
						}
						else {
							c.conquered(function(){me.attachScore(c,-1); c.refresh(); me.shake(1); });
						}
					}
				}

				hasConquered = true;
				currentMessage = ZombieAttack( o, info , {x:playedCell.x, y:playedCell.y} );
				return;

			case ArmageddonEvent( x,y, o, z ) :

				var playedCell = grid[x][y];

				var me = this;
				var prevPoints = playedCell.points;
				playedCell.changePoints(0);
				playedCell.conquered( function(){
					me.attachScore(playedCell,-prevPoints);
				});
				attachTinyAnim("fx_arma", playedCell.mc._x+25, playedCell.mc._y+25);
				playedCell.armageddon = true;
				playedCell.refresh();
				shake(4,0.1);
				updateArmageddonNeighbourCells(playedCell);

				hasConquered = true;
				currentMessage = ZombieAttack( o, info , {x:playedCell.x, y:playedCell.y} );
				return;

			case GunEvent( x,y, o, z ) :

				var playedCell = grid[x][y];

				shake(1);
				playedCell.changePoints( playedCell.points-1 );
				if( playedCell.points<= 0 ) {
					var me = this;
					playedCell.conquered(function(){
						me.attachScore(playedCell,-1);
						playedCell.reset();
					});
				} else {
					var me = this;
					playedCell.conquered(function(){
						me.attachScore(playedCell,-1);
						playedCell.refresh();
					} );
				}

				// SEND MESSAGE
				updateScore();
				checkVictory();
				currentMessage = null;
				if( messageFromMe ) {
					disableOption( o );
					if( !canPlayFurther() ) {
						lock = false;
						MMApi.lockMessages( false );
						MMApi.endTurn( NewTurn );
						return;
					}

					currentTurnOption =  -1;
					messageFromMe = false;
					unlockControls();
				}
				lock = false;
				MMApi.lockMessages( false );
				return;

			case WaterEvent : // Géré dans ChooseCell
			case ZombieAttack( o, info, playedCell ) :
				zombieAttack(o, info, playedCell);
				return;

			case SportElecEvent( x,y, o, z ) :

				var playedCell = grid[x][y];

				var me = this;
				playedCell.changePoints( playedCell.points+1 );
				playedCell.conquered(function() {
					playedCell.refresh();
					me.attachScore(playedCell,1);
				} );

				updateScore();
				checkVictory();
				currentMessage = null;
				if( messageFromMe ) {
					disableOption( o );
					if( !canPlayFurther() ) {
						lock = false;
						MMApi.lockMessages( false );
						MMApi.endTurn( NewTurn );
						return;
					}
					currentTurnOption =  -1;
					messageFromMe = false;
					unlockControls();
				}
				lock = false;
				MMApi.lockMessages( false );
				return;

			case ShieldEvent( x,y, o, z ) :
				// Non implémenté
				return;

			case CatEvent( x,y, o, z, killed ) :

				var playedCell = grid[x][y];

				if( killed > playedCell.points ) killed = playedCell.points;
				playedCell.changePoints( playedCell.points - killed );
				var me = this;
				if( playedCell.points <= 0 ) {
					playedCell.conquered( function() {
						me.attachScore(playedCell,-killed);
						playedCell.reset();
						playedCell.refresh();
					});
				} else {
					playedCell.conquered( function() {
						me.attachScore(playedCell,-killed);
						playedCell.refresh();
					});
				}

				hasConquered = true;
				currentMessage = ZombieAttack( o, info , {x:playedCell.x, y:playedCell.y} );
				return;

			case MegaShieldEvent( x,y, o, z ) :

				var playedCell = grid[x][y];
				playedCell.conquered(function() {
					playedCell.protect(true);
				} );

				MMApi.sendMessage( ZombieAttack( o, info, {x:playedCell.x,y:playedCell.y} ) );
				return;

			case TrapEvent( x,y, o, z ) :

				var playedCell = grid[x][y];
				playedCell.setTrap();

				if( messageFromMe ) {
					playedCell.conquered( function() {} );
				}

				updateScore();
				checkVictory();
				currentMessage = null;
				if( messageFromMe ) {
					disableOption( o );
					if( !canPlayFurther() ) {
						lock = false;
						MMApi.lockMessages( false );
						MMApi.endTurn( NewTurn );
						return;
					}
					currentTurnOption =  -1;
					messageFromMe = false;
					unlockControls();
				}
				lock = false;
				MMApi.lockMessages( false );

				/*
				hasConquered = true;
				currentMessage = ZombieAttack( o, info , {x:playedCell.x, y:playedCell.y} );
				*/
				return;

			case NewTurn :
				playTurnAnim();
				return;
		}
	}

	// Animation jouée en fin de liste une fois que les actions ont été jouées
	function playTurnAnim( o = -1, info : String = null ) {

		if( messageFromMe && !hasCellsToConquer() && !Const.MODE_DUEL) {
			if( canStillPlayOption(myOptions) && !canStillPlayOption( oppOptions ) ){ // sous-entend que l'adversaire ne peut plus jouer
				disableOption( o );
				currentTurnOption =  -1;
				messageFromMe = false;
				unlockControls();
				lock = false;
				MMApi.lockMessages( false );
				return;
			}
		}

		var me = this;
		// C'est moi qui vient de jouer
		if( messageFromMe ) {
			disableOption( o );
			oppTurnAnim.startRoll();
			oppTurnAnim.onEnd = function() { me.lockControls(); me.onEndAnim(); }
			anim.push( oppTurnAnim );
			return;
		}

		var me = this;
		anim.push( new TurnGradient(this) );
		oppTurnAnim.startUnroll();
		oppTurnAnim.onEnd = function () {};
		anim.push( oppTurnAnim );

		// Si ça c'est pas un foutu paradoxe temporel ;)
		if ( ( !messageFromMe && currentTurn == zombieTurn )
			|| ( !messageFromMe && currentTurn == zombieTurn + 1 ) )  {
			var plasma = new PlasmaBg(this, dm.empty(Const.DP_TOP), 3);
			plasma.onEnd = function () {
			}
			anim.add( plasma );

			var a = new MidnightAnim( this );
			a.onEnd = function() {
//				plasma.fadeOut();
				me.unlockControls();
				me.onEndAnim();
			}
			anim.push(a);
		}
		else {
			var b = new TurnInfo( me, me.currentTurn );
			b.onEnd = function () { me.onEndAnim(); me.unlockControls();};
			me.anim.push( b );
		}
	}

	function onEndAnim() {
		updateScore();
		checkVictory();
		messageFromMe = false;
		currentMessage = null;
		currentTurnOption = -1;
		lock = false;
		MMApi.lockMessages( false );
	}

	function zombieAttack( o : Int, info : String = null, playedCell : {x:Int,y:Int} ) {

		//trace( "--------zombieAttack" );
		// Les zombies attaquent après l'action du joueur
		if( invasionDone && o != Type.enumIndex( Water )) {
			var cz = null;
			for( i in 0...zombieMoves.length ) {

				var m = zombieMoves[i];
				var c = grid[m.x][m.y];
				if( c == null ) continue;
				if( c.points > 0 ) continue;
				if( c.void ) continue;
				if( c.armageddon ) continue;
				if( c.x == playedCell.x && c.y == playedCell.y ) continue;

				c.points = m.n;
				cz = c;
				zombieMoves.splice( i, 1 );
				break;
			}

			if( cz != null ) {

				// TODO : vérifier que ce cas n'arrive jamais
				if( cz.points <= 0 ) {
					cz.points = 1;
				}

				// Dans tous les cas on affiche l'animation d'apparition des zombies
				cz.zombify();
				cz.conquered(  function() {
					cz.refresh();
				}, false );

				// les zombies peuvent être affectés par un piège
				if( cz.trap ) {
					cz.untrap();
					if( cz.points <= 0 ) {
						// on affiche la disparition des zombies
						var me = this;
						cz.conquered(  function() {
							me.attachScore(cz,-cz.points);
							cz.reset();
							cz.refresh();
						} );
					} else {
						// on affiche la disparition du piège et la perte d'une unité de zombie
						var me = this;
						cz.conquered(  function() {
							me.attachScore(cz,-Const.TRAP_DAMAGE);
							if( cz.points >= Const.TRAP_DAMAGE ) {
								cz.setPoints(  cz.points - Const.TRAP_DAMAGE );
								cz.refresh();
							} else {
								cz.reset();
							}
						} );
					}
				} else {
					updateNeighbourCells( cz );
				}
			}
		}

		updateScore();
		checkVictory();
		playTurnAnim(o, info);
	}

	function canPlayFurther() {
		if( !Const.MODE_DUEL ) return true;

		if( hasCellsToConquer() ) return true;
		if( canStillPlayOption( myOptions ) ) return true;
		return false;
	}

	/*---------------------------------- INTERFACE -----------------------------------------*/
	/*--------------------------------------------------------------------------------------*/


	function lockControls() {
		mcSelector._visible = false;
		mcSelectedOption._visible = false;
		for( o in options ) o.hide();
		lockGrid();
	}

	function unlockControls() {
		for( o in options ) o.show();
		justUnlockOptions();
		if( team ) zCell.show(); else hCell.show();
		resetGrid();
	}


	/*----------------------------------- OPTIONS ------------------------------------------*/
	/*--------------------------------------------------------------------------------------*/


	public function hideOptionSelector(disabled) {
		if( disabled ) return;
		mcSelectedOption._visible = false;
	}

	public function justUnlockOptions() {

		var ilc = isLastCell();

		for( i in 0...options.length ) {
			var o = options[i];

			if( ( (o.option -1 ) == Type.enumIndex( Water ) ) && ilc ) { o.lock(); continue; }

			if( !canPlayOption( o.option ) ) { o.lock(); continue; }
			if( !o.disabled ) o.unLock();
		}
	}

	public function canPlayOption( option : Int ) {
		switch( option - 1) {
			case Type.enumIndex( MachineGun ):
				return hasOppCells();
			case Type.enumIndex( Gun ):
				return hasOppCells();
			case Type.enumIndex( Cat ):
				return hasOppCells();
			case Type.enumIndex( SportElec ):
				return hasMyCells(); // && c.points < Const.CHANCES[Const.CHANCES.length-1]; // on ne peut pas incrémenter la valeur qui est déjà au max
			case Type.enumIndex( MegaShield ):
				return hasMyCells();
				/*
			case Type.enumIndex( Shield ):
			case Type.enumIndex( Water ):
			case Type.enumIndex( Bed ):
			case Type.enumIndex( Armageddon ):*/
		}
		return true;
	}

	public function unlockOptions( option : Int ) {

		currentTurnOption = -1;
		resetGrid();
		/*
		switch( option ) {
			case Type.enumIndex( MegaShield ) :
				
			case Type.enumIndex( Trap ) :
				resetGrid();
			case Type.enumIndex( Armageddon ) :
				resetGrid();
			case Type.enumIndex( MachineGun ) :
				resetGrid();
			case Type.enumIndex( Gun ) :
				resetGrid();
			case Type.enumIndex( SportElec ) :
				resetGrid();
			case Type.enumIndex( Shield ) :
				resetGrid();
			case Type.enumIndex( Cat ) :
				resetGrid();
		}
		*/

		justUnlockOptions();
	}

	function activateOption( option : Int ) {
		for( i in 0...options.length ) {
			var o = options[i];
			if( option == o.option - 1 ) {
				o.activate();
			} else {
				o.lock();
			}
		}
	}

	function disableOption( option : Int ) {
		for( i in 0...options.length ) {
			var o = options[i];
			if( o.disabled ) continue;
			if( option == o.option - 1 ) {
				o.disable();
				break;
			}
		}

		for( i in 0...options.length ) {
			var o = options[i];
			o.display(o.option);
		}
	}


	/*------------------------------------ GRILLE ------------------------------------------*/
	/*--------------------------------------------------------------------------------------*/

	function hasMyCells() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.points <= 0 ) continue;
				if( c.megaShield ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				if( c.zombie ) continue;
				if( isMyTeam( c ) ) return true;
			}
		}
		return false;
	}

	function hasOppCells() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.points <= 0 ) continue;
				if( c.megaShield ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				if( c.zombie ) return true;
				if( !isMyTeam( c ) ) return true;
			}
		}
		return false;
	}

	function lockGrid() {
		if( grid == null ) return;

		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				c.lock();
			}
		}
	}

	function resetGrid() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				if( c.points <= 0 ) {
					c.unLock( );
					continue;
				}
				c.lock();
			}
		}
	}

	function enableOppCells() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				if( c.points <= 0 ) { c.lock(); continue; }
				if( !c.zombie && isMyTeam( c ) ) { c.lock(); continue; }
				if( c.megaShield ) { c.lock();  continue; }
				c.unLock();
			}
		}
	}

	function enableMyCells() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				if( c.zombie ) continue;
				if( c.points <= 0 ) { c.lock(); continue; }
				if( currentTurnOption == Type.enumIndex( SportElec ) && c.points > 6 ) { c.lock(); continue; }
				if( !isMyTeam( c ) ) { c.lock(); continue; }
				if( c.megaShield ) { c.lock();  continue; }
				if( c.shield ) { c.lock(); continue; }
				c.unLock();
			}
		}
	}

	function enableAllCells() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				c.unLock();
			}
		}
	}

	function enableEmptyCells() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.armageddon ) continue;
				if( c.void ) continue;
				if( c.points > 0 ) continue;
				c.unLock();
			}
		}
	}

	function isMyTeam(c : Cell ) {
		return c.team1 == team;
	}

	function updateNeighbourCells( center : Cell ) {
		var points = 0;
		var directions = if( center.y % 2 == 0 ) Const.DIRECTIONS_2 else Const.DIRECTIONS_1;

		for( d in directions ) {
			var x = center.x + d.x;
			var y = center.y + d.y;
			var c = grid[x][y];

			if(c == null ) continue;
			if( c.armageddon ) continue;
			if( c.void ) continue;
			if( c.points == 0 ) continue;
			if( c.shield )  continue; // cellule vérouillée
			if( c.megaShield )  continue; // cellule vérouillée à vie sauf armageddon
			if( !center.zombie && !c.zombie && ( c.team1 && center.team1 ) ) continue;
			if( !center.zombie && !c.zombie && ( !c.team1 && !center.team1 ) ) continue; // Une des miennes
			if( c.trap && ( !c.team1 && !center.team1 ) ) continue;


			if( c.points < center.points ) {
				var prevSide = c.getSide();

				// Cas de l'invasion zombie
				if( center.zombie ) {
					if( c.zombie ) continue;

					c.zombify();
					//c.conquered( function() { c.refresh(); } );
					c.switched( prevSide, function() {
						c.refresh();
					});
					continue;
				}


				// Les zombies sont éradiqués de la zone mais ne peuvent être tranformés en humains :)
				if( c.zombie ) {
					var me = this;
					c.conquered( function() {
						me.attachScore(c,-c.points);
						c.reset();
					} );
					continue;
				}

				c.switchTeam();
				c.switched( prevSide, function() {
					c.refresh();
				} );
			}
		}
	}

	function updateArmageddonNeighbourCells( cell : Cell ) {
		// TODO test d'ordre des anims

		var points = 0;
		var directions = if( cell.y % 2 == 0 ) Const.DIRECTIONS_2 else Const.DIRECTIONS_1;
		var ump = 0;
		var uop = 0;
		var zmp = 0;
		var zop = 0;

		for( d in directions ) {
			var x = cell.x + d.x;
			var y = cell.y + d.y;
			var c = grid[x][y];
			if(c == null ) continue;
			if( c.armageddon ) continue;
			if( c.void ) continue;
			if( c.megaShield ) continue;
			if( c.points == 0 ) continue;
			c.points--;

			if( c.zombie ) {
				if( c.points <= 0 ) {
					var me = this;
					c.conquered( function() {
						me.attachScore(c,-1);
						c.reset();
					} );
				}
				continue;
			}

			if( c.points <= 0 ){
				var me = this;
				c.conquered( function() {
					me.attachScore(c,-1);
					c.reset();
				} );
				continue;
			}

			var me = this;
			c.conquered( function() {
				me.attachScore(c,-1);
				c.setPoints( c.points );
				c.refresh();
			} );
		}
	}


	/*------------------------------------- INIT -------------------------------------------*/
	/*--------------------------------------------------------------------------------------*/


	// Grid Generation
	public function initialize() {

		// Tableaux des options disponibles
		myOptions = getOptions();
		oppOptions = getOptions();

		var mm = new Array();
		var om = new Array();
		addDeck(mm,om);
		addDeck(mm,om);
		addDeck(mm,om);
		addDeck(mm,om);
		addDeck(mm,om);
		addDeck(mm,om);

		// TODO : Gérer l'option :)
		//var vMode = Std.random( 2 ) == 0;
		var vMode = true;
		var zTurn = Const.HORDE_ATTACK + Std.random( Const.HORDE_ATTACK_VARIATION );
		if( zTurn % 2 != 0 ) zTurn++;
		var grid = Grid.generate();

		// Mouvements des zombies en cas d'invasion
		var max = Const.BOARD_SIZE;
		var moves : Array<{x:Int,y:Int}>= new Array();
		for( x in 0...max ){
			for( y in 0...max ){
				moves.push( grid[x][y] );
			}
		}
		var zmoves = new Array();
		while( moves.length > 0 ) {
			var idx = Std.random( moves.length );
			var m = moves[idx];
			zmoves.push( {x:m.x,y:m.y,n:Std.random( 5 ) + 2 } );
			moves.splice( idx, 1);
		}

		return Init( grid, mm, om, myOptions, oppOptions, vMode, zTurn, zmoves );
	}

	function addDeck(mm,om) {
		// Tableaux des coups à jouer
		var am = 6;

		// 1 - On ajoute les mêmes coups
		var sum = 0;
		var moves = new Array();
		for( i in 0...am ) {
			var val = Const.CHANCES[Std.random(Const.CHANCES.length)];
			moves.push( val );
			sum += val;
		}

		var cgl = moves.copy();
		var zgl = moves.copy();

		// mes coups
		for( i in 0...am ) {
			var idx = Std.random(moves.length);
			var currentMove = moves[idx];
			mm.push( currentMove );
			moves.splice( idx, 1 );
		}

		// coups de l'opposant
		for( i in 0...am ) {
			var idx = Std.random(cgl.length);
			var currentMove = cgl[idx];
			om.push( currentMove );
			cgl.splice( idx, 1 );
		}

		
		// 2 - on ajoute la même somme de coups
		var remaining = sum;
		var oremaining = sum;
		var nv = new Array();
		var ov = new Array();
		for( i in 0...am ) {
			nv.push( 1 );
			ov.push( 1 );
			remaining--;
			oremaining--;
			continue;
		}
	
		// mes coups
		while( remaining > 0 ) {
			for( i in 0...am ) {
				var idx = Std.random(nv.length);
				var val = nv[idx];
				if( val > 6 ) continue;
				remaining --;
				val++;
				nv[idx] = val;
			}
		}
		for( n in nv ) mm.push( n );	

		// coups opp
		while( oremaining > 0 ) {
			for( i in 0...am ) {
				var idx = Std.random(ov.length);
				var val = ov[idx];
				if( val > 6 ) continue;
				oremaining --;
				val++;
				ov[idx] = val;
			}
		}
		for( n in ov ) om.push( n );	
	}

	function getOptions() {

		if( Const.DEBUG ) return [10,10,6,6];

		var h : IntHash<Int>= new IntHash();

		// Tableaux des options obtenues par chaque joueur
		// Les options spéciales ne peuvent être insérées qu'une fois dans le deck
		var a = new Array();
		var o = 0;
		var i = 0;
		while( o < Const.MAX_OPTIONS && i < 200 ) {
			var idx = Std.random( Const.OPTIONS.length );
			var go = Const.OPTIONS[idx];
			var option = Type.enumIndex( go ) + 1;
			if( h.exists( option ) ) {
				var found = false;
				for( g in Const.SINGLE ) {
					if( go == g ) {
						i++;
						found = true;
						break;
					}
				}
				if( found ) continue;
				if( h.get( option) >= 2 ) {
					i++;
					continue;
				}
				h.set( option, 2 );
			}
			else {
				h.set( option, 1 );
			}
			o++;
			i++;
			a.push( option );
		}

		/****
		var hack = [Armageddon,Armageddon,Gun,Gun]; a = new Array();
		for (o in hack) {
			a.push(Type.enumIndex(o)+1);
		}
		/****/

		return a;
	}

	function new( base : flash.MovieClip ) {
		wasTrap = false;
		optionAnim = false;
		invasionDone = false;
		currentMessage = null;
		messageFromMe = false;
		doorClosed = true;
		currentTurn = 0;
		zombieTurn = 0;
		backgroundOption = 1;
		root = base;
		myCount = 0;
		oppCount = 0;
		lock = false;
		myMoves = new Array();
		oppMoves = new Array();
		myOptions = new Array();
		oppOptions = new Array();
		options = new Array();
		currentTurnOption = -1;

		tinyAnims = new Array();
		conquered = new List();
		anim = new List();
		dm = new mt.DepthManager(base);

		mcBg = dm.attach("bground",Const.DP_BG);
		mcBg.cacheAsBitmap = true;

		var mcFenceTop = dm.attach("fence_top",Const.DP_FENCE);
		var mcFenceBottom = dm.attach("fence_bottom",Const.DP_FENCE);
		mcFenceBottom._y = mcFenceTop._height;

		oppTurnAnim = new OppTurnAnim( this );

		MMApi.lockMessages( false );
	}

	function initInterface( messageFromMe ) {

		if( !MMApi.hasControl()	) return;


		// Dock des joueurs
		if( team ) {
			// dock joueur 2
			zCell = new PlayerDock( this,true);
			zCell.setPoints( myMoves[0], myMoves[1] );
			zCell.display();
		} else {
			// dock joueur 1
			hCell = new PlayerDock( this,false);
			hCell.setPoints( myMoves[0], myMoves[1] );
			hCell.display();
		}

		// options de jeu
		for( i in 0...Const.MAX_OPTIONS ) {
			options.push( new Option(this) );
		}

		mcSelector = dm.attach("mcSelection",Const.DP_SELECT);
		mcSelector._visible = false;

		mcSelectedOption = dm.attach("optionCursor",Const.DP_TOP);
		mcSelectedOption._visible = false;
		mcSelectedOption.gotoAndStop( 1 );

		// Tip
		helpTip = new HelpTip( this );


		// Affichage des options
		for( i in 0...myOptions.length ) {
			options[i].display( myOptions[i] );
		}

		var xBase = 47;
		options[0].move( xBase, 257 );
		options[1].move( xBase+38, 257 );
		options[2].move( xBase+135, 257 );
		options[3].move( xBase+173, 257 );
	}

	function initGrid( g : T_Grid) {
		grid = new Array();
		for( i in 0...Const.BOARD_SIZE ){
			grid[i] = new Array();
			for( j in 0...Const.BOARD_SIZE ){
				var d= g[i][j];
				var c = new Cell(this,i,j);
				if( d == null ) {
					c.void = true;
				} else if( d.x == -1 && d.y == -1 ) {
					c.door = true;
				}
				grid[i][j] = c;
			}
		}

		if( Const.DEBUG ) {
			grid = new Array();
			for( i in 0...Const.BOARD_SIZE ){
				grid[i] = new Array();
				for( j in 0...Const.BOARD_SIZE ){
					var d= g[i][j];
					var c = new Cell(this,i,j);
					if( d == null ) {
						c.void = true;
					} else if( d.x == -1 && d.y == -1 ) {
						c.door = true;
					}
					c.points = d.p;
					c.team1 = d.t;
					grid[i][j] = c;
				}
			}
		}

		// Gestion des depths > gauche à droite de haut en bas
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				grid[j][i].display();
				if( Const.DEBUG ) grid[j][i].refresh(); 
			}
		}

	}

	function defineConst() {
		var totalWidth = Const.WIDTH - Const.MARGIN * 2;
		var actualWidth : Float = Const.BOARD_SIZE * Const.CELL_SIZE ;
		this.scale = totalWidth / actualWidth * 100;
		Const.HEXA_BORDER = Const.HEXA_BORDER * this.scale / 100;
		Const.HEXA_ANGLE_HEIGHT = Const.HEXA_BORDER * 0.5;
		Const.HEXA_ANGLE_WIDTH = Const.HEXA_BORDER * 0.866;
		var me = this;
		var scaleValue = function(v) { return v * me.scale / 100; };
		Const.CENTER_X = ( Const.WIDTH - ( Const.BOARD_SIZE * scaleValue( Const.CELL_SIZE ) + Const.HEXA_ANGLE_WIDTH ) ) / 2;
		Const.CENTER_Y = ( Const.WIDTH - ( ( Const.BOARD_SIZE / 2 ) * Const.HEXA_BORDER + ( Const.BOARD_SIZE / 2 ) * scaleValue( Const.CELL_SIZE ) ) ) / 2 - Const.DOCK_Y;
	}

	public function clean() {
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				grid[i][j].cleanUp();
			}
		}
		mcBg.removeMovieClip();
		helpTip.clean();
		for( o in options ){
			o.clean();
		}
		oppTurnAnim.clean();
		hCell.clean();
		zCell.clean();
	}

	public function displayHelp(option){
		helpTip.display( option );
	}

	public function hideHelp(){
		helpTip.hide();
	}

	/*---------------------------SCORE && VICTORY-------------------------------*/


	public function onTurnDone() {
	}

	public function updateScore(){
		var s = "";

		myCount = 0;
		oppCount = 0;

		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.points <= 0 ) continue;
				if( c.zombie ) continue;
				if( c.void ) continue;
				if( c.armageddon ) continue;
				if( !isMyTeam( c ) ) {
					if( Const.MODE_VICTORY == Units )
						oppCount += c.points;
					else if( Const.MODE_VICTORY == Land )
						oppCount++;
				} else {
					if( Const.MODE_VICTORY == Units )
						myCount += c.points;
					else if( Const.MODE_VICTORY == Land )
						myCount++;
				}
			}
		}

		if( Const.MODE_VICTORY == Units ) {
			if( myCount != null && oppCount != null ){
				s += "<div class=\"score0\">"+myCount+" unités</div>";
				s += "<div class=\"score1\">"+oppCount+" unités</div>";
			}
		} else if( Const.MODE_VICTORY == Land ) {
			if( myCount != null && oppCount != null ){
				s += "<div class=\"score0\">"+myCount+" zones</div>";
				s += "<div class=\"score1\">"+oppCount+" zones</div>";
			}
		}

		MMApi.setInfos(s);
	}

	function canStillPlayOption( options : Array<Int>) {
		if( options.length <= 0 ) return false;

		for( oo in options ) {
			var o = oo - 1;
			if( o == Type.enumIndex( Gun )
				|| o == Type.enumIndex( MachineGun )
				|| o == Type.enumIndex( Armageddon )
				|| o == Type.enumIndex( SportElec )
				|| o == Type.enumIndex( Cat ) )
				return true;
		}

		return false;
	}

	function hasCellsToConquer() {
		// CASES
		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.void ) continue;
				if( c.armageddon ) continue;
				if( c.zombie ) continue;
				if( c.points == 0 ) return true; // il y encore au moins une case à jouer
			}
		}
		return false;
	}

	function isLastCell() {
		var count = 0;

		for( i in 0...Const.BOARD_SIZE ){
			for( j in 0...Const.BOARD_SIZE ){
				var c = grid[i][j];
				if( c == null ) continue;
				if( c.void ) continue;
				if( c.armageddon ) continue;
				if( c.points == 0 ) count++; // il y encore au moins une case à jouer
			}
		}

		return count == 1;
	}

	function checkVictory(){

		if( hasCellsToConquer() ) return false;

		if( Const.MODE_DUEL ) {
			if( canStillPlayOption( myOptions ) ) return false;
			if( canStillPlayOption( oppOptions ) ) return false;
		}

		// TODO : intégrer le fait qu'on puisse continuer à jouer si des optiosn sont encore disponibles
		if( myCount == oppCount )
			victory(null);
		else
			victory( myCount > oppCount );

		return true;
	}

	function victory( mine : Bool ){
		mcSelector.removeMovieClip();
		oppTurnAnim.clean();
		MMApi.victory( mine );
	}

	public function onVictory( mine : Bool ){
		haxe.Timer.delay( onGameOver, 2000 );
	}

	public function onGameOver() {
		MMApi.gameOver();
		clean();
	}

	public function onReconnectDone(){
		updateScore();
	}


	/*------------------------------------------ MAIN --------------------------------------------*/


	public function main() {

		if( canShowOptionCursor() ) {
			flash.Mouse.hide();
			mcSelectedOption._x = mcBg._xmouse;
			mcSelectedOption._y = mcBg._ymouse;
			mcSelectedOption.gotoAndStop( currentTurnOption + 1);
			mcSelectedOption._visible = true;
		} else {
			flash.Mouse.show();
			mcSelectedOption._visible = false;
		}


		if ( shakeCpt>0 ) {
			root._x = (Std.random(2)*2-1) * shakeCpt;
			root._y = (Std.random(2)*2-1) * shakeCpt;
			shakeCpt-=shakeSpeed;
			if ( shakeCpt<=0 ) {
				shakeCpt = 0;
				root._x = 0;
				root._y = 0;
			}
		}
		var i = 0;
		while (i<tinyAnims.length) {
			var mc = tinyAnims[i];
			mc.nextFrame();
			if ( mc._currentframe>=mc._totalframes ) {
				mc.removeMovieClip();
				tinyAnims.splice(i,1);
				i--;
			}
			i++;
		}

		if( conquered.length > 0 ){
			var a = conquered.first();
			if( a.play() ) {
				a.onEnd();
				a.clean();
				conquered.remove(a);
			}
			return;
		} else {
			if( hasConquered ) {
				var t = messageFromMe;
				var c = currentMessage;
				onEndAnim();
				if( t ) {
					MMApi.sendMessage( c );
				}
				hasConquered = false;
			}
		}

		if( anim.length > 0 ){
			for( a in anim ){
				if( a.play() ){
					a.onEnd();
					a.clean();
					anim.remove( a );
				}
			}
			return;
		}

		if(!MMApi.isReconnecting()){
			helpTip.update();
		}

		if( !MMApi.isMyTurn() || !MMApi.hasControl()) {
			return;
		}

		if( lock )
			return;

	}

	function canShowOptionCursor() {
		if ( lock ) return false;
		if( currentTurnOption < 0 ) return false;

		switch( currentTurnOption ) {
			case Type.enumIndex( Shield ) : return false;
			case Type.enumIndex( Gun ) : return true;
			case Type.enumIndex( MachineGun ) : return true;
			case Type.enumIndex( Armageddon ) : return true;
			case Type.enumIndex( SportElec ) : return true;
			case Type.enumIndex( Water ) : return false;
			case Type.enumIndex( Bed ) : return false;
			case Type.enumIndex( Cat ) : return true;
			case Type.enumIndex( MegaShield ) : return true;
			case Type.enumIndex( Trap ) : return true;
		}
		return false;
	}

	function attachTinyAnim(link:String, x,y) {
		var mc = dm.attach(link, Const.DP_FENCE);
		mc._x = x;
		mc._y = y;
		mc.stop();
		tinyAnims.push(mc);
		return mc;
	}

	function attachScore(cell:Cell,n:Int) {
		if (n==0) return;
		var mc = cast attachTinyAnim("fx_score", cell.mc._x+25, cell.mc._y+25);
		var smc : {>flash.MovieClip, field:flash.TextField} = cast mc.smc;
		smc.field.text = (if(n>0) "+" else "") + n;
	}

	public function shake(cpt,?spd=0.1) {
		shakeCpt = cpt;
		shakeSpeed = spd;
	}

}
