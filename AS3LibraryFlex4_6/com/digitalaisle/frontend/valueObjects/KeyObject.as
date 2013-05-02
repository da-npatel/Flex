package com.digitalaisle.frontend.valueObjects
{
	public class KeyObject extends Object
	{
		public var value:String;
		public var type:int;
		public var weight:Number;
		public var functionType:String;
		
		public function KeyObject()
		{
			super();
		}
		
		public static function create(type:int, value:String, functionType:String = "value", weight:Number=0):KeyObject
		{
			var keyObject:KeyObject = new KeyObject();
			keyObject.type = type;
			keyObject.value = value;
			keyObject.functionType = functionType;
			keyObject.weight = weight;
			return keyObject;
		}
	}
}