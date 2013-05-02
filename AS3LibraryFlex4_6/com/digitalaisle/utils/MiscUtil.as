package com.digitalaisle.utils
{
	import mx.utils.StringUtil;

	public class MiscUtil
	{
		public function MiscUtil()
		{
		}
		
		public static function convertStringToKeyValueObject(value:String, keepAssignment:Boolean=false):Object
		{
			var results:Array = value.split(";");
			var returnObject:Object = new Object();
			
			for(var i:int = 0; i < results.length; i++)
			{
				var keyValuePair:Array = results[i].split("=");
				if(keyValuePair.length > 0) returnObject[StringUtil.trim(keyValuePair[0])] = keepAssignment ? StringUtil.trim(keyValuePair[0]) + "=" + StringUtil.trim(keyValuePair[1]) : StringUtil.trim(keyValuePair[1]);
				else returnObject[StringUtil.trim(keyValuePair[0])] = null;
			}
			return returnObject;
		}
		
		public static function getFilePath(path:String):String
		{
			var fSlash: int = path.lastIndexOf("/");
			var bSlash: int = path.lastIndexOf("\\"); // reason for the double slash is just to escape the slash so it doesn't escape the quote!!!
			var slashIndex: int = fSlash > bSlash ? fSlash : bSlash;
			trace(path.slice(0, slashIndex + 1));
			return path.slice(0, slashIndex + 1);
		}
	}
}