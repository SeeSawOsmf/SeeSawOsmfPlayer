/**
 * Created by IntelliJ IDEA.
 * User: bmeade
 * Date: 22/02/11
 * Time: 11:51
 * To change this template use File | Settings | File Templates.
 */
package com.seesaw.player.utils {
public class HelperUtils {

    public static function getBoolean(string:String):Boolean {
        switch (string) {
            case "1":
            case "true":
            case "yes":
                return true;
            case "0":
            case "false":
            case "no":
                return false;
            default:
                return Boolean(string);
        }
    }
}
}
