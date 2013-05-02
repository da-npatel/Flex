package com.digitalaisle.frontend.valueObjects
{
	public class LocaleObject extends Object
	{
		public var en:Object;
		public var es:Object;
		public var fr:Object;
		
		public function LocaleObject()
		{
			super();
		}
		
		public static function create(en:Object, es:Object, fr:Object):LocaleObject
		{
			var localeObject:LocaleObject = new LocaleObject();
			localeObject.en = en;
			localeObject.es = es;
			localeObject.fr = fr;
			return localeObject;
		}
	}
}