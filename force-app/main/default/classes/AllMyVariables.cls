public class AllMyVariables {

    public boolean isThisCorrect;
    public Account myAccountRecord; 
   public Date todaysDate = system.today();
    

public static Integer calculateAgeInYears (Date dateOfBirthInput){
   
    Date currentDate = new AllMyVariables().todaysDate;
    integer ageInYears = (currentDate.monthsBetween(dateOfBirthInput))/12;
    return ageInYears;
}
}