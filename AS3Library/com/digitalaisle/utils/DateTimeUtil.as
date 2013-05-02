package com.digitalaisle.utils {
	
	/**
	 * 
	 * The DateTimeUtil class contains methods for translating and validating common Date and Time formats.  
	 * 
	 * 
	 **/
	
	public class DateTimeUtil {
		
		public function DateTimeUtil() {
		
		}		
		/**
		 * Converts seconds to a valid time string in the format of <i>HH:MM:SS</i>
		 * 
		 * @param seconds The total number of seconds to be converted.
		**/
		public static function secondsToTimeString(seconds:int):String { // TODO Requires improvement
			var remainder:Number;
			var hours:Number = seconds / ( 60 * 60 );
			remainder = hours - (Math.floor ( hours ));
			hours = Math.floor ( hours );
			var minutes:Number = remainder * 60;
			remainder = minutes - (Math.floor ( minutes ));
			minutes = Math.floor ( minutes );
			var secs:Number = remainder * 60;
			remainder = secs - (Math.floor ( secs ));
			secs = Math.floor ( secs );
			
			var hString:String = hours < 10 ? "0" + hours : "" + hours;	
			var mString:String = minutes < 10 ? "0" + minutes : "" + minutes;
			var sString:String = secs < 10 ? "0" + secs : "" + secs;
			
			if ( seconds < 0 || isNaN(seconds)) return "00:00:00";			
			
			if ( hours > 0 ) {			
				return hString + ":" + mString + ":" + sString;
			} else {
				return "00:" + mString + ":" + sString;
			}
		}
		
		/**
		 * Converts a valid time string in the format of <i>HH:MM:SS</i> to seconds.
		 * 
		 * @param time A valid time string in the format of <i>HH:MM:SS:</i>
		 * **/
		public static function timeStringToSeconds(time:String):int {
			if(!validateTimeString(time)){
				trace("timeStringToSeconds Error: "+time+" is not a properly formatted time string.");
				return -1;
			}		
			
			var hours:int = int(time.substr(0,2));
			var mins:int = int(time.substr(3,2));
			var secs:int = int(time.substr(6,2));	
			secs += (hours * 3600) + (mins * 60);
				
			return secs;
		}
		
		/**
		 * Tests a value to determine if is a valid time string with the format <i>HH:MM:SS</i>.
		 * 
		 * @param value The string value to be tested.
		 * **/		
		public static function validateTimeString(value:String):Boolean {
			var valid:Boolean;
			var pattern:RegExp = /[0-9]{2}:[0-9]{2}:[0-9]{2}/;
			if(pattern.exec(value) != null){
				valid = true;
			}
			return valid;
		}
		
		/**
		 * 
		 * **/
		public static function dateAdd(datepart:String = "", number:int = 0, date:Date = null):Date {
			if (date == null) {		
				date = new Date(); /* Default to current date. */
			}
			
			var returnDate:Date = copyDate(date);
			
			switch (datepart.toLowerCase()) {
				
				case "y":
					returnDate["fullYear"] += number;
					break;
				case "m":
					returnDate["month"] += number;
					break;
				case "w":
					returnDate["date"] += number * 7;
					break;
				case "d":
					returnDate["date"] += number;
					break;
				case "min":
					returnDate["minutes"] += number;
					break;
				case "sec":
					returnDate["seconds"] += number;
					break;
				default: /* Unknown date part, do nothing. */			
					break;
			}
			
			return returnDate;
		}
		
		/**
		 * Converts a valid time string with the format <i>HH:MM:SS</i> to a time display label.
		 * 
		 * @param time A valid time string.
		 * @param showSeconds Flags whether or not seconds will be displayed in the label
		 * @param twentyFourHourClock Flags whether or not to display the time label as a twenty four hour clock. If set to FALSE (default) the appropriate meridiem will be appended to the time label.
		 * **/		
		public static function timeStringToLabel(time:String, showSeconds:Boolean = false, twentyFourHourClock:Boolean = false):String {
			if(!validateTimeString(time)){
				trace("timeStringToLabel Error: "+time+" is not a valid time string.");
			}
			
			var hours:String = time.substr(0,2);
			var minutes:String = time.substr(3,2);
			var seconds:String = time.substr(6,2);			
			var lbl:String = "";
			
			if(twentyFourHourClock){				
				lbl = hours+":"+minutes
				if(showSeconds){
					lbl += ":" + seconds;
				}
			} else {
				var hourDisplay:String = String(int(hours)%12);
				hourDisplay = hourDisplay == "0" ? "12" : hourDisplay;
				lbl = hourDisplay + ":" + minutes;
				if(showSeconds){
					lbl += ":" + seconds;
				}
				
				lbl += int(hours) < 11 ? " AM" : " PM";				
			}
				
			return lbl;
		}
		
		/**
		 * Converts a value in seconds to a time label with the format <i>HH:MM AM|PM</i>
		 * 
		 * @param seconds An int value for the total number of seconds to be converted. 
		 * **/		
		public static function secondsToLabel(seconds:int):String {
			return timeStringToLabel(secondsToTimeString(seconds));
		}
		
		/**
		 * Returns a new Date object that is a duplicate of the target date.
		 * 
		 * @param date The date object to be duplicated.
		 * **/
		public static function copyDate(date:Date):Date {			
			return new Date(date.fullYear, date.month, date.date, date.hours, date.minutes, date.seconds, date.milliseconds);
		}
		
		/*private function dateToTimeString(date:Date):String {
			var hString:String = date.hours < 10 ? "0" + date.hours : "" + date.hours;	
			var mString:String = date.minutes < 10 ? "0" + date.minutes : "" + date.minutes;
			var sString:String = date.seconds < 10 ? "0" + date.seconds : "" + date.seconds;
			
			if ( date.seconds < 0 || isNaN(date.seconds)) return "00:00:00";			
			
			if ( date.hours > 0 ) {			
				return hString + ":" + mString + ":" + sString;
			} else {
				return "00:" + mString + ":" + sString;
			}
		}*/
		
	}
}