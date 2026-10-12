public class ReservationTriggerHandler {
    
    // Check for maintenance status and date conflicts before saving
    public static void validateReservation(List<Reservation__c> newList, Map<Id, Reservation__c> oldMap) {
        Set<Id> roomIds = new Set<Id>();
        for (Reservation__c res : newList) {
            if (res.Room__c != null && res.Reservation_Status__c != 'Cancelled') {
                roomIds.add(res.Room__c);
            }
        }
        
        if (roomIds.isEmpty()) return;
        
        Map<Id, Room__c> roomMap = new Map<Id, Room__c>([
            SELECT Id, Name, Room_Status__c, Capacity__c 
            FROM Room__c 
            WHERE Id IN :roomIds
        ]);
        
        List<Reservation__c> existingReservations = [
            SELECT Id, Room__c, Check_In_Date__c, Check_Out_Date__c, Reservation_Status__c
            FROM Reservation__c
            WHERE Room__c IN :roomIds
            AND Reservation_Status__c IN ('Confirmed', 'Checked-In')
        ];
        
        for (Reservation__c res : newList) {
            if (res.Room__c == null || res.Reservation_Status__c == 'Cancelled') continue;
            
            Room__c relatedRoom = roomMap.get(res.Room__c);
            
            if (relatedRoom != null && relatedRoom.Room_Status__c == 'Maintenance') {
                res.addError('This room is under Maintenance and cannot be booked.');
            }
            
            for (Reservation__c existing : existingReservations) {
                if (existing.Room__c == res.Room__c && existing.Id != res.Id) {
                    if (res.Check_In_Date__c < existing.Check_Out_Date__c && 
                        res.Check_Out_Date__c > existing.Check_In_Date__c) {
                        res.addError('This room is already booked for the selected dates.');
                    }
                }
            }
        }
    }
    
    // Update room status based on reservation status changes
    public static void updateRoomStatus(List<Reservation__c> newList, Map<Id, Reservation__c> oldMap) {
        Map<Id, Room__c> roomsToUpdate = new Map<Id, Room__c>();
        
        for (Reservation__c res : newList) {
            if (res.Room__c == null) continue;
            
            String status = res.Reservation_Status__c;
            String newRoomStatus;
            
            if (status == 'Confirmed') {
                newRoomStatus = 'Reserved';
            } else if (status == 'Checked-In') {
                newRoomStatus = 'Occupied';
            } else if (status == 'Checked-Out') {
                newRoomStatus = 'Cleaning';
            } else if (status == 'Cancelled') {
                newRoomStatus = 'Available';
            }
            
            if (newRoomStatus != null) {
                roomsToUpdate.put(res.Room__c, new Room__c(
                    Id = res.Room__c,
                    Room_Status__c = newRoomStatus
                ));
            }
        }
        
        if (!roomsToUpdate.isEmpty()) {
            update roomsToUpdate.values();
        }
    }
}
