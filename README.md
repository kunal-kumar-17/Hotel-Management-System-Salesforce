# Hotel Management System (Salesforce)

This project is a Salesforce Lightning application built to manage hotel rooms, guest records, reservations, and daily check-in/check-out operations. It was developed as part of the LNCT Salesforce COE Capstone Project.

## Data Model (Custom Objects)

* **Room (`Room__c`)**: Stores room details including Room Number, Room Type (Single, Double, Deluxe, Suite), Floor, Room Rate, Capacity, Amenities, and current Room Status.
* **Guest (`Guest__c`)**: Stores guest contact info, ID proof details, Date of Birth, and a formula field to calculate Age.
* **Reservation (`Reservation__c`)**: Links Guest and Room records using Lookup relationships. Includes formula fields for `Number_of_Nights__c` and `Estimated_Amount__c` (`Room Rate * Number of Nights`).
* **Hotel Staff (`Hotel_Staff__c`)**: Tracks staff members across Reception, Housekeeping, Manager, and Accounts departments.

## Business Logic & Automation

### Validation Rules
* Room rate and capacity must be greater than zero.
* Check-out date must be after the check-in date.
* Number of guests cannot exceed the selected room's capacity.
* Rooms under Maintenance cannot be selected for new reservations.

### Record-Triggered Flows
* Sends a confirmation email to the guest when a new reservation is created.
* Updates the related Room status to `Occupied` on Check-In and `Cleaning` on Check-Out.
* Sends a cancellation alert to the Hotel Manager when a booking is cancelled.

### Apex Trigger (`ReservationTrigger`)
* Blocks overlapping bookings for the same room on conflicting dates.
* Prevents booking rooms that are currently in `Maintenance` status.
* Automatically updates the parent `Room__c` status (`Reserved`, `Occupied`, `Cleaning`, `Available`) when a reservation record is created or updated.

## Security Setup
* **Role Hierarchy**: Hotel CEO -> Hotel Manager -> Receptionist, Housekeeping, and Accounts.
* **Permission Sets**: Separate permission sets created for Receptionists (Create/Read/Edit reservations, no delete), Housekeeping (Update room status), and Accounts (Read-only access for billing).

## Reports & Dashboard
Built 6 custom reports and an operations dashboard to track:
* Room count by current status
* Today's check-ins and check-outs
* Current month reservations by room type
* Monthly estimated revenue
* Cancelled reservations and booking history
