package AssessmentKarishma;

import java.util.Scanner;

public class RailwaySeat {
	
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        int[] seats = new int[10]; 

        System.out.println("Railway Reservation System (Seats 1 to 10)");
        boolean continueBooking = true;
        while (continueBooking) 
        {
            System.out.print("Enter seat number to book (1-10): ");
            int seat = sc.nextInt();
            if (seat < 1 || seat > 10) 
            {
                System.out.println("Invalid seat number. Choose between 1 and 10.");
            } else
            {
                if (seats[seat - 1] == 1) {
                    System.out.println("Seat " + seat + " is already booked. Choose another seat.");
                } else {
                    seats[seat - 1] = 1;
                    
                    System.out.println("Ticket confirmed for Seat " + seat);
                }
            }
            System.out.print("Do you want to book another seat? (y/n): ");
            String ans = sc.next();
            continueBooking = ans.equalsIgnoreCase("y");
        }

        System.out.println("\nFinal Seat Map:");
        
        for (int i = 0; i < seats.length; i++) 
        {
            String status = seats[i] == 0 ? "Available" : "Booked";
            System.out.println("Seat " + (i + 1) + ": " + status);
        }

        sc.close();
    }
}
