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

import org.mortbay.jetty.Connector;
import org.mortbay.jetty.Server;
import org.mortbay.jetty.nio.SelectChannelConnector;
import org.mortbay.jetty.security.SslSocketConnector;
import org.mortbay.jetty.webapp.WebAppContext;
import org.mortbay.management.MBeanContainer;

import javax.management.MBeanServer;
import java.lang.management.ManagementFactory;

public class RunUx {

    public static void main(String[] args) throws Exception {

        System.setProperty("javax.xml.stream.XMLInputFactory", "com.ctc.wstx.stax.WstxInputFactory");
        System.setProperty("net.sf.ehcache.enableShutdownHook", "true");

        Server server = new Server();
        server.setSendDateHeader(true);
        Connector connector = new SelectChannelConnector();
        connector.setHeaderBufferSize(32000);
        connector.setPort(Integer.getInteger("jetty.port", 8080));

        String jetty_home = System.getProperty("jetty.home", "./");

        SslSocketConnector sslConnector = new SslSocketConnector();
        sslConnector.setPort(8443);
        sslConnector.setKeyPassword("password");
        sslConnector.setKeystore(jetty_home + "IntegrationTests/src/test/resources/keystore");
        server.setConnectors(new Connector[]{connector, sslConnector});

        WebAppContext webapp = new WebAppContext();
        webapp.setContextPath("/");
        webapp.setWar(jetty_home + "CorePlayer/");

        webapp.setServerClasses(new String[]{"-org.mortbay.jetty.plus.jaas.", "org.mortbay.jetty."});

        server.setHandler(webapp);

        MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
        MBeanContainer mBeanContainer = new MBeanContainer(mBeanServer);
        server.getContainer().addEventListener(mBeanContainer);
        mBeanContainer.start();

        server.start();
        server.join();
    }
}