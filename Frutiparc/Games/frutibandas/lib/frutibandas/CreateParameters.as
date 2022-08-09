// 
// Copyright (c) 2004 Motion-Twin
//
// $Id: CreateParameters.as,v 1.9 2004/05/06 11:10:42  Exp $
// 

/**
 * Game creation parameters.
 */
class frutibandas.CreateParameters 
{
    private static var timeChoices : Array = [600, 480, 400, 240];
    private static var sizeChoices : Array = [8, 7, 6, 5];
    private static var cardChoices : Array = [4, 3, 2, 1];

    /** Maximum play time for each team. */
    public var time : Number;
    /** Board size. */
    public var size : Number;
    /** Number of cards per player. */
    public var card : Number;

    /**
     * Constructor.
     */
    public function CreateParameters()
    {
        this.time = undefined;
        this.size = undefined;
        this.card = undefined;
    }

    /**
     * Set parameter data using specified choice indexes.
     */
    public function init( timeId : Number, sizeId:Number, cardId:Number ) : Void 
    {
        time = timeChoices[timeId];
        size = sizeChoices[sizeId];
        card = cardChoices[cardId];
    }
}
//EOF

