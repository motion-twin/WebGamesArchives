// 
// $Id: Callback.as,v 1.5 2004/06/24 11:43:43  Exp $
// 

class frutibandas.Callback 
{
    private var object; // : Object;
    private var method : Function;

    public function Callback(o, m:Function) 
    {
        this.object = o;
        this.method = m;
    }

    public function execute() 
    {
        this.method.call(this.object);
    }

    public function execute_1(param) : Void
    {
        this.method.call(this.object, param);
    }

    public function toString() : String
    {
        return this.object+"."+this.method+"()";
    }
}

//EOF
