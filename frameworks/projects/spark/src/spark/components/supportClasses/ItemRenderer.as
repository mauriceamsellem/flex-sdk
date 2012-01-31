////////////////////////////////////////////////////////////////////////////////
//
//  ADOBE SYSTEMS INCORPORATED
//  Copyright 2008 Adobe Systems Incorporated
//  All Rights Reserved.
//
//  NOTICE: Adobe permits you to use, modify, and distribute this file
//  in accordance with the terms of the license agreement accompanying it.
//
////////////////////////////////////////////////////////////////////////////////

package spark.components.supportClasses
{
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.events.FlexEvent;
import mx.styles.StyleManager;

import spark.components.DataGroup;
import spark.components.Group;
import spark.components.IItemRenderer;
import spark.components.MXMLComponent; 
import spark.primitives.supportClasses.TextGraphicElement;

/**
 *  The ItemRenderer class is the base class for Spark item renderers.
 * 
 *  @mxml
 *
 *  <p>The <code>&lt;ItemRenderer&gt;</code> tag inherits all of the tag 
 *  attributes of its superclass and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;ItemRenderer
 *    <strong>Properties</strong>
 *    allowDeselection="true"
 *    selected="false"
 *    caret="false"
 *  /&gt;
 *  </pre>
 *  
 *  @langversion 3.0
 *  @playerversion Flash 10
 *  @playerversion AIR 1.5
 *  @productversion Flex 4
 */
public class ItemRenderer extends MXMLComponent implements IItemRenderer
{    
    //--------------------------------------------------------------------------
    //
    //  Constructor
    //
    //--------------------------------------------------------------------------
    
    /**
     *  Constructor.
     * 
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function ItemRenderer()
    {
        super();
        
        // Initially state is dirty
        rendererStateIsDirty = true;
        
        addHandlers();
    }
    
    //--------------------------------------------------------------------------
    //
    //  Style-driven properties
    //
    //--------------------------------------------------------------------------
    
    [Bindable("contentBackgroundColorChanged")]
    [Bindable("dataChange")]
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get contentBackgroundColor():uint
    {
        var alternatingColors:Array = getStyle("alternatingItemColors");
        
        if (alternatingColors && alternatingColors.length > 0)
        {
            var idx:int;
            
            // translate these colors into uints
            StyleManager.getColorNames(alternatingColors);
            
            if (parent is DataGroup)
                idx = DataGroup(parent).dataProvider.getItemIndex(data);
            else if (parent is Group)
                idx = Group(parent).getElementIndex(this);
            else
                idx = parent.getChildIndex(this);
             
            return alternatingColors[idx % alternatingColors.length];
        }
        
        return getStyle("contentBackgroundColor");
    }
    
    /**
     *  @private
     */
    public function set contentBackgroundColor(value:uint):void
    {
        setStyle("contentBackgroundColor", value);
    }
    
    [Bindable("rollOverColorChanged")]
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get rollOverColor():uint
    {
        return getStyle("rollOverColor");
    }
    
    /**
     *  @private
     */
    public function set rollOverColor(value:uint):void
    {
        setStyle("rollOverColor", value);
    }
    
    [Bindable("selectionColorChanged")]
    /**
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public function get selectionColor():uint
    {
        return getStyle("selectionColor");
    }
    
    /**
     *  @private
     */
    public function set selectionColor(value:uint):void
    {
        setStyle("selectionColor", value);
    }
    
    //--------------------------------------------------------------------------
    //
    //  Private Properties
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Flag that is set when the mouse is hovered over the item renderer.
     */
    private var hovered:Boolean = false;
    
    /**
     *  @private
     *  Whether the renderer's state is invalid or not.
     */
    private var rendererStateIsDirty:Boolean = false;
    
    //--------------------------------------------------------------------------
    //
    //  Public Properties 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  labelElement
    //----------------------------------
    
    /**
     *  Optional item renderer label component. 
     *  This component is used to determine the value of the 
     *  <code>baselinePosition</code> property in the host component of 
     *  the item renderer. 
     *  
     *  @langversion 3.0
     *  @playerversion Flash 10
     *  @playerversion AIR 1.5
     *  @productversion Flex 4
     */
    public var labelElement:TextGraphicElement;
    
    //----------------------------------
    //  allowDeselection
    //----------------------------------

    /**
     *  @private
     *  Storage for the allowDeselection property 
     */
    private var _allowDeselection:Boolean = true;

    /**
     *  @inheritDoc 
     *
     *  @default true
     */    
    public function get allowDeselection():Boolean
    {
        return _allowDeselection;
    }
    
    /**
     *  @private
     */    
    public function set allowDeselection(value:Boolean):void
    {
        if (value == _allowDeselection)
            return;
            
        _allowDeselection = value;
    }
    
    //----------------------------------
    //  caret
    //----------------------------------

    /**
     *  @private
     *  Storage for the caret property 
     */
    private var _caret:Boolean = false;

    /**
     *  @inheritDoc 
     *
     *  @default false  
     */    
    public function get caret():Boolean
    {
        return _caret;
    }
    
    /**
     *  @private
     */    
    public function set caret(value:Boolean):void
    {
        if (value == _caret)
            return;

        _caret = value;
        currentState = getCurrentRendererState(); 
    }
    
    //----------------------------------
    //  selected
    //----------------------------------
    /**
     *  @private
     *  storage for the selected property 
     */    
    private var _selected:Boolean = false;
    
    /**
     *  @inheritDoc 
     *
     *  @default false
     */    
    public function get selected():Boolean
    {
        return _selected;
    }
    
    /**
     *  @private
     */    
    public function set selected(value:Boolean):void
    {
        if (value != _selected)
        {
            _selected = value;
            currentState = getCurrentRendererState();
        }
    }
       
    //----------------------------------
    //  labelText
    //----------------------------------
    [Bindable("textChanged")]
    
    /**
     *  @private 
     *  Storage var for labelText
     */ 
    private var _labelText:String = "";
    
    /**
     *  @inheritDoc 
     *
     *  @default ""    
     */
    public function get labelText():String
    {
        return _labelText;
    }
    
    /**
     *  @private
     */ 
    public function set labelText(value:String):void
    {
        if (value != _labelText)
            _labelText = value;
        dispatchEvent(new FlexEvent("textChanged"));
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Properties - UIComponent 
    //
    //--------------------------------------------------------------------------
    
    //----------------------------------
    //  baselinePosition
    //----------------------------------

    /**
     *  @private
     */
    override public function get baselinePosition():Number
    {
        if (!mx_internal::validateBaselinePosition() || !labelElement)
            return super.baselinePosition;

        var labelPosition:Point = globalToLocal(labelElement.parent.localToGlobal(
            new Point(labelElement.x, labelElement.y)));
            
        return labelPosition.y + labelElement.baselinePosition;
    }
    
    //--------------------------------------------------------------------------
    //
    //  Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Return the skin state. This can be overridden by subclasses to add more states.
     *  NOTE: Undocumented for now since MXMLComponent class has not been fleshed out.
     */
    protected function getCurrentRendererState():String
    {
    	// TODO (jszeto) Add selectedCaret state support (true if selected && caret)
        if (selected)
            return "selected";
        
        if (hovered)
            return "hovered";
        
        // TODO (dsubrama) Caret state support will be turned on when the 
        // packaged renderers support the state visually 
        //if (caret)
        //    return "caret"; 
            
        return "normal";
    }
    
    //--------------------------------------------------------------------------
    //
    //  Overridden Methods
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     */ 
    override protected function commitProperties():void
    {
        super.commitProperties();
        
        if (rendererStateIsDirty)
        {
            currentState = getCurrentRendererState();
            rendererStateIsDirty = false;
        }
    }
    
    /**
     *  @private
     */ 
    override public function styleChanged(styleName:String):void
    {
        var allStyles:Boolean = styleName == null || styleName == "styleName";
        
        super.styleChanged(styleName);
        
        if (allStyles || styleName == "alternatingItemColors")
        {
            conditionalEventDispatch("contentBackgroundColorChanged");
        }
        
        if (allStyles || styleName == "contentBackgroundColor")
        {
            conditionalEventDispatch("contentBackgroundColorChanged");
        }
        
        if (allStyles || styleName == "rollOverColor")
        {
            conditionalEventDispatch("rollOverColorChanged");
        }
        
        if (allStyles || styleName == "selectionColor")
        {
            conditionalEventDispatch("selectionColorChanged");
        }
    }
    
    //--------------------------------------------------------------------------
    //
    //  Event handling
    //
    //--------------------------------------------------------------------------
    
    /**
     *  @private
     *  Attach the mouse events.
     */
    private function addHandlers():void
    {
        addEventListener(MouseEvent.ROLL_OVER, itemRenderer_rollOverHandler);
        addEventListener(MouseEvent.ROLL_OUT, itemRenderer_rollOutHandler);
    }
    
    /**
     *  @private
     */
    private function conditionalEventDispatch(eventName:String):void
    {
        if (hasEventListener(eventName))
           dispatchEvent(new Event(eventName));
    }
    
    private function anyButtonDown(event:MouseEvent):Boolean
    {
        var type:String = event.type;
        return event.buttonDown || (type == "middleMouseDown") || (type == "rightMouseDown"); 
    }
    
    /**
     *  @private
     *  Mouse rollOver event handler.
     */
    protected function itemRenderer_rollOverHandler(event:MouseEvent):void
    {
        if (!anyButtonDown(event))
        {
            hovered = true;
            currentState = getCurrentRendererState();
        }
    }
    
    /**
     *  @private
     *  Mouse rollOut event handler.
     */
    protected function itemRenderer_rollOutHandler(event:MouseEvent):void
    {
        hovered = false;
        currentState = getCurrentRendererState();
    }

}
}