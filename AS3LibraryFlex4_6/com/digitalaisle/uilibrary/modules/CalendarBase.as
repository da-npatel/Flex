package com.digitalaisle.uilibrary.modules
{	
	import com.digitalaisle.frontend.components.DAPanelSlider;
	import com.digitalaisle.uilibrary.components.buttons.DAButton;
	import com.digitalaisle.uilibrary.containers.ProductPage;
	
	import flash.events.MouseEvent;
	
	import mx.controls.DateChooser;
	import mx.events.FlexEvent;
	import mx.modules.ModuleBase;
	
	import spark.components.RichText;
	
	public class CalendarBase extends ModuleBase
	{
				
		private var currentDate:Date = new Date();
		private var currentMonth:Number;
				
		[SkinPart(required="true")]
		public var calendar:DateChooser;
		
		[SkinPart(required="true")]
		public var btnPrevMonth:DAButton;
		
		[SkinPart(required="true")]
		public var btnNextMonth:DAButton;
		
		[SkinPart(required="false")]
		public var txtPanelTitle:RichText;
		
		[SkinPart(required="false")]
		public var eventsPanel:DAPanelSlider;
		
		[SkinPart(required="false")]
		public var productPage:ProductPage;
		
		[SkinPart(required="false")]
		public var btnPrevFlow:DAButton;
		
		public function CalendarBase()
		{
			super();
			addEventListener(FlexEvent.PREINITIALIZE, preinitialize);
			addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		private function preinitialize(event:FlexEvent):void
		{
			calendarEventObj = DataManager.getInstance().fetchModuleDataById(ApplicationUtil.getInstance().selectedModuleId) as EventCalendarObject;
			trace("APP UTIL" + ApplicationUtil.getInstance().selectedModuleId);
			eventCalUtil = new EventCalendarUtil();
			eventCalUtil.eventsList = calendarEventObj.eventsList;
		}
		
		private function onCreationComplete(event:FlexEvent):void
		{
			txtPanelTitle.text = "Events on " + getDayString(currentDate.getDay()) + ", " + getMonthString(currentDate.getMonth()) + " " + String(currentDate.getDate()) + ", " + String(currentDate.getFullYear());
			calendar.selectedDate = currentDate;
			populateDaysEvents(currentDate);
		}
		
		private function onCalendarCreationComplete(event:FlexEvent):void
		{
			showMonthsEvents();
		}private function onCalendarCreationComplete(event:FlexEvent):void
		{
			showMonthsEvents();
		}		
						
		override protected function partAdded(partName:String, instance:Object):void
		{
			super.partAdded(partName, instance);
			
			switch(instance)
			{
				case calendar:
					calendar.addEventListener(FlexEvent.UPDATE_COMPLETE, onCalendarUpdate);
					calendar.addEventListener(FlexEvent.CREATION_COMPLETE, onCalendarCreationComplete);
					calendar.addEventListener(MouseEvent.CLICK, onCalendarClick);
					break;
				case btnNextMonth:
					btnNextMonth.addEventListener(MouseEvent.CLICK, onNextMonthClick);
					break;
				case btnPrevMonth:
					btnPrevMonth.addEventListener(MouseEvent.CLICK, onPrevMonthClick);
					break;
				case txtPanelTitle:
					txtPanelTitle.text = _txtPanelTitle;
					break;
				case eventsPanel:
					eventsPanel.addEventListener(PanelEvent.SINGLE_CLICK, onTitledSliderClick);
					eventsPanel.clickSound = ApplicationUtil.getInstance().defaultClick;
					break;
				case productPage:
					break;
				case btnPrevFlow:
					btnPrevFlow.addEventListener(MouseEvent.CLICK, onPrevFlowClick);
					break;
			}
		}
		
		override protected function partRemoved(partName:String, instance:Object):void
		{
			super.partRemoved(partName, instance);
			
			switch(instance)
			{
				case calendar:
					calendar.removeEventListener(FlexEvent.UPDATE_COMPLETE, onCalendarUpdate);
					calendar.removeEventListener(FlexEvent.CREATION_COMPLETE, onCalendarCreationComplete);
					calendar.removeEventListener(MouseEvent.CLICK, onCalendarClick);
					break;
				case btnNextMonth:
					btnNextMonth.removeEventListener(MouseEvent.CLICK, onNextMonthClick);
					break;
				case btnPrevMonth:
					btnPrevMonth.removeEventListener(MouseEvent.CLICK, onPrevMonthClick);
					break;
				case txtPanelTitle:
					txtPanelTitle.text = _txtPanelTitle;
					break;
				case eventsPanel:
					eventsPanel.removeEventListener(PanelEvent.SINGLE_CLICK, onTitledSliderClick);
					eventsPanel.clickSound = ApplicationUtil.getInstance().defaultClick;
					break;
				case productPage:
					video.source = _sourceVideo;
					break;
				case btnPrevFlow:
					contentScroller.content = _bodySource;
					break;
			}
		}
		
		public function get panelTitle():String { return _txtPanelTitle; }
		public function set panelTitle(value:String):void {
			txtPanelTitle.text = value;
		}
		
		public function get sourceVideo():String { return _sourceVideo; }
		public function set sourceVideo(value:String):void {
			if(_productViewMode == VIDEO)
			{
				video.source = value;
			}
		}
				
		public function get bodyContent():String { return _bodySource; }
		public function set bodyContent(value:String):void {
			//Check and see if part was added
			if(txtBody)
				txtBody.content = value;
		}
		
		private function onCalendarUpdate(event:FlexEvent):void
		{
			if(currentDate.month != currentMonth)
			{
				currentMonth = currentDate.month;
				populateMonthsEvents(currentDate);
			}
		}		
		
		private function onCalendarClick(event:MouseEvent):void
		{
			SessionManager.getInstance().updateSession(0, ActionType.IGNORE, new Point(0, 0));
			ApplicationUtil.getInstance().defaultClick.play();
			
			if(currentDate.month != calendar.displayedMonth) //MONTH CHANGE
			{
				populateMonthsEvents(currentDate);
			}else if(calendar.selectedDate != null && calendar.selectedDate != currentDate){ //DAY CHANGE
				currentDate = calendar.selectedDate;
				populateDaysEvents(currentDate);
			}
		}
		
		private function onNextMonthClick(event:MouseEvent):void
		{
			var tempDate:Date = currentDate;
			tempDate.date = 1;
			tempDate.month++;
			calendar.selectedDate = tempDate;
			currentDate = tempDate;
		}
		
		private function onPrevMonthClick(event:MouseEvent):void
		{
			var tempDate:Date = currentDate;
			tempDate.date = 1;
			tempDate.month--;
			calendar.selectedDate = tempDate;
			currentDate = tempDate;
			//populateMonthsEvents(currentDate);
		}
		
		private function onTitledSliderClick(event:MouseEvent):void
		{
			currentState = "EventPage";
			var currentEventResult:ProjectEventItem = eventCalUtil.fetchEventById(event.currentTarget.selectedID);
			
			if(currentEventResult.binaryContentItems.length > 0)
			{
				for each(var value:BinaryContentItem in currentEventResult.binaryContentItems)
				{
					if(value.type == 2)
					{
						//productImage.source = finalResults[event.target.selectedId].folderPath + value.uri;
						//productImage.source = DataManager.getInstance().fetchBinaryContentByType(finalResults[event.target.selectedID], BinaryType.IMAGE);
						productPage.currentState = "Video";
						productPage.sourceVideo = DataManager.getInstance().fetchBinaryContentByType(currentEventResult, BinaryType.VIDEO);
						break;
					}else if(value.type == 0)
					{					
						productPage.currentState = "Image";
						
						var tempSource:String = DataManager.getInstance().fetchBinaryContentByType(currentEventResult, BinaryType.IMAGE);
						if(tempSource != null && tempSource != "")
						{
							productPage.sourceImage = tempSource;
						}else{
							productPage.sourceImage = _defaultEventImage
						}
					}
				}
			}else{
				productPage.sourceImage = _defaultEventImage;
			}
			
			productPage.txtTitle.text = currentEventResult.name;
			if(currentEventResult.longDescription != null && currentEventResult.longDescription.length > 0)
			{
				productPage.bodyContent = currentEventResult.longDescription as Object;
			}else if(currentEventResult.shortDescription != null && currentEventResult.shortDescription.length > 0){
				productPage.bodyContent = currentEventResult.shortDescription as Object;
			}else{
				productPage.bodyContent = "No current description.";
			}
		}	
		
		private function populateMonthsEvents(curDate:Date):void
		{
			var monthsEvents:ArrayCollection = new ArrayCollection();
			var startDate:Date = new Date(curDate.fullYear, curDate.month,1);
			var lastDayInMonth:int = DateUtil.getDaysInMonth(curDate.fullYear, curDate.month);
			var endDate:Date = new Date(curDate.fullYear, curDate.month, lastDayInMonth);
			monthsEvents = eventCalUtil.fetchEventsByDateRange(startDate ,endDate);
			//monthsEvents = eventCalUtil.fetchEventsByDateRange(new Date(2010,10,1) ,new Date(2010,10,31));
			panelGroupDP = new ArrayCollection();
			dateCollection = new ArrayCollection();
			
			for each(var value:EventCalendarItem in monthsEvents)
			{
				var newObj:Object = new Object();
				newObj.date = value.eventDate.month + "/" + value.eventDate.date + "/" + value.eventDate.fullYear;
				newObj.data = value;
				dateCollection.addItem(newObj);
			}
			
			showMonthsEvents();
			populateDaysEvents(currentDate);
		}
		
		private function populateDaysEvents(currentDate:Date):void
		{
			if(currentDate != null)
			{
				titleText.text = "Events on " + getDayString(currentDate.day) + ", " + getMonthString(currentDate.month) + " " + String(currentDate.date) + ", " + String(currentDate.fullYear);
				//panelTitle = "Events on " + getDayString(currentDate.day) + ", " + getMonthString(currentDate.month) + " " + String(currentDate.date) + ", " + String(currentDate.fullYear);
				var daysEvents:ArrayCollection = eventCalUtil.fetchEventsByDate(currentDate);
				panelGroupDP = new ArrayCollection();
				for each(var value:EventCalendarItem in daysEvents)
				{
					trace("DATE " + value.eventDate);
					var newListPanelObj:ListPanelObject = new ListPanelObject();
					newListPanelObj.descriptionText = value.shortDescription;
					newListPanelObj.overriddenID = value.id;
					if(value.thumbnail == "")
					{
						newListPanelObj.thumbGraphic = _defaultEventThumb;//"app:/assets/ESPN/images/thumbs/defaultEvent.png";
					}else{
						newListPanelObj.thumbGraphic = value.thumbnail;
					}
					newListPanelObj.titleText = value.name;
					panelGroupDP.addItem(newListPanelObj);
					
				}
				if(panelGroupDP.length > 0)
				{
					listPanelGroup.source = panelGroupDP;
					calendar.selectedDate = currentDate;
					eventsPanel.source = listPanelGroup;
					noEvents.visible = false;
				}else{
					noEvents.visible = true;
				}
			}
			
		}
		
		private function showMonthsEvents():void
		{				
			//Compare above collection to current month in dateChooser and highlight dates with events
			for(var i:uint = 0; i < calendar.numChildren; i++)
			{
				var calendarObj:Object = calendar.getChildAt(i);
				if(calendarObj.hasOwnProperty("className"))
				{
					if(calendarObj.className == "CalendarLayout")
					{
						var cal:CalendarLayout = CalendarLayout(calendarObj);
						for(var j:uint = 0; j < cal.numChildren; j++)
						{
							var dateLabel:Object = cal.getChildAt(j);										
							if(dateLabel.hasOwnProperty("text"))
							{
								
								var day:UITextField = UITextField(dateLabel);				
								day.styleName = "dateNoEvent";
								day.background = false;
								day.border = true;
								day.borderColor = day.getStyle("borderColor");
								day.alpha = 1;
								var eventArray:Array = dateHelper((calendar.displayedMonth) + "/" + dateLabel.text + "/" + currentDate.fullYear);
								if(eventArray.length > 0)
								{
									day.styleName = "dateEvent";
									day.background = true;
									day.backgroundColor = day.getStyle("backgroundColor");
									day.borderColor = day.getStyle("borderColor");
									day.alpha = .7;
								}
							}
						}
					}
				}
			}
		}	
		
		private function dateHelper(renderedDate:String):Array
		{
			var result:Array = new Array();
			for(var i:uint = 0; i < dateCollection.length; i++)
			{
				if(dateCollection[i].date == renderedDate)
				{
					result.push(dateCollection[i]);
				}
			}
			return result;
		}	
		
		private function getDayString(day:int):String
		{
			var dayString:String;
			switch(day){
				case 0:
					dayString = "Sunday";
					break;
				case 1:
					dayString = "Monday";
					break;
				case 2:
					dayString = "Tuesday";
					break;
				case 3:
					dayString = "Wednesday";  
					break;
				case 4:
					dayString = "Thursday";
					break;
				case 5:
					dayString = "Friday";
					break;
				case 6:
					dayString = "Saturday";
					break;
			}
			return dayString;
		}
		
		private function getMonthString(month:int):String
		{
			var monthString:String;
			switch(month){
				case 0:
					monthString = "January";
					break;
				case 1:
					monthString = "Febuary";
					break;
				case 2:
					monthString = "March";
					break;
				case 3:
					monthString = "April";  
					break;
				case 4:
					monthString = "May";
					break;
				case 5:
					monthString = "June";
					break;
				case 6:
					monthString = "July";
					break;
				case 7:
					monthString = "August";
					break;
				case 8:
					monthString = "September";
					break;
				case 9:
					monthString = "October";
					break;
				case 10:
					monthString = "November";
					break;
				case 11:
					monthString = "December";
					break;
			}
			return monthString;
		}
		
		private function onPrevFlowClick(event:MouseEvent):void
		{
			currentState = "Main";
		}
	}
}