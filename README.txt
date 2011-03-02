This is the Player for SeeSaw.com.


This is licensed under Mozilla Public License Version 1.1 (the "License")

Building Instructions
~~~~~~~~~~~~~~~~~~~~~
 *   Check it out
 *   Install Maven 2.2.x (Maven 3 may also work but we haven't tried it)
 *   Change into the folder with the code and run
   *   mvn install -Dmaven.test.skip
 *   This will download dependencies/build the code
 *   If you want to open in an IDE
   *   Using IntelliJ Ultimate just open the pom <- This is the one we use and works first time!
   *   Using Flex Builder run mvn flexmojos:flexbuilder and import the project
   *   Using Flash Builder run mvn flexmojos:flashbuilder and import the project

If you run CorePlayer/com/seesaw/player/Player.as it will start the player
using a test video. In local mode the player uses the XML in CorePlayer/src/test/resources/dev_config.xml

We recommend installing the Flash Player Debugger Projector from
http://www.adobe.com/support/flashplayer/downloads.html. To get the tests running from maven you need to

Edit your .profile and add (replace PATH TO with folder you put the projector
    export PATH=/Users/PATH_TO/Flash\ Player\ Debugger.app/Contents/MacOS:$PATH
and in a terminal in the path you installed the debugger run
    ln Flash\ Player\ Debugger Flash\ Player

You will also need to 'trust' the SWF file by adding
it http://www.macromedia.com/support/documentation/en/flashplayer/help/settings_manager04.html



License Instructions
~~~~~~~~~~~~~~~~~~~~

To apply the MPL to your code you need to decide
a) Is this a file from OSMF you are modifying

b) Is this a new file

If a)
    Use copyrightOSMF.txt
    Add your company to the Portions Created Line
    Add your company to the Contributors line

If b)
    Use copyrightSeeSaw.txt
    (If you aren't SeeSaw edit the copyright/original creator to be yourself!)
    If you copy/paste Adobe samples in you MUST add a line saying portions are copyright Adobe


Note to ioko staff - you are Arqiva for this purpose!