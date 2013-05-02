package com.digitalaisle.frontend.managers {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	
	public class TemplateManager extends EventDispatcher {		
				
		private var items:Array;
		private var loaded:Array;
		
		public function TemplateManager(target:IEventDispatcher=null) {			
			items = new Array();
			loaded = new Array();
		}		
		
		public function addItem(target:*):void {
			for(var i:int=0; i<items.length; i++){
				if(items[i] == target){
					trace(target+" is a duplicate item and will not be added to TemplateManager queue.");
					return;
				}
			}
			items.push(target);
			target.addEventListener(Event.COMPLETE, onItemComplete, false, 0, true);
		}
		
		private function onItemComplete(e:Event):void {
			trace(e.target+" ready and loaded.");
			e.target.removeEventListener(Event.COMPLETE, onItemComplete);
			var num:int = -1;
			for(var i:int=0; i<items.length; i++){
				if(items[i] == e.target){					
					num = i;					
					break;
				}
			}
			if(num >= 0){				
				loaded.push(items.splice(num, 1));
			} else {
				trace("TemplateManager Error: Item "+e.target+" not found in queue.");
			}
			if(items.length == 0){ // Load queue empty				
				dispatchEvent(new Event(Event.COMPLETE));
			} else {
				dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS));
			}
		}
		
		public function clear():void {
			for(var i:int=0; i<items.length; i++){
				items[i].removeEventListener(Event.COMPLETE, onItemComplete);
			}
			items = new Array();
			loaded = new Array();
		}
		
		public function destroy():void {
			clear();		
		}
	}
}