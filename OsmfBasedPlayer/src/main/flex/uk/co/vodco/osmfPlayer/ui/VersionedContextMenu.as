package uk.co.vodco.osmfPlayer.ui {
import flash.display.InteractiveObject;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

public class VersionedContextMenu {

    public static const VERSION:String = PLAYER::V;

    public function VersionedContextMenu(interactiveObject:InteractiveObject) {

        var versionedMenu:ContextMenu = new ContextMenu();
        versionedMenu.hideBuiltInItems();

        var item:ContextMenuItem = new ContextMenuItem("SeeSaw player version " + VERSION);
        versionedMenu.customItems.push(item);

        interactiveObject.contextMenu = versionedMenu;


    }
}
}