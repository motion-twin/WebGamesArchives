package game.ai;

import game.GameState;
import game.PlayerData;

/*
 * The player chose to support the ball's owner pushing and blocking oponents.
 */
class SupportRun {
	public static function enter(p:PlayerData) : Void {
	}
	public static function update(player:PlayerData){
		var resolver = player.resolver;
		var supported = if (resolver.ball.owner != null) resolver.ball.owner else player.targetPlayer;
		if (supported == null || (resolver.ball.owner == null && resolver.ball.velocity == null) || supported.stuntTurns > 0){
			player.changeState(IdleState);
			return;
		}
		// If we are the thrower we must make the big decision of unleashing the batter or not
		if (player.isThrower()){
			// TODO: add some random there and may be some extraordinary conditions
			if (resolver.state == GameState.FLY || player.distanceToBall() > 25){
				player.changeState(IdleState);
				return;
			}
		}
		// If an attacker is really near the runner  and we have the opportunity to attack it, we do so
		var runnerFoes = supported.foesByDistance();
		if (runnerFoes.length > 0 && player.distanceToPlayer(runnerFoes[0]) < PlayerData.FIGHT_DIST){
			player.contactPlayer(runnerFoes[0], true);
			return;
		}
		// If an attacker is between us and the runner, it may be a good idea to block it
		var myFoes = player.foesByDistance();
		for (foe in myFoes){
			var distToFoe = player.distanceToPlayer(foe);
			if (distToFoe < PlayerData.MEDIUM_DIST
			&& resolver.random() > 0.8
			&& player.distanceToPlayer(foe) < foe.distanceToPlayer(supported)){
				player.targetPlayer = foe;
				player.changeState(BlockPlayer);
				return;
			}
		}
		if (!player.selectSupportPoint(supported)){
			#if flash
			trace("This fucking player "+player.pos+" was not able to find a support coordinate !");
			#end
		}
	}
	public static function leave(p:PlayerData){
	}
	public static function toString(player:PlayerData) : String {
		if (player.resolver.ball.owner != null)
			return "Support(BallOwner)";
		if (player.targetPlayer == null)
			return "Support(null)";
		return "Support("+player.targetPlayer.pos+")";
	}
}

