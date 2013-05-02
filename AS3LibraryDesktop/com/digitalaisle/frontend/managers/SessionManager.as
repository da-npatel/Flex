package com.digitalaisle.frontend.managers
{ 
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.SessionEvent;
	import com.digitalaisle.services.kioskRepository.KioskRepository;
	import com.digitalaisle.services.kioskRepository.valueObjects.StatusResult;
	import com.digitalaisle.services.kioskRepository.valueObjects.UserEvent;
	import com.digitalaisle.services.kioskRepository.valueObjects.UserSession;
	import com.digitalaisle.services.kioskRepository.valueObjects.UserTouch;
	
	import flash.desktop.NativeApplication;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.casalib.events.InactivityEvent;
	import org.casalib.time.Inactivity;
	import org.casalib.util.DateUtil;
	import org.casalib.util.StageReference;
	
	public class SessionManager extends EventDispatcher
	{ 
		public static const TRACKING_TIMEOUT:String = "trackingTimeout";
		public static const TRACKING_NO_TIMEOUT:String = "trackingNoTimeout";
		public static const NO_TRACKING_TIMEOUT:String = "noTrackingTimeout";
		
		private static var instance:SessionManager;
		private static var allowInstantiation:Boolean;		
		private var _kisokServiceManager:KioskServiceManager = KioskServiceManager.getInstance();
		private var _timeoutInactivity:Inactivity;
		private var _confirmationInactivity:Inactivity;
		private var _confirmationEnabled:Boolean = true; // iF confirmationPopup defined then this is enabled inheriently
		private var _userData:Array = new Array();
		private var _unitId:int;
		//private var _isTrackingData:Boolean;								// checks if data will be sent	
		private var _sessionId:String = "0";
		private var _sessionEventIncriment:int = 0;
		private var _sessionEnded:Boolean = false;
		//private var _enableInstant
		private var _mode:String;
		
		public function SessionManager()  
		{ 
			if (!allowInstantiation) 
				throw new Error("Error: Instantiation failed: Use SessionManager.getInstance() instead of new.");
		} 
		
		
		//---- STATIC FUNCTIONS -----------------------------------------------------------------------------------
		
		public static function getInstance():SessionManager
		{
			if (instance == null) {
				allowInstantiation = true;
				instance = new SessionManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		//---- PUBLIC FUNCTIONS -----------------------------------------------------------------------------------
		/**
		 * 
		 * @param timeoutDuration: time in seconds for initial timeout
		 * @param confirmDuration: time in seconds for confirmation window timeout
		 * @param trackData: boolean if app will be sending data
		 * 
		 */
		public function init(mode:String, timeoutDuration:int = 200, confirmDuration:int = 20):void
		{
			_mode = mode;
			// Needed by Inactivity Util
			StageReference.setStage(FlexGlobals.topLevelApplication.stage);
			
			//_isTrackingData = trackData;											
			
			var userSession:UserSession = new UserSession();
			userSession.sessionStart = DateUtil.formatDate(new Date(), "Y-m-d H:i:s");
			userSession.data = "";
			userSession.unitId = String(_unitId);
			KioskServiceManager.getInstance().startUserSession(userSession, onStartUserSessionResult, onStartUserSessionFault);
			
			if(mode == TRACKING_TIMEOUT || mode == NO_TRACKING_TIMEOUT) {
				_confirmationInactivity = new Inactivity(confirmDuration * 1000);
				_confirmationInactivity.addEventListener(InactivityEvent.INACTIVE, onConfirmationInactive);
				_timeoutInactivity = new Inactivity(timeoutDuration * 1000);
				_timeoutInactivity.addEventListener(InactivityEvent.INACTIVE, onTimoutInactive);
				_timeoutInactivity.start();
			}
		}
		
		
		/**
		 * update session method called from swf events
		 * @param actionType: String - action type (CLICK, EMAIL, PRINT)
		 * @param desc: String - description of action
		 * 
		 */		
		public function updateSession(uid:int, actionType:int, userTouchPoint:Point, description:String = ""):void
		{
			if(actionType != ActionType.IGNORE || !_sessionEnded)
			{	
				var ignoreTouch:Boolean = false;
				var ignoreTimerUpdate:Boolean = false;
				
				var userTouch:UserTouch = new UserTouch();
				userTouch.x = userTouchPoint.x;
				userTouch.y = userTouchPoint.y;
				
				var userEvent:UserEvent = new UserEvent();
				userEvent.userTouch = userTouch;
				userEvent.timeStamp = DateUtil.formatDate(new Date(), "Y-m-d H:i:s");
				userEvent.type = actionType;
				if(uid != 0) 
				{ 
					userEvent.itemId = uid;
					if(description != "")
						userEvent.data = description;
				}else userEvent.data = description;
				
				switch(actionType)// TODO: Not Needed???
				{
					case ActionType.IMPRESSION:
						ignoreTimerUpdate = true;
						break;
					default:
						resumeSession();
						break;
				}
				
				if(!ignoreTimerUpdate){
					if(mode == TRACKING_TIMEOUT) {
					_userData.push(userEvent);
					}else if(mode == TRACKING_NO_TIMEOUT) {
						KioskServiceManager.getInstance().sendUserEvent(_sessionId, userEvent, onSendUserEventResult, onSendUserEventFault);
					}
				}
					
				
				
			}
		}
		
		public function pauseSession():void
		{
			if(mode == TRACKING_TIMEOUT || mode == NO_TRACKING_TIMEOUT) {
				_confirmationInactivity.stop();
				_timeoutInactivity.stop();
			}
		}
		
		public function resumeSession():void
		{
			if(mode == TRACKING_TIMEOUT || mode == NO_TRACKING_TIMEOUT) {
				_confirmationInactivity.stop();
				_timeoutInactivity.start();
			}
		}
		
		public function endSession():void
		{
			if(mode == TRACKING_TIMEOUT || mode == NO_TRACKING_TIMEOUT) {
				
				_sessionEnded = true;
				_confirmationInactivity.stop();
				_confirmationInactivity.destroy();
				_timeoutInactivity.destroy();
			}
			
			if(mode == TRACKING_TIMEOUT) {
				sendSessionData();
			}
			
			dispatchEvent(new SessionEvent(SessionEvent.SESSION_ENDED));
		}
		
		
		private function onTimoutInactive(e:InactivityEvent):void
		{
			dispatchEvent(new SessionEvent(SessionEvent.TIMEOUT));
			_timeoutInactivity.stop();
			_confirmationInactivity.start();
			
		}
		
		private function onConfirmationInactive(e:InactivityEvent):void
		{
			endSession();
		}
		
		private function sendSessionData():void
		{
			MonsterDebugger.trace(this, "Log: There were a total of " + _userData.length + " user events for this session.");
			
			var userData:Array = _userData;
			var resultTimer:Timer = new Timer(10000);
			resultTimer.addEventListener(TimerEvent.TIMER, onResultTimer, false, 0, true);
			
			if(userData.length > 0){
				KioskServiceManager.getInstance().sendUserEvent(_sessionId, userData[0], onSendUserEventResult, onSendUserEventFault);
			}else
				KioskServiceManager.getInstance().endUserSession(_sessionId, "Timeout", onEndUserSessionResult, onEndUserSessionFault);			
		}
		
		
		private function onSendUserEventResult(e:ResultEvent):void
		{
			_sessionEventIncriment++;
			if(_sessionEventIncriment != _userData.length){
				KioskServiceManager.getInstance().sendUserEvent(_sessionId, _userData[_sessionEventIncriment], onSendUserEventResult, onSendUserEventFault);
			}else{
				KioskServiceManager.getInstance().endUserSession(_sessionId, "Timeout", onEndUserSessionResult, onEndUserSessionFault);
				_sessionEventIncriment = 0;
			}
			
			var statusResult:StatusResult = e.result as StatusResult;
			switch(statusResult.result)
			{
				case "OK":
					MonsterDebugger.trace(this, "Success: User event was sent successfully.", MonsterDebugger.COLOR_SUCCESS);
					break;
				case "ERROR":
					MonsterDebugger.trace(this, "Error: User event failed to send.", MonsterDebugger.COLOR_ERROR);
					break;
			}
		}
		
		private function onStartUserSessionResult(e:ResultEvent):void
		{
			var statusResult:StatusResult = e.result as StatusResult;
			_sessionId = statusResult.args;
			switch(statusResult.result)
			{
				case "OK":
					MonsterDebugger.trace(this, "Success: User session successfully started. Session Id= " + _sessionId, MonsterDebugger.COLOR_SUCCESS);
					break;
				case "ERROR":
					MonsterDebugger.trace(this, "Error: User session failed to start.", MonsterDebugger.COLOR_ERROR);
					break;
			}
		}
		
		private function onStartUserSessionFault(e:FaultEvent):void
		{
			MonsterDebugger.trace(this, "Error: User session failed to start.", MonsterDebugger.COLOR_ERROR);
		}
		
		private function onSendUserEventFault(e:FaultEvent):void
		{
			MonsterDebugger.trace(this, "Error: User event failed to send.", MonsterDebugger.COLOR_ERROR);
		}
		
		private function onEndUserSessionResult(e:ResultEvent):void
		{
			var statusResult:StatusResult = e.result as StatusResult;
			switch(statusResult.result)
			{
				case "OK":
					MonsterDebugger.trace(this, "Success: Session ended successfully.", MonsterDebugger.COLOR_SUCCESS);
					break;
				case "ERROR":
					MonsterDebugger.trace(this, "Error: Session failed to end.", MonsterDebugger.COLOR_ERROR);
					break;
			}
			
			MonsterDebugger.trace(this, "Log: Exiting frontend application");
			NativeApplication.nativeApplication.exit();
		}
		
		private function onEndUserSessionFault(e:FaultEvent):void
		{
			MonsterDebugger.trace(this, "Error: Session failed to end.", MonsterDebugger.COLOR_ERROR);
			NativeApplication.nativeApplication.exit();
		}
		
		private function onResultTimer(e:TimerEvent):void
		{
			MonsterDebugger.trace(this, "Warning: Application ending due to a timeout of the Kiosk Manager results", MonsterDebugger.COLOR_WARNING);
			NativeApplication.nativeApplication.exit();
		}
		
		
		/*public function confirmYes():void
		{
		
		}
		
		
		public function confirmNo():void
		{
		
		}*/
		
		public function get unitId():int
		{
			return _unitId;
		}
		
		public function set unitId(value:int):void
		{
			_unitId = value;
		}

		public function get mode():String
		{
			return _mode;
		}
		
		
	} 
}