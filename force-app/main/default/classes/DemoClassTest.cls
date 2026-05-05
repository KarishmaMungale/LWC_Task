@isTest

public class DemoClassTest {

    @isTest static void testingCalculate()
    {
       Integer i = DemoTest.calculate('Add',2,3);
        system.assertEquals(5,i);
    }
     @isTest static void testingCalculateSub()
    {
       Integer i = DemoTest.calculate('Sub',2,3);
        system.assertEquals(-1,i);
    }
}