public class DemoTest {
    
    public static void callMethod (){
        Decimal value = calculate('Sub', 1, 2);
        System.debug('value' + value );
    }

    	public static Integer calculate (string operation, integer num1, Integer num2)
        {
            if(operation == 'Add')
            {
                return num1+ num2;
                
            }
            else
            {
                return num1 - num2;
            }
        }
}