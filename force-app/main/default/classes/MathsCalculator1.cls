public class MathsCalculator1 {

  
   private static Integer add (Integer a , Integer b)
   {
       return a +b;
   }
   private static Integer multiply(Integer a , Integer b)
   {
       return a *b;
      
   }
   private static Integer subtract(Integer a, Integer b)
   {
    return a-b;
   }
   private static Integer divide(Integer a, Integer b)
   {
    return a/b;
   }
 
   private static void printOutput(String label, Integer result)
   { 
      System.debug(label + ': ' +result);
      
   }
   public static void doMath()
   {
       Integer num1=10;
       Integer num2=20;
       Integer sumResult=add(num1, num2);
      printOutput('Added Result', sumResult);
      
       Integer productResult =multiply(num1, num2);
      printOutput('Multiplied Result', productResult);
   
      Integer subtractResult =subtract(num1, num2);
      printOutput('Subtracted Result', subtractResult);
      Integer divideResult =divide(num1, num2);
      printOutput('Division Result', divideResult);
     }

}