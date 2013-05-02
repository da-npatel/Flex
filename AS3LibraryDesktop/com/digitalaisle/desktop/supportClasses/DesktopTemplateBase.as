package com.digitalaisle.desktop.supportClasses
{
	import com.digitalaisle.frontend.enums.ActionType;
	import com.digitalaisle.frontend.events.DataManagerEvent;
	import com.digitalaisle.frontend.events.SessionEvent;
	import com.digitalaisle.frontend.managers.KioskServiceManager;
	import com.digitalaisle.frontend.managers.SessionManager;
	import com.digitalaisle.frontend.utils.ApplicationUtil;
	import com.digitalaisle.uilibrary.components.DASequence;
	import com.digitalaisle.uilibrary.keypads.OffScreenKeyboard;
	import com.digitalaisle.uilibrary.popups.Confirm;
	import com.digitalaisle.uilibrary.supportClasses.TemplateBase;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.ResultEvent;
	
	import org.casalib.util.LocationUtil;
	
	public class DesktopTemplateBase extends TemplateBase
	{
		public function DesktopTemplateBase()
		{
			super();
			
			if(!LocationUtil.isAirApplication()) {
				throw new Error("DesktopTemplateBase was meant to be used on desktop based templates");
			}
		}
		
		override protected function onPreinitializeComplete(e:FlexEvent):void
		{
			super.onPreinitializeComplete(e);
		}
		
		override protected function onCreationComplete(e:FlexEvent):void
		{
			super.onCreationComplete(e);
			
			
			var offScreenKeyboard:OffScreenKeyboard = new OffScreenKeyboard();
			addElement(offScreenKeyboard);
			ApplicationUtil.appKeypad = offScreenKeyboard;
			var sequencer:DASequence = new DASequence();
			addElement(sequencer);
			sequencer.addEventListener("showadmin", onSequenceShowAdmin, false, 0, true);
			dataManager.init();
		}
		
		override protected function onDataLoaded(e:DataManagerEvent):void 
		{
			super.onDataLoaded(e);
			
			SessionManager.getInstance().addEventListener(SessionEvent.TIMEOUT, onConfirmStart);
			SessionManager.getInstance().init(SessionManager.TRACKING_TIMEOUT, ApplicationUtil.timoutTime, ApplicationUtil.confirmationTime);
			
			ApplicationUtil.returnHome();
		}
		
		private function confirm(e:Event):void
		{
			if(e.target.confirmed)
				onSessionEnded();
			else
				onSessionExtended();
			
			PopUpManager.removePopUp(confirmationPopup);
		}
		
		protected function onConfirmStart(e:SessionEvent):void
		{
			confirmationPopup = new Confirm();
			confirmationPopup.addEventListener(Event.SELECT, confirm);
			PopUpManager.addPopUp(confirmationPopup, this, true);
			PopUpManager.centerPopUp(confirmationPopup);
		}
		
		protected function onSessionEnded():void
		{
			//TODO: Ins this update session even needed
			ApplicationUtil.updateSession(0, ActionType.END, new Point(confirmationPopup.mouseX, confirmationPopup.mouseY));
			SessionManager.getInstance().endSession();
		}
		
		protected function onSessionExtended():void
		{
			SessionManager.getInstance().resumeSession();
			ApplicationUtil.updateSession(0, ActionType.CLICK, new Point(confirmationPopup.mouseX, confirmationPopup.mouseY));
		}
		
		private function onSequenceShowAdmin(e:Event):void
		{
			KioskServiceManager.getInstance().startApplication("ADMIN", doNothing);
		}
		
		private function doNothing(e:ResultEvent):void { }
	}
}