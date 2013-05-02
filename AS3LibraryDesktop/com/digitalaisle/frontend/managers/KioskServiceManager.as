package com.digitalaisle.frontend.managers
{
	import com.digitalaisle.services.kioskRepository.KioskRepository;
	import com.digitalaisle.services.kioskRepository.valueObjects.AppStatusMsg;
	import com.digitalaisle.services.kioskRepository.valueObjects.UserEvent;
	import com.digitalaisle.services.kioskRepository.valueObjects.UserSession;
	import com.digitalaisle.services.kioskRepository.valueObjects.UserTouch;
	
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import mx.rpc.AsyncToken;
	import mx.rpc.CallResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	public class KioskServiceManager extends EventDispatcher
	{
		private static var instance:KioskServiceManager;
		private static var allowInstantiation:Boolean;
		private var _kioskRepository:KioskRepository = new KioskRepository();
		//private var topLevel:Stage = FlexGlobals.topLevelApplication.stage;
		
		public function KioskServiceManager()
		{
			if (!allowInstantiation) 
			{
				throw new Error("Error: Instantiation failed: Use KioskServiceManager.getInstance() instead of new.");
			}
		}
		
		public static function getInstance():KioskServiceManager
		{
			if (instance == null) {
				allowInstantiation = true;
				instance = new KioskServiceManager();
				allowInstantiation = false;
			}
			return instance;
		}
		
		
		/**
		 * 
		 * @param resultHandler
		 * @param faultHandler
		 * 
		 */		
		public function applyUpdates(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.applyUpdates();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		
		/**
		 * 
		 * @param resultHandler
		 * @param faultHandler
		 * 
		 */		
		public function closeKeyboard(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.CloseKeyboard();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		
		public function endUserSession(sessionId:String, reason:String, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.endUserSession(sessionId, reason);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		/**
		 * 
		 * @param resultHandler
		 * @param faultHandler
		 * 
		 */		
		public function getContentUpdateStatus(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.getContentUpdateStatus();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function getUnitId(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.getUnitId();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function getUnitUpdateStatus(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.getUnitUpdateStatus();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		
		public function moveKeyboard(position:Point, height:int, width:int, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.MoveKeyboard(position.x, position.y, height, width);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function restartUnit(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.restartUnit();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function sendUserEvent(sessionId:String, userEvent:UserEvent, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.sendUserEvent(sessionId, userEvent);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function showKeyboard(position:Point, height:int, width:int, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.ShowKeyboard(position.x, position.y, height, width);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function startUserSession(userSession:UserSession, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.startUserSession(userSession);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function startApplication(appType:String, resultHandler:Function = null, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.startApplication(appType);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function stopApplication(appType:String, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.stopApplication(appType);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function sendEmail(recipients:ArrayCollection, subject:String, message:String, from:String, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.sendEmail(recipients, subject, message, from);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function sendEmailWithAttachments(recipients:ArrayCollection, subject:String, message:String, from:String, attachments:ArrayCollection, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.sendEmailWithAttachments(recipients, subject, message, from, attachments);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function sendStatusMessage(statusMessage:AppStatusMsg, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.sendStatusMessage(statusMessage);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function sendUserSession(userSession:UserSession, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.sendUserSession(userSession);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function sendUserTouch(userTouch:UserTouch, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.sendUserTouch(userTouch);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function setSystemVolume(volume:int, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.setSystemVolume(volume);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		
		public function updateContent(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.updateContent();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function updateUnitConfig(unitName:String, unitId:int, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.updateUnitConfig(unitName, unitId);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function uploadToHPHotFolder(fileNames:ArrayCollection, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.uploadToHPHotFolder(fileNames);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function lockKeyboard(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.LockKeyboard();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function unlockKeyboard(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.UnlockKeyboard();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function isKeyboardLocked(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.IsKeyboardLocked();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function showTaskbar(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.ShowTaskbar();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function isTaskbarHidden(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.IsTaskbarHidden();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function hideTaskbar(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.HideTaskbar();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function postToFacebook(appId:String, message:String, imageURL:String, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.postToFacebook(appId, message, imageURL);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function isPostToFacebookInProgress(resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.isPostToFacebookInProgress();
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		public function requestCopiaPIN(itemGUID:String, resultHandler:Function, faultHandler:Function = null):void
		{
			var dataToken:AsyncToken = _kioskRepository.requestCopiaPIN(itemGUID);
			attachListener(dataToken, resultHandler, faultHandler);
		}
		
		private function attachListener(asyncToken:AsyncToken, resultHandler:Function, faultHandler:Function):void
		{
			//_kioskRepository.addEventListener(ResultEvent.RESULT, onStaticResult);	
			
			var callRespond:CallResponder = new CallResponder();
			callRespond.addEventListener(ResultEvent.RESULT, resultHandler, false, 0, true)
			callRespond.token = asyncToken;
			
			//CursorManager.setBusyCursor();
			
			if(faultHandler != null)
				callRespond.addEventListener(FaultEvent.FAULT, faultHandler, false, 0, true);
			else
				callRespond.addEventListener(FaultEvent.FAULT, onStaticFault, false, 0, true);
			
			function onStaticFault(e:FaultEvent):void
			{
				//trace("Fault Message = " + e.message);
				MonsterDebugger.trace(this, "Error:", MonsterDebugger.COLOR_ERROR);
				_kioskRepository.removeEventListener(FaultEvent.FAULT, onStaticFault);
			}
		}
	}
}