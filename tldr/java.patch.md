- terminal-setup extras (davetang/terminal-setup):

- Which JDK this is, and where it lives:

`java -version && echo $JAVA_HOME`

- Run a single source file with no compile step (Java 11+):

`java {{path/to/Main.java}}`

- Try things interactively (jshell is in $JAVA_HOME/bin, not ~/bin):

`$JAVA_HOME/bin/jshell`

- Run an executable jar, giving the heap a ceiling:

`java -Xmx{{2g}} -jar {{path/to/app.jar}}`

- List the JVMs' running processes (jps is in $JAVA_HOME/bin):

`$JAVA_HOME/bin/jps -l`
