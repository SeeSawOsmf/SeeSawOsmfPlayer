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
		server.setConnectors(new Connector[] { connector, sslConnector });

		WebAppContext webapp = new WebAppContext();
		webapp.setContextPath("/");
		webapp.setWar(jetty_home + "CorePlayer/");

		webapp.setServerClasses(new String[] { "-org.mortbay.jetty.plus.jaas.", "org.mortbay.jetty." });

		server.setHandler(webapp);

		MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
		MBeanContainer mBeanContainer = new MBeanContainer(mBeanServer);
		server.getContainer().addEventListener(mBeanContainer);
		mBeanContainer.start();

		server.start();
		server.join();
	}
}