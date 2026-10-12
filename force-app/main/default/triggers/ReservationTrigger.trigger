trigger ReservationTrigger on Reservation__c (before insert, before update, after insert, after update) {
    if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
        ReservationTriggerHandler.validateReservation(Trigger.new, Trigger.oldMap);
    }
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ReservationTriggerHandler.updateRoomStatus(Trigger.new, Trigger.oldMap);
    }
}
