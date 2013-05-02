package com.digitalaisle.frontend.valueObjects
{
	public class EventCalendarItem extends Object
	{
		public var id:int = 0;
		public var name:String;
		public var shortDescription:String;
		public var eventDate:Date;
		public var startTime:String = "";
		public var endTime:String = "";
		public var thumbnail:String = "";
		
		public function EventCalendarItem()
		{
			super();
		}
		
		public static function create(id:int, name:String, shortDesc:String, thumbnail:String, eventDate:Date, startTime:String, endTime:String):EventCalendarItem
		{
			var eventCalendarItem:EventCalendarItem = new EventCalendarItem();
			eventCalendarItem.id = id;
			eventCalendarItem.name = name;
			eventCalendarItem.shortDescription = shortDesc;
			eventCalendarItem.eventDate = eventDate;
			eventCalendarItem.startTime = startTime;
			eventCalendarItem.endTime = endTime;
			eventCalendarItem.thumbnail = thumbnail;
			return eventCalendarItem;
		}
	}
}