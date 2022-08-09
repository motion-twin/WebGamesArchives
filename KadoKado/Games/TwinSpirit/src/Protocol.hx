
enum Bomb {
	Reverse;
	Transfert;
	Standard;
}

enum Command {

	// POSITION
	Pos( x:Float, y:Float );
	StarPos( x:Float, y:Float, a:Float, d:Float );

	// POUSSEE
	Gear( n:Float );
	Impulse( n:Float, ?angle:Float );
	Push( n:Float, ?angle:Float );
	Acc( n:Float, time:Int );

	// ROTATION
	Angle( n:Float );
	Rot( n:Float );
	Turn( n:Float, time:Int );


	// GFX
	Spin( rot:Float, speedRot:Float );
	PlayAnim( frame:String );
	SetOrient(or:Orient);

	// MISC
	Back( inc:Int, time:Int );
	Wait( n:Float );
	Frict( n:Float );
	AddBehaviour( bh:Behaviour );
	RemoveBehaviour( ?id:Int );
	AddStatus( st:Status );
	RemoveStatus( st:Status );

	// TURRET
	Turret( cycle:Float );
	TurretStrafe( ec:Float );
	TurretShoot( n:Int );
	TurretCycle( n:Int );

	// SHOOT
	Shoot( angle:Float, ?ra:Float  );
	Fire(  angle:Float, ?ra:Float );
	Aim(   da:Float, ?speed:Float  );

	ShotType( n:ShotType );
	ShotPos( ?x:Float, ?y:Float );



	//Shoot( speed:Int, ?multi:Int, ?type:Int );
}

enum Orient{
	Front(c:Float);
	Incline(c:Float);
}

enum BadFamily {
	DRONE;
	SUPER_DRONE;
	SENTINELLE;
	ZILA;
	ASSASSIN;
	VOLT_BALL;
	BEHEMOTH;
	KOBOLD;

}

enum Status {
	INVINCIBLE;
}

enum ShotType {
	STNormal;
	STVolt;
	STSpeed;
}






























