package com.digitalaisle.frontend.utils
{
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.SessionEvent;
	import com.digitalaisle.frontend.managers.AvatarManager;
	import com.digitalaisle.frontend.managers.DataManager;
	import com.digitalaisle.frontend.managers.SessionManager;
	import com.digitalaisle.uilibrary.keypads.OffScreenKeyboard;
	import com.digitalaisle.uilibrary.popups.EmailPad;
	import com.digitalaisle.utils.ScreenResoultionUtil;
	
	import flash.display.DisplayObject;
	import flash.events.ErrorEvent;
	import flash.geom.Point;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.CloseEvent;
	import mx.managers.PopUpManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.casalib.util.LocationUtil;
	
	public class ApplicationUtil
	{
		public static var isDebug:Boolean = true;
		public static var globalDictionary:Dictionary = new Dictionary(true);
		public static var timoutTime:int = 120;
		public static var confirmationTime:int = 20;
		public static var appKeypad:OffScreenKeyboard;
		public static var topLevel:DisplayObject;
		
		/** @private **/
		[Embed(source="sounds/DefaultClick.mp3")]
		private static var DefaultSoundClass:Class;
		[Bindable]
		public static var defaultClick:Sound = new DefaultSoundClass() as Sound;
		private static var _selectedModuleId:int;
		
		private var sessionManager:SessionManager = SessionManager.getInstance();			// TODO session manager needs to be private since the AppUtil will handle and report to it
		private var avatarManager:AvatarManager = AvatarManager.getInstance();
		//public var soundManager:SoundManager = SoundManager.getInstance();
		
		/*public var appContentView:ApplicationContent;*/
		public static var appProductPageSkinClass:Class;
		
		private static var _mutedVolume:int = 0;
		
		public function ApplicationUtil()
		{

		}
		
		public static function email(subject:String, message:String, from:String="do_not_reply@digitalaisle.com", itemId:int = 0):void
		{
			var emailPad:EmailPad = new EmailPad();
			emailPad.subject = subject;
			emailPad.message = message;
			emailPad.from = from;
			emailPad.itemId = itemId;
			
			if(ScreenResoultionUtil.screenResolution.equals(ScreenResoultionUtil.HD_720)) {
				emailPad.width = 877;
				emailPad.height = 406;
				emailPad.styleName = "hd720";
			}else{
				emailPad.width = 877;
				emailPad.height = 406;
				emailPad.styleName = "hd720";
			}
			
			PopUpManager.addPopUp(emailPad, topLevel, true);
			PopUpManager.centerPopUp(emailPad);
		}		
		
		public static function mute():Boolean
		{
			if(SoundMixer.soundTransform.volume == 0) {
				systemVolume = _mutedVolume;
				return false;
			} else {
				_mutedVolume = SoundMixer.soundTransform.volume;
				return true;
			}
		}
		
		
		
		/*public function search(targetTemplateItemId:int = -1):void
		{
			var searchPad:SearchPad = new SearchPad();
			
			if(targetTemplateItemId != -1)
				searchPad.targetTemplateItemId = targetTemplateItemId;
			
			if(ScreenResoultionUtil.screenResolution.equals(ScreenResoultionUtil.HD_720)) {
				searchPad.width = 870;
				searchPad.height = 600;
				searchPad.styleName = "hd720";
			}else {
				searchPad.width = 870;
				searchPad.height = 600;
				searchPad.styleName = "hd720";
			}
			
			PopUpManager.addPopUp(searchPad, topLevel, true);
			PopUpManager.centerPopUp(searchPad);
		}*/
		
		public function confirm(message:String, onConfirmationHandler:Function):void
		{
			
		}
		
		public static function playSound(id:String = "Click"):void
		{
			defaultClick.play();
		}
		
		//TODO: Tapped into the SOUND MAnager
		public static function getSound(id:String = "Click"):Sound
		{
			return defaultClick;
		}
		
		public static function updateSession(id:int, actionType:int, userTouchPoint:Point, description:String = ""):void
		{
			SessionManager.getInstance().updateSession(id, actionType, userTouchPoint, "ModuleId=" + _selectedModuleId + ";" + description);
		}
		
		public static function returnHome():void
		{
			_selectedModuleId = DataManager.getInstance().projectObject.logoId;
			updateSession(_selectedModuleId, ActionType.CLICK, new Point(FlexGlobals.topLevelApplication.mouseX, FlexGlobals.topLevelApplication.mouseY));
		}
		
		// TODO: Is this method even needed
		public static function logError(e:ErrorEvent):void
		{
			MonsterDebugger.trace(FlexGlobals.topLevelApplication, "MISSING XML FILE: " + e.text);
			Alert.show("Unable to launch the application due to invalid content.  Please contact technical support.", "Unable to Launch Application", Alert.OK, FlexGlobals.topLevelApplication.stage.parent, ApplicationUtil.onContentError);
		}
		
		private static function onContentError(e:CloseEvent):void
		{
			ApplicationUtil.exitApplication();
		}
		
		private function onConfirmPopup(e:SessionEvent):void
		{
			// Pause Avatar Player
			avatarManager.pause();
		}
		
		public static function exitApplication():void
		{
			if(LocationUtil.isAirApplication()) {
				var DesktopNativeApplication:Class = getDefinitionByName("flash.desktop.NativeApplication") as Class;
				DesktopNativeApplication.nativeApplication.exit();
			}
		}
		
		public static function get selectedModuleId():int
		{
			return ApplicationUtil._selectedModuleId;
		}

		public static function set selectedModuleId(value:int):void
		{
			ApplicationUtil._selectedModuleId = value;
			ApplicationUtil.updateSession(value, ActionType.CLICK, new Point(FlexGlobals.topLevelApplication.mouseX, FlexGlobals.topLevelApplication.mouseY));
		}
		
		public static function get systemVolume():Number
		{
			return SoundMixer.soundTransform.volume;
		}
		
		public static function set systemVolume(value:Number):void
		{
			var volumeTransform:SoundTransform = new SoundTransform();
			volumeTransform.volume = value;
			SoundMixer.soundTransform = new SoundTransform(volumeTransform.volume);
		}
	}
}