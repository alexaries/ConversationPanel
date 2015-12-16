package com.doer.common.mouse.style
{
	import flash.display.Sprite;
	import com.doer.common.mouse.MouseFactory;
	import com.doer.common.interfaces.IMouseStyle;

	public class EraserMouseStyle extends Sprite implements IMouseStyle
	{
		private var w:Number = 50;
		
		private var h:Number = 50;
		
		public function EraserMouseStyle()
		{
			MouseFactory.getInstance().mouseStyle = this;
			
			rePaint();
		}
		
		public function setSize(w:Number,h:Number):void
		{
			this.w = w;
			this.h = h;
			
			rePaint();
		}
		
		public function rePaint():void
		{
			this.graphics.clear()
				
			this.graphics.lineStyle(1,0x000000);
			this.graphics.beginFill(0xffffff,0.6);
			this.graphics.drawCircle(w/2,w/2,w/2);
			
			this.graphics.endFill();
				
		}
		
	}
}