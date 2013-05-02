 package com.digitalaisle.frontend.events {
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.core.UIComponent;
		
	public class UserTouchEvent extends Event {
		
		public static const TOUCH:String = "touch";
		
		private var _point:Point;
		private var _uid:int;
		private var _action:int;
		private var _description:String;
		
		public function UserTouchEvent(type:String, uid:int, action:int, point:Point, description:String = "", bubbles:Boolean=true, cancelable:Boolean=false) {								
					
			_point = point;
			_uid = uid;
			_action = action;
			_description = description;
			
			super(type, bubbles, cancelable);
		}
		
		public function get description():String
		{
			return _description;
		}

		public override function clone():Event { 
			return new UserTouchEvent(type, _uid, _action, _point, _description, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("UserTouchEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}

		public function get point():Point
		{
			return _point;
		}

		public function get uid():int
		{
			return _uid;
		}

		public function get action():int
		{
			return _action;
		}


	}
}