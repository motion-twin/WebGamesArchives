package game.ai;

import GameParameters;
import game.Event;
import game.GameState;
import game.PlayerData;

/*
 * Idle state: the player has to decide what to do now.
 */
class IdleState {

	public static function enter(p:PlayerData){
		_update(p, true);
	}

	public static function update(player:PlayerData){
		_update(player);
	}

	static function _update(player:PlayerData,first=false){
		var resolver = player.resolver;
		if (player.team.leader == player)
			player.team.leader = null;
		if (player.updateAway())
			return;
		if (player.life <= 0){
			player.changeState(Exhausted);
			return;
		}
		if (triggerVice(player))
			return;
		if (triggerPicoFreeze(player))
			return;
		if (triggerShockwave(player))
			return;
		switch (player.pos){
			case Def(p):
				if (resolver.state == GameState.FLY && player.isThrower() && resolver.ballDest.magnitude() > 45){
					return;
				}
				if (resolver.ball.owner == null){
					var friends = player.friends();
					resolver.field.sortDistances(1, friends);
					if (player.team.leader == null){
						for (i in 0...friends.length)
							if (friends[i].canPlay() && friends[i].life > 0){
								player.team.leader = friends[i];
								break;
							}
					}
					if (player.team.leader == player){
						player.changeState(ChaseBall);
					}
					else if (friends[0] == player){ // I am the nearest
						player.targetPlayer = player.team.leader;
						player.changeState(SupportRun);
					}
					else if (friends[1] == player){ // I am near
						player.selectSupportPoint(player.team.leader);
					}
					else if (p != Thro && friends[2] == player){ // I am rather far
						player.selectSupportPoint(player.team.leader);
					}
					else if (p != Thro && friends[3] == player){ // I am far
						player.targetPlayer = player.team.leader;
						player.changeState(SupportRun);
					}
					else if (p != Thro && friends[4] == player){
						player.selectSupportPoint(player.team.leader);
					}
					else if (p == Thro && !first){
						player.steering.div(2);
						player.velocity.div(2);
					}
				}
				else {
					var friends = player.friends();
					resolver.field.sortDistances(1, friends);
					if (resolver.ball.owner == player){
						// What's the ? Me ? Really ?
						player.changeState(RunToBase);
					}
					else {
						player.targetPlayer = friends[0];
						player.changeState(SupportRun);
					}
				}

			case Att(p):
				var friends = player.friends();
				resolver.field.sortDistances(1, friends);
				if (triggerPicoFreeze(player)){
				}
				else if (friends[0] == player){ // I am the nearest
					player.changeState(ChaseBall);
				}
				else {
					player.changeState(CutRetreat);
				}

			case Bat:
				if (resolver.state == GameState.FLY && !resolver.throwerMoved)
					return;
				if (resolver.throwerMoved || resolver.field.distance(0, 1) < 30){
					if (player.distanceToBall() < 30)
						player.changeState(ChaseBall);
					else
						player.changeState(CutRetreat);
				}
				else {
					var batPos = Field.posToPoint(player.pos);
					var batPos = new geom.PVector3D(batPos.x, batPos.y);
					if (!player.position.equals(batPos)){
						player.seek(batPos);
					}
					else {
						player.stop();
					}
				}
		}
	}

	public static function leave(player:PlayerData){
	}

	public static function toString(p:PlayerData) {
		return "Idle";
	}

	static function triggerVice( player:PlayerData ){
		if (player.waitingVice != null && player.resolver.state == GameState.GROUND){
			var vice = player.waitingVice;
			player.waitingVice = null;
			if (vice.cond(player))
				if (player.triggerVice(vice.vice))
					return true;
		}
		return false;
	}

	static function triggerPicoFreeze( player:PlayerData ) : Bool {
		var resolver = player.resolver;
		if (resolver.ball.owner == null && resolver.state == GameState.GROUND && player.hasCompetence(Competence.get.PicoFreeze)){
			var players = resolver.field.players.copy();
			resolver.field.sortDistances(1, players);
			if (players[0] != player && players[0].team == player.team && player.triggerCompetence(Competence.get.PicoFreeze)){
				player.competencesCooldown.set(Competence.get.PicoFreeze.dbid, 1);
				player.stuntTurns = 10;
				player.changeState(game.ai.Stunt);
				resolver.ball.stuntTurns = 20;
				resolver.event(CompetenceActive(player, Competence.get.PicoFreeze));
				return true;
			}
		}
		return false;
	}

	static function triggerShockwave( player:PlayerData ) : Bool {
		var resolver = player.resolver;
		var shockwave = Competence.get.Shockwave;
		var shockwaveStunt = 10;
		var shockwaveRadius = 10;
		if (!player.triggerCompetence(shockwave))
			return false;
		var nearestFriend = player.getNearestFriend();
		if (nearestFriend != null && nearestFriend.distanceToPlayer(player) <= shockwaveRadius)
			return false;
		var others = player.others().players.filter(
			function(p) return (player.stuntTurns == 0 && !player.isAway && player.life > 0 && player.distanceToPlayer(p) <= shockwaveRadius)
		);
		var hasOwner = false;
		if (resolver.ball.owner != null)
			for (o in others)
				if (resolver.ball.owner == o){
					hasOwner = true;
					break;
				}
		if (others.length < 3 && !hasOwner)
			return false;
		for (p in others){
			p.stuntTurns = shockwaveStunt;
			p.changeState(game.ai.Stunt);
		}
		if (hasOwner)
			resolver.ball.owner.loseBall();
		resolver.event(CompetenceActive(player, shockwave));
		player.competencesCooldown.set(Competence.get.Shockwave.dbid, 1);
		return true;
	}
}