package com.digitalaisle.frontend.utils
{
	import com.adobe.utils.DateUtil;
	import com.digitalaisle.frontend.enums.BinaryType;
	import com.digitalaisle.frontend.enums.entity.RecurrenceType;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.valueObjects.EventCalendarItem;
	import com.digitalaisle.frontend.valueObjects.entityObjects.ProjectEventItem;
	import com.digitalaisle.utils.DateTimeUtil;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import mx.collections.ArrayCollection;
	
	import org.casalib.util.ArrayUtil;
	import org.casalib.util.ConversionUtil;
	import org.casalib.util.DateUtil;
	
	public class EventCalendarUtil extends EventDispatcher
	{
		private static const GREATHER_THAN:int = -1;
		private static const LESS_THAN:int = 1;
		private static const EQUAL:int = 0;
		
		private var _eventsList:ArrayCollection = new ArrayCollection();
		
		public function EventCalendarUtil(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		/**
		 * 
		 * @param startDate
		 * @param endDate
		 * @return 
		 * 
		 */		
		public function fetchEventsByDateRange(startDate:Date, endDate:Date):ArrayCollection
		{
			var validEvents:Array = new Array();
			
			for(var i:int = 0; i < _eventsList.length; i++)
			{
				
				var currentEvent:ProjectEventItem = _eventsList[i];
				var eventDate:Date = currentEvent.firstOccurenceDate;
				var isValid:Boolean;

				//isValid = isEventValid(eventDate, startDate, endDate);
			
				//if(isValid)
				//{
					//validEvents.push(EventCalendarItem.create(currentEvent.id, currentEvent.name, currentEvent.shortDescription, retrieveThumbnail(currentEvent), currentEvent.firstOccurenceDate, currentEvent.startTime, currentEvent.endTime));
					
					if(currentEvent.isRecurring)
					{
						//if(isValid) {validEvents.push(EventCalendarItem.create(currentEvent.id, currentEvent.name, currentEvent.shortDescription, currentEvent.firstOccurenceDate, currentEvent.startTime, currentEvent.endTime)); }
						if(currentEvent.maxRecurrences > 0)
						{
							for(var j:int = 0; j < currentEvent.maxRecurrences; j++)
							{
								var nextRecurrenceDate:Date = fetchNextOccurenceDateByReccurenceType(currentEvent.reccurrenceType, eventDate, j);
								isValid = isEventValid(nextRecurrenceDate, startDate, endDate);

								if(isValid) { validEvents.push(currentEvent); }
								else { break; }
							}
						}else
						{
							var incriment:Number;
							var lastOccurenceDate:Date;
							
							if(currentEvent.lastOccurenceDate)
							{
								lastOccurenceDate = currentEvent.lastOccurenceDate;
							}else
							{
								lastOccurenceDate = endDate;
							}
								
							var days:Number = Math.ceil(ConversionUtil.millisecondsToDays(org.casalib.util.DateUtil.getTimeBetween(currentEvent.firstOccurenceDate, lastOccurenceDate)));
							
							switch(currentEvent.reccurrenceType)
							{
								case RecurrenceType.DAILY:
									incriment = days;
									break;
								case RecurrenceType.WEEKLY:
									incriment = days / 7; 
									break;
								case RecurrenceType.MONTHLY:
									incriment = (days / 7) / 4; 
									break;
								case RecurrenceType.ANNUALLY:
									incriment = Math.floor(days / 365);		// TODO: CHECK FOR LEAP YEAR????
									trace("Annually = " + incriment);
									break;
							}
							
							var validEventsByType:Array = fetchValidEventsByRecurrencType(currentEvent, startDate, endDate, currentEvent.reccurrenceType, incriment);
							ArrayUtil.addItemsAt(validEvents, validEventsByType, (validEvents.length - 1));
						}
					}else
					{
						// Check single date
						isValid = isEventValid(currentEvent.firstOccurenceDate, startDate, endDate);
						if(isValid)
						{
							validEvents.push(currentEvent);

						}
				}
			}
			
			return new ArrayCollection(validEvents);
		}
		

		public function fetchEventsByDate(date:Date):ArrayCollection
		{
			var validEvents:ArrayCollection = fetchEventsByDateRange(date, date);
			return validEvents;
		}
		
		private function isEventValid(eventDate:Date, startDate:Date, endDate:Date):Boolean
		{
			var isValid:Boolean = true;
			
			
			if(com.adobe.utils.DateUtil.compareDates(eventDate, startDate) == GREATHER_THAN || com.adobe.utils.DateUtil.compareDates(eventDate, startDate) == EQUAL)
			{
				if(com.adobe.utils.DateUtil.compareDates(eventDate, endDate) != GREATHER_THAN || com.adobe.utils.DateUtil.compareDates(eventDate, endDate) == EQUAL) { isValid = true; }
				else { isValid = false; }
			}else
			{
				isValid = false;
			}
			
			return isValid;
		}
		
		
		private function fetchValidEventsByRecurrencType(event:ProjectEventItem, startDate:Date, endDate:Date, recurrenceType:int, incriment:int):Array
		{
			var validEvents:Array = new Array();

			for(var i:int = 0; i < (incriment + 1); i++)
			{
				var nextRecurrenceDate:Date = fetchNextOccurenceDateByReccurenceType(recurrenceType, event.firstOccurenceDate, i);

				if(com.adobe.utils.DateUtil.compareDates(nextRecurrenceDate, startDate) != LESS_THAN || com.adobe.utils.DateUtil.compareDates(nextRecurrenceDate, startDate) == EQUAL)
				{
					if(isEventValid(nextRecurrenceDate, startDate, endDate))
					{
						validEvents.push(event);	
					}else
					{
						break;
					}
				}
			}
			
			return validEvents;
		}

		
		
		
		/**
		 * 
		 * @param eventId
		 * @return 
		 * 
		 */		
		public function fetchEventById(eventId:int):ProjectEventItem
		{
			var projectEventItem:ProjectEventItem = new ProjectEventItem();
			
			for(var i:int = 0; i < _eventsList.length; i++)
			{
				if(_eventsList[i].id == eventId)
				{
					projectEventItem = _eventsList[i];
					break;
				}
			}
			
			return projectEventItem;
		}
		
		
		private function fetchNextOccurenceDateByReccurenceType(type:int, firstDate:Date, incriment:int):Date
		{
			var nextOccurenceDate:Date;
			
			switch(type)
			{
				case RecurrenceType.DAILY:
					nextOccurenceDate = DateTimeUtil.dateAdd("d", incriment, firstDate);
					break;
				case RecurrenceType.WEEKLY:
					nextOccurenceDate = DateTimeUtil.dateAdd("w", incriment, firstDate);
					break;
				case RecurrenceType.MONTHLY:
					nextOccurenceDate = DateTimeUtil.dateAdd("m", incriment as Number, firstDate);
					break;
				case RecurrenceType.ANNUALLY:
					nextOccurenceDate = DateTimeUtil.dateAdd("y", incriment as Number, firstDate);
					break;
			}
			
			return nextOccurenceDate;
		}

		private function retrieveThumbnail(eventItem:ProjectEventItem):String
		{
			var thumbnail:String = DataManager.getInstance().fetchBinaryContentByType(eventItem, BinaryType.THUMBNAIL);
			return thumbnail;
		}
		
		public function get eventsList():ArrayCollection
		{
			return _eventsList;
		}

		public function set eventsList(value:ArrayCollection):void
		{
			_eventsList = value;
		}

	}
}