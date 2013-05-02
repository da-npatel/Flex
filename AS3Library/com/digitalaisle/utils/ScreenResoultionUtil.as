package com.digitalaisle.utils
{
	import flash.geom.Point;
	import flash.system.Capabilities;

	public class ScreenResoultionUtil
	{
		public static var HD_720:Point = new Point(1280, 720);
		public static var HD_1080:Point = new Point(1920, 1080);
		public static var HP_SLATE:Point = new Point(600, 1024);
		
		
		public function ScreenResoultionUtil()
		{
		}
		
		public static function get screenResolution():Point
		{
			return new Point(Capabilities.screenResolutionX, Capabilities.screenResolutionY);
		}
	}
}