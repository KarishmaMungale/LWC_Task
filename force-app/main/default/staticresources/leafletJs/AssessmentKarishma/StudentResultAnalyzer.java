package AssessmentKarishma;

		import java.util.*;

		class Student {
		    String name;
		    int[] marks;
		    int total;
		    double average;

		    Student(String name, int[] marks) {
		        this.name = name;
		        this.marks = marks;
		        this.total = Arrays.stream(marks).sum();
		        this.average = this.total / 5.0;
		    }
		}

		public class StudentResultAnalyzer {
		    public static void main(String[] args) {
		        Scanner sc = new Scanner(System.in);
		        System.out.print("Enter number of students (max 15): ");
		        int n = sc.nextInt();
		        sc.nextLine();
		        if (n < 1 || n > 15) {
		            System.out.println("Number must be betweeen 1 to 15 ");
		            sc.close();
		            return;
		        }

		        List<Student> students = new ArrayList<>();
		        for (int i = 0; i < n; i++) 
		        {
		            System.out.print("Enter student name: ");
		            String name = sc.nextLine().trim();
		            
		            int[] marks = new int[5];
		            System.out.println("Enter marks for 5 subjects:");
		            
		            for (int j = 0; j < 5; j++) {
		                marks[j] = sc.nextInt();
		            }
		            sc.nextLine();
		            
		            students.add(new Student (name, marks));
		        }

		        
		        System.out.println("Student Totals & Averages:");
		        for (Student s : students)
		        {
		            System.out.printf("%s -> Total: %d, Average: %.2f%n", s.name, s.total, s.average);
		        }

		        Student topper = students.get(0);
		        for (Student s : students) {
		            if (s.total > topper.total) topper = s;
		        }
		        System.out.println("Topper: " + topper.name + " (Total: " + topper.total + ")");

		        String[] subjectTopperName = new String[5];
		        int[] subjectTopperMarks = new int[5];
		       
		        for (Student s : students) {
		            for (int subj = 0; subj < 5; subj++) {
		                if (s.marks[subj] > subjectTopperMarks[subj])
		                {
		                    subjectTopperMarks[subj] = s.marks[subj];
		                    subjectTopperName[subj] = s.name;
		                }
		            }
		        }

		       
         }
}

		
	
	


