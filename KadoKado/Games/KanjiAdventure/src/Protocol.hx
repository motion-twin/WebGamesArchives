
/*
enum BadType {
	CACA;
	ORK;
	INSECT;
	HYDRA;
}
*/

enum SquareType {
	GROUND;
	WALL;
	STAIR_UP;
	STAIR_DOWN;
}

enum Action {
	Attack(d:Int);
	Goto(d:Int);

}

enum AttackBehaviour {

	BRandom(c:Float);
	BStick;

}
enum MoveBehaviour {

	BHunt;
	BNormal(c:Float);
	BErratic(c:Float);
	BCoward;
}
