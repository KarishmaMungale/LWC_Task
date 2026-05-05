public class DemoClass {


    public String helloWorldString;

    private static final String DEFAULT_STRING;

    static{

        DEFAULT_STRING = 'Hello World';

    }

    public DemoClass(){

        this(DEFAULT_STRING);

    }

    public DemoClass(String stringToDisplay){

        this.helloWorldString = stringToDisplay;

    }

    public void printOutput(){

        System.debug('Display text: ' + helloWorldString);

    }
 
}