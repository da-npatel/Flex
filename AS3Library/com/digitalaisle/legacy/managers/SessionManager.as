package com.digitalaisle.legacy.managers 
{ 
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.enums.SessionType;
	import com.digitalaisle.legacy.events.SessionEvent;
	import com.digitalaisle.legacy.services.statusservice.StatusService;
	import com.digitalaisle.legacy.services.valueObjects.ICISClientStatusType;
	import com.digitalaisle.legacy.services.valueObjects.ICISServiceEmailRequest;
	import com.digitalaisle.legacy.services.valueObjects.ICISServiceResultType;
	import com.digitalaisle.legacy.services.valueObjects.ICISServiceUserActionType;
	import com.digitalaisle.legacy.services.valueObjects.ICISServiceUserSessionType;
	import com.digitalaisle.legacy.services.valueObjects.ICISServiceUserSurvey;
	
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.core.*;
	import mx.rpc.CallResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.casalib.util.DateUtil;
	
	//import valueObjects.*;

	
	public class SessionManager extends EventDispatcher
	{ 
		private static var instance:SessionManager;
		private static var allowInstantiation:Boolean;
		private static const IS_DEBUG:Boolean = true;
		
		private var _timeOutTime:Number;							// initial time out in seconds
		private var _confirmTime:Number;							// confirmation timer in seconds
		// confirm time out in seconds
		private var _timeOutTimer:Timer;							// Timer object for initial session time
		private var _confirmTimer:Timer;							// Timer object for confirm time 
		private var _currentCount:int;								// stores current count of timer
		private var _confirmIsOn:Boolean = false;					// checks for confirmation popup
		private var sessionPause:Boolean = false;					// checks if timer is on PAUSE
		
		private var _userData:Array;
		private var _date:Date;										// date object to store date info for time stamps etc.
		private var _sessionStartTime:String;						// session start time as string
		private var _sessionStartTimeNum:Number;					// used to calculate total session time: see sessionTotalTime()
		private var _sessionEndTime:String;							// session end time as string
		private var _sessionEndTimeNum:Number;						// used to calculate total session time: see sessionTotalTime()
		private var _sessionTotal:Number;							// total time for session
		private var _lastClickTime:String;							// tracks click date stamp as string
		private var _actionType:String;								// action type for tracking
		private var _currentDay:String;								// day of the week
		private var _currentMonth:String;							// month
		private var _currentYear:String;							// year
		private var _currentDate:String;							// date
		private var _currentHour:String;							// hour
		private var _currentMinute:String;							// minutes
		private	var _currentSeconds:String;							// seconds
		private var _remainingTime:Number;							// countdown time on confirmation timer
		
		private var _hasData:Boolean;								// checks if data will be sent				

		// MERGED FROM ICISClient
		// required strings
		private var _responsetxt:String;						// stores string returned from webservice
		private var _datatxt:String;							// stores string from textfield sent to webservice
		private var _statustxt:String;							// stores var to send to webservice
		private var icisClientService:StatusService;			// instance of webservice
		private var responder:CallResponder;					// responder for webservice
		
		
		// De MonsterDebugger instance
		// This is needed to explore your live application
		private var debugger:MonsterDebugger;
		
		public function SessionManager()  
		{ 
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use BeerFinderUtil.getInstance() instead of new.");
			}
		} 
		
		public static function getInstance():SessionManager
		{
			if (instance == null) {
				allowInstantiation = true;
				instance = new SessionManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		// TODO: Remove unnecessary parameters upon initialization.
		/**
		 * 
		 * @param t: time in seconds for initial timeout
		 * @param c: time in seconds for confirmation window timeout
		 * @param b: boolean if app will be sending data
		 * 
		 */
		public function init(t:Number, c:Number, b:Boolean = true):void
		{
			debugger = new MonsterDebugger(this);
			MonsterDebugger.enabled = IS_DEBUG;
			
			trace("SESSION MANAGER INITIATED");
			_hasData = b;											// boolean if session will send data
			_timeOutTime = t;										// time in seconds for initial session timeout
			_confirmTime = c;										// time in seconds for the confirmation popup to show
						
			icisClientService = new StatusService();
			icisClientService.addEventListener(ResultEvent.RESULT, statusResult);
			icisClientService.addEventListener(FaultEvent.FAULT, statusFault);
			
			// listener for response from ICIS
			//icisClientService.addEventListener(SessionEvent.RESULT, displayResult, false, 0, false);
			
			
			// creates a new timer from TIME OUT paramater in seconds
			_timeOutTimer = new Timer(1000, _timeOutTime); 
			// add listeners and start the initial time out timer
			_timeOutTimer.addEventListener(TimerEvent.TIMER, onTick); 
			_timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete); 

			// start the main timer
			resetTimer();
			
			// set PAUSE to false
			sessionPause = false;
			
			// create start time also used as session name
			_date = new Date();
			_sessionStartTimeNum = _date.getTime();					// stores initial time start of session for calculating total session time
			_sessionStartTime = DateUtil.formatDate(new Date(), "Y-m-d H:i:s");					// stores formatted date information for SESSION_START
			
			// create userdata array to store userdata objects to send to webservice
			_userData = new Array();
			_userData = [];
			
			// start countdown time from confirmation time setting
			_remainingTime = _confirmTime;
			
			// START SESSION STAMP
			updateSession(SessionType.SESSION_STARTED, "start session");
			
			
		}
		

		/** SEND EMAIL - to send email. use the "sendEmail" method of the current SessionManager instance
		 * required string paramaters:
		 * 
		 * @param to: email address
		 * @param from: from email address
		 * @param subject: subject line
		 * @param body: email body
		 * 
		 */
		public function sendEmail(to:String, from:String, subject:String, body:String):void
		{
			//trace("send email to ICIS");
			
			var emailObj:ICISServiceEmailRequest = new ICISServiceEmailRequest();
			emailObj.email_to = to;
			emailObj.email_from = from;
			emailObj.email_subject = subject;
			emailObj.email_body = escape(body);
			
			//trace ("Email obj: " + emailObj+" email: "+emailObj.email_to+" body: "+emailObj.email_body);
			icisClientService.SendEmail(emailObj);	
		}
		
		
		
		public function sendUserSurvey(surveyObject:ICISServiceUserSurvey):void
		{
			
			icisClientService.SendUserSurvey(surveyObject);
		}
		
		
		// reset timer. runs everytime something is clicked on the screen.
		/**
		 * 
		 * @param t: action name String
		 * 
		 */		
		private function resetTimer(t:String = null):void
		{
			// CLICK or END_SESSION
			// starts the timer ticking

			//trace("reset timer");
			//trace(_confirmIsOn);
			
			// check if confirmation popup window is open, reset and stop that timer
			
			if (_confirmIsOn)
			{
				// remove event listener for confirm timer
				_confirmTimer.removeEventListener(TimerEvent.TIMER, onTickC); 
				_confirmTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onConfirmComplete); 
				_confirmTimer.reset();
				_confirmTimer.stop();
				_confirmIsOn = false;
				
				// add event listeners for main timer
				_timeOutTimer.addEventListener(TimerEvent.TIMER, onTick); 
				_timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete); 
			}
			
			
			// RESET the timer on any click except when it's end of session
			if (t != SessionType.SESSION_ENDED)
			{
				_timeOutTimer.reset();
				_timeOutTimer.start();
				
				// reset the confirmation popup timer
				/*_confirmTimer.reset();
				_confirmTimer.stop();
				_confirmIsOn = false;*/
			}
			
			dispatchEvent(new SessionEvent(SessionEvent.RESET_TIMER));
		}
		
		// runs when initial session timer runs out
		private function onTimerComplete(e:TimerEvent):void 
		{ 
			_confirmIsOn = true;
			//trace(_confirmIsOn);

			// remove listeners for main timer
			_timeOutTimer.removeEventListener(TimerEvent.TIMER, onTick); 
			_timeOutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete); 

			// start confirmation timer
			_confirmTimer = new Timer(1000, _confirmTime);
			// designates listeners for the interval and completion events 
			_confirmTimer.addEventListener(TimerEvent.TIMER, onTickC); 
			_confirmTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onConfirmComplete); 
			_confirmTimer.reset();
			_confirmTimer.start();
			
			//trace("Time's Up!"); 
			_timeOutTimer.reset();
			_timeOutTimer.stop();
			trace("TIMER ENDED");
			
			//endSession();
			// dispatch timeout event
			dispatchEvent(new SessionEvent(SessionEvent.CONFIRM_START));

		} 

		// runs when confirmation timer runs out. signals end of the session
		private function onConfirmComplete(e:TimerEvent):void
		{
			endSession();
		}
		
		// Run's every tick during Session Timer
		private function onTick(e:TimerEvent):void  
		{ 
			// displays the tick count so far 
			// The target of this event is the Timer instance itself.
			_currentCount = e.target.currentCount;
			//trace("tick " + e.target.currentCount);
		} 
		
		
		// Run's every tick during Confirmation Timer	
		private function onTickC(e:TimerEvent):void  
		{ 
			// displays the tick count so far 
			// The target of this event is the Timer instance itself. 
			_currentCount = e.target.currentCount;
			//trace("tick " + e.target.currentCount);

			// calculate and set time remaining
			_remainingTime = _confirmTime - e.target.currentCount;

			// TODO: Provide a public read-only property that outputs the remaining time left(seconds) from CONFIRM to TIMEOUT
			dispatchEvent(new SessionEvent(SessionEvent.COUNTDOWN));
		}
				
		// pause and upause timer
		public function pauseUnpause():void
		{
			if (sessionPause)
			{
				sessionPause = false;
				_timeOutTimer.start();
			} else
			{
				sessionPause = true;
				_timeOutTimer.stop();

			} 
		}
		
		/**
		 * update session method called from swf events
		 * @param actionType: String - See com.digitalaisle.core.enums.SessionType
		 * @param desc: String - description of action
		 * 
		 */		
		public function updateSession(actionType:String, details:String):void
		{
			var userAction:ICISServiceUserActionType;
			
			switch(actionType)
			{
				case SessionType.CLICK:
					userAction = createUserAction(actionType, details);
					resetTimer(actionType);
					break;
				case SessionType.IGNORE:
					resetTimer(actionType);
					break;
				case SessionType.EMAIL:
					userAction = createUserAction(actionType, details);
					resetTimer(actionType);
					break;
				case SessionType.PRINT:
					userAction = createUserAction(actionType, details);
					resetTimer(actionType);
					break;
				case SessionType.END_SESSION:			// FORCED END
					userAction = createUserAction(actionType, details);
					_userData.push(userAction);
					showOutput(userAction.action, userAction.details);
					endSession();
					return;
				case SessionType.SESSION_STARTED:
					userAction = createUserAction(actionType, details);
					resetTimer(actionType);
					break;
				case ActionType.IMPRESSION:
					userAction = createUserAction(actionType, details);
					break;
				default:
					userAction = createUserAction(actionType, details);
					break;
			}
			
			if(userAction)
			{
				//trace("last action: " + userAction.action + " " + userAction.details + " " + userAction.time_stamp);
				_userData.push(userAction);
				// reset the time unless you are at the end of the session

				
				showOutput(userAction.action, userAction.details);
				
			}
		}
		
		
		
		protected function showOutput(action:String, details:String):void
		{
			if(MonsterDebugger.enabled)
			{
				MonsterDebugger.trace(this, "Action Type = " + action + " , Description = " + details); 
			}
		}
		
		
		
		protected function createUserAction(action:String, details:String):ICISServiceUserActionType
		{
			var userAction:ICISServiceUserActionType = new ICISServiceUserActionType();
			userAction.action = action;
			userAction.details = details;
			userAction.time_stamp = DateUtil.formatDate(new Date(), "Y-m-d H:i:s");
			
			return userAction;
			
		}
		// end session - create session data - send data - reset all
		public function endSession():void
		{
			// remove timer listeners
			//_confirmTimer.removeEventListener(TimerEvent.TIMER, onTickC); 
			//_confirmTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onConfirmComplete); 

			//updateSession("END_SESSION", "end session by timer");
			
			trace("send END_SESSION dispatch");
			
			// stores end session time
			_sessionEndTime = DateUtil.formatDate(new Date(), "Y-m-d H:i:s");
			
			// calculate total time of this session
			_sessionTotal = sessionTotalTime();
			
		
			// if _hasData is true, send session Data
			if (_hasData)
			{
				sendSessionData(_sessionTotal, _sessionEndTime, _sessionStartTime, _userData);
			}
			
			// reset all timers and popup window
			//resetAll();
			
			//ExternalInterface.call("da_utility", escape("flashtimeout"));			// COMMENTED OUT on 7/20/10
			
			dispatchEvent(new SessionEvent(SessionEvent.END_SESSION));			// POSSIBLY NOT NEEDED
			
		}
		
		
		// reset all timer and hide confirmation popup window
		private function resetAll():void
		{
			if (_confirmIsOn)
			{
				_confirmTimer.reset();
				_confirmTimer.stop();
				//	_confirmIsOn = false;
			}
			_timeOutTimer.reset();
			_timeOutTimer.stop();
			_confirmIsOn = false;
			
			
			// traces
			//trace("Session over"); 
			
		}
			
		/** ///////////////////////  SEND USER STATUS //////////////////////////////////
		 * to send email. use the "sendEmail" method of the current SessionManager instance
		 * @param session_duration: calculated time of session
		 * @param session_end: session end time
		 * @param session_start: session start time
		 * @param user_actions: array of user actions
		 * 
		 */		
		private function sendSessionData(session_duration:Number, session_end:String, session_start:String, user_actions:Array):void
		{
			var userSessionData:ICISServiceUserSessionType = new ICISServiceUserSessionType();
			
			userSessionData.session_start = session_start;
			userSessionData.session_end = session_end;
			userSessionData.session_duration = session_duration;
			
			var actions_coll:ArrayCollection = new ArrayCollection();
			
			for each(var a:Object in user_actions)
			{
				var newAction:ICISServiceUserActionType = new ICISServiceUserActionType();
				newAction.action = a.action;
				newAction.details = a.details;
				newAction.time_stamp = a.time_stamp;
				actions_coll.addItem(newAction);
			}
			
			userSessionData.user_actions = actions_coll;
			
			//trace(userSessionData.session_start);
			//trace(userSessionData);
			icisClientService.SendUserSession(userSessionData);
			//trace("data sent as service user session: " + userSessionData);
			trace("APP_EXIT");
		}

		// checks if service has connected
		protected function statusFault(e:FaultEvent) : void{
			//trace('statusFault Called: ' + e.toString());
			
			//trace ("service: "+e.target.service);
			//trace ("port: "+e.target.port);
			//trace ("wsdl: "+e.target.wsdl);		
		}
		
		// checks result of web service connection
		protected function statusResult(e:ResultEvent) : void
		{
			var sr:ICISServiceResultType = e.result as ICISServiceResultType;
			
			// clear previous results
			//clearResults();
			dispatchEvent(new SessionEvent(SessionEvent.SERVICE_RESULT, false, false, sr.result));
			
			
		}
		
		public function clearResults():void
		{
			_responsetxt = "";
		}
		
		//protected function btnSendStatus_clickHandler(e:MouseEvent):void
		private function sendData():void
		{			
			var _newStatus : ICISClientStatusType = new ICISClientStatusType();
			
			//			var _dataToSend:String = "\nemail:"+_statustxt+"\nreturn email:"+_statustxt+"\nsubject:"+_subjectLine+"\n\n"+_datatxt + "\n\n"+_date + "\n\n"+_footer+"\n\n"+_additionalText;
			_newStatus.data = _datatxt;
			_newStatus.status_msg = _statustxt;
			
			icisClientService.SendStatus(_newStatus);
		}
		
		// TODO: This will be a good property to have as read only
		// calculates the total session time from start to end and returns calculation
		private function sessionTotalTime():Number
		{
			_date = new Date();
			_sessionEndTimeNum = _date.getTime();
			return  (_sessionEndTimeNum - _sessionStartTimeNum)/1000;
			
		}
		
		//// GETTERS AND SETTERS

		// GET time out time set on construct
		public function get timeOutTime():Number
		{
			return _timeOutTime;
		}
		
		// GET confirm time set on construct
		public function get confirmTime():Number
		{
			return _confirmTime;
		}
		
		// GET current count (optional)
		public function get timerCount():int
		{
			return _currentCount;
		}
		
		// GET remaining time for countdown
		public function get remainingTime():Number
		{	
			return _remainingTime;	
		}
		
	} 
}