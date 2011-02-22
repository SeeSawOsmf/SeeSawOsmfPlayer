/*
 * The contents of this file are subject to the Mozilla Public License
 *   Version 1.1 (the "License"); you may not use this file except in
 *   compliance with the License. You may obtain a copy of the License at
 *   http://www.mozilla.org/MPL/
 *
 *   Software distributed under the License is distributed on an "AS IS"
 *   basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *   License for the specific language governing rights and limitations
 *   under the License.
 *
 *   The Initial Developer of the Original Code is Arqiva Ltd.
 *   Portions created by Arqiva Limited are Copyright (C) 2010, 2011 Arqiva Limited.
 *   Portions created by Adobe Systems Incorporated are Copyright (C) 2010 Adobe
 * 	Systems Incorporated.
 *   All Rights Reserved.
 *
 *   Contributor(s):  Adobe Systems Incorporated
 */

import com.thoughtworks.selenium.DefaultSelenium;
import com.thoughtworks.selenium.FlashSelenium;
import com.thoughtworks.selenium.Selenium;
import junit.extensions.TestSetup;
import junit.framework.Test;
import junit.framework.TestCase;
import junit.framework.TestSuite;
import org.openqa.selenium.server.SeleniumServer;

import java.util.ResourceBundle;

public class ParentalGuidanceTest extends TestCase {

    private FlashSelenium flashApp;
    private Selenium browser;
    private SeleniumServer server;
    private static String playerURL;

    public void setUp() throws Exception {
        server = new SeleniumServer();
        server.start();
        pauseForMillis(1000);
        browser = new DefaultSelenium("localhost", 4444, "*safari", playerURL);
        pauseForMillis(1000);
        browser.start();
        pauseForMillis(1000);
        flashApp = new FlashSelenium(browser, "plugin");
        pauseForMillis(1000);
        browser.open(playerURL);
    }

    private void pauseForMillis(int milliseconds) throws InterruptedException {
        Thread.sleep(milliseconds);
    }

    public void testAcceptGuidance() throws Exception {
        pauseForMillis(3000);
        flashApp.call("proceed");
        pauseForMillis(1000);
        flashApp.call("guidancePanelAccept");
        Thread.sleep(1000);
        assertEquals("PLAYING", flashApp.call("playState"));
    }

    public void testDeclineGuidance() throws Exception {
        pauseForMillis(3000);
        flashApp.call("proceed");
        pauseForMillis(1000);
        flashApp.call("guidancePanelDecline");
        pauseForMillis(1000);
        assertEquals("NOT_STARTED", flashApp.call("playState"));
    }

    public void tearDown() {
        browser.stop();
        server.stop();
    }

    public static Test suite() {
        TestSetup setup = new TestSetup(new TestSuite(ParentalGuidanceTest.class)) {
            protected void setUp() throws Exception {
                ResourceBundle bundle = ResourceBundle.getBundle("testing");
                playerURL = bundle.getString("player.url");
                assertNotNull(playerURL);
            }

            protected void tearDown() throws Exception {

            }
        };

        return setup;
    }
}
