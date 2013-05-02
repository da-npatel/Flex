package com.digitalaisle.frontend.valueObjects.entityObjects
{
	import com.digitalaisle.utils.DateTimeUtil;
	
	import org.casalib.util.DateUtil;
	import org.casalib.util.ObjectUtil;

	public class ProjectEventItem extends ProjectContentItem
	{
		public var startTime:String;
		public var endTime:String;
		public var duration:int = 0;
		public var firstOccurenceDate:Date;
		public var lastOccurenceDate:Date;
		public var isRecurring:Boolean;
		public var reccurrenceType:int;
		public var maxRecurrences:int;
		
		public function ProjectEventItem()
		{
			super();
		}
		
		override public function create(projectEventItemNode:XML, uri:String, ownerId:int, projectURI:String):void
		{
			super.create(projectEventItemNode, uri, ownerId, projectURI);
			
			startTime = DateTimeUtil.timeStringToLabel(projectEventItemNode.startTime); 
			endTime = DateTimeUtil.secondsToLabel(DateTimeUtil.timeStringToSeconds(projectEventItemNode.startTime) + (projectEventItemNode.duration * 60));
			duration = projectEventItemNode.duration;
			firstOccurenceDate = DateUtil.iso8601ToDate(projectEventItemNode.firstOccurenceDate);
			if(projectEventItemNode.hasOwnProperty("lastOccurenceDate")) 
				lastOccurenceDate = DateUtil.iso8601ToDate(projectEventItemNode.lastOccurenceDate);
			if(projectEventItemNode.hasOwnProperty("isRecurring")) 
				isRecurring = projectEventItemNode.isRecurring == "89" ? true : false;
			if(projectEventItemNode.hasOwnProperty("reccurenceType")) 
				reccurrenceType = projectEventItemNode.reccurenceType; 
			if(projectEventItemNode.hasOwnProperty("maxRecurrences")) 
				maxRecurrences = projectEventItemNode.maxRecurrences;
		}
	}
}
