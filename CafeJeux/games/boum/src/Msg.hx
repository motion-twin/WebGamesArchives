enum Msg {
	Init( g : Int );
	SendTurn(pid:Int,log:Array<Array<Int>>);
	Victory;
}