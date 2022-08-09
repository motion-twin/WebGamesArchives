package;

import data.DataManager;
import data.LevelDesign;
import Protocol;
import Common;

/**
 * ...
 * @author Tipyx
 */
class MobileServer
{
	#if mBase
	public static var IS_WAITING_SERVER		: Bool		= false;

	public static function DO_PROTOCOL(p:ProtocolCom) {
		switch (p) {
			case ProtocolCom.DoLaunchGame(l) :
				LAUNCH_GAME(l);
			case ProtocolCom.DoSendGame(g) :
				SAVE_GAME(g);
			case ProtocolCom.DoGetUserData:
				// update lives in USER_LOCAL
				LevelDesign.SAVE_USERLOCAL();
			default :
				SEND_PROTOCOL(p);
		}
	}
	
	static function LAUNCH_GAME(level:Int) {
		var userLocal = LevelDesign.USER_LOCAL;

		if (userLocal.userData.levelMax < 1)
			userLocal.userData.levelMax = 1;
		
		if (level == 5) {
			var b = true;
			
			for (t in userLocal.userData.tutoDone)
				if (t == level)
					b = false;
					
			if (b && userLocal.userData.pickaxe == 0)
				userLocal.userData.pickaxe = 1;
		}
		
		if (userLocal.life > 0) {
			USE_LIFE();
			
			if (process.popup.GoalLevels.ME != null)
				process.popup.GoalLevels.ME.goToLevel();
		}
		else {
			if (process.Levels.ME != null) {
				if (process.popup.GoalLevels.ME != null)
					process.popup.GoalLevels.ME.onClose();
				process.ProcessManager.ME.showLife(process.Levels.ME);
			}
			else if (process.Game.ME != null)
				process.ProcessManager.ME.showLife(process.Game.ME);
		}
		
		LevelDesign.SAVE_USERLOCAL();
	}
	
	static function USE_LIFE() {
		var userLocal = LevelDesign.USER_LOCAL;
		
		if( userLocal.life == LevelDesign.GET_MAX_LIFES() )
			userLocal.lastGivingLife = Date.now().getTime();

		userLocal.life -= 1;
	
		if( userLocal.life == 0 ){
			userLocal.nextFullLife = userLocal.lastGivingLife + DateTools.minutes(Protocol.TIME_REFILL_LIFE) * LevelDesign.GET_MAX_LIFES();
			#if push
			var t = data.Lang.T._("Vous avez à nouveau toutes vos vies.");
			mtnative.push.Push.scheduleNotification( {
				tag: "fullLife",
				date: Date.fromTime(userLocal.nextFullLife),
				title: data.Lang.T._("Plein de vies !"),
				text: t,
				ticker: t,
				url: "/",
			});
			#end
		}
	}

	public static function ADD_LIVES( delta : Int ){
		var userLocal = LevelDesign.USER_LOCAL;

		userLocal.life += delta;
		if( userLocal.life >= LevelDesign.GET_MAX_LIFES() )
			userLocal.life = LevelDesign.GET_MAX_LIFES();
		userLocal.nextFullLife = null;
		#if push
		mtnative.push.Push.cancelNotification("fullLife");
		#end
	}
	
	static function SAVE_GAME(g:GameData) {
		var userLocal = LevelDesign.USER_LOCAL;
		var userData = userLocal.userData;
		
		if (g.level <= userData.levelMax) {
			userLocal.gamesBuffer.push(g);
			
			switch (g.success) {
				case TypeEndGame.TEGVictory :
					ADD_LIVES( 1 );
					
					if (g.level == userData.levelMax){
						userData.levelMax += 1;
						//if (userData.levelMax > Protocol.MAX_LEVEL)
							//userData.levelMax = Protocol.MAX_LEVEL;
					}
					
					if (userData.arHighScore[g.level] == null || g.score > userData.arHighScore[g.level])
						userData.arHighScore[g.level] = g.score;
				case TypeEndGame.TEGDefeat, TypeEndGame.TEGGiveUp:
			}
			
			for (a in g.arAssets) {
				var b = true;
				for (as in userData.arAssets) {
					if (as.tr.equals(a.tr)) {
						b = false;
						as.num += a.num;
					}
				}
				
				
				if (b)
					userData.arAssets.push( { tr:a.tr, num:a.num } );
			}
			
			for (l in g.arLoots) {
				var b = true;
				for (lo in userData.arLoots) {
					if (lo.id == l.id) {
						b = false;
						lo.num += l.num;
					}
				}
				
				if (b)
					userData.arLoots.push( { id:l.id, num:l.num } );
			}
			
			LevelDesign.SAVE_USERLOCAL();
			
			if( process.popup.End.ME != null )
				process.popup.End.ME.isSendGameGood = true;
			
			userLocal.gamesBuffer.push(g);
			
			SEND_PROTOCOL( DoGetUserData );
		}
	}
	
	public static function SEND_PROTOCOL( p : Null<ProtocolCom>, ?onData:ProtocolCom->Void, ?onError:mt.net.Error->Void, retry=3 ) {
		if( IS_WAITING_SERVER ){
			if( p != null )
				haxe.Timer.delay(function() SEND_PROTOCOL(p),500);
		}

		var userLocal = LevelDesign.USER_LOCAL;
		var buf = userLocal.gamesBuffer.copy();

		if( buf.length == 0 && p == null )
			return;
		
		IS_WAITING_SERVER = true;
			
		Main.getWorker().enqueue(new mt.Worker.WorkerTask(function() {
			var s = Type.enumIndex(p);
			var mobileP = ProtocolCom.DoMobileAPI(buf, p);
			mt.net.Codec.requestUrl( data.DataManager.API_URL() + "/m_" + s, mobileP, function(d) {
				var resendBuf = false;
				switch (d) {
					case ProtocolCom.SendValidMobileAPI(arId, subResp) :
						mt.device.User.syncGoals();
						for (g in userLocal.gamesBuffer.copy()) {
							for (id in arId)
								if (g.mobileID == id)
									userLocal.gamesBuffer.remove(g);
						}

						if( onData != null )
							onData( subResp );
						else if( subResp != null )
							onFromServer(subResp);

						resendBuf = true;
					default :
				}
				IS_WAITING_SERVER = false;
				if ( resendBuf )
					SEND_PROTOCOL( null );
			}, function (d) {
				IS_WAITING_SERVER = false;
				#if debug
				trace (d);
				#end
				if( onError != null )
					onError( d );
				else if( p != null )
					DataManager.onError(d);
			}, retry);
		}));
	}

	static function onFromServer( subResp : ProtocolCom ){
		var preventDefault = false;
		var userLocal = data.LevelDesign.USER_LOCAL;
		switch( subResp ){
		case SendValidPurchaseLife(udata):
			ADD_LIVES( LevelDesign.GET_MAX_LIFES() );
		default:
		}
		if( !preventDefault )
			DataManager.onFromServer(subResp);
	}
	#end
}
