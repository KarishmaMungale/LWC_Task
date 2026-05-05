package AssessmentKarishma;


	import java.util.*;

	class Patient {
	    int id;
	    String name;
	    String disease;
	    int age;

	    public Patient(int id, String name, String disease, int age) {
	        this.id = id;
	        this.name = name;
	        this.disease = disease;
	        this.age = age;
	    }
	}

	public class PatientExample{
	    public static void main(String[] args) {
	        Scanner sc = new Scanner(System.in);
	        System.out.print("Enter number of patients: ");
	        int n = sc.nextInt();
	        sc.nextLine(); 
	        

	        List<Patient> list = new ArrayList<>();
	        for (int i = 0; i < n; i++) 
	        {
	            System.out.println("Enter details for patient " + (i + 1) + " (format: id,name,disease,age)");
	            String line = sc.nextLine();
	           
	            String[] parts = line.split(",");
	            if (parts.length == 4) {
	                int id = Integer.int(parts[0]);
	                String name = parts[1];
	                String disease = parts[2];
	                int age = Integer.int(parts[3]);
	                list.add(new Patient(id, name, disease, age));
	                
	            } else
	            
	            
	            {
	              
	                System.out.print("ID: ");
	                int id = Integer.parseInt(sc.nextLine());
	                System.out.print("Name: ");
	                String name = sc.nextLine();
	                System.out.print("Disease: ");
	                String disease = sc.nextLine();
	                System.out.print("Age: ");
	                int age = Integer.parseInt(sc.nextLine());
	                list.add(new Patient(id, name, disease, age));
	            }
	        }

	       
	        System.out.print("patients with disease: ");
	        String searchDisease = sc.nextLine();
	        System.out.println("Patients with " + searchDisease + ":");
	        for (Patient p : list) 
	        {
	            if (p.disease.equalsIgnoreCase(searchDisease)) {
	                System.out.println(p.name + " (ID: " + p.id + ", Age: " + p.age + ")");
	            }
	        }

	    
	        System.out.println("Patients above 60:");
	        for (Patient p : list) {
	            if (p.age > 60) {
	                System.out.println(p.name + " (ID: " + p.id + ", Disease: " + p.disease + ")");
	            }
	        }

	       
	        
	    }
	}



