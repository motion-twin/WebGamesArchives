package game.viewer;
import game.Event;
import GameParameters;
import Item;
using StringFormat;

class GameLog {
	public static var watcherName : String;
	static var seed : mt.Rand;
	public static var resolver : game.Resolver;

	public static function reset(s:mt.Rand){
		seed = s;
		usedAmbiants = [];
	}

	public static function posName( pos:Pos ){
		if (pos == null)
			return "Banc de touche";
		switch (pos){
			case Att(p):
				if (p == null)
					return "Banc de touche";
				return switch (p){
					case AttL:"Attaquant gauche";
					case AttR:"Attaquant droit";
					case Bat1:"Batteur 1";
					case Bat2:"Batteur 2";
					case Bat3:"Batteur 3";
					case ASub:"Remplaçant";
				}
			case Def(p):
				if (p == null)
					return "Banc de touche";
				return switch (p){
					case Thro:"Lanceur";
					case DefL:"Défenseur gauche";
					case DefM:"Défenseur central";
					case DefR:"Défenseur droit";
					case DefF:"Défenseur arrière";
					case DSub:"Remplaçant";
				}
			case Bat:
				return "Batteur";
		}
	}

	static function otherTeamName( team:game.Team ){
		return teamName(team == resolver.teamA ? resolver.teamB : resolver.teamA);
	}

	static function teamName( team:game.Team ){
		return "<span class='team"+team.id+"'>"+team.name+"</span>";
	}

	public static function getPlayerName( p:PlayerData ){
		if (p == null)
			return "#null";
		return (watcherName == p.team.name && p.label != "" && p.label != null) ? p.label : p.name;
	}

	static function playerName( p:PlayerData ){
		if (p == null)
			return "null";
		var n = (watcherName == p.team.name && p.label != "" && p.label != null) ? p.label : p.name;
		return "<span class='team"+p.team.id+"'>"+n+"</span>";
	}

	static function randomPlayer(){
		var p = Lambda.array(resolver.players);
		var n = seed.random(p.length);
		return p[n];
	}

	static var NAMER : tools.Namer;
	static function comment(key:String, ?data:Dynamic){
		if (NAMER == null)
			NAMER = new tools.Namer(haxe.Resource.getString("gamelog.txt"));
		var str = NAMER.template(key, data, seed);
		return str;
	}

	static var battlerTricked : Bool = false;
	static var actionBeforeGround : Bool = false;
	static var catchWait : String = null;
	static var ballOwner : PlayerData = null;
	static var usedAmbiants = [];

	public static function getAmbiant() : String {
		if (usedAmbiants.length >= 10)
			return null;
		var data = { name:playerName(randomPlayer()) };
		var attempts = 0;
		var result = "";
		do {
			result = comment("{ambiant}", data);
		}
		while (Lambda.has(usedAmbiants, result) && ++attempts < 2);
		usedAmbiants.push(result);
		return div("ambiant", result);
	}

	public static function eventToString( e:game.Event ){
		var r1 = null;
		var pass = false;
		if (catchWait != null){
			switch (e){
				case HasPicoron(pId):
					r1 = catchWait;
					pass = true;
				case PicoSafe(pId):
				default:
					r1 = catchWait;
			}
			catchWait = null;
		}
		if (resolver.state == game.GameState.FLY){
			switch (e){
				case Ground(f):
				default:
					actionBeforeGround = true;
			}
		}
		var res = switch (e){
			case Hit(att, def, life, lostBall): {
				var data = { name:playerName(att), name2:playerName(def), life:life };
				div("attack", comment("{attack}", data) + (lostBall ? comment("{attack-lostball}",data) : ""));
			}
			case ItemDamaged(p): {
    			div("item-damaged", comment("{item-damaged}", { name:playerName(p) }));
			}
			case ItemDestroyed(p): {
			    div("item-destroyed", comment("{item-destroyed}", { name:playerName(p) }));
			}
			case Bobo(p,o): {
			    div("bobo", comment("{bobo-light}", { name:playerName(p), organ:o.xid }), "/img/comps/Wound.jpg");
			}
			case Injure(p,o): {
			    div("injure", comment("{bobo-hard}", { name:playerName(p), organ:o.xid }), "/img/comps/Wound.jpg");
			}
			case Ko(p): {
			    div("ko", comment("{ko}", { name:playerName(p) }), "/img/comps/Wound.jpg");
			}
			case Recovered(p): {
			    div("recovered", comment("{recovered}", { name:playerName(p) }));
			}
			case TooMuchKo(t): {
				div("abandon", comment("{abandon}", { team:teamName(t) }));
			}
			case Replace(out, sub, pos): {
				if (out == null){
					div("enter", comment("{enter}", {
						name:playerName(sub),
						position:posName(pos)
					}));
				}
				else {
					div("replace", comment("{replace}", {
						name:playerName(sub),
						name2:playerName(out),
						position:posName(pos)
					}));
				}
			}
			case BatTry:
			case Push(att,def,lostBall): {
				var data = { name:playerName(att), name2:playerName(def) };
				div("push",	comment("{push}", data) + (lostBall ? comment("{push-lostball}", data) : ""));
			}
			case HalfTime: {
			    div("pause", comment("{pause}", {}), "/img/comps/Halftime.jpg");
			}
			case DefStart:
				null;
			case DefPlayer(z,w):
				null;
			case DefEnd:
			    null;
			case GiveUp(team): {
				div("forfait", comment("{forfait}", {name:teamName(team), name2:otherTeamName(team)}));
			}
			case Draw: {
				div("draw", comment("{draw}", {name:teamName(resolver.teamA), name2:otherTeamName(resolver.teamB)}));
			}
			case Winner(team): {
				div("victory", comment("{victory}", {name:teamName(team), name2:otherTeamName(team)}));
			}
			case RoundStart:
				null;
			case Ground(dist): {
			    if (actionBeforeGround)
					null;
			    if (dist <= 40)
			        div("ground-bof", comment("{ground-bof}", {name:playerName(resolver.battler)}));
			    else
			        div("ground-cool", comment("{ground-cool}", {name:playerName(resolver.battler)}));
			}
			case PhaseStart(team, round, phase): {
			    if (round != 0 || phase != 0)
				    div("phase", comment("{phase}", {name:teamName(team)}), "/img/comps/Changeside.jpg");
			}
			case NextBattler(p): {
				div("next-battler", comment("{next-battler}", {name:playerName(p)}),
				"/img/comps/"+(resolver.attTeam.id == 0 ? "blue" : "red")+"_changebatt"+(resolver.batNumber+1)+".jpg"
				);
			}
			case NextAttempt(round,phase,bat,attempt): {
			    battlerTricked = false;
			    ballOwner = null;
			    "";
			}
			case AttemptEnd:
			case RefereeIsWaitingThrower(p): {
			    div("referee-waiting-thrower", comment("{referee-waiting-thrower}", {name:playerName(p)}));
			}
			case PreThrow:
			case Throw(kind, extraComp): {
			    if (extraComp != null){
					div("skill",
					tools.MyStringTools.format(extraComp.getAmbiant(seed), {name:playerName(resolver.thrower), name2:playerName(resolver.battler)}),
					"/img/comps/"+extraComp.icon+".jpg"
					);
				}
				else {
					div("throw", comment("{throw}", {kind:throwKindToString(kind)}));
				}
			}
			case BattlerTricked(bId,tId,malus): {
			    battlerTricked = true;
			    "";
			}
			case BattlerNotTricked(b,t): {
			    battlerTricked = true;
				div("battler-not-tricked", comment("{battler-not-tricked}", {name:playerName(b), name2:playerName(t)}));
			}
			case FalseThrowFault: {
			    div("false-throw-fault", comment("{false-throw-fault}", {}));
			}
			case ThrowFault: {
			    if (!battlerTricked)
					div("throw-fault", comment("{throw-fault}", {}));
			}
			case Strike,FalseStrike: {
			    if (battlerTricked && e == Strike){
					div("battler-tricked-loose",
					    comment("{battler-tricked}", {name:playerName(resolver.battler), name2:playerName(resolver.thrower)})+
					    comment("{battler-tricked-loose}", {name:playerName(resolver.battler), name2:playerName(resolver.thrower)})
					);
				}
				else if (e == Strike){
					div("strike", comment("{strike}", {name:playerName(resolver.battler), name2:playerName(resolver.thrower)}));
				}
				else {
					div("false-strike", comment("{false-strike}", {name:playerName(resolver.battler), name2:playerName(resolver.thrower)}));
				}
			}
 			case Battled: {
			    actionBeforeGround = false;
			    if (battlerTricked)
					div("battler-tricked", comment("{battler-tricked}", {name:playerName(resolver.battler), name2:playerName(resolver.thrower)}));
			}
			case TooShort: {
			    div("battled-too-short", comment("{battled-too-short}", {name:playerName(resolver.battler)}));
			}
			case BatFault: {
				div("battled-fault", comment("{battled-fault}", {name:playerName(resolver.battler)}));
			}
			case PicoStar: {
				div("picostar", comment("{picostar}", {name:playerName(resolver.battler)}));
			}
			case HasPicoron(p): {
				if (pass){
					var t = div("pass", comment("{pass}", {name:playerName(ballOwner), name2:playerName(p)}));
					ballOwner = p;
					t;
				}
				else {
					catchWait = div("catch", comment("{catch}", {name:playerName(p)}));
					ballOwner = p;
					null;
				}
			}
			case PicoPafAttempt(p): {
				div("picopaf-try", comment("{picopaf-try}", {name:playerName(p)}));
			}
			case PicoPaf(p): {
			    div("picopaf", comment("{picopaf}", {name:playerName(p)}));
			}
			case AttScore:
			case AttFailed:
			case PicoOut: {
				div("out", comment("{out}", {}));
			}
			case PicoSafe(p): {
			    div("safe", comment("{safe}", {name:playerName(p)}));
			}
			case DefFault(n):
			case AttFault:
			case Fault(team, player): {
			    div("fault", comment("{fault}", {name:playerName(player), team:teamName(team), team2:otherTeamName(team)}));
			}
			case DebugPos(p): {
				"DBG "+Std.string(p);
			}
			case BattlerCannotPlayAttempt(batNbr): {
				div("no-battler", comment("{no-battler}", { num:batNbr }));
			}
			case PlayerDisabled(pid): {
			    null;
			}
			case ViceActive(p, v): {
				div("vice", tools.MyStringTools.format(v.getAmbiant(), {name:playerName(p)}));
			}
			case CompetenceActive(p, c): {
			    div("skill",
			    tools.MyStringTools.format(c.getAmbiant(seed), {name:playerName(p)}),
				"/img/comps/"+c.icon+".jpg"
				);
			}
			case CompetenceActive2(p, p2, c): {
			    div("skill",
				tools.MyStringTools.format(c.getAmbiant(seed), {name:playerName(p), name2:playerName(p2)}),
				"/img/comps/"+c.icon+".jpg"
				);
			}
			case RefereeJocker(p): {
				div("referee-jocker", comment("{referee-jocker}", {name:playerName(p)}));
			}
			case UseDrug(p, drug): {
    			div("use-drug", comment("{use-drug}", { name:playerName(p), drug:drug.name }));
			}
			case DrugFault(seen, p, drug): {
				var data = { name:playerName(p), drug:drug.name };
				if (seen)
					div("drug-fault", comment("{drug-fault}", data));
				else
					div("no-drug-fault", comment("{no-drug-fault}", data));
			}
			case HooliganAlone(t, h): {
			    div("hooligan-alone", comment("{hooligan-alone}", { team:teamName(t), name:h.name }));
			}
			case HooliganDraw(hA, hB, s): {
			    div("hooligan-draw", comment("{hooligan-draw}", { teamA:teamName(resolver.teamA), teamB:teamName(resolver.teamB), nameA:hA.name, nameB:hB.name }));
			}
			case HooliganFight(tA, hA, sA, tB, hB, sB): {
			    div("hooligan-fight", comment("{hooligan-fight}", { winnerTeam:teamName(tA), loserTeam:teamName(tB), winner:hA.name, loser:hB.name }));
			}
		}
		if (res == null)
			return r1;
		if (r1 != null)
			res = r1+res;
		return StringTools.replace(res, " !", "&nbsp;!");
	}

	public static function eventArtwork(e:game.Event) : { img:String, team:Int, title:String } {
		var image = function(str:String, teamId:Int){
			return str.format([ teamId == 0 ? "B" : "R" ]);
		}
		var result = switch (e){
			case PicoStar: { img:"/img/temp/vignette_{0}_picostar.jpg", team:resolver.attTeam.id, title:"Picostar" };
			case Winner(t): { img:"/img/temp/vignette_{0}_victoire.jpg", team:t.id, title:"Victoire" };
			case NextBattler(p): { img:"/img/temp/vignette_{0}_newbatt.jpg", team:p.team.id, title:"Batteur suivant" };
			case PhaseStart(t,r,p): { img:"/img/temp/vignette_{0}_changement.jpg", team:t.id, title:"Changement" };
			case HalfTime: { img:"/img/temp/vignette_{0}_mitemps.jpg", team:resolver.attTeam.id, title:"Mi-temps" };
			case Bobo(p, o): { img:"/img/temp/vignette_{0}_blesslegere.jpg", team:p.team.id, title:"Blessure légère" };
			case Injure(p, o): { img:"/img/temp/vignette_{0}_blessgrave.jpg", team:p.team.id, title:"Blessure grave" };
			case ThrowFault: { img:"/img/temp/vignette_{0}_lancefaute.jpg", team:resolver.defTeam.id, title:"Lancer faute" };
			case PicoPaf(p): { img:"/img/temp/vignette_{0}_splotch.jpg", team:resolver.attTeam.id, title:"Splatch" };
			case PicoSafe(p): { img:"/img/temp/vignette_{0}_sauve.jpg", team:resolver.defTeam.id, title:"Sauve" };
			case Fault(t,p): { img:"/img/temp/vignette_{0}_arbitre.jpg", team:p.team.id, title:"Faute" };
				// case XXX: { img:"/img/temp/arbitre.png", team:0, title:"Faute" };
			case Strike: { img:"/img/temp/vignette_{0}_strike.jpg", team:resolver.defTeam.id, title:"Strike" };
			case FalseStrike: { img:"/img/temp/vignette_{0}_arbitre.jpg", team:resolver.attTeam.id, title:"Arbitrage douteux" };
			case FalseThrowFault:  { img:"/img/temp/vignette_{0}_arbitre.jpg", team:resolver.defTeam.id, title:"Arbitrage douteux" };
			case BatFault,TooShort: { img:"/img/temp/vignette_{0}_battfaute.jpg", team:resolver.attTeam.id, title:"Faute batteur" };
			default: null;
		}
		if (result != null){
			result.img = image(result.img, result.team);
		}
		return result;
	}

	inline static function div(cls:String, str:String, ?img:String) : String {
		return if (str == null || str == "") null
			else "<div class='"+cls+"'>"+(img == null ? "" : "<img src='"+img+"' alt=''/>")+str+"</div>";
	}


	public static function throwKindToString(kind:ThrowKind){
		return switch (kind){
			case PowerThrow: "une balle Forte";
			case SpeedThrow: "une balle Rapide";
			case CurveThrow: "une balle Courbe";
		}
	}
}
