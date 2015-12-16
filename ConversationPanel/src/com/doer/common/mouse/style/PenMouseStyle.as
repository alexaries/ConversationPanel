package com.doer.common.mouse.style
{
	import flash.display.Sprite;
	import com.doer.common.mouse.MouseFactory;
	import com.doer.common.interfaces.IMouseStyle;
	
	public class PenMouseStyle extends Sprite implements IMouseStyle
	{
		private var w:Number = 10;
		
		private var h:Number = 10;
		
		public function PenMouseStyle()
		{
			MouseFactory.getInstance().mouseStyle = this;
			
			rePaint();
		}
		
		public function setSize(w:Number,h:Number):void
		{
			this.w = w;
			
			rePaint();
		}
		
		public function rePaint():void
		{
			this.graphics.clear()
			
			this.graphics.lineStyle(1,0x000000);
			this.graphics.beginFill(0xffffff);
			this.graphics.drawCircle(w/2,w/2,w/2);
			
			this.graphics.endFill();
			
		}
	}
}